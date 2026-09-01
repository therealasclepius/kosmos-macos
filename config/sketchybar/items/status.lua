local colors = require("colors")

local function open_app(name)
  return function()
    sbar.exec("open -a '" .. name .. "'")
  end
end

local calendar = sbar.add("item", "calendar", {
  position = "right",
  icon = { string = "󰃭", color = colors.accent },
  label = { color = colors.gold },
  background = { drawing = false },
  padding_left = 6,
  padding_right = 6,
  update_freq = 30,
})

local function update_calendar()
  local date = os.date("%a %d"):gsub(" 0", " ")
  local time = os.date("%I:%M"):gsub("^0", "")
  calendar:set({ label = { string = date .. " · " .. time } })
end

calendar:subscribe({ "routine", "forced", "system_woke" }, update_calendar)
calendar:subscribe("mouse.clicked", function(env)
  if env.BUTTON == "right" then
    sbar.exec("if open -Ra 'Notion Calendar'; then open -a 'Notion Calendar'; else open -a Calendar; fi")
  else
    sbar.exec("if pgrep -qx 'Notion Calendar'; then skhd -k 'ctrl + cmd - k'; else open -a 'Notion Calendar'; fi")
  end
end)

local function weather_location()
  local file = io.open(os.getenv("HOME") .. "/.config/kosmos/weather-location", "r")
  if not file then return "" end
  local location = file:read("*l") or ""
  file:close()
  return location
end

local function url_encode(value)
  return value:gsub("([^%w%-_%.~])", function(character)
    return string.format("%%%02X", string.byte(character))
  end)
end

local weather = sbar.add("item", "weather", {
  position = "right",
  icon = { drawing = false },
  label = { string = "--°", color = colors.foreground },
  background = { drawing = false },
  padding_left = 5,
  padding_right = 5,
  update_freq = 900,
})

local function update_weather()
  local location = url_encode(weather_location())
  local url = "https://wttr.in/" .. location .. "?format=%25c%7C%25t"
  sbar.exec("curl -fsSL --max-time 8 '" .. url .. "'", function(result)
    local icon, temperature = result:match("^%s*(.-)%s*|%s*([%+%-]?%d+)°")
    if not icon or not temperature then return end
    weather:set({ label = { string = icon .. " " .. temperature:gsub("^%+", "") .. "°" } })
  end)
end

weather:subscribe({ "routine", "forced", "system_woke" }, update_weather)
weather:subscribe("mouse.clicked", function()
  sbar.exec("open -a Weather")
end)

local battery = sbar.add("item", "battery", {
  position = "right",
  icon = { drawing = false },
  label = { color = colors.green },
  background = { drawing = false },
  padding_left = 6,
  padding_right = 6,
  update_freq = 60,
})

local function update_battery()
  sbar.exec("pmset -g batt", function(result)
    local percent = result:match("(%d+)%%") or "AC"
    local on_power = result:find("charging", 1, true) or result:find("charged", 1, true)
    battery:set({
      label = { string = percent .. (percent == "AC" and "" or "%") },
      icon = { color = on_power and colors.green or colors.foreground },
    })
  end)
end

battery:subscribe({ "routine", "power_source_change", "system_woke" }, update_battery)

local volume = sbar.add("item", "volume", {
  position = "right",
  icon = { color = colors.green },
  background = { drawing = false },
  padding_left = 6,
  padding_right = 6,
})

local function set_volume(value, muted)
  local icon = "󰕾"
  local label = tostring(value) .. "%"
  if muted or value == 0 then
    icon, label = "󰝟", "MUTE"
  elseif value < 35 then
    icon = "󰕿"
  elseif value < 70 then
    icon = "󰖀"
  end
  volume:set({ icon = { string = icon }, label = { string = label } })
end

local function update_volume()
  sbar.exec("osascript -e 'get volume settings'", function(result)
    local value = tonumber(result:match("output volume:(%d+)")) or 0
    local muted = result:match("output muted:(%a+)") == "true"
    set_volume(value, muted)
  end)
end

volume:subscribe({ "volume_change", "system_woke", "routine" }, update_volume)
volume:subscribe("mouse.clicked", function()
  sbar.exec("open 'x-apple.systempreferences:com.apple.Sound-Settings.extension'")
end)

local memory = sbar.add("item", "memory", {
  position = "right",
  icon = { string = "", color = colors.gold },
  background = { drawing = false },
  padding_left = 6,
  padding_right = 6,
  update_freq = 15,
})

local function update_memory()
  sbar.exec([[memory_pressure | awk '/System-wide memory free percentage/ { gsub(/%/, "", $5); print 100 - $5; exit }']], function(result)
    memory:set({ label = { string = (result:match("%d+") or "--") .. "%" } })
  end)
end

memory:subscribe({ "routine", "system_woke" }, update_memory)
memory:subscribe("mouse.clicked", open_app("Activity Monitor"))

local cpu = sbar.add("item", "cpu", {
  position = "right",
  icon = { string = "", color = colors.accent },
  background = { drawing = false },
  padding_left = 6,
  padding_right = 6,
  update_freq = 5,
})

local function update_cpu()
  sbar.exec([[cores=$(sysctl -n hw.logicalcpu 2>/dev/null || echo 1); ps -A -o %cpu= | awk -v cores="$cores" '{ sum += $1 } END { value = int(sum / cores + 0.5); if (value > 100) value = 100; print value }']], function(result)
    cpu:set({ label = { string = (result:match("%d+") or "--") .. "%" } })
  end)
end

cpu:subscribe({ "routine", "system_woke" }, update_cpu)
cpu:subscribe("mouse.clicked", open_app("Activity Monitor"))

update_calendar()
update_weather()
update_battery()
update_volume()
update_memory()
update_cpu()
