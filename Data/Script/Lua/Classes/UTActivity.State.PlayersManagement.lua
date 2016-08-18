
--[[--------------------------------------------------------------------------
--
-- File:            UTActivity.State.PlayersManagement.lua
--                  Copyright (c) Ubisoft Entertainment. All rights reserved.
--
-- Project:         Ubitoys.Tag
-- Date:            July 26, 2010
--
------------------------------------------------------------------------------
--
-- Description:     ...
--
----------------------------------------------------------------------------]]

--[[ Dependencies ----------------------------------------------------------]]

require "UTTeam"
require "UTPlayer"

-- interfaces

require "UTActivity.Ui.PlayersManagement"

--[[ Class -----------------------------------------------------------------]]

UTActivity.State.PlayersManagement = UTClass(UTState)

-- default

UTActivity.State.PlayersManagement.uiClass = UTActivity.Ui.PlayersManagement

-- __ctor --------------------------------------------------------------------

function UTActivity.State.PlayersManagement:__ctor(activity, ...)

    assert(activity)

    -- events

    self._PlayerAdded = UTEvent:New()
    self._PlayerRemoved = UTEvent:New()

end

-- Begin ---------------------------------------------------------------------

function UTActivity.State.PlayersManagement:Begin()

    -- unlock the usb proxy so as to accept all pending connection requests,
    -- register for the device added event

    assert(engine.libraries.usb)
    assert(engine.libraries.usb.proxy)

    engine.libraries.usb.proxy._DeviceAdded:Add(self, UTActivity.State.PlayersManagement.OnDeviceAdded)
    engine.libraries.usb.proxy._DeviceRemoved:Add(self, UTActivity.State.PlayersManagement.OnDeviceRemoved)
    engine.libraries.usb.proxy:Unlock()

    -- decrease the timings on the device pinger,
    -- so that we can detect device deconnections a little bit faster

    assert(engine.libraries.usb.proxy.processes.devicePinger)
    engine.libraries.usb.proxy.processes.devicePinger:Reset(2000000, 4000000, 500000)

    -- reset the list of matches,
    -- when we get back to the players management we are going to go through the match making right after ...
    
    activity.matches = nil
    
    -- reset all entities lists

	activity.players = {}
    activity.teams = {}

    local numberOfTeams = (type(activity.settings.numberOfTeams) == "number") and activity.settings.numberOfTeams or 0

    if (0 < numberOfTeams) then

        for index = 1, activity.settings.numberOfTeams do

            local team = UTTeam:New()

            -- setup team

            team.index = index
            team.profile = UTTeam.profiles[index]

            -- register team

            table.insert(activity.teams, team)

        end
    end

    -- warning: the ui must be pushed first,
    -- the ui is listening for incoming players

    UIManager.stack:Pusha()
    UIMenuManager.stack:Pusha()

	self.ui = nil
    if (self.uiClass) then
        self.ui = self.uiClass:New()
        UIMenuManager.stack:Push(self.ui)
    end

    -- some guns may already have been registered (previous games),
	-- check all connected devices and add players

	if (engine.libraries.usb.proxy.devices.byClass[0x02000020]) then

		-- create player with old profile ...

		for i, device in pairs(engine.libraries.usb.proxy.devices.byClass[0x02000020]) do

			local team = nil
			if (activity.teamBackup and activity.teamBackup[device]) then
				team = activity.teams[activity.teamBackup[device]]
			end 
			self:CreatePlayer(device, device.playerProfile, team)
			if (device.owner) then
			    device.owner._ProfileUpdated:Invoke(device.owner)
			end
			device.teamdefault = true
		end

		-- rearrange ui's player slot grid ?



		-- need to check number of player ...

        --if (self.ui.CheckNumberOfPlayers) then
		--    self.ui:CheckNumberOfPlayers()
		--end
		
	end

end

-- ChangeTeam --------------------------------------------------------

function UTActivity.State.PlayersManagement:ChangeTeam(player, teamIndex)

    assert(player:IsKindOf(UTPlayer))

	-- next team

	local newTeamIndex = teamIndex or (player.team.index + 1)
	
	if (newTeamIndex > #activity.teams) then
		newTeamIndex = 1
	end

	-- remove the player from his former team

	if (player.team) then

		for i = 1, #player.team.players do

			if (player == player.team.players[i]) then

				--self._PlayerRemoved:Invoke(player)
				table.remove(player.team.players, i)
				player.team = nil
				break

			end
		end
	end

    -- add the player to his new team

	player.team = activity.teams[newTeamIndex]
	table.insert(player.team.players, player)

	-- rearrange player slot grid

	self.ui.slotGrid:Rearrange()

	--if (self.ui.CheckNumberOfPlayers) then
	--	self.ui:CheckNumberOfPlayers()
	--end

end

-- CreatePlayer --------------------------------------------------------------

function UTActivity.State.PlayersManagement:CreatePlayer(device, profile, team)

	if (#activity.players < activity.maxNumberOfPlayer) then

		local player = UTPlayer:New()

		-- setup player

		if (device) then

			local playerWithGun = 0
			table.foreachi(activity.players, function(index, player)
				playerWithGun = playerWithGun + (player.rfGunDevice and 1 or 0)
			end )

			assert(playerWithGun < activity.maxNumberOfPlayer, "Too many guns connected : ")

			-- add a new profile
	
			if (profile) then
				player.profile = profile
			end

		else

			-- default profile

			player.profile.name = UTPlayer.profiles.guest.name
			player.profile.icon = UTPlayer.profiles.guest.icon
			player.profile.team = UTPlayer.profiles.guest.team

		end
		
		if (activity.advancedsettings.classes) then
			player.class = 1
		end

		-- the game has teams !

		if (0 < #activity.teams) then

			-- !! PREFER: UTTEAM:ADDPLAYER() METHOD, OR UTPLAYER:SETTEAM() METHOD + ALL DEPENDENT EVENTS ...
			-- ?? WHAT IS THE TEAM INSERTION POLICY

			-- insert into team

			local team = team or self:LookupTeam()

			-- team is nil if there is no slot available
			if (team) then
				assert(team:IsKindOf(UTTeam))
			else
				print("All teams are full, can' add player")
				return
			end

			table.insert(team.players, player)
			player.team = team

		end

		if (device) then

			assert(device:IsKindOf(ULUsbDevice))

			-- !! BIND GUN DEVICE TO PLAYER
			-- !! CHECK THIS IN PLAYER SETUP TO REDISTRIBUTE GUN DEVICE (CATEGORY #1)

			player:BindDevice(device)

		end

		-- register player

		table.insert(activity.players, player)
		self._PlayerAdded:Invoke(player)

	end
	
end

-- DeletePlayer --------------------------------------------------------

function UTActivity.State.PlayersManagement:DeletePlayer(player)

    assert(player and player:IsKindOf(UTPlayer), "Error in PlayersManagement:DeletePlayer() : not a player")

    assert(activity.players)
    assert(activity.teams)

    -- remove the player from his former team

    if (player.team) then

        for i = 1, #player.team.players do

            if (player == player.team.players[i]) then
                table.remove(player.team.players, i) break
            end
        end

        player.team = nil
    end

    -- remove the player from the game

    for i = 1, #activity.players do

        if (player == activity.players[i]) then

            table.remove(activity.players, i)
            break

        end
    end

    -- invoke delegates first,
    -- they might need a valid player

	self._PlayerRemoved:Invoke(player)

    player:BindDevice()
    player:Delete()

end

-- End -----------------------------------------------------------------------

function UTActivity.State.PlayersManagement:End()

    UIManager.stack:Popa()
    UIMenuManager.stack:Popa()

    -- lock the usb proxy so as to refuse any further connection requests,
    -- unregister for the device added event

    if (engine.libraries.usb.proxy) then

        --if (game.settings.GameSettings.unregister == 1) then
        	engine.libraries.usb.proxy:Lock()
        --end
        engine.libraries.usb.proxy._DeviceAdded:Remove(self, UTActivity.State.PlayersManagement.OnDeviceAdded)
        engine.libraries.usb.proxy._DeviceRemoved:Remove(self, UTActivity.State.PlayersManagement.OnDeviceRemoved)

        -- reset the timings on the device pinger

        assert(engine.libraries.usb.proxy.processes.devicePinger)
        --engine.libraries.usb.proxy.processes.devicePinger:Reset()

    end
    
    MultiColumn = game.settings.UiSettings.aspectratio == 2 and #activity.players > 16 and #activity.teams > 1 and #activity.teams < 5
    activity:SaveTeamInformation()

end

-- LookupTeam ----------------------------------------------------------------

function UTActivity.State.PlayersManagement:LookupTeam()

	-- get smallest team 

	local selectedTeam = nil
	local number = nil
	for _, team in ipairs(activity.teams) do

		if (not number or #team.players < number) then

			number = #team.players
			selectedTeam = team

		end

	end
	return selectedTeam

end

-- OnDeviceAdded -------------------------------------------------------------

function UTActivity.State.PlayersManagement:OnDeviceAdded(device)

	-- create a player 

    self:CreatePlayer(device)

	-- updating player 

	if (device.owner) then device.owner:UpdateProfile()
	end
	
	uploadbytecode = true

end

-- OnDeviceRemoved -----------------------------------------------------------

function UTActivity.State.PlayersManagement:OnDeviceRemoved(device)

    -- lookup the player with the matching device,
    -- remove the player from the list

    if (device) then
        for _, player in pairs(activity.players) do
            if (player.rfGunDevice == device) then
				self:DeletePlayer(player)
			end
        end

    end

    print("OnDeviceRemoved")

end