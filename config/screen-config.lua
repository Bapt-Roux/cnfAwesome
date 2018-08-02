-- Screen layout with list of widgets
------------------------------------------------------------
-- Grab environment
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local redflat = require("redflat")

-- Init tables and vars
---------------------------------------
local screen = {}
function screen:init(args)

  local args = args or {}
  local env = args.env or {} -- fix this?
  local customMenu = args.customMenu or {} -- fix this?
  -- Separator
  ---------------------------------------
  local separator = redflat.gauge.separator.vertical()

  -- Tasklist
  ---------------------------------------
  local tasklist = {}
  -- load apps alias
  tasklist.style = { appnames = require("config.alias-config")}
  tasklist.buttons = awful.util.table.join(
    awful.button({}, 1, redflat.widget.tasklist.action.select),
    awful.button({}, 2, redflat.widget.tasklist.action.close),
    awful.button({}, 3, redflat.widget.tasklist.action.menu),
    awful.button({}, 4, redflat.widget.tasklist.action.switch_next),
    awful.button({}, 5, redflat.widget.tasklist.action.switch_prev)
  )

  -- Taglist widget
  ---------------------------------------
  local taglist = {}
  taglist.style = { widget = redflat.gauge.tag.orange.new, show_tip = true }
  taglist.buttons = awful.util.table.join(
    awful.button({         }, 1, function(t) t:view_only() end),
    awful.button({ env.mod }, 1, function(t) if client.focus then client.focus:move_to_tag(t) end end),
    awful.button({         }, 2, awful.tag.viewtoggle),
    awful.button({ env.mod }, 2, function(t) if client.focus then client.focus:toggle_tag(t) end end),
    awful.button({         }, 3, function(t) awful.tag.viewnext(t.screen) end),
    awful.button({ env.mod }, 3, function(t) awful.tag.viewprev(t.screen) end)
  )

  -- Textclock widget
  ---------------------------------------
  local textclock = {}
  textclock.widget = redflat.widget.textclock({ timeformat = "%H:%M", dateformat = "%b  %d  %a" })

  -- Layoutbox configure
  ---------------------------------------
  local layoutbox = {}

  layoutbox.buttons = awful.util.table.join(
    awful.button({ }, 1, function () customMenu.mainmenu:toggle() end),
    awful.button({ }, 3, function () redflat.widget.layoutbox:toggle_menu(mouse.screen.selected_tag) end),
    awful.button({ }, 2, function () awful.layout.inc( 1) end),
    awful.button({ env.mod }, 2, function () awful.layout.inc(-1) end)
  )

  -- Tray widget
  ---------------------------------------
  local tray = {}
  tray.widget = redflat.widget.minitray()

  tray.buttons = awful.util.table.join(
    awful.button({}, 1, function() redflat.widget.minitray:toggle() end),
    awful.button({}, 2, function() redflat.widget.minitray:toggle() end),
    awful.button({}, 3, function() redflat.widget.minitray:toggle() end)
  )

  -- PA volume control
  ---------------------------------------
  local volume = {}
  volume.widget = redflat.widget.pulse(nil, { widget = redflat.gauge.audio.red.new })

  -- activate player widget
  redflat.float.player:init({ name = env.player })

  volume.buttons = awful.util.table.join(
    awful.button({}, 4, function() redflat.widget.pulse:change_volume()                end),
    awful.button({}, 5, function() redflat.widget.pulse:change_volume({ down = true }) end),
    awful.button({}, 2, function() redflat.widget.pulse:mute()                         end),
    awful.button({}, 3, function() redflat.float.player:show()                         end),
    awful.button({}, 1, function() redflat.float.player:action("PlayPause")            end),
    awful.button({}, 8, function() redflat.float.player:action("Previous")             end),
    awful.button({}, 9, function() redflat.float.player:action("Next")                 end)
  )


  -- Keyboard layout indicator
  ---------------------------------------
  local kbindicator = awful.widget.keyboardlayout()
  kbindicator.buttons = awful.util.table.join(
    awful.button({}, 1, function () awful.spawn.with_shell("setxkbmap -layout us -variant dvp") end),
    awful.button({}, 3, function () awful.spawn.with_shell("setxkbmap -layout fr") end)
  )

  -- System resource monitoring widgets
  --------------------------------------------------------------------------------
  local sysmon = { widget = {}, buttons = {} }

  -- battery
  sysmon.widget.battery = redflat.widget.sysmon(
    { func = redflat.system.pformatted.bat(25), arg = "BAT0" },
    { timeout = 60, widget = redflat.gauge.monitor.circle }
  )
  -- network speed
  sysmon.widget.network = redflat.widget.net(
    {
      interface = "enp0s25",
      speed = { up = 6 * 1024^2, down = 6 * 1024^2 },
      autoscale = false
    },
    { timeout = 2, widget = redflat.gauge.icon.double }
  )

  -- CPU usage
  sysmon.widget.cpu = redflat.widget.sysmon(
    { func = redflat.system.pformatted.cpu(80) },
    { timeout = 2, widget = redflat.gauge.monitor.circle }
  )

  sysmon.buttons.cpu = awful.util.table.join(
    awful.button({ }, 1, function() redflat.float.top:show("cpu") end)
  )

  -- RAM usage
  sysmon.widget.ram = redflat.widget.sysmon(
    { func = redflat.system.pformatted.mem(80) },
    { timeout = 10, widget = redflat.gauge.monitor.circle }
  )

  sysmon.buttons.ram = awful.util.table.join(
    awful.button({ }, 1, function() redflat.float.top:show("mem") end)
  )

  -- Screen setup
  ---------------------------------------
  awful.screen.connect_for_each_screen(
    function(s)
      -- wallpaper
      env.wallpaper(s)

      -- tags
      awful.tag({ "Vim", "Term", "Various", "Task", "Mail" }, s, 
        {awful.layout.layouts[1],
        awful.layout.layouts[1],
        awful.layout.layouts[1],
        awful.layout.layouts[1],
        awful.layout.layouts[5]})

      -- layoutbox widget
      layoutbox[s] = redflat.widget.layoutbox({ screen = s })

      -- taglist widget
      taglist[s] = redflat.widget.taglist({ screen = s, buttons = taglist.buttons, hint = env.tagtip }, taglist.style)

      -- tasklist widget
      tasklist[s] = redflat.widget.tasklist({ screen = s, buttons = tasklist.buttons })

      -- panel wibox
      s.panel = awful.wibar({ position = "bottom", screen = s, height = beautiful.panel_height or 36 })
      -- add widgets to the wibox
      s.panel:setup {
        layout = wibox.layout.align.horizontal,
        { -- left widgets
          layout = wibox.layout.fixed.horizontal,

          env.wrapper(layoutbox[s], "layoutbox", layoutbox.buttons),
          separator,
          env.wrapper(taglist[s], "taglist"),
          separator,
        },
        { -- middle widget
          layout = wibox.layout.align.horizontal,
          expand = "outside",

          nil,
          env.wrapper(tasklist[s], "tasklist"),
        },
        { -- right widgets
          layout = wibox.layout.fixed.horizontal,

          separator,
          env.wrapper(sysmon.widget.network, "network"),
          env.wrapper(sysmon.widget.cpu, "cpu", sysmon.buttons.cpu),
          env.wrapper(sysmon.widget.ram, "ram", sysmon.buttons.ram),
          env.wrapper(sysmon.widget.battery, "battery"),
          separator,
          env.wrapper(volume.widget, "volume", volume.buttons),
          separator,
          env.wrapper(textclock.widget, "textclock"),
          separator,
          env.wrapper(kbindicator.widget, "keyboard", kbindicator.buttons),
          separator,
          env.wrapper(tray.widget, "tray", tray.buttons),
        },
      }
    end
  )
end
return screen
