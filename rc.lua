-----------------------------------------------------------
-- Awesome configuration file
-----------------------------------------------------------

-- Load standard awesome library
----------------------------------------
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
require("awful.autofocus")

-- Load custom modules from worron:
-- -> https://github.com/worron/awesome-config
----------------------------------------
local redflat = require("redflat")
-- global module
timestamp = require("redflat.timestamp")

-- Error handling
-------------------
require("config.ercheck-config")

-- Theme setup
-------------------
local env = require("config.env-config")
env:init()

-- Tiling layouts
-------------------
local layouts = require("config.layout-config")
layouts:init()

-- Custom menu
-------------------
local customMenu = require("config.menu-config")
customMenu:init({ env = env })


-- Screen layout
-------------------
local screen = require("config.screen-config")
screen:init({env = env, customMenu = customMenu})

-- Active screen edges
-----------------------------------------------------------------------------------------------------------------------
-- local edges = require("config.edges-config") -- load file with edges configuration
-- edges:init()

-- Key bindings
-------------------
local keyBinds = require("config.keys-config")
keyBinds:init({ env = env, menu = customMenu.mainmenu })

-- Rules
-------------------
local rules = require("config.rules-config")
rules:init({ hotkeys = keyBinds})

-- Titlebar setup
-------------------
-- local titlebar = require("config.titlebar-config")
-- titlebar:init()


-- Base signal set for awesome wm
-------------------
local signals = require("config.signals-config")
signals:init({ env = env })


-- Autostart user applications
-------------------
local autostart = require("config.autostart-config")
if timestamp.is_startup() then
	autostart.run()
end
