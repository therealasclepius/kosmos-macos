local colors = require("colors")

local mode = sbar.add("item", "wm_mode", {
  position = "left",
  icon = { string = "", color = colors.active_text },
  label = { string = "OMNI", color = colors.active_text },
  background = {
    drawing = true,
    color = colors.accent,
  },
  padding_left = 4,
  padding_right = 4,
})

mode:subscribe("mouse.clicked", function()
  sbar.exec("open -a OmniWM")
end)
