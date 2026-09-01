local colors = require("colors")

sbar.add("event", "yashiki_workspace_change")

local function contains_tag(mask, tag_number)
  local value = tonumber(mask) or 0
  local bit = 2 ^ (tag_number - 1)
  return math.floor(value / bit) % 2 == 1
end

for tag_number = 1, 9 do
  local tag = sbar.add("item", "tag." .. tag_number, {
    position = "left",
    icon = {
      string = tostring(tag_number),
      padding_left = 7,
      padding_right = 7,
      color = colors.muted,
    },
    label = { drawing = false },
    background = {
      drawing = true,
      color = colors.inactive_surface,
    },
  })

  tag:subscribe("yashiki_workspace_change", function(env)
    local active = contains_tag(env.ACTIVE_TAGS, tag_number)
    local occupied = contains_tag(env.OCCUPIED_TAGS, tag_number)
    tag:set({
      icon = {
        color = active and colors.active_text or (occupied and colors.foreground or colors.muted),
      },
      background = {
        color = active and colors.accent or colors.inactive_surface,
      },
    })
  end)

  tag:subscribe("mouse.clicked", function(env)
    local bit = 2 ^ (tag_number - 1)
    if env.BUTTON == "right" then
      sbar.exec("yashiki tag-toggle " .. bit)
    else
      sbar.exec("yashiki tag-view " .. bit)
    end
  end)
end
