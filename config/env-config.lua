-----------------------------------------------------------------------------------------------------------------------
--                                                  Environment config                                               --
-----------------------------------------------------------------------------------------------------------------------

local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
local wibox = require("wibox")
local naughty = require("naughty")

local redflat = require("redflat")

-- Initialize tables and vars for module
-----------------------------------------------------------------------------------------------------------------------
local env = {}

-- Build hotkeys depended on config parameters
-----------------------------------------------------------------------------------------------------------------------
function env:init(args)

	-- init vars
	local args = args or {}

	-- environment vars
	self.mod = args.mod or "Mod4"
  -- Applications list
	self.terminal = args.terminal or "urxvt"
	self.geditor = args.geditor or "nvim"
	self.fm = args.fm or "nemo"
	self.web = args.web or "luakit"
	self.mail = args.mail or "evolution"
	self.pdf = args.pdf or "zathura"
	self.chat = args.chat or "mattermost"
	self.player = args.player or "spotify"
	self.upgrades = args.upgrades or "bash -c 'pacman -Qu | grep -v ignored | wc -l'"
	self.home = os.getenv("HOME")
	self.themedir = awful.util.get_configuration_dir() .. "themes/"

	self.sloppy_focus = false
	self.color_border = false
	self.set_slave = true

	-- theme setup
	beautiful.init(env.themedir .. "/theme.lua")

	-- naughty config
	naughty.config.padding = beautiful.useless_gap and 2 * beautiful.useless_gap or 0

	if beautiful.naughty then
		naughty.config.presets.normal   = redflat.util.table.merge(beautiful.naughty.base, beautiful.naughty.normal)
		naughty.config.presets.critical = redflat.util.table.merge(beautiful.naughty.base, beautiful.naughty.critical)
		naughty.config.presets.low      = redflat.util.table.merge(beautiful.naughty.base, beautiful.naughty.low)

		-- dirty fix to ignore forced geometry for critical preset
		-- For the sake of laziness I prefer fix some parameters after inherit than write pure table without inherit
		naughty.config.presets.critical.height, naughty.config.presets.critical.width = nil, nil
	end
end


-- Common functions
-----------------------------------------------------------------------------------------------------------------------

-- Wallpaper setup
--------------------------------------------------------------------------------
env.wallpaper = function(s, walldir)
  -- Choose random wallpaper 
  math.randomseed(os.time())
  pictures = assert(io.popen("ls " .. env.themedir .. walldir .. "/*.jpg"))
  wallpaper = {}
  for jpg in pictures:lines() do wallpaper[#wallpaper +1] = jpg end
  trgt_wallpaper = wallpaper[math.random(1, #wallpaper)]

  io.output(io.open("/tmp/awesome.txt", "a"))
  io.write( "trgt wallpaper: " .. walldir .. "  " .. trgt_wallpaper)
  io.close()

  -- Apply wallpaper
  if gears.filesystem.file_readable(trgt_wallpaper) then
    gears.wallpaper.maximized(trgt_wallpaper, s, true)
  else
    gears.wallpaper.set(beautiful.color.bg)
  end

end

-- Tag tooltip text generation
--------------------------------------------------------------------------------
env.tagtip = function(t)
	local layname = awful.layout.getname(awful.tag.getproperty(t, "layout"))
	if redflat.util.table.check(beautiful, "widget.layoutbox.name_alias") then
		layname = beautiful.widget.layoutbox.name_alias[layname] or layname
	end
	return string.format("%s (%d apps) [%s]", t.name, #(t:clients()), layname)
end

-- Panel widgets wrapper
--------------------------------------------------------------------------------
env.wrapper = function(widget, name, buttons)
	local margin = { 0, 0, 0, 0 }

	if redflat.util.table.check(beautiful, "widget.wrapper") and beautiful.widget.wrapper[name] then
		margin = beautiful.widget.wrapper[name]
	end
	if buttons then
		widget:buttons(buttons)
	end

	return wibox.container.margin(widget, unpack(margin))
end


-- Keyboard Layout
--------------------------------------------------------------------------------
env.kdbLayout = function(map)
  if 'fr' == map then
    awful.spawn.with_shell("setxkbmap -layout fr")
  else -- Default to dvp
    awful.spawn.with_shell("setxkbmap -layout us -variant dvp")
    awful.spawn.with_shell("xmodmap -e \"keycode 94 = eacute egrave\"")
    awful.spawn.with_shell("xmodmap -e \"clear lock\"")
    awful.spawn.with_shell("xmodmap -e \"keycode 66 = Super_L agrave\"")
  end
end
-- End
-----------------------------------------------------------------------------------------------------------------------
return env
