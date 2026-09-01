local colors = require("colors")

for sid = 1, 9 do
  local space = sbar.add("space", "space." .. sid, {
    position = "left",
    associated_space = sid,
    icon = {
      string = tostring(sid),
      padding_left = 7,
      padding_right = 7,
      color = colors.foreground,
    },
    label = { drawing = false },
    background = {
      drawing = true,
      color = colors.inactive_surface,
    },
  })

  space:subscribe("space_change", function(env)
    local selected = env.SELECTED == "true"
    space:set({
      icon = { color = selected and colors.active_text or colors.foreground },
      background = { color = selected and colors.accent or colors.inactive_surface },
    })
  end)

  space:subscribe("mouse.clicked", function()
    sbar.exec("yabai -m space --focus " .. sid)
  end)
end
