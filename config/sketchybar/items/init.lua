local mode_file = io.open(os.getenv("HOME") .. "/.config/kosmos/window-manager", "r")
local window_manager = mode_file and mode_file:read("*l") or "yabai"
if mode_file then mode_file:close() end

if window_manager == "yashiki" then
  require("items.yashiki_spaces")
elseif window_manager == "omniwm" then
  require("items.wm_mode")
else
  require("items.spaces")
end
require("items.front_app")
require("items.status")
