local colors = require("colors")
local settings = require("settings")

sbar.default({
  updates = "when_shown",
  icon = {
    font = {
      family = settings.font,
      style = settings.icon_style,
      size = settings.font_size,
    },
    color = colors.foreground,
  },
  label = {
    font = {
      family = settings.font,
      style = settings.label_style,
      size = settings.font_size,
    },
    color = colors.foreground,
  },
  background = {
    corner_radius = 0,
    height = settings.item_height,
  },
  padding_left = 4,
  padding_right = 4,
})
