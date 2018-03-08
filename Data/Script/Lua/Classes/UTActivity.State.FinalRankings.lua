--[[--------------------------------------------------------------------------
--
-- File:            UTActivity.State.FinalRankings.lua
--                  Copyright (c) Ubisoft Entertainment. All rights reserved.
--
-- Project:         Ubitoys.Tag
-- Date:            July 28, 2010
--
------------------------------------------------------------------------------
--
-- Description:     ...
--
----------------------------------------------------------------------------]]

--[[ Dependencies ----------------------------------------------------------]]

require "UTActivity.Ui.FinalRankings"

--[[ Class -----------------------------------------------------------------]]

UTActivity.State.FinalRankings = UTClass(UTState)

-- __ctor --------------------------------------------------------------------

function UTActivity.State.FinalRankings:__ctor(activity, ...)

    assert(activity)
    
end

UTActivity.State.FinalRankings.TeamColor = 
{
	["red"] = "DLG_GM_FRAG_TEAM_07.wav",
	["blue"] = "DLG_GM_FRAG_TEAM_08.wav",
	["yellow"] = "DLG_GM_FRAG_TEAM_09.wav",
	["green"] = "DLG_GM_FRAG_TEAM_10.wav",	
	["silver"] = "DLG_GM_FRAG_TEAM_11.wav",
	["purple"] = "DLG_GM_FRAG_TEAM_12.wav",
}

-- Begin ---------------------------------------------------------------------

function UTActivity.State.FinalRankings:Begin()

	--engine.libraries.usb.updateFrameRate = 15

	-- empty all activity matches
	local score = -1000
	local offsetTime = 2

        local gametype = activity.name
        local header = ""
        local scores = ""
	local randomnum = math.random(000000, 999999)
	local filename = "scores_" .. gametype .. "-" .. randomnum .. ".txt"

	header = "Info" .. "," .. "Ranking"
	if (gametype == 'Free For All') then
		header = header .. "," .. "Name" .. "," .. "Victim" .. "," .. "Score" .. "," .. "Shots" .. "," .. "Hits" .. "," .. "Frags" .. "," .. "Respawned" .. "," .. "Ammo" .. "," .. "Med Kits" .. "," .. "Accuracy" .. "," .. "# Hit" .. "\r\n"
	elseif (gametype == 'Free Frag') then
		header = header .. "," .. "Name" .. "," .. "Victim" .. "," .. "Score" .. "," .. "Shots" .. "," .. "Hits" .. "," .. "Accuracy" .. "," .. "# Hit" .. "\r\n"
	elseif (gametype == 'Starter Frag') then
		header = header .. "," .. "Name" .. "," .. "Victim" .. "," .. "Score" .. "," .. "Shots" .. "," .. "Hits" .. "," .. "Ammo" .. "," .. "Accuracy" .. "," .. "# Hit" .. "\r\n"
	elseif (gametype == 'Solo Frag') then
		header = header .. "," .. "Name" .. "," .. "Victim" .. "," .. "Score" .. "," .. "Shots" .. "," .. "Hits" .. "," .. "Frags" .. "," .. "Ammo" .. "," .. "Med Kits" .. "," .. "Accuracy" .. "," .. "# Hit" .. "\r\n"
	elseif (gametype == 'Last Man Standing') then
		header = header .. "," .. "Name" .. "," .. "Victim" .. "," .. "Score" .. "," .. "Shots" .. "," .. "Hits" .. "," .. "Frags" .. "," .. "Ammo" .. "," .. "Med Kits" .. "," .. "Accuracy" .. "\r\n"
	elseif (gametype == 'LAST TEAM STANDING') then
		header = header .. "," .. "Team" .. "," .. "Name" .. "," .. "Victim" .. "," .. "Score" .. "," .. "Shots" .. "," .. "Hits" .. "," .. "Frags" .. "," .. "Ammo" .. "," .. "Med Kits" .. "," .. "Accuracy" .. "\r\n"
	elseif (gametype == 'Infection' or gametype == l"title001") then
		header = header .. "," .. "Name".. "," .. "Score" .. "," .. "Hits" .. "\r\n"
	elseif (gametype == l"title026") then
		header = header .. "," .. "Name".. "," .. "Score" .. "," .. "Shots" .. "," .. "Hits" .. "\r\n"
	elseif (gametype == 'THE MARTIAN WOLF' or gametype == 'Last of the Species' or gametype == 'Wild West Duel') then
		header = header .. "," .. "Name" .. "," .. "Score" .. "\r\n"
    elseif (gametype == 'CAPTURE') then
        header = header .. "," .. "Team" .. "," .. "Name" .. "," .. "Victim" .. "," .. "Score" .. "," .. "Shots" .. "," .. "Hits" .. "," .. "Frags" .. "," .. "Respawned" .. "," .. "Ammo" .. "," .. "Med Kits" .. "," .. "Flags" .. "," .. "Accuracy" .. "," .. "# Hit" .. "\r\n"
	else
		header = header .. "," .. "Team" .. "," .. "Name" .. "," .. "Victim" .. "," .. "Score" .. "," .. "Shots" .. "," .. "Hits" .. "," .. "Frags" .. "," .. "Respawned" .. "," .. "Ammo" .. "," .. "Med Kits" .. "," .. "Accuracy" .. "," .. "# Hit" .. "\r\n"
	end

        
        

	game.gameMaster:Begin()
	
	local oneWinner = game.gameMaster:RegisterSound({paths = {"base:audio/gamemaster/DLG_GM_GLOBAL_53.wav"},})
	
	if (0 < #activity.teams) then

		for _, team in ipairs(activity.teams) do

			for i, value in ipairs(team.players) do

				if (gametype ~= l'title026') then
					if (gametype == 'LAST TEAM STANDING') then
						scores = scores .. "Player" .. "," .. value.data.baked.ranking .. "," .. team.profile.teamColor .. "," .. value.profile.name .. "," .. "-" .. "," .. (value.data.baked.score or 0) .. "," .. (value.data.baked.nbShot or 0) .. "," .. (value.data.baked.hit or 0) .. "," .. (value.data.baked.death or 0) .. "," .. (value.data.baked.nbAmmoPack or 0) .. "," .. (value.data.baked.nbMediKit or 0) .. "," .. value.data.baked.accuracy .. "\r\n"
					elseif (gametype == 'CAPTURE') then
						scores = scores .. "Player" .. "," .. value.data.baked.ranking .. "," .. team.profile.teamColor .. "," .. value.profile.name .. "," .. "-" .. "," .. (value.data.baked.score or 0) .. "," .. (value.data.baked.nbShot or 0) .. "," .. (value.data.baked.hit or 0) .. "," .. (value.data.baked.death or 0) .. "," .. (value.data.baked.nbRespawn or 0) .. "," .. (value.data.baked.nbAmmoPack or 0) .. "," .. (value.data.baked.nbMediKit or 0) .. "," .. (value.data.baked.flag or 0) .. "," .. value.data.baked.accuracy .. "," .. (value.data.baked.timeshit or 0) .. "\r\n"
					else
						scores = scores .. "Player" .. "," .. value.data.baked.ranking .. "," .. team.profile.teamColor .. "," .. value.profile.name .. "," .. "-" .. "," .. (value.data.baked.score or 0) .. "," .. (value.data.baked.nbShot or 0) .. "," .. (value.data.baked.hit or 0) .. "," .. (value.data.baked.death or 0) .. "," .. (value.data.baked.nbRespawn or 0) .. "," .. (value.data.baked.nbAmmoPack or 0) .. "," .. (value.data.baked.nbMediKit or 0) .. "," .. value.data.baked.accuracy .. "," .. (value.data.baked.timeshit or 0) .. "\r\n"
					end
					for _, pstats in ipairs(activity.players) do
						if (pstats.profile.name ~= value.profile.name) then
							scores = scores .. "Details" .. "," .. "" .. "," .. team.profile.teamColor .. "," .. value.profile.name .. "," .. pstats.profile.name .. "," .. "" .. "," .. "" .. "," .. (value.data.baked.hitByName[pstats.nameId] or 0) .. "," .. (value.data.baked.killByName[pstats.nameId] or 0) .. "\r\n"
						end
					end
				end
			end
		end
		application.serialize(filename,header .. scores)
		
		for i, team in ipairs(activity.teams) do
			
			if (team.data.baked.score >= score) then
			
				if (#team.players > 0 ) then
					if (score ~= -1000 and oneWinner ~= nil) then
				
						game.gameMaster:UnRegisterSound(oneWinner)				
						game.gameMaster:RegisterSound({paths = {"base:audio/gamemaster/DLG_GM_GLOBAL_54.wav"}})
						oneWinner = nil
					
					end 
				
					game.gameMaster:RegisterSound({paths = {"base:audio/gamemaster/" .. UTActivity.State.FinalRankings.TeamColor[team.profile.teamColor]}, offset = offsetTime})
					offsetTime = offsetTime + 1.5
					score = team.data.baked.score;
				end
			else
				break
			end
			
		end

	else
                
        for i, value in ipairs(activity.players) do
                
            scores = scores .. "Player" .. "," .. value.data.baked.ranking .. "," .. value.profile.name
            if not (gametype == 'THE MARTIAN WOLF' or gametype == 'Infection' or gametype == l"title001" or gametype == 'Last of the Species' or gametype == 'Wild West Duel') then
                scores = scores .. "," .. "-"
            end
            if (value.data.baked.score) then
                scores = scores .. "," .. (value.data.baked.score or 0)
            end
            if (value.data.baked.nbShot) then
                scores = scores .. "," .. (value.data.baked.nbShot or 0)
            end
            if (value.data.baked.hit) then
                scores = scores .. "," .. (value.data.baked.hit or 0)
            end
            if (value.data.baked.death) then
                scores = scores .. "," .. (value.data.baked.death or 0)
            end
            if (value.data.baked.nbRespawn) then
                scores = scores .. "," .. (value.data.baked.nbRespawn or 0)
            end
            if (value.data.baked.nbAmmoPack) then
                scores = scores .. "," .. (value.data.baked.nbAmmoPack or 0)
            end
            if (value.data.baked.nbMediKit) then
                scores = scores .. "," .. (value.data.baked.nbMediKit or 0)
            end
            if (value.data.baked.flag) then
                scores = scores .. "," .. (value.data.baked.flag or 0)
            end
            if (value.data.baked.accuracy) then
                scores = scores .. "," .. (value.data.baked.accuracy or 0)
            end
            if (value.data.baked.timeshit) then
                scores = scores .. "," .. (value.data.baked.timeshit or 0)
            end
            if (value.data.baked.nbHit) then
                scores = scores .. "," .. (value.data.baked.nbHit or 0) .. "\r\n"
            else
                scores = scores .. "\r\n"
            end
            if not (gametype == l'title026' or gametype == 'THE MARTIAN WOLF' or gametype == 'Infection' or gametype == l"title001" or gametype == 'Last of the Species' or gametype == 'Wild West Duel') then
			    for _, pstats in ipairs(activity.players) do
			        if (pstats.profile.name ~= value.profile.name) then
			            scores = scores .. "Details" .. "," .. "" .. "," .. value.profile.name .. "," .. pstats.profile.name .. "," .. "" .. "," .. "" .. "," .. (value.data.baked.hitByName[pstats.nameId] or 0)
				        if (gametype == 'Free Frag' or gametype == 'Starter Frag') then
				            scores = scores .. "," .. 0 .. "\r\n"
				        else
				            scores = scores .. "," .. (value.data.baked.killByName[pstats.nameId] or 0) .. "\r\n"
				        end
				    end
		        end
		    end
                
        end

        application.serialize(filename,header .. scores)

		for i, player in ipairs(activity.players) do

			if (player.data.baked.score >= score) then
			
				if (score ~= -1000 and oneWinner ~= nil) then
				
					game.gameMaster:UnRegisterSound(oneWinner)				
					game.gameMaster:RegisterSound({paths = {"base:audio/gamemaster/DLG_GM_GLOBAL_54.wav"}})
					oneWinner = nil
					
				end 
				
				if (not player.primary) then
					if (player.rfGunDevice) then
						if (player.rfGunDevice.classId == 9) then
							game.gameMaster:RegisterSound({paths = {"base:audio/gamemaster/DLG_GM_GLOBAL_63.wav"}, offset = offsetTime})
						elseif (game.settings.GameSettings.playernumbermod == 1) then
							if (player.rfGunDevice.classId < 23) then
								if (player.rfGunDevice.classId > 15) then
									game.gameMaster:RegisterSound({paths = {"base:audio/gamemaster/DLG_GM_GLOBAL_" ..(48 + player.rfGunDevice.classId) .. ".wav"}, offset = offsetTime})
								else
									game.gameMaster:RegisterSound({paths = {"base:audio/gamemaster/DLG_GM_GLOBAL_" ..(96 + player.rfGunDevice.classId) .. ".wav"}, offset = offsetTime})
								end
							end
						elseif (player.rfGunDevice.classId < 17) then
							game.gameMaster:RegisterSound({paths = {"base:audio/gamemaster/DLG_GM_GLOBAL_" ..(96 + player.rfGunDevice.classId) .. ".wav"}, offset = offsetTime})
						end
					end
					offsetTime = offsetTime + 1.5
					score = player.data.baked.score;
				end
			else
				break
			end

		end
	end
			
	-- pop end match / gameover ui

	UIManager.stack:Pop()	

	-- no matches anymore 
	
	activity.matches = nil

	-- can leave ...

    self.timer = quartz.system.time.gettimemicroseconds()
	for _, player in ipairs(activity.players) do
		if (player.rfGunDevice) then player.rfGunDevice.acknowledge = false
		end
	end
	self.isReady = false
	--engine.libraries.usb.proxy:Unlock()
	
	-- respond to proxy message

	engine.libraries.usb.proxy._DispatchMessage:Add(self, UTActivity.State.FinalRankings.OnDispatchMessage)	
	
end

-- End -----------------------------------------------------------------------

function UTActivity.State.FinalRankings:End()

	game.gameMaster:End()	

	UIMenuManager.stack:Pop() 


    if (engine.libraries.usb.proxy) then

	-- no longer respond to proxy message

		engine.libraries.usb.proxy._DispatchMessage:Remove(self, UTActivity.State.FinalRankings.OnDispatchMessage)
			
	end

end

-- OnDispatchMessage ---------------------------------------------------------

function UTActivity.State.FinalRankings:OnDispatchMessage(device, addressee, command, arg)

	-- acknowledge answers 

	if (0x94 == command) then
		if (device and not device.acknowledge) then device.acknowledge = true
		end
	end

end

-- Update --------------------------------------------------------------------

function UTActivity.State.FinalRankings:Update()

	local elapsedTime = quartz.system.time.gettimemicroseconds() - (self.time or quartz.system.time.gettimemicroseconds())
	self.time = quartz.system.time.gettimemicroseconds()
	
	self.msgTimer = (self.msgTimer or 0) + elapsedTime
	if (not self.isReady and self.msgTimer > 250000) then

		-- gameover msg

		self.msgTimer = 0
		self.isReady = true
		for _, player in ipairs(activity.players) do

			if (player.rfGunDevice and not player.rfGunDevice.acknowledge) then

				local msg = { 0x06, player.rfGunDevice.radioProtocolId, 0x94, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 }
				quartz.system.usb.sendmessage(engine.libraries.usb.proxy.handle, msg)
				self.isReady = false

			end

		end

	end

end