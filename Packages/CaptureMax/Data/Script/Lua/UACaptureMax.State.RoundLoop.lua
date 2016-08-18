
--[[--------------------------------------------------------------------------
--
-- File:            UACaptureMax.State.RoundLoop.lua
--                  Copyright (c) Ubisoft Entertainment. All rights reserved.
--
-- Project:         Ubitoys.Tag
-- Date:            November 25, 2010
--
------------------------------------------------------------------------------
--
-- Description:     ...
--
----------------------------------------------------------------------------]]

--[[ Dependencies ----------------------------------------------------------]]

require "UTActivity.State.RoundLoop"
require "UACaptureMax.Ui.RoundLoop"

--[[ Class -----------------------------------------------------------------]]

UACaptureMax.State.RoundLoop = UTClass(UTActivity.State.RoundLoop)

-- defaults ------------------------------------------------------------------

UACaptureMax.State.RoundLoop.uiClass = UACaptureMax.Ui.RoundLoop

-- __ctor --------------------------------------------------------------------

function UACaptureMax.State.RoundLoop:__ctor(activity, ...)

    -- timer

    self.time = quartz.system.time.gettimemicroseconds()
    activity.timer = 0
    
    assert(activity)
	
end

-- Begin ---------------------------------------------------------------------

function UACaptureMax.State.RoundLoop:Begin()

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

	game.gameMaster:RegisterSound({ paths = {"base:audio/gamemaster/DLG_GM_GLOBAL_45.wav"},offset = activity.settings.playtime * 60 - 60,})
						 
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
    self.shootCount = 0
    self.shootCountTime = self.time
    activity.timer = activity.settings.playtime * 60 * 1000000
	game.gameplayData = { 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 }
    if (activity.settings.flagmode == 1) then
        if (activity.settings.numberOfTeams > 2) then
            activity.flagbase = { 4, 5, 6, 7 }
        else
            activity.flagbase = { 2, 3 }
        end
    elseif (activity.settings.numberOfTeams > 2) then
        activity.flagbase = { 0, 1, 2, 3 }
    else
        activity.flagbase = { 0, 1 }
    end
    activity.flagdevices = {}
    for i = 1, activity.settings.numberOfTeams do
        activity.flagdevices[i] = false
    end
    activity.lastflagdevices = {}
end

-- Message received from device  -----------------------------------------------------------------------

function UACaptureMax.State.RoundLoop:OnDispatchMessage(device, addressee, command, arg)

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
		elseif (device.owner.data.heap.guntime + 5000000 < quartz.system.time.gettimemicroseconds() and game.settings.GameSettings.vestdisconnect == 0) then
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
				
				if (device.owner.data.heap.ammunitions < ammunitions and device.owner.data.heap.clips <= clips or device.owner.data.heap.clips < clips) then
						
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
			if (activity.settings.ammunitions == 255) then
				device.owner.data.heap.ammunitionsAndClips = "-/-"
			else
				device.owner.data.heap.ammunitionsAndClips = device.owner.data.heap.ammunitions .. "/" .. device.owner.data.heap.clips
			end
	
			-- data
			
			local lifePoints = (arg[2] * 256) + arg[3]
			if (device.owner.primary) then
				lifePoints = device.owner.primary.data.heap.lifePoints
			end
			local lastBaseScanned = (arg[10] * 256) + arg[11]
			local energy = 0
            for i, flagdevice in ipairs(activity.flagdevices) do
                if (flagdevice == device and activity.settings.energymode == 1) then
                    energy = (arg[12] * 256) + arg[13]
                    break
                end
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
	
			end
            local flagnum = 0
            local noflagnum = 0
            for i, flagdevice in ipairs(activity.flagdevices) do
                if (i ~= device.owner.team.index and flagdevice ~= device) then
                    if (not flagdevice and not device.owner.primary and device.owner.gameplayData[2] ~= 7) then
                        flagnum = flagnum + 1
                        device.owner.gameplayData[flagnum * 2 + 2] = activity.flagbase[i]
                    else
                        noflagnum = noflagnum + 1
                        if (device.owner.primary or device.owner.gameplayData[2] == 7) then
                            device.owner.gameplayData[10 - noflagnum * 2] = 9
                        else
                            device.owner.gameplayData[10 - noflagnum * 2] = 10
                        end
                    end
                end
            end
            for i, flagdevice in ipairs(activity.lastflagdevices) do
                if (flagdevice.owner.team == device.owner.team) then
                    device.owner.gameplayData[4] = 9
                    if (flagdevice == device) then
                        table.remove(activity.lastflagdevices, flagdevice)
                    end
                end
            end
            for i, flagdevice in ipairs(activity.flagdevices) do
                if (flagdevice) then
                    if (flagdevice.timedout or flagdevice == device and device.owner.gameplayData[2] == 7) then
                        activity.uiAFP:PushLine(flagdevice.owner.profile.name .. " " .. l"ingame065", flagdevice.owner.team.profiles[flagdevice.owner.team.index].teamcolor, "base:texture/Ui/Icons/16x/FlagIcon" .. flagdevice.owner.team.index .. ".tga")
                    elseif (flagdevice == device) then
                        device.owner.gameplayData[4] = device.owner.team.index - 1
                    end
                end
            end
            if (device.owner.gameplayData[2] ~= 7 and (device.owner.gameplayData[4] ~= 10 or device.owner.gameplayData[6] ~= 10 or device.owner.gameplayData[8] ~= 10)) then
                for i, flagdevice in ipairs(activity.flagdevices) do
			        if (device.owner.team.index ~= i and lastBaseScanned == activity.flagbase[i] and not flagdevice) then
                        device.owner.gameplayData[4] = device.owner.team.index - 1
                        if (activity.settings.flagmode == 1 and activity.settings.numberOfTeams > 2) then
                            activity.flagdevices[lastBaseScanned - 3] = device
                        else
                            activity.flagdevices[lastBaseScanned + 1] = device
                        end
				        activity.uiAFP:PushLine(device.owner.profile.name .. " " .. l"ingame043" .. " " .. lifePoints .. " " .. l"ingame044", device.owner.team.profiles[device.owner.team.index].teamcolor, "base:texture/Ui/Icons/16x/FlagIcon" .. device.owner.team.index .. ".tga")
				        game.gameMaster:RegisterSound({ paths = {"base:audio/gamemaster/DLG_GM_RUSTLERS_02.wav",}, priority = 2,})
                        break
			        end
                end
            end
			-- energy, life points, and score 
			if (lastBaseScanned == device.owner.team.index - 1) then
                for i, flagdevice in ipairs(activity.flagdevices) do
                    if (flagdevice == device) then
				        -- scoring
                        device.owner.data.heap.flag = device.owner.data.heap.flag + 1
                         if (activity.settings.flagmode == 1 and activity.settings.numberOfTeams > 2) then
                            activity.flagdevices[i] = false
                        else
                            activity.flagdevices[i] = false
                        end
				        device.owner.team.data.heap.capturegoal = device.owner.team.data.heap.capturegoal - 1
				        game.gameMaster:RegisterSound({ paths = {"base:audio/gamemaster/DLG_GM_CAPTURE_01.wav"}})
				        if (activity.settings.energymode == 1) then
					        curpoints = device.owner.data.heap.energy
				        else
					        curpoints = lifePoints
				        end
				        activity.uiAFP:PushLine(device.owner.profile.name .. " " .. l"ingame045" .. " " .. curpoints .. " " .. l"ingame044", device.owner.team.profiles[device.owner.team.index].teamcolor, "base:texture/Ui/Icons/16x/FlagIcon" .. device.owner.team.index .. ".tga")
				        device.owner.data.heap.score = device.owner.data.heap.score + (curpoints * activity.settings.capturepointsplayer)
				        device.owner.team.data.heap.score = device.owner.team.data.heap.score + (curpoints * activity.settings.capturepointsplayer * activity.settings.capturepointsteam)
				        if (curpoints >= 5) then
					        game.gameMaster:RegisterSound({ paths = {"base:audio/gamemaster/DLG_GM_GLOBAL_138.wav", "base:audio/gamemaster/DLG_GM_GLOBAL_139.wav", "base:audio/gamemaster/DLG_GM_GLOBAL_140.wav"}, offset = 3, priority = 2,})	
				        elseif (activity.settings.energymode == 0 and curpoints == 3) then
					        game.gameMaster:RegisterSound({ paths = {"base:audio/gamemaster/DLG_GM_RUSTLERS_13.wav",}, offset = 3, priority = 2,})
				        else
					        game.gameMaster:RegisterSound({ paths = {"base:audio/gamemaster/DLG_GM_RUSTLERS_0" .. 2 + curpoints .. ".wav",}, offset = 3, priority = 2,})	
				        end
				        if (activity.settings.timeleft ~= -1 and device.owner.team.data.heap.capturegoal == 0) then
					        activity.timer = activity.settings.timeleft * 1000000
				        end
                        break
                    end
                end
			end
					
			local curIndex = math.max(0, device.owner.data.heap.lifePoints - lifePoints)
			if (device.owner.gameplayData[4] == device.owner.team.index - 1) then
				curIndex = curIndex + math.max(0, device.owner.data.heap.energy - energy)
			end
			while (curIndex > 0 ) do
				
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
							shooter.data.heap.score = shooter.data.heap.score + game.settings.ActivitySettings.playerpoints
							if (activity.settings.wincondition == 0) then
								shooter.team.data.heap.score = shooter.team.data.heap.score + game.settings.ActivitySettings.teampoints + game.settings.ActivitySettings.playerpoints
							end
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
						elseif (activity.settings.teamFrag == 1) then
							activity.uiAFP:PushLine(shooter.profile.name .. " " .. l"ingame011" .. " " .. device.owner.profile.name, UIComponent.colors.gray, "base:texture/Ui/Icons/16x/Death" .. shooter.team.profiles[shooter.team.index].teamColor .. ".tga" )
							shooter.data.heap.death = shooter.data.heap.death + 1
							shooter.data.heap.killByName[device.owner.nameId] = (shooter.data.heap.killByName[device.owner.nameId] or 0) + 1
							game.gameMaster:RegisterSound({ paths = {"base:audio/gamemaster/DLG_GM_GLOBAL_41.wav","base:audio/gamemaster/DLG_GM_GLOBAL_42.wav"}, priority = 2,})
						end
						-- person with the flag is dead
						for i, flagdevice in ipairs(activity.flagdevices) do
                            if (flagdevice == device) then
                                activity.flagdevices[i] = false
                                table.insert(activity.lastflagdevices, device)
							    activity.uiAFP:PushLine(device.owner.profile.name .. " " .. l"ingame046", device.owner.team.profiles[device.owner.team.index].teamcolor, "base:texture/Ui/Icons/16x/FlagIcon" .. device.owner.team.index .. ".tga")
                                break
                            end
						end
						device.owner.data.heap.isDead = 1
						device.owner.team.data.heap.nbteamPlayerAlive = device.owner.team.data.heap.nbteamPlayerAlive - 1
						if (activity.settings.endgamemode == 1) then
							if (device.owner.team.data.heap.nbteamPlayerAlive == 0) then
								device.owner.team.data.heap.endgametimer = activity.timer
							end
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
							shooter.data.heap.score = shooter.data.heap.score + 1
							if (activity.settings.wincondition == 0) then
								shooter.team.data.heap.score = shooter.team.data.heap.score + 1
							end
							activity.uiAFP:PushLine(shooter.profile.name .. " " .. l"ingame009" .. " " .. device.owner.profile.name, UIComponent.colors.gray, "base:texture/Ui/Icons/16x/Hit.tga")
							shooter.data.heap.hitByName[device.owner.nameId] = (shooter.data.heap.hitByName[device.owner.nameId] or 0) + 1
							shooter.data.heap.hit = shooter.data.heap.hit + 1
						elseif (activity.settings.teamFrag == 1) then
							-- throw "teammateshoot" sound	
							game.gameMaster:RegisterSound({ paths = {"base:audio/gamemaster/DLG_GM_GLOBAL_41.wav","base:audio/gamemaster/DLG_GM_GLOBAL_42.wav"}, priority = 2,})			
							activity.uiAFP:PushLine(shooter.profile.name .. " " .. l"ingame009" .. " " .. device.owner.profile.name, UIComponent.colors.gray, "base:texture/Ui/Icons/16x/Hit" .. shooter.team.profiles[shooter.team.index].teamColor .. ".tga" )
							shooter.data.heap.hitByName[device.owner.nameId] = (shooter.data.heap.hitByName[device.owner.nameId] or 0) + 1
							shooter.data.heap.hit = shooter.data.heap.hit + 1
						end
						if (device.owner.gameplayData[4] == device.owner.team.index - 1) then
							if (activity.settings.energymode == 1) then
								if (energy == 0) then
                                    for i, flagdevice in ipairs(activity.flagdevices) do
                                        if (flagdevice == device) then
                                            activity.flagdevices[i] = false
                                            table.insert(activity.lastflagdevices, device)
									        -- being shot
									        activity.uiAFP:PushLine(device.owner.profile.name .. " " .. l"ingame042", device.owner.team.profiles[device.owner.team.index].teamcolor, "base:texture/Ui/Icons/16x/FlagIcon" .. device.owner.team.index .. ".tga")
                                            break
                                        end
                                    end
								else
									-- loose energy
									activity.uiAFP:PushLine(device.owner.profile.name .. " " .. l"ingame041", device.owner.team.profiles[device.owner.team.index].teamcolor, "base:texture/Ui/Icons/16x/FlagIcon" .. device.owner.team.index .. ".tga")
								end
							else
								-- loose lifepoints
								activity.uiAFP:PushLine(device.owner.profile.name .. " " .. l"ingame047", device.owner.team.profiles[device.owner.team.index].teamcolor, "base:texture/Ui/Icons/16x/FlagIcon" .. device.owner.team.index .. ".tga")
							end
						end
					end
				end
				if (activity.settings.lives >= 1) then
					if (0 == lifePoints and device.owner.data.heap.nbRespawn == activity.settings.lives - 1) then
										
						-- This player is out
											
						device.owner.data.heap.icon = string.sub(device.owner.data.heap.icon, 0, #device.owner.data.heap.icon - 4)
						device.owner.data.heap.icon = device.owner.data.heap.icon .. "_Out.tga"
						device.owner.team.data.heap.nbPlayerAlive = device.owner.team.data.heap.nbPlayerAlive - 1
											
						-- only one player left in this team
											
						if (device.owner.team.data.heap.nbPlayerAlive == 1) then
			
							local curTeam = {"DLG_GM_LAST_TEAM_02.wav", "DLG_GM_LAST_TEAM_05.wav" }
							game.gameMaster:RegisterSound({ paths = {"base:audio/gamemaster/" .. curTeam[device.owner.team.index],}, priority = 1,})	 
			
						elseif (device.owner.team.data.heap.nbPlayerAlive == 2) then
			
							local curTeam = {"DLG_GM_LAST_TEAM_07.wav", "DLG_GM_LAST_TEAM_10.wav" }
							game.gameMaster:RegisterSound({ paths = {"base:audio/gamemaster/" .. curTeam[device.owner.team.index],}, priority = 1,})	 
			
						elseif (device.owner.team.data.heap.nbPlayerAlive > 0) then
							game.gameMaster:RegisterSound({ paths = {"base:audio/gamemaster/DLG_GM_LAST_TEAM_01.wav",}, priority = 1,})
						end
					end
								
					-- check end of game
											
					if (device.owner.team.data.heap.nbPlayerAlive == 0) then
						activity:PostStateChange("endround")					
					end
				end
			end
	
			-- back to life or medkit !
	
			if (device.owner.data.heap.lifePoints < lifePoints) then
	
				if (1 == device.owner.data.heap.isDead or game.settings.addons.medkitPack == 0) then
					device.owner.data.heap.nbRespawn = device.owner.data.heap.nbRespawn + 1
					device.owner.team.data.heap.endgametimer = 0
					activity.uiAFP:PushLine(device.owner.profile.name .. " " .. l"ingame014", UIComponent.colors.gray, "base:texture/Ui/Icons/16x/Respawn" .. device.owner.team.profiles[device.owner.team.index].teamColor .. ".tga")
						
					if (1 == device.owner.data.heap.isDead) then
						device.owner.team.data.heap.nbteamPlayerAlive = device.owner.team.data.heap.nbteamPlayerAlive + 1
					end
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
			-- store energy
			device.owner.data.heap.energy = energy
			if (device.owner.team.data.heap.endgametimer >= activity.timer + (activity.settings.respawnTime + 10) * 1000000) then
				activity:PostStateChange("endround")
			end
		end
	end
end

function UACaptureMax.State.RoundLoop:Update()

	UTActivity.State.RoundLoop.Update(self)

	-- end match
		
		if (activity.timer <= 0) then
			activity:PostStateChange("endround")
		end

end