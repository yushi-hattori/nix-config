Name = "power"
NamePretty = "Power Menu"
Icon = "system-shutdown"
Cache = false
Action = "%VALUE%"

function GetEntries()
	return {
		{ Text = "Shutdown", Subtext = "Power off the system", Value = "shutdown now", Icon = "system-shutdown" },
		{ Text = "Reboot", Subtext = "Restart the system", Value = "reboot", Icon = "system-reboot" },
		{ Text = "Suspend", Subtext = "Sleep mode", Value = "systemctl suspend", Icon = "system-suspend" },
		{ Text = "Logout", Subtext = "End current session", Value = "pkill -u $USER", Icon = "system-log-out" },
	}
end
