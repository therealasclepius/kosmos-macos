local colors = require("colors")

sbar.bar({
  position = "top",
  height = 28,
  margin = 6,
  y_offset = 3,
  corner_radius = 0,
  border_width = 1,
  border_color = colors.bar_border,
  color = colors.bar_bg,
  shadow = true,
  blur_radius = 24,
  padding_left = 8,
  padding_right = 8,
  sticky = true,
  topmost = "off",
})
