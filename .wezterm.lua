local wezterm = require("wezterm")
local config = {}

if wezterm.config_builder then
  config = wezterm.config_builder()
end

config = {
  automatically_reload_config = true,
  window_close_confirmation = "NeverPrompt",
  adjust_window_size_when_changing_font_size = false,
  window_decorations = "RESIZE",
  check_for_updates = false,
  use_fancy_tab_bar = false,
  tab_bar_at_bottom = false,
  font_size = 11,
  font = wezterm.font("MesloLGS Nerd Font Mono"),
  enable_tab_bar = false,
  color_scheme = 'Afterglow',
  keys = {
    { key = 'LeftArrow', mods = 'SHIFT|ALT', action = wezterm.action.SplitPane { direction = 'Left'} },
    { key = 'DownArrow', mods = 'SHIFT|ALT', action = wezterm.action.SplitPane { direction = 'Down'} },
    { key = 'RightArrow', mods = 'SHIFT|ALT', action = wezterm.action.SplitPane { direction = 'Right'} },
    { key = 'UpArrow', mods = 'SHIFT|ALT', action = wezterm.action.SplitPane { direction = 'Up'} }
},
  window_padding = {
    left = 3,
    right = 3,
    top = 0,
    bottom = 0,
  },
  background = {
    {
      source = {
        File = os.getenv("HOME").."/.config/wezterm/minimalist.jpg",
      },
      hsb = {
        hue = 1.0,
        saturation = 1.02,
        brightness = 0.25,
      },
    },
    {
      source = {
        Color = "#282c35",
      },
      width = "100%",
      height = "100%",
      opacity = 0.75,
    },
  },
  hyperlink_rules = {
    {
      regex = "\\((\\w+://\\S+)\\)",
      format = "$1",
      highlight = 1,
    },
    {
      regex = "\\[(\\w+://\\S+)\\]",
      format = "$1",
      highlight = 1,
    },
    {
      regex = "\\{(\\w+://\\S+)\\}",
      format = "$1",
      highlight = 1,
    },
    {
      regex = "<(\\w+://\\S+)>",
      format = "$1",
      highlight = 1,
    },
    {
      regex = "[^(]\\b(\\w+://\\S+[)/a-zA-Z0-9-]+)",
      format = "$1",
      highlight = 1,
    },
    {
      regex = "\\b\\w+@[\\w-]+(\\.[\\w-]+)+\\b",
      format = "mailto:$0",
    },
  },
}
return config

