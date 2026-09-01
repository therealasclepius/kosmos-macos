local runtime_palette = os.getenv("HOME") .. "/.config/kosmos/palette.lua"
local ok, colors = pcall(dofile, runtime_palette)

if ok and type(colors) == "table" then
  return colors
end

return {
  bar_bg = 0xee111c18,
  bar_border = 0xff53685b,
  surface = 0xff23372b,
  foreground = 0xffc1c497,
  accent = 0xff71cead,
  muted = 0xff53685b,
  green = 0xff63b07a,
  gold = 0xffd7c995,
  active_text = 0xff111c18,
  inactive_surface = 0x0023372b,
}
