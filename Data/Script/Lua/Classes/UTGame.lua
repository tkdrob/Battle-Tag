
--[[--------------------------------------------------------------------------
--
-- File:            UTGame.lua
--                  Copyright (c) Ubisoft Entertainment. All rights reserved.
--
-- Project:         Ubitoys.Tag
-- Date:            May 28, 2010
--
------------------------------------------------------------------------------
--
-- Description:     ...
--
----------------------------------------------------------------------------]]

--[[ Dependencies ----------------------------------------------------------]]

require "UTEvent"
require "UTProcess"

require "Engine/UEEngine"
require "UTLocale"
require "Ui/UIManager"

require "UTGameMaster"
require "UTBasics"

--[[ Class -----------------------------------------------------------------]]

UTClass.UTGame(UTProcess)

-- defaults

UTGame.updateFrameRate = 30

-- state dependencies

UTGame.State = {}

    require "UTGame.State.Basics"
    require "UTGame.State.Connected"
    require "UTGame.State.Connection"
    require "UTGame.State.Ignition"
    require "UTGame.State.Revision"
    require "UTGame.State.Selector"
    require "UTGame.State.Session"
    require "UTGame.State.Title"
    require "UTGame.State.Video"
    require "UTGame.State.Settings"
    require "UTGame.State.Loading"


-- __ctor --------------------------------------------------------------------

function UTGame:__ctor(...)

    -- engine

    self.engine = UEEngine:New()

    -- locale

    self.locale = UTLocale:New()
    
    -- game master

    self.gameMaster = UTGameMaster:New()

    -- basic initialize
	
    UTBasics:Initialize()
    
    -- settings

    self.settings = {}

    self.settings.audio = {

        ["l-volume:music"] = 5, ["volume:music"] = 0.357,
        ["l-volume:sfx"] = 2, ["volume:sfx"] = 0.25,
        ["l-volume:gm"] = 5, ["volume:gm"] = 0.625,
        ["gmtalkative"] = 1,
        ["l-volume:gd"] = 8, ["volume:gd"] = 0.625,
        ["l-volume:blaster"] = 0, ["volume:blaster"] = 0,
        
    }

    self.settings.addons = {

        ["medkitPack"] = 0,
        ["customPack"] = 0,
    }
    
    self.settings.GameSettings = {

        ["protectedmode"] = 1,
        ["playernumbermod"] = 0,
        ["unregister"] = 0,
        ["reconnect"] = 2,
		["vestdisconnect"] = 1,
    }
    
    self.settings.ActivitySettings = {

        ["beamPower"] = 3,
		["teampoints"] = 2,
        ["playerpoints"] = 1,
        ["assist"] = 1,
        ["preventlaunch"] = 1,
        ["teamdefaults"] = 0,
        ["gameLaunch"] = 1,
		["countdown"] = 10,
    }
    
    self.settings.UiSettings = {

        ["slideBegin"] = true,
        ["slideEnd"] = false,
        ["playerslotgrid"] = 0,
        ["nbplayerslot"] = 12,
        ["teamribbon"] = 0,
		["aspectratio"] = 0,
		["teamcolors"] = 0,
		["finalranking"] = 0,
		["lastgame"] = 1,
    }

    self.settings.TestSettings = {

        ["roundloopcycle"] = 100000,
        ["bytecodeoverride"] = 0,
    }

    self.settings.registers = {
    
        ["firstTime"] = false, -- the first time the application gets launched
    }
    
    self.settings.activities = {
    
    }
    
    self.settings.advactivities = {
    
    }

    -- states

    self.states["basics"] = UTGame.State.Basics:New(self)
    self.states["ignition"] = UTGame.State.Ignition:New(self)
    self.states["video"] = UTGame.State.Video:New(self)
    self.states["connection"] = UTGame.State.Connection:New(self)
    self.states["revision"] = UTGame.State.Revision:New(self)
    self.states["connected"] = UTGame.State.Connected:New(self)
    self.states["title"] = UTGame.State.Title:New(self)
    self.states["selector"] = UTGame.State.Selector:New(self)
    self.states["settings"] = UTGame.State.Settings:New(self)
    self.states["session"] = UTGame.State.Session:New(self)
    self.states["loading"] = UTGame.State.Loading:New(self)

    self.default = "ignition"

    -- wait for engine ignition before restarting the state machine

    self.engine._IgnitionComplete:Add(self, UTGame.EngineIgnitionComplete)

    -- ui manager

    self.ui = UIManager:New()
    self.ui:Suspend()

    -- processes

    self.processes = {}

    table.insert(self.processes, self.engine)
    table.insert(self.processes, self.ui)

	-- events

	self._Char = UTEvent:New()
	self._Draw = UTEvent:New()
	self._KeyDown = UTEvent:New()
	self._MouseButtonDown = UTEvent:New()
	self._MouseButtonUp = UTEvent:New()
	self._MouseMove = UTEvent:New()
	self._Pause = UTEvent:New()
	self._Render = UTEvent:New()

end

-- __dtor --------------------------------------------------------------------

function UTGame:__dtor()

    self.ui = self.ui:Delete()
    self.locale = self.locale:Delete()
    self.engine = self.engine:Delete()

    -- fool the state machine,
    -- do not call the End method for the current state,
    -- we are dead anyway...

    self.current = nil

end

-- Char ----------------------------------------------------------------------

function UTGame:Char(char)

    self._Char:Invoke(char)

end

-- Draw ----------------------------------------------------------------------

function UTGame:Draw()

    -- reset the device first,
    -- the function checks for lost devices & all...

    if (quartz.system.drawing.reset()) then

        quartz.system.drawing.loadcolor3f(0.0, 0.0, 0.0)
        quartz.system.drawing.clear()

        quartz.system.drawing.beginscene()

        -- invoke all drawing delegates

        self._Draw:Invoke()

        -- present the device (swap buffers)

        quartz.system.drawing.endscene()
        quartz.system.drawing.present()

    end

end

-- EngineIgnitionComplete ----------------------------------------------------

function UTGame:EngineIgnitionComplete()

    -- engine ingition was complete,
    -- we can restart the state machine

    self:Restart()

    -- drawing library is ready,
    -- we can register a new delegate that is responsible for the whole rendering process

    self._Render:Add(self, UTGame.Draw)

end

-- KeyDown -------------------------------------------------------------------

function UTGame:KeyDown(virtualKeyCode, scanCode)

    self._KeyDown:Invoke(virtualKeyCode, scanCode)

end

-- LoadSettings --------------------------------------------------------------

function UTGame:LoadSettings()

	-- load settings from disk

    local settingsFile = REG_USERAPPFOLDER .. "/settings/user.settings"
    local chunk, message = loadfile(settingsFile)

    if (chunk) then

        local result, settings = pcall(chunk)

        if (result) then self.settings = settings
        else print("[UTGame.LoadSettings] : failed, ", settings)
        end

    elseif (message) then

        print("[UTGame.LoadSettings] LUA_ERRRUN : runtime error.\r\n" .. message)

    else

        print("[UTGame.LoadSettings] : file not found,")
        print("path = " .. settingsFile)

    end

    -- compatibility

    if (not self.settings.registers) then
		self.settings.registers = {}
        self.settings.registers.firstTime = false
    end

end

-- SaveSettings --------------------------------------------------------------------

function UTGame:SaveSettings()

    local settingsFile = "settings/user.settings"

    -- audio

    local settingsString = [[
local settings = {

    audio = {
]]  

	for key, value in pairs(self.settings.audio) do
		settingsString = settingsString .. '        ["' .. key  .. '"] = ' .. tostring(value) .. ',\n'
	end

    -- addons

	settingsString = settingsString .. [[
	},
	addons = {
]]

	for key, value in pairs(self.settings.addons) do
		settingsString = settingsString .. '        ["' .. key  .. '"] = ' .. tostring(value) .. ',\n'
	end
	
    -- Game Settings

	settingsString = settingsString .. [[
	},
	GameSettings = {
]]

	for key, value in pairs(self.settings.GameSettings) do
		settingsString = settingsString .. '        ["' .. key  .. '"] = ' .. tostring(value) .. ',\n'
	end
	
    -- Activity Settings

	settingsString = settingsString .. [[
	},
	ActivitySettings = {
]]

	for key, value in pairs(self.settings.ActivitySettings) do
		settingsString = settingsString .. '        ["' .. key  .. '"] = ' .. tostring(value) .. ',\n'
	end
	
    -- Ui Settings

	settingsString = settingsString .. [[
	},
	UiSettings = {
]]

	for key, value in pairs(self.settings.UiSettings) do
		settingsString = settingsString .. '        ["' .. key  .. '"] = ' .. tostring(value) .. ',\n'
	end

    -- Test Settings

	settingsString = settingsString .. [[
	},
	TestSettings = {
]]

	for key, value in pairs(self.settings.TestSettings) do
		settingsString = settingsString .. '        ["' .. key  .. '"] = ' .. tostring(value) .. ',\n'
	end

	-- registers

    settingsString = settingsString .. [[
	},
	registers = {
]]

	for key, value in pairs(self.settings.registers) do
		settingsString = settingsString .. '        ["' .. key  .. '"] = ' .. tostring(value) .. ',\n'
	end

    -- closure,
    -- lua script returns the settings table

    settingsString = settingsString .. [[
	}, 
	activities = {
]]

    if (not self.settings.activities) then
        self.settings.activities = {}
    end

	for key, value in pairs(self.settings.activities) do

		settingsString = settingsString .. '        ["' .. key  .. '"] = {'

		for key, value in pairs(self.settings.activities[key]) do
			settingsString = settingsString .. '        ["' .. key  .. '"] = ' .. tostring(value) .. ','
		end

	    settingsString = settingsString .. '},\n'

	end

    settingsString = settingsString .. [[
	}, 
	advactivities = {
]]

    if (not self.settings.advactivities) then
        self.settings.advactivities = {}
    end

	for key, value in pairs(self.settings.advactivities) do

		settingsString = settingsString .. '        ["' .. key  .. '"] = {'

		for key, value in pairs(self.settings.advactivities[key]) do
			settingsString = settingsString .. '        ["' .. key  .. '"] = ' .. tostring(value) .. ','
		end

	    settingsString = settingsString .. '},\n'

	end

	-- registers

    settingsString = settingsString .. [[
	},
}
return settings
]]

	application.serialize(settingsFile, settingsString)

end

-- MouseButtonDown -----------------------------------------------------------

function UTGame:MouseButtonDown(...)

    self._MouseButtonDown:Invoke(...)

end

-- MouseButtonUp -------------------------------------------------------------

function UTGame:MouseButtonUp(...)

    self._MouseButtonUp:Invoke(...)

end

-- MouseMove -----------------------------------------------------------------

function UTGame:MouseMove(...)

    self._MouseMove:Invoke(...)

end

-- Pause ---------------------------------------------------------------------

function UTGame:Pause(paused)

    self._Pause:Invoke(paused)

end

-- PostStateChange -----------------------------------------------------------

function UTGame:PostStateChange(transition, ...)

	local args = {...}

    local delegate = function ()
        UTProcess.PostStateChange(self, transition, unpack(args))
    end

	if (UIMenuManager and UIMenuManager.stack.top and UIMenuManager.stack.top.slideEnd) then

		self.mvtFx = UIManager:AddFx("position", { duration = 0.75, __self = UIMenuManager.stack.top, from = {0, UIMenuManager.stack.top.rectangle[2]}, to = { -1100, UIMenuManager.stack.top.rectangle[2] }, type = "accelerate" })
		self.postChangeFx = UIManager:AddFx("callback", { timeOffset = 0.75, __function = delegate })
		UIMenuManager.stack.top.closingMvt = true

	else

		delegate()

	end

end

-- Render --------------------------------------------------------------------

function UTGame:Render()

    self._Render:Invoke()

end

-- Update --------------------------------------------------------------------

-- the update function is still called every frame,
-- it is the UTProcess class that takes fixed time steps into account

function UTGame:Update()

	-- processes

	table.foreach(self.processes, function (_, process) process:Update() end)

    -- process/ state machine

    UTProcess.Update(self)
    
    self.gameMaster:Update()

end
