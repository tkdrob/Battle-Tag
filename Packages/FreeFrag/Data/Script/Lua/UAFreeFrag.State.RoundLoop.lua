
--[[--------------------------------------------------------------------------
--
-- File:            UAFreeFrag.State.RoundLoop.lua
--                  Copyright (c) Ubisoft Entertainment. All rights reserved.
--
-- Project:         Ubitoys.Tag
-- Date:            September 27, 2010
--
------------------------------------------------------------------------------
--
-- Description:     ...
--
----------------------------------------------------------------------------]]

--[[ Dependencies ----------------------------------------------------------]]

require "UTActivity.State.RoundLoop"

	require "UAFreeFrag.Ui.RoundLoop"

--[[ Class -----------------------------------------------------------------]]

UAFreeFrag.State.RoundLoop = UTClass(UTActivity.State.RoundLoop)

-- defaults ------------------------------------------------------------------

UAFreeFrag.State.RoundLoop.uiClass = UAFreeFrag.Ui.RoundLoop

-- __ctor --------------------------------------------------------------------

function UAFreeFrag.State.RoundLoop:__ctor(activity, ...)

    assert(activity)

end

-- Begin ---------------------------------------------------------------------

function UAFreeFrag.State.RoundLoop:Begin()

	UTActivity.State.RoundLoop.Begin(self)
	
	game.gameMaster:RegisterSound({ paths = {"base:audio/gamemaster/DLG_GM_GLOBAL_13.wav", 
											 "base:audio/gamemaster/DLG_GM_GLOBAL_14.wav", 
											 "base:audio/gamemaster/DLG_GM_GLOBAL_15.wav"}, probas = {0.8, 0.1, 0.1}})

	if (activity.settings.playtime >= 2) then
		game.gameMaster:RegisterSound({ paths = {"base:audio/gamemaster/DLG_GM_GLOBAL_45.wav"},offset = activity.settings.playtime * 60 - 60,})
	end
						 
	game.gameMaster:RegisterSound({ paths = {"base:audio/gamemaster/DLG_GM_GLOBAL_48.wav",
											 "base:audio/gamemaster/DLG_GM_GLOBAL_49.wav"},
									offset = activity.settings.playtime * 60 - 57, priority = 2, proba = 0.333})
						 
	game.gameMaster:RegisterSound({ paths = {"base:audio/gamemaster/DLG_GM_GLOBAL_46.wav"},
									offset = activity.settings.playtime * 60 - 30,})
						 
	game.gameMaster:RegisterSound({ paths = {"base:audio/gamemaster/DLG_GM_GLOBAL_48.wav",
											 "base:audio/gamemaster/DLG_GM_GLOBAL_49.wav"},
									offset = activity.settings.playtime * 60  - 27,priority = 2, proba = 0.333})
						 
	game.gameMaster:RegisterSound({ paths = {"base:audio/gamemaster/DLG_GM_GLOBAL_47.wav"},
									offset = activity.settings.playtime * 60  - 15,})
						 
	game.gameMaster:RegisterSound({ paths = {"base:audio/gamemaster/DLG_GM_GLOBAL_48.wav",
											 "base:audio/gamemaster/DLG_GM_GLOBAL_49.wav"},
									offset = activity.settings.playtime * 60 - 12, priority = 2, proba = 0.333})
									
    -- timer

    self.time = quartz.system.time.gettimemicroseconds()
    self.shootCount = 0
    self.shootCountTime = self.time
    activity.timer = activity.settings.playtime * 60 * 1000000
	game.gameplayData = { 0x00, 0x00 }

end

-- Message received from device  ----------------------------------------------

function UAFreeFrag.State.RoundLoop:OnDispatchMessage(device, addressee, command, arg)

	if (0x95 == command) then

		-- decode this msg !!

		if (device.rejoin) then
			if ((arg[2] * 256) + arg[3] > 0) then
				device.rejoin = false
			end
		end
		if (device.owner and not device.rejoin) then

			--------------------------------------------------------------------------------------
			-- nb shots

			local shots = (arg[4] * 256) + arg[5]
			if (device.owner.data.heap.nbShot > shots) then
				if (shots == 0) then
					device.owner.data.heap.nbShotbackup = device.owner.data.heap.nbShot
				end
				device.owner.data.heap.nbShot = device.owner.data.heap.nbShotbackup + shots
			else
				device.owner.data.heap.nbShot = shots
			end

			--------------------------------------------------------------------------------------
			-- nb hits
		
			local nbHit = (arg[2] * 256) + arg[3]
			if (nbHit == 0) then
				device.owner.data.heap.nbHitbackup = device.owner.data.heap.nbHit
			end

			-- check if I have been shot ...
			if (device.owner.data.heap.nbHit < nbHit + device.owner.data.heap.nbHitbackup) then

				if (self.shootCount) then
					self.shootCount = self.shootCount + 1
					
					if (self.shootCount == 10) then
					
						local time = quartz.system.time.gettimemicroseconds()
					
						if (time - self.shootCountTime < 10 * 1000000) then
							if (game.settings.audio.gmtalkative == 1) then
								-- ouais jsuis a donf
								game.gameMaster:RegisterSound({ paths = {"base:audio/gamemaster/DLG_GM_GLOBAL_24.wav","base:audio/gamemaster/DLG_GM_GLOBAL_25.wav","base:audio/gamemaster/DLG_GM_GLOBAL_121.wav","base:audio/gamemaster/DLG_GM_GLOBAL_133.wav","base:audio/gamemaster/DLG_GM_GLOBAL_134.wav",}, priority = 2, proba = 0.25})
							end
						end			
						
						self.shootCountTime = time			
						self.shootCount = 0
					end
					
				end
				
				local curIndex = math.max(0, nbHit + device.owner.data.heap.nbHitbackup - device.owner.data.heap.nbHit)
				while (curIndex > 0) do

					-- loose one life
					device.owner.data.heap.nbHit = device.owner.data.heap.nbHit + 1

					-- get device that shot me
					local shooterDevice = engine.libraries.usb.proxy.devices.byRadioProtocolId[arg[math.min(10, curIndex + 5)]]
					curIndex = curIndex - 1
					if (shooterDevice and shooterDevice.owner and shooterDevice.owner.primary ~= device.owner and device.owner.primary ~= shooterDevice.owner) then

						-- get shooter
						local shooter = shooterDevice.owner
						if (shooterDevice.owner.primary) then
							shooter = shooterDevice.owner.primary
						end

						--!! give him point 
						if (shooter) then

							-- HIT ------------------------------------------------------
							
							if (shooter.data.heap.lastPlayerShooted == device.owner) then
								shooter.data.heap.nbHitLastPlayerShooted = shooter.data.heap.nbHitLastPlayerShooted + 1
								if (shooter.data.heap.nbHitLastPlayerShooted == 3) then
									if (game.settings.audio.gmtalkative == 1) then
										-- throw "Tireur d'�lite" sound	
										game.gameMaster:RegisterSound({ paths = {"base:audio/gamemaster/DLG_GM_GLOBAL_26.wav","base:audio/gamemaster/DLG_GM_GLOBAL_122.wav","base:audio/gamemaster/DLG_GM_GLOBAL_123.wav","base:audio/gamemaster/DLG_GM_GLOBAL_124.wav",}, priority = 3, proba = 0.33})	
									end
									shooter.data.heap.nbHitLastPlayerShooted = 0
								end
							else
								shooter.data.heap.nbHitLastPlayerShooted = 1
								shooter.data.heap.lastPlayerShooted = device.owner
							end
								
							shooter.data.heap.score = shooter.data.heap.score + 1
							shooter.data.heap.hit = shooter.data.heap.hit + 1
							activity.uiAFP:PushLine(shooter.profile.name .. " "  .. l"ingame009" .. " " .. device.owner.profile.name, UIComponent.colors.gray, "base:texture/Ui/Icons/16x/Hit.tga")
							shooter.data.heap.hitByName[device.owner.nameId] = (shooter.data.heap.hitByName[device.owner.nameId] or 0) + 1
							if (game.settings.audio.gmtalkative == 1) then
								-- throw "Touch� ! �a doit faire mal" sound									
								game.gameMaster:RegisterSound({ paths = {"base:audio/gamemaster/DLG_GM_GLOBAL_29.wav","base:audio/gamemaster/DLG_GM_GLOBAL_30.wav"}, priority = 3, proba = 0.333})							
							end
						end
					end
				end
			end
			device.owner.data.heap.nbHit = nbHit + device.owner.data.heap.nbHitbackup
		end
	end
end

-- Update ---------------------------------------------------------------------

function UAFreeFrag.State.RoundLoop:Update()

	UTActivity.State.RoundLoop.Update(self)

	-- end match

	if (activity.timer <= 0) then
			activity:PostStateChange("endround")
	end

end
