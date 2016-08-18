
--[[--------------------------------------------------------------------------
--
-- File:            UTActivity.lua
--                  Copyright (c) Ubisoft Entertainment. All rights reserved.
--
-- Project:         Ubitoys.Tag
-- Date:            July 26, 2010
--
------------------------------------------------------------------------------
--
-- Description:     Standard activity.
--
----------------------------------------------------------------------------]]

--[[ Dependencies ----------------------------------------------------------]]

	require "Ui/UIPlayerSlot"

--[[ Class -----------------------------------------------------------------]]

UTClass.UTActivity(UTProcess)

-- these are the three categories all activities are built upon

UTActivity.categories = {

    single = 1, -- harness is not mandatory, 1 or more guns are shared
    open = 2, -- championship, harness is mandatory, more players than max. supported
    closed = 3, -- harness is mandatory, 1 gun per player

}

-- defaults

UTActivity.updateFrameRate = 30

UTActivity.maxNumberOfPlayer = 48
UTActivity.minNumberOfPlayer = 2

UTActivity.bytecodePath = nil

UTActivity.countdownDuration = 10

UTActivity.gameoverTexture = "base:texture/ui/text_gameover.tga"

UTActivity.gameoverSound = {"base:audio/gamemaster/DLG_GM_GLOBAL_50.wav", 
							 "base:audio/gamemaster/DLG_GM_GLOBAL_51.wav", 
							 "base:audio/gamemaster/DLG_GM_GLOBAL_52.wav"}

UTActivity.playerSlot = UIPlayerSlot

-- SD16 snd
UTActivity.gameoverSnd = { 0x53, 0x44, 0x31, 0x36 }

-- state dependencies

UTActivity.State = {}

    require "UTActivity.State.Begin"
    require "UTActivity.State.End"

    require "UTActivity.State.Title"
    require "UTActivity.State.Settings"
    require "UTActivity.State.AdvancedSettings"
    require "UTActivity.State.Playground"
    require "UTActivity.State.PlayersManagement"
    require "UTActivity.State.PlayersSetup"
    require "UTActivity.State.Bytecode"

    require "UTActivity.State.Matchmaking"
        require "UTActivity.State.BeginMatch"
        require "UTActivity.State.EndMatch"

    require "UTActivity.State.BeginRound"
    require "UTActivity.State.EndRound"
        require "UTActivity.State.RoundLoop"

    require "UTActivity.State.IntermediateRankings"
    require "UTActivity.State.FinalRankings"

    require "UTActivity.State.Loading"
    require "UTActivity.State.Revision"

-- __ctor --------------------------------------------------------------------

function UTActivity:__ctor(...)

    -- states

    self.states["begin"] = UTActivity.State.Begin:New(self)
    self.states["end"] = UTActivity.State.End:New(self)

	self.states["title"] = UTActivity.State.Title:New(self)
    self.states["settings"] = UTActivity.State.Settings:New(self)
    self.states["advancedsettings"] = UTActivity.State.AdvancedSettings:New(self)
	self.states["playground"] = UTActivity.State.Playground:New(self)
    self.states["playersmanagement"] = UTActivity.State.PlayersManagement:New(self)
	self.states["playerssetup"] = UTActivity.State.PlayersSetup:New(self)
	self.states["bytecode"] = UTActivity.State.Bytecode:New(self)

	self.states["matchmaking"] = UTActivity.State.Matchmaking:New(self)
	    self.states["beginmatch"] = UTActivity.State.BeginMatch:New(self)
	    self.states["endmatch"] = UTActivity.State.EndMatch:New(self)

	self.states["beginround"] = UTActivity.State.BeginRound:New(self)
	self.states["endround"] = UTActivity.State.EndRound:New(self)
	    self.states["roundloop"] = UTActivity.State.RoundLoop:New(self)

	self.states["intermediaterankings"] = UTActivity.State.IntermediateRankings:New(self)
	self.states["finalrankings"] = UTActivity.State.FinalRankings:New(self)

    self.states["loading"] = UTActivity.State.Loading:New(self)
    self.states["revision"] = UTActivity.State.Revision:New(self)

    self.default = "title"

	-- properties

    self.name = "UTActivity"
    self.category = nil -- single, open, closed

    -- text for title stat

    self.textRules = "Default rules for standard activity"
    self.textScoring = "Default scoring for standard activity"

    -- settings
    
    self.settings = {}
    self.advancedsettings = {}

    -- gameplay data send

    self.gameplayData = {}
	game.gameplayData = {}

    -- listen for disconnected devices,
    -- will handler players entities' bindings

    assert(engine.libraries.usb)
    assert(engine.libraries.usb.proxy)
    
    engine.libraries.usb.proxy._DeviceRemoved:Add(self, self.OnDeviceRemoved, 10)

    -- restart the state machine

    self:Restart("begin")

end

-- __dtor --------------------------------------------------------------------

function UTActivity:__dtor()

    if (engine and engine.libraries.usb.proxy) then
        engine.libraries.usb.proxy._DeviceRemoved:Remove(self, self.OnDeviceRemoved)
    end

end

-- Check ---------------------------------------------------------------------

function UTActivity:Check()

	return true

end

-- InitEntityBakedData  ------------------------------------------------------

function UTActivity:InitEntityBakedData(entity, ranking)

	-- profile information

    entity.data.baked.name = entity.profile.name
    entity.data.baked.icon = entity.profile.icon
    entity.data.baked.classId = entity.rfGunDevice and entity.rfGunDevice.classId or "?"

end

-- InitEntityHeapData  -------------------------------------------------------

function UTActivity:InitEntityHeapData(entity, ranking)

	-- name id = profile.name + device.classId

	if (entity.rfGunDevice) then
		entity.nameId = entity.profile.name .. entity.rfGunDevice.classId
	else
		entity.nameId = entity.profile.name	
	end

	-- profile information

    entity.data.heap.name = entity.profile.name
    entity.data.heap.icon = entity.profile.icon
    entity.data.heap.classId = entity.rfGunDevice and entity.rfGunDevice.classId or "?"

end

-- OnDeviceRemoved -----------------------------------------------------------

function UTActivity:OnDeviceRemoved(device)

    if (device.owner) then

        local playerEntity = device.owner
        playerEntity:BindDevice()

	    -- update profile information

if (GEAR_CFG_COMPILE == GEAR_COMPILE_DEBUG) then

        playerEntity.profile.name = l"oth039"
        playerEntity.data.heap.icon = nil

        playerEntity.data.heap.name = l"oth039"
        playerEntity.data.heap.icon = nil
        playerEntity.data.heap.classId = nil

end

        playerEntity.data.heap.disconnected = true

    end

end

-- PostStateChange -----------------------------------------------------------

function UTActivity:PostStateChange(transition, ...)

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

-- SaveTeamInformation  ------------------------------------------------------

function UTActivity:SaveTeamInformation()

	self.teamBackup = {}
	if (0 < #activity.teams) then

		for _, team in pairs(self.teams) do
			for _, player in pairs(team.players) do
				if (player.rfGunDevice) then
					self.teamBackup[player.rfGunDevice] = team.index
				end					
			end			
		end			

	end
		
end

-- UpdateEntityBakedData  ----------------------------------------------------

function UTActivity:UpdateEntityBakedData(entity, ranking)
end
