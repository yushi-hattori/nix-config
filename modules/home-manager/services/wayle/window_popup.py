#!/usr/bin/env python3
"""A GTK4 layer-shell popup listing niri windows as a grid of cards.

Runs as a persistent background daemon (started at login). The wayle "windows"
module's left-click sends SIGUSR1 to toggle visibility. Clicking a card focuses
that window; clicking elsewhere (or pressing Escape) hides the popup.
"""

import json
import os
import signal
import subprocess
import sys
import threading
import tomllib

import gi

gi.require_version("Gtk", "4.0")
gi.require_version("Gdk", "4.0")
gi.require_version("Gtk4LayerShell", "1.0")
from gi.repository import Gdk, GLib, Gtk, Gtk4LayerShell  # noqa: E402

PIDFILE = os.path.expanduser("~/.cache/wayle-window-popup.pid")
NIRI = "niri"


def niri_json(*args):
    return json.loads(subprocess.check_output([NIRI, "msg", "-j", *args]))


def load_palette():
    try:
        with open(os.path.expanduser("~/.config/wayle/config.toml"), "rb") as f:
            cfg = tomllib.load(f)
        return cfg.get("styling", {}).get("palette", {})
    except (OSError, tomllib.TOMLDecodeError):
        return {}


def pretty(app_id):
    return app_id.split(".")[-1].replace("_", " ").removesuffix("-twilight")


def focus_window(wid):
    subprocess.Popen([NIRI, "msg", "action", "focus-window", "--id", str(wid)])


def focus_key(focused):
    if not focused:
        return None
    ts = focused.get("focus_timestamp") or {}
    return (focused.get("id"), ts.get("secs", 0), ts.get("nanos", 0))


def find_monitor(display, name):
    for m in display.get_monitors():
        if m.get_connector() == name:
            return m
    return None


def get_groups():
    workspaces = niri_json("workspaces")
    windows = niri_json("windows")
    out = {str(w["id"]): w["output"] for w in workspaces}
    wsidx = {str(w["id"]): w["idx"] for w in workspaces}
    focus_out = next((w["output"] for w in workspaces if w.get("is_focused")), "")
    focus_id = next(
        (w.get("active_window_id") for w in workspaces if w.get("is_focused") and w.get("active_window_id")),
        None,
    )

    rows = []
    for w in windows:
        pos = (w.get("layout") or {}).get("pos_in_scrolling_layout") or [0, 0]
        rows.append(
            {
                "id": w["id"],
                "app": w.get("app_id") or "?",
                "output": out.get(str(w["workspace_id"]), "?"),
                "wsidx": wsidx.get(str(w["workspace_id"]), 0),
                "col": pos[0],
                "tile": pos[1],
                "focused": w["id"] == focus_id,
            }
        )
    rows.sort(key=lambda r: (0 if r["output"] == focus_out else 1, r["output"], r["wsidx"], r["col"], r["tile"]))

    order, groups = [], {}
    for r in rows:
        if r["output"] not in groups:
            groups[r["output"]] = []
            order.append(r["output"])
        groups[r["output"]].append(r)
    return order, groups


def main():
    try:
        with open(PIDFILE, "w") as f:
            f.write(str(os.getpid()))
    except OSError:
        pass

    palette = load_palette()
    elevated = palette.get("elevated", "#1f1f1f")
    surface = palette.get("surface", "#161616")
    fg = palette.get("fg", "#f2f4f8")
    fg_muted = palette.get("fg-muted", "#a8aab1")
    primary = palette.get("primary", "#78a9ff")

    def with_alpha(hexcolor, alpha):
        hexcolor = hexcolor.lstrip("#")
        r, g, b = int(hexcolor[0:2], 16), int(hexcolor[2:4], 16), int(hexcolor[4:6], 16)
        return f"rgba({r}, {g}, {b}, {alpha})"

    css = f"""
    window.background {{
        background-color: transparent;
    }}
    .wayle-popup {{
        background-color: {elevated};
        border: 1px solid rgba(255, 255, 255, 0.08);
        border-radius: 20px;
        padding: 12px;
    }}
    .monitor-header {{
        color: {fg_muted};
        font-size: 0.78em;
        font-weight: 700;
        letter-spacing: 0.06em;
        margin: 2px 6px 6px 6px;
    }}
    .app-card {{
        background-color: {surface};
        border: 1px solid rgba(255, 255, 255, 0.04);
        border-radius: 16px;
        padding: 10px 6px;
    }}
    .app-card:hover {{
        background-color: {surface};
        border: 1px solid rgba(255, 255, 255, 0.04);
    }}
    .app-card.focused {{
        background-color: {with_alpha(primary, 0.14)};
        border-color: {with_alpha(primary, 0.5)};
    }}
    .app-label {{
        color: {fg};
        font-size: 0.8em;
    }}
    .app-label.focused {{
        color: {primary};
        font-weight: 700;
    }}
    """
    provider = Gtk.CssProvider()
    provider.load_from_string(css)
    Gtk.StyleContext.add_provider_for_display(
        Gdk.Display.get_default(), provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
    )

    display = Gdk.Display.get_default()
    theme = Gtk.IconTheme.get_for_display(display)

    def resolve_icon(app):
        for name in (app, app.split(".")[-1]):
            if name and theme.has_icon(name):
                return name
        low = app.lower()
        if any(t in low for t in ("term", "ghostty", "kitty", "alacritty", "wezterm", "foot")):
            return "utilities-terminal-symbolic"
        return "application-x-executable-symbolic"

    window = Gtk.Window()
    window.set_title("wayle-window-popup")
    window.set_decorated(False)
    Gtk4LayerShell.init_for_window(window)
    Gtk4LayerShell.set_layer(window, Gtk4LayerShell.Layer.TOP)
    Gtk4LayerShell.set_anchor(window, Gtk4LayerShell.Edge.TOP, True)
    Gtk4LayerShell.set_anchor(window, Gtk4LayerShell.Edge.LEFT, True)
    Gtk4LayerShell.set_margin(window, Gtk4LayerShell.Edge.TOP, 0)
    Gtk4LayerShell.set_margin(window, Gtk4LayerShell.Edge.LEFT, 55)
    Gtk4LayerShell.set_keyboard_mode(window, Gtk4LayerShell.KeyboardMode.ON_DEMAND)

    root = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=8)
    root.add_css_class("wayle-popup")
    window.set_child(root)
    window.set_size_request(360, -1)

    loop = GLib.MainLoop()
    visible = [False]
    grab_confirmed = [False]
    poll_source = [None]

    def quit_daemon(*_a):
        try:
            os.remove(PIDFILE)
        except OSError:
            pass
        loop.quit()

    def hide():
        visible[0] = False
        if poll_source[0] is not None:
            GLib.source_remove(poll_source[0])
            poll_source[0] = None
        window.set_visible(False)

    def poll_focus():
        if not visible[0]:
            return True
        try:
            focused = niri_json("focused-window")
        except Exception:
            return True
        if not focused:
            grab_confirmed[0] = True
        elif grab_confirmed[0]:
            hide()
        return True

    def show():
        visible[0] = True
        # put the popup on the currently focused output
        try:
            focused_out = niri_json("focused-output")["name"]
            mon = find_monitor(display, focused_out)
            if mon is not None:
                Gtk4LayerShell.set_monitor(window, mon)
        except Exception:
            pass

        # rebuild content from current window list
        while True:
            child = root.get_first_child()
            if child is None:
                break
            root.remove(child)

        order, groups = get_groups()
        for mon in order:
            header = Gtk.Label(label=mon)
            header.add_css_class("monitor-header")
            header.set_halign(Gtk.Align.START)
            root.append(header)

            flow = Gtk.FlowBox()
            flow.set_selection_mode(Gtk.SelectionMode.NONE)
            flow.set_column_spacing(8)
            flow.set_row_spacing(8)
            flow.set_homogeneous(True)
            flow.set_max_children_per_line(4)
            for r in groups[mon]:
                card = Gtk.Button()
                card.add_css_class("flat")
                card.add_css_class("app-card")
                card.set_size_request(76, 76)
                vbox = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=4)
                vbox.set_halign(Gtk.Align.CENTER)
                vbox.set_valign(Gtk.Align.CENTER)
                icon = Gtk.Image.new_from_icon_name(resolve_icon(r["app"]))
                icon.set_pixel_size(30)
                label = Gtk.Label(label=pretty(r["app"])[:10])
                label.add_css_class("app-label")
                label.set_ellipsize(3)  # PANGO_ELLIPSIZE_END
                label.set_max_width_chars(9)
                label.set_halign(Gtk.Align.CENTER)
                if r["focused"]:
                    card.add_css_class("focused")
                    label.add_css_class("focused")
                vbox.append(icon)
                vbox.append(label)
                card.set_child(vbox)
                card.connect("clicked", lambda _b, wid=r["id"]: (focus_window(wid), hide()))
                flow.append(card)
            root.append(flow)

        grab_confirmed[0] = False
        poll_source[0] = GLib.timeout_add(200, poll_focus)
        window.present()

    def toggle(*_a):
        if visible[0]:
            hide()
        else:
            show()

    def on_sigusr1(_signum, _frame):
        GLib.idle_add(toggle)

    def on_sigterm(_signum, _frame):
        GLib.idle_add(quit_daemon)

    signal.signal(signal.SIGUSR1, on_sigusr1)
    signal.signal(signal.SIGTERM, on_sigterm)

    window.set_visible(False)
    loop.run()


if __name__ == "__main__":
    main()
