-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

-- Set node path explicitly for GUI apps
if vim.fn.has("gui_running") == 1 or vim.g.neovide then
  vim.g.node_host_prog = "/Users/krishna/.nvm/versions/node/v24.9.0/bin/node"
  vim.cmd('let $PATH = "/Users/krishna/.nvm/versions/node/v24.9.0/bin:" .. $PATH')
end

-- Neovide-specific settings
if vim.g.neovide then
  -- Set font size (adjust the :h value to change size, e.g., :h16, :h18, :h20)
  vim.o.guifont = "MesloLGL Nerd Font Mono:h20"

  -- Scale factor (1.0 = default, increase for larger UI)
  vim.g.neovide_scale_factor = 1.3

  -- =====================
  -- Window Features
  -- =====================
  vim.g.neovide_remember_window_size = true
  vim.g.neovide_remember_window_position = true

  -- Borderless window (cleaner look, no title bar)
  -- vim.g.neovide_titlebar_style = "none"

  -- Fullscreen on start
  -- vim.g.neovide_fullscreen = true

  -- =====================
  -- Visual Effects
  -- =====================
  -- Window transparency (0.0 = fully transparent, 1.0 = opaque)
  vim.g.neovide_opacity = 0.9

  -- Blur behind floating windows (looks great with transparency)
  vim.g.neovide_floating_blur_amount_x = 2.0
  vim.g.neovide_floating_blur_amount_y = 2.0

  -- Floating window shadow
  vim.g.neovide_floating_shadow = true
  vim.g.neovide_floating_z_height = 10
  vim.g.neovide_light_angle_degrees = 45
  vim.g.neovide_light_radius = 5

  -- Smooth scrolling
  vim.g.neovide_scroll_animation_length = 0.3

  -- Window blur (macOS only - blur desktop behind window)
  vim.g.neovide_window_blurred = true
end
