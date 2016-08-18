
--[[--------------------------------------------------------------------------
--
-- File:            UADisarm.State.RoundLoop.lua
--                  Copyright (c) Ubisoft Entertainment. All rights reserved.
--
-- Project:         Ubitoys.Tag
-- Date:            Novmber 18, 2010
--
------------------------------------------------------------------------------
--
-- Description:     ...
--
----------------------------------------------------------------------------]]

--[[ Dependencies ----------------------------------------------------------]]

require "UTActivity.State.RoundLoop"
require "UADisarm.Ui.RoundLoop"

--[[ Class -----------------------------------------------------------------]]

UADisarm.State.RoundLoop = UTClass(UTActivity.State.RoundLoop)

-- defaults ------------------------------------------------------------------

UADisarm.State.RoundLoop.uiClass = UADisarm.Ui.RoundLoop

-- __ctor --------------------------------------------------------------------

function UADisarm.State.RoundLoop:__ctor(activity, ...)

    -- timer

    self.time = quartz.system.time.gettimemicroseconds()
    activity.timer = 0
    
    assert(activity)
	
end

-- Begin ---------------------------------------------------------------------

function UADisarm.State.RoundLoop:Begin()

	UTActivity.State.RoundLoop.Begin(self)
	
	game.gameMaster:RegisterSound({ paths = {"base:audio/gamemaster/DLG_GM_GLOBAL_13.wav", 
											 "base:audio/gamemaster/DLG_GM_GLOBAL_14.wav", 
											 "base:audio/gamemaster/DLG_GM_GLOBAL_15.wav"}, probas = {0.8, 0.1, 0.1}})

	game.gameMaster:RegisterSound({ paths = {"base:audio/gamemaster/DLG_GM_GLOBAL_32.wav",
											"base:audio/gamemaster/DLG_GM_GLOBAL_33.wav",
											"base:audio/gamemaster/DLG_GM_GLOBAL_34.wav",
											"base:audio/gamemaster/DLG_GM_GLOBAL_35.wav",
											"base:audio/gamemaster/DLG_GM_GLOBAL_125.wav",
											"base:audio/gamemaster/DLG_GM_GLOBAL_126.wav",
											"base:audio/gamemaster/DLG_GM_GLOBAL_132.wav",}, priority = 4 })
						 
	game.gameMaster:RegisterSound({ paths = {"base:audio/gamemaster/DLG_GM_GLOBAL_48.wav",
											 "base:audio/gamemaster/DLG_GM_GLOBAL_49.wav"},
									offset = activity.settings.playtime * 60 - 57, priority = 3, proba = 0.333})
						 
	game.gameMaster:RegisterSound({ paths = {"base:audio/gamemaster/DLG_GM_GLOBAL_48.wav",
											 "base:audio/gamemaster/DLG_GM_GLOBAL_49.wav"},
									offset = activity.settings.playtime * 60  - 27,priority = 3, proba = 0.333})
						 
	game.gameMaster:RegisterSound({ paths = {"base:audio/gamemaster/DLG_GM_GLOBAL_48.wav",
											 "base:audio/gamemaster/DLG_GM_GLOBAL_49.wav"},
									offset = activity.settings.playtime * 60 - 12, priority = 3, proba = 0.333})

    -- timer

    self.time = quartz.system.time.gettimemicroseconds()
    self.shootCount = 0
    self.shootCountTime = self.time
    activity.timer = activity.settings.playtime * 60 * 1000000
	activity.bombcode = { activity.settings.firstdigit, activity.settings.seconddigit, activity.settings.thirddigit, activity.settings.fourthdigit }
	activity.gameplayData = { 0x00, 0x00 }
	game.gameplayData = { 0x00, 0x00, 0x00, 0x00 }
	activity.bombdisarmed = false
	activity.gameoverSound = {"base:audio/gamemaster/DLG_GM_LIQUID_08.wav"}

end

-- Message received from device  -----------------------------------------------------------------------

function UADisarm.State.RoundLoop:OnDispatchMessage(device, addressee, command, arg)

	-- base

	UTActivity.State.RoundLoop.OnDispatchMessage(self)

	if (0x95 == command) then

		-- decode this msg !!

		local gunseconds = (arg[8] * 256) + arg[9]
		if (gunseconds ~= device.owner.data.heap.gunseconds or gunseconds == 0 or device.owner.data.heap.lifePoints == 0) then
			device.owner.data.heap.guntime = quartz.system.time.gettimemicroseconds()
			device.owner.vestconnect = false
			if (gunseconds == 0) then
				device.owner.gameplayData[2] = 0
			end
		elseif (device.owner.data.heap.guntime + 5000000 < quartz.system.time.gettimemicroseconds() and game.settings.GameSettings.vestdisconnect == 0 and not device.timedout) then
			device.owner.gameplayData[2] = 7
		end
		if (device.owner.data.heap.guntime + 1000000 < quartz.system.time.gettimemicroseconds()) then
			device.owner.vestconnect = true
		end
		if (device.owner.secondary) then
			if (device.owner.data.heap.guntime + 900000 < quartz.system.time.gettimemicroseconds() or device.owner.data.heap.lifePoints == 0) then
				device.owner.secondary.gameplayData[2] = 7
			elseif (device.owner.gameplayData[2] ~= 7) then
				device.owner.secondary.gameplayData[2] = 6
			end
		end
		device.owner.data.heap.gunseconds = gunseconds
		if (device.rejoin) then
			if ((arg[2] * 256) + arg[3] > 0) then
				device.rejoin = false
			end
		end
		if (device.owner and not device.rejoin) then

			-- ammunitions and clip
		
			local ammunitions = (arg[4] * 256) + arg[5]	
			
			if (ammunitions == 3) then
				if (game.settings.audio.gmtalkative == 1) then
					-- throw "We need Ammo! Now" sound		
					game.gameMaster:RegisterSound({ paths = {"base:audio/gamemaster/DLG_GM_GLOBAL_22.wav","base:audio/gamemaster/DLG_GM_GLOBAL_23.wav"},priority = 3,})
				end
			end
			
			local clips = (arg[6] * 256) + arg[7]
			if (0 == device.owner.data.heap.isDead) then
				
				if (not device.owner.terrorist and activity.settings.ammunitionsCommando < 255 and (device.owner.data.heap.ammunitions < ammunitions and device.owner.data.heap.clips <= clips or device.owner.data.heap.clips < clips)) then
						
					device.owner.data.heap.nbAmmoPack = device.owner.data.heap.nbAmmoPack + 1
					activity.uiAFP:PushLine(device.owner.profile.name .. " " .. l"ingame006", UIComponent.colors.gray, "base:texture/Ui/Icons/16x/Ammunition.tga")
					
				elseif (device.owner.data.heap.ammunitions > ammunitions) then
					device.owner.data.heap.nbShot = device.owner.data.heap.nbShot + (device.owner.data.heap.ammunitions - ammunitions)
					device.owner.data.heap.hitLost = device.owner.data.heap.hitLost + 1
					if (device.owner.data.heap.hitLost == 5) then
						if (game.settings.audio.gmtalkative == 1) then
							-- throw "T'es aveugle" sound	
							game.gameMaster:RegisterSound({ paths = {"base:audio/gamemaster/DLG_GM_GLOBAL_43.wav","base:audio/gamemaster/DLG_GM_GLOBAL_44.wav"},priority = 2,})
						end
						device.owner.data.heap.hitLost = 0
					end
					if (device.owner.data.heap.hitLost >= 2) then
						device.owner.data.nbHitLastPlayerShooted = 0
					end
				end
			end
			device.owner.data.heap.clips = clips
			device.owner.data.heap.ammunitions = ammunitions
			if (device.owner.terrorist or not device.owner.terrorist and activity.settings.ammunitionsCommando == 255) then
				device.owner.data.heap.ammunitionsAndClips = "-/-"
			else
				device.owner.data.heap.ammunitionsAndClips = device.owner.data.heap.ammunitions .. "/" .. device.owner.data.heap.clips
			end

			-- check if bomb defused

			local bombdigitscanned = (arg[10] * 256) + arg[11] + 1
			local bombdigitscancount = (arg[12] * 256) + arg[13]
			
			if (not activity.bombdisarmed) then
				if (device.owner.data.heap.bombdigitscancount ~= bombdigitscancount and bombdigitscancount ~= 0 and not device.owner.primary) then
					for i, j in pairs(activity.bombcode) do
						if (bombdigitscanned == j and device.owner.gameplayData[2] == i - 1) then
							device.owner.gameplayData[2] = device.owner.gameplayData[2] + 1
							break
						end
					end
					if (device.owner.gameplayData[2] == 4) then
						activity.uiAFP:PushLine(device.owner.profile.name .. " " .. l"ingame053", UIComponent.colors.gray, "base:texture/Ui/Icons/16x/Bomb.tga")
						activity.bombdisarmed = true
					end
					if (device.owner.gameplayData[2] < 4) then
						if (bombdigitscancount < 4) then
							game.gameMaster:RegisterSound({ paths = {"base:audio/gamemaster/DLG_GM_DISARM_0" .. bombdigitscanned .. ".wav"}})
							activity.uiAFP:PushLine(device.owner.profile.name .. " " .. l"ingame051" .. " " .. bombdigitscanned, UIComponent.colors.gray, "base:texture/Ui/Icons/16x/Bomb.tga")
						else
							activity.uiAFP:PushLine(device.owner.profile.name .. " " .. l"ingame052", UIComponent.colors.gray, "base:texture/Ui/Icons/16x/Bomb.tga")
							device.owner.gameplayData[2] = 5
						end
					end
					device.owner.data.heap.bombdigitscancount = bombdigitscancount
				end
			else
				device.owner.gameplayData[2] = 5
			end
			
			-- life points
		
			local lifePoints = (arg[2] * 256) + arg[3]
			if (device.owner.primary) then
				lifePoints = device.owner.primary.data.heap.lifePoints
			end
							
			if (lifePoints == 1) then
				if (game.settings.audio.gmtalkative == 1) then
					-- throw "Mediiiic!" sound	
					game.gameMaster:RegisterSound({ paths = {"base:audio/gamemaster/DLG_GM_GLOBAL_18.wav","base:audio/gamemaster/DLG_GM_GLOBAL_19.wav"},priority = 3,})	 
				end
			end

			-- check if I have been shot ...

			if (device.owner.data.heap.lifePoints > lifePoints) then

				if (self.shootCount) then
					self.shootCount = self.shootCount + 1
					
					if (self.shootCount == 10) then
					
						local time = quartz.system.time.gettimemicroseconds()
					
						if (time - self.shootCountTime < 10 * 1000000) then
							if (game.settings.audio.gmtalkative == 1) then
								-- ouais jsuis a donf
								game.gameMaster:RegisterSound({ paths = {"base:audio/gamemaster/DLG_GM_GLOBAL_24.wav","base:audio/gamemaster/DLG_GM_GLOBAL_25.wav",}, priority = 2, proba = 0.25})
							end
						end			
						
						self.shootCountTime = time			
						self.shootCount = 0
					end
					
				end
				
				local curIndex = math.max(0, device.owner.data.heap.lifePoints - lifePoints)
				while (curIndex > 0) do
				
					device.owner.data.heap.timeshit = device.owner.data.heap.timeshit + 1

					-- get device that shot me
					local shooterDevice = engine.libraries.usb.proxy.devices.byRadioProtocolId[arg[math.min(18, curIndex + 13)]]
					curIndex = curIndex - 1
					if (shooterDevice and shooterDevice.owner and shooterDevice.owner.primary ~= device.owner and device.owner.primary ~= shooterDevice.owner) then
					
						-- get shooter
						local shooter = shooterDevice.owner
						if (shooterDevice.owner.primary) then
							shooter = shooterDevice.owner.primary
						end
						
						if (0 == lifePoints and curIndex == 0) then

							-- KILL ------------------------------------------------------

							if (shooter.team ~= device.owner.team) then
								activity.uiAFP:PushLine(shooter.profile.name .. " " .. l"ingame011" .. " " .. device.owner.profile.name, UIComponent.colors.gray, "base:texture/Ui/Icons/16x/Death.tga")
								shooter.data.heap.death = shooter.data.heap.death + 1
								shooter.data.heap.killByName[device.owner.nameId] = (shooter.data.heap.killByName[device.owner.nameId] or 0) + 1
								if (game.settings.audio.gmtalkative == 1) then
									-- throw "Dans le mille!" sound	
									game.gameMaster:RegisterSound({ paths = {"base:audio/gamemaster/DLG_GM_GLOBAL_27.wav",
									"base:audio/gamemaster/DLG_GM_GLOBAL_28.wav",
									"base:audio/gamemaster/DLG_GM_GLOBAL_37.wav",
									"base:audio/gamemaster/DLG_GM_GLOBAL_38.wav",
									"base:audio/gamemaster/DLG_GM_GLOBAL_128.wav",
									"base:audio/gamemaster/DLG_GM_GLOBAL_129.wav",
									"base:audio/gamemaster/DLG_GM_GLOBAL_130.wav",
									}, priority = 2,})
								end
							elseif (activity.settings.teamFragTerrorist == 1 and device.owner.terrorist or activity.settings.teamFragCommando == 1 and not device.owner.terrorist) then
								activity.uiAFP:PushLine(shooter.profile.name .. " " .. l"ingame011" .. " " .. device.owner.profile.name, UIComponent.colors.gray, "base:texture/Ui/Icons/16x/Death" .. shooter.team.profiles[shooter.team.index].teamColor .. ".tga" )
								shooter.data.heap.death = shooter.data.heap.death + 1
								shooter.data.heap.killByName[device.owner.nameId] = (shooter.data.heap.killByName[device.owner.nameId] or 0) + 1
								game.gameMaster:RegisterSound({ paths = {"base:audio/gamemaster/DLG_GM_GLOBAL_41.wav","base:audio/gamemaster/DLG_GM_GLOBAL_42.wav"}, priority = 2,})
							end
							device.owner.data.heap.isDead = 1
							device.owner.data.heap.bombdefuseprogress = 0
							if (activity.settings.retry or device.owner.data.heap.bombdigitscancount < 4) then
								device.owner.gameplayData[2] = 0
							end

						else

							-- HIT ------------------------------------------------------
								
							if (shooter.data.heap.lastPlayerShooted == device.owner) then
								shooter.data.heap.nbHitLastPlayerShooted = shooter.data.heap.nbHitLastPlayerShooted + 1
								if (shooter.data.heap.nbHitLastPlayerShooted == 3) then
									if (game.settings.audio.gmtalkative == 1) then
										-- throw "Tireur d'�lite" sound	
										game.gameMaster:RegisterSound({ paths = {"base:audio/gamemaster/DLG_GM_GLOBAL_26.wav",}, priority = 3, proba = 0.33})	
									end
									shooter.data.heap.nbHitLastPlayerShooted = 0
								end
							else
								shooter.data.heap.nbHitLastPlayerShooted = 1
								shooter.data.heap.lastPlayerShooted = device.owner
							end
							shooter.data.heap.hitLost = 0
							
							if (shooter.team ~= device.owner.team) then
								activity.uiAFP:PushLine(shooter.profile.name .. " " .. l"ingame009" .. " " .. device.owner.profile.name, UIComponent.colors.gray, "base:texture/Ui/Icons/16x/Hit.tga")
								shooter.data.heap.hitByName[device.owner.nameId] = (shooter.data.heap.hitByName[device.owner.nameId] or 0) + 1
								shooter.data.heap.hit = shooter.data.heap.hit + 1
							elseif (activity.settings.teamFragTerrorist == 1 and device.owner.terrorist or activity.settings.teamFragCommando == 1 and not device.owner.terrorist) then
								-- throw "teammateshoot" sound	
								game.gameMaster:RegisterSound({ paths = {"base:audio/gamemaster/DLG_GM_GLOBAL_41.wav","base:audio/gamemaster/DLG_GM_GLOBAL_42.wav"}, priority = 2,})			
								activity.uiAFP:PushLine(shooter.profile.name .. " " .. l"ingame009" .. " " .. device.owner.profile.name, UIComponent.colors.gray, "base:texture/Ui/Icons/16x/Hit" .. shooter.team.profiles[shooter.team.index].teamColor .. ".tga" )
								shooter.data.heap.hitByName[device.owner.nameId] = (shooter.data.heap.hitByName[device.owner.nameId] or 0) + 1
								shooter.data.heap.hit = shooter.data.heap.hit + 1
							end

							-- terrorist ?

							if (device.owner.terrorist) then
								if (lifePoints == 3) then
									game.gameMaster:RegisterSound({ paths = {"base:audio/gamemaster/DLG_GM_LIQUID_06.wav",}, priority = 2 })
								elseif (lifePoints == 1) then
									activity.gameplayData[2] = activity.gameplayData[2] + 1
									game.gameMaster:RegisterSound({ paths = {"base:audio/gamemaster/DLG_GM_LIQUID_07.wav",}, priority = 2 })
								elseif (game.settings.audio.gmtalkative == 1) then
									game.gameMaster:RegisterSound({ paths = {"base:audio/gamemaster/DLG_GM_LIQUID_01.wav",
											"base:audio/gamemaster/DLG_GM_LIQUID_02.wav",
											"base:audio/gamemaster/DLG_GM_LIQUID_03.wav",
											"base:audio/gamemaster/DLG_GM_LIQUID_04.wav",
											"base:audio/gamemaster/DLG_GM_LIQUID_05.wav",}, priority = 2 })
								end
							end
						end
					end
				end

				-- test if commando is killed 

				if (not device.owner.terrorist and 0 == lifePoints) then

					activity.timer = math.max(activity.timer - (activity.settings.timePenality * 1000000), 0)

				end

			elseif (device.owner.data.heap.lifePoints < lifePoints) then

				-- back to life or medkit !
				
				if (1 == device.owner.data.heap.isDead or 0 == device.owner.data.heap.isDead and game.settings.addons.medkitPack == 0) then

					device.owner.data.heap.nbRespawn = device.owner.data.heap.nbRespawn + 1
					activity.uiAFP:PushLine(device.owner.profile.name .. " " .. l"ingame014", UIComponent.colors.gray, "base:texture/Ui/Icons/16x/Respawn" .. device.owner.team.profiles[device.owner.team.index].teamColor .. ".tga")
					
					device.owner.data.heap.isDead = 0
					if (game.settings.audio.gmtalkative == 1) then
						-- throw "De retour" sound		
						game.gameMaster:RegisterSound({ paths = {"base:audio/gamemaster/DLG_GM_GLOBAL_36.wav"}, priority = 2,})
					end
				
				else

					device.owner.data.heap.nbMediKit = device.owner.data.heap.nbMediKit + 1
					activity.uiAFP:PushLine(device.owner.profile.name .. " " .. l"ingame012", UIComponent.colors.gray, "base:texture/Ui/Icons/16x/Heart.tga")
					if (game.settings.audio.gmtalkative == 1) then
						-- throw "�a va mieux?" sound		
						game.gameMaster:RegisterSound({ paths = {"base:audio/gamemaster/DLG_GM_GLOBAL_16.wav","base:audio/gamemaster/DLG_GM_GLOBAL_17.wav"}, priority = 2,})	 
					end
				
				end

			end
			
			-- store life points

			device.owner.data.heap.lifePoints = lifePoints

		end

	end

end

function UADisarm.State.RoundLoop:Update()

	UTActivity.State.RoundLoop.Update(self)

	local terroristsdead = true
	local commandosdead = true
	for _, player in ipairs(activity.match.challengers[2].players) do
		if (player.data.heap.lifePoints > 0) then
			commandosdead = false
			break
		end
	end
	for _, player in ipairs(activity.match.challengers[1].players) do
		if (player.data.heap.lifePoints > 0) then
			terroristsdead = false
			break
		end
	end

	-- end match
	
	if (activity.bombdisarmed and activity.settings.wincondition == 1 or activity.bombdisarmed and terroristsdead) then
		activity.match.challengers[1].data.heap.score = 0
		activity.match.challengers[2].data.heap.score = 1
		activity.gameoverSound = {"base:audio/gamemaster/DLG_GM_LIQUID_10.wav"}
		activity:PostStateChange("endround")
	end

	if (commandosdead or activity.timer <= 0) then

		activity:PostStateChange("endround")

	end
end
