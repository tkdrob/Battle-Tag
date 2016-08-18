
--[[--------------------------------------------------------------------------
--
-- File:            UALastoftheSpecies.State.RoundLoop.lua
--                  Copyright (c) Ubisoft Entertainment. All rights reserved.
--
-- Project:         Ubitoys.Tag
-- Date:            July 27, 2010
--
------------------------------------------------------------------------------
--
-- Description:     ...
--
----------------------------------------------------------------------------]]

--[[ Dependencies ----------------------------------------------------------]]

require "UTActivity.State.RoundLoop"
require "UALastoftheSpecies.Ui.RoundLoop"

--[[ Class -----------------------------------------------------------------]]

UALastoftheSpecies.State.RoundLoop = UTClass(UTActivity.State.RoundLoop)

-- defaults ------------------------------------------------------------------

UALastoftheSpecies.State.RoundLoop.uiClass = UALastoftheSpecies.Ui.RoundLoop

-- __ctor --------------------------------------------------------------------

function UALastoftheSpecies.State.RoundLoop:__ctor(activity, ...)

    -- timer

    self.time = quartz.system.time.gettimemicroseconds()
    activity.timer = 0
    
    assert(activity)
	
end

-- Begin ---------------------------------------------------------------------

function UALastoftheSpecies.State.RoundLoop:Begin()

	UTActivity.State.RoundLoop.Begin(self)

	if (activity.settings.playtime >= 2) then
		game.gameMaster:RegisterSound({ paths = {"base:audio/gamemaster/DLG_GM_GLOBAL_45.wav"},offset = activity.settings.playtime * 60 - 60,})
	end
						 
	game.gameMaster:RegisterSound({ paths = {"base:audio/gamemaster/DLG_GM_GLOBAL_48.wav",
											 "base:audio/gamemaster/DLG_GM_GLOBAL_49.wav"},
									offset = activity.settings.playtime * 60 - 57, priority = 3, proba = 0.333})
						 
	game.gameMaster:RegisterSound({ paths = {"base:audio/gamemaster/DLG_GM_GLOBAL_46.wav"},
									offset = activity.settings.playtime * 60 - 30,})
						 
	game.gameMaster:RegisterSound({ paths = {"base:audio/gamemaster/DLG_GM_GLOBAL_48.wav",
											 "base:audio/gamemaster/DLG_GM_GLOBAL_49.wav"},
									offset = activity.settings.playtime * 60  - 27,priority = 3, proba = 0.333})
						 
	game.gameMaster:RegisterSound({ paths = {"base:audio/gamemaster/DLG_GM_GLOBAL_47.wav"},
									offset = activity.settings.playtime * 60  - 15,})
						 
	game.gameMaster:RegisterSound({ paths = {"base:audio/gamemaster/DLG_GM_GLOBAL_48.wav",
											 "base:audio/gamemaster/DLG_GM_GLOBAL_49.wav"},
									offset = activity.settings.playtime * 60 - 12, priority = 3, proba = 0.333})

    -- timer

    self.time = quartz.system.time.gettimemicroseconds()
    activity.timer = activity.settings.playtime * 60 * 1000000

	for i, player in ipairs(activity.match.challengers) do
		player.wolf = true
	end
	activity.gameplayData = { 0x00, 0x00 }
	game.gameplayData = { 0x00, 0x00 }
											
end

-- Message received from device  -----------------------------------------------------------------------

function UALastoftheSpecies.State.RoundLoop:OnDispatchMessage(device, addressee, command, arg)

	-- base

	UTActivity.State.RoundLoop.OnDispatchMessage(self)

	if (0x95 == command) then

		-- decode this msg !!

		if (device.rejoin) then
			if ((arg[2] * 256) + arg[3] > 0) then
				device.rejoin = false
			end
		end
		if (device.owner and not device.rejoin) then

			-- nb hit
		
			local nbHit = (arg[2] * 256) + arg[3]
			if (nbHit == 0) then
				device.owner.data.heap.nbHitbackup = device.owner.data.heap.nbHit
			end

			if (nbHit + device.owner.data.heap.nbHitbackup > device.owner.data.heap.nbHit) then
			
				local shooterDevice = engine.libraries.usb.proxy.devices.byRadioProtocolId[arg[4]]
				if (shooterDevice and shooterDevice.owner) then
					-- get shooter
					local shooter = shooterDevice.owner
					if (not device.owner.wolf) then
						activity.uiAFP:PushLine(device.owner.profile.name .. " " .. l"ingame062", UIComponent.colors.gray, "base:texture/Ui/Icons/16x/wolf.tga")
						game.gameMaster:RegisterSound({ paths = {"base:audio/gamemaster/DLG_GM_WOLF_02.wav"}, priority = 1 })
					end
					activity.uiAFP:PushLine(shooter.profile.name .. " " .. l"ingame063", UIComponent.colors.gray, "base:texture/Ui/Icons/16x/wolf.tga")
					shooter.wolf = false
					device.owner.wolf = true
					activity.gameplayData = { 0x00, shooter.data.heap.id }
				end
				device.owner.data.heap.nbHit = nbHit + device.owner.data.heap.nbHitbackup

			end

		end

	end

end

-- Update ---------------------------------------------------------------------

function UALastoftheSpecies.State.RoundLoop:Update()

	UTActivity.State.RoundLoop.Update(self)

	-- end match

	if (activity.timer <= 0) then
		activity:PostStateChange("endround")
	end
	local wolves = 0
	for i, player in ipairs(activity.match.challengers) do
		if (player.wolf) then
			wolves = wolves + 1
		end
	end
	if (wolves <= 1) then
		for i, player in ipairs(activity.match.challengers) do
			if (player.wolf) then
		    	activity.match.challengers[i].data.heap.score = 0
		    else
		    	activity.match.challengers[i].data.heap.score = 1
			end
		end
		activity:PostStateChange("endround")
	end
	-- timer

    local wolfElapsedTime = quartz.system.time.gettimemicroseconds() - self.wolfTime
    self.wolfTime = quartz.system.time.gettimemicroseconds()

end