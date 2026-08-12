-- Hyprland Lua config, split by concern into the files required below.
-- https://wiki.hypr.land/Configuring/Start/

require("monitors")
require("vars")
require("config")
require("autostart")
require("keybindings")
require("windowrules")

-- For Noctalia Color templates
require("noctalia").apply_theme()
