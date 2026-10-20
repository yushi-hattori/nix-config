-- Render real image previews over yazi.nvim's preview column.
--
-- Neovim's embedded terminal cannot forward a graphics protocol, so yazi inside
-- it can only fall back to chafa. We instead open a borderless floating window
-- over yazi's preview column (yazi's default layout ratio is parent/current/
-- preview = 1/4/3, so the preview starts at 5/8 of the width) and draw the
-- image into it with snacks.image.placement.
local M = {}

---@class yazi_image.Session
---@field yazi_buf number
---@field path string?
---@field placement snacks.image.Placement?
---@field image_win number?
---@field image_buf number?
---@field generation integer
---@field timer integer?
---@field augroup number?

---@type table<number, yazi_image.Session>
local sessions = {}

--- Close the preview overlay: remove the snacks placement, the floating window,
--- and the scratch buffer.
---@param session yazi_image.Session
local function close_preview(session)
  if session.placement then
    pcall(session.placement.close, session.placement)
    session.placement = nil
  end
  if session.image_win and vim.api.nvim_win_is_valid(session.image_win) then
    vim.api.nvim_win_close(session.image_win, true)
  end
  session.image_win = nil
  if session.image_buf and vim.api.nvim_buf_is_valid(session.image_buf) then
    vim.api.nvim_buf_delete(session.image_buf, { force = true })
  end
  session.image_buf = nil
end

--- Number of cells the yazi floating window's border insets its content by.
---@param win number
---@return integer
local function border_offset(win)
  local ok, cfg = pcall(vim.api.nvim_win_get_config, win)
  if not ok or not cfg.border or cfg.border == "none" or cfg.border == "" then
    return 0
  end
  return 1
end

--- Geometry of yazi's preview column (editor-relative), from its 1/4/3 ratio.
---@param session yazi_image.Session
---@return table?
local function preview_geometry(session)
  local yazi_win = vim.fn.bufwinid(session.yazi_buf)
  if yazi_win == -1 or not vim.api.nvim_win_is_valid(yazi_win) then
    return nil
  end

  local pos = vim.api.nvim_win_get_position(yazi_win)
  local width = vim.api.nvim_win_get_width(yazi_win)
  local height = vim.api.nvim_win_get_height(yazi_win)
  if width < 16 or height < 4 then
    return nil
  end

  local preview_start = math.floor(width * 5 / 8)
  local border = border_offset(yazi_win)
  local zindex = vim.api.nvim_win_get_config(yazi_win).zindex or 50

  return {
    relative = "editor",
    row = pos[1] + border + 1,
    col = pos[2] + border + preview_start + 1,
    width = width - preview_start - 1,
    height = height - 2,
    style = "minimal",
    focusable = false,
    mouse = false,
    zindex = zindex + 1,
  }
end

--- Resize/reposition the existing preview without recreating it.
---@param session yazi_image.Session
local function resize_preview(session)
  local geom = preview_geometry(session)
  if not geom then
    return
  end
  if session.image_win and vim.api.nvim_win_is_valid(session.image_win) then
    vim.api.nvim_win_set_config(session.image_win, geom)
  end
  if session.placement then
    session.placement.opts.pos = { 1, 0 }
    session.placement.opts.width = geom.width
    session.placement.opts.height = geom.height
    session.placement:update()
  end
end

--- Create the overlay and the snacks.image.placement for `path`.
---@param session yazi_image.Session
---@param path string?
---@param generation integer
local function show_preview(session, path, generation)
  -- Deferred: never call the API from a fast event context (E5560).
  vim.schedule(function()
    if generation ~= session.generation then
      return -- a newer update superseded this one
    end

    close_preview(session)

    if not path or not Snacks.image.supports_file(path) then
      return
    end

    local geom = preview_geometry(session)
    if not geom then
      return
    end

    session.image_buf = vim.api.nvim_create_buf(false, true)
    session.image_win = vim.api.nvim_open_win(session.image_buf, false, geom)
    session.placement = Snacks.image.placement.new(session.image_buf, path, {
      pos = { 1, 0 },
      width = geom.width,
      height = geom.height,
      auto_resize = true,
    })
  end)
end

--- Validate the path, close the previous preview, and (debounced) render it.
---@param session yazi_image.Session
---@param path string?
local function update_preview(session, path)
  session.generation = session.generation + 1
  local generation = session.generation

  if session.timer then
    pcall(session.timer.stop, session.timer)
    pcall(session.timer.close, session.timer)
    session.timer = nil
  end

  local timer = vim.uv.new_timer()
  session.timer = timer
  timer:start(30, 0, function()
    timer:stop()
    timer:close()
    if session.timer == timer then
      session.timer = nil
    end
    show_preview(session, path, generation)
  end)
end

--- Tear down all state and autocmds for a yazi instance.
---@param yazi_buf number
local function close_session(yazi_buf)
  local session = sessions[yazi_buf]
  if not session then
    return
  end
  if session.timer then
    pcall(session.timer.stop, session.timer)
    pcall(session.timer.close, session.timer)
    session.timer = nil
  end
  if session.augroup then
    pcall(vim.api.nvim_del_augroup_by_id, session.augroup)
  end
  close_preview(session)
  sessions[yazi_buf] = nil
end

--- yazi.nvim `yazi_opened` hook: capture and render the initially selected path.
---@param path string?
---@param yazi_buf number
function M.opened(path, yazi_buf)
  local session = sessions[yazi_buf]
  if not session then
    return
  end
  session.path = path
  update_preview(session, path)
end

--- yazi.nvim `on_yazi_ready` hook: register state + autocmds for this instance.
---@param yazi_buf number
---@param _ table?
---@param process_api table?
function M.setup(yazi_buf, _, process_api)
  -- Deferred to avoid E5560 (API call in a fast event context).
  vim.schedule(function()
    if not yazi_buf or not vim.api.nvim_buf_is_valid(yazi_buf) then
      return
    end

    local session = {
      yazi_buf = yazi_buf,
      path = nil,
      placement = nil,
      image_win = nil,
      image_buf = nil,
      generation = 0,
      timer = nil,
      augroup = nil,
    }
    sessions[yazi_buf] = session

    local group = vim.api.nvim_create_augroup("yazi_image_" .. yazi_buf, { clear = true })
    session.augroup = group

    vim.api.nvim_create_autocmd("User", {
      group = group,
      pattern = "YaziDDSHover",
      callback = function(ev)
        local url = ev.data and ev.data.url
        session.path = url
        update_preview(session, url)
      end,
    })

    vim.api.nvim_create_autocmd("VimResized", {
      group = group,
      callback = function()
        resize_preview(session)
      end,
    })

    vim.api.nvim_create_autocmd({ "TermClose", "BufWipeout" }, {
      group = group,
      buffer = yazi_buf,
      callback = function()
        vim.schedule(function()
          close_session(yazi_buf)
        end)
      end,
    })
  end)
end

return M
