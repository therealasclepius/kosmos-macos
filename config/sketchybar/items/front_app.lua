local colors = require("colors")

local front_app = sbar.add("item", "front_app", {
  position = "left",
  icon = {
    string = "●",
    color = colors.accent,
  },
  label = { max_chars = 32 },
})

front_app:subscribe("front_app_switched", function(env)
  front_app:set({ label = { string = env.INFO or "Desktop" } })
end)
