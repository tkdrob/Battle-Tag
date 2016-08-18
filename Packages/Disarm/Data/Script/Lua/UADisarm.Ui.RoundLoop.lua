
--[[--------------------------------------------------------------------------
--
-- File:            UADisarm.Ui.RoundLoop.lua
--                  Copyright (c) Ubisoft Entertainment. All rights reserved.
--
-- Project:         Ubitoys.Tag
-- Date:            August 03, 2010
--
------------------------------------------------------------------------------
--
-- Description:     ...
--
----------------------------------------------------------------------------]]

--[[ Dependencies ----------------------------------------------------------]]

require "UTActivity.Ui.RoundLoop"
require "Ui/UIAFP"
require "Ui/UILeaderboard"

--[[ Class -----------------------------------------------------------------]]

UADisarm.Ui = UADisarm.Ui or {}
UADisarm.Ui.RoundLoop = UTClass(UIMenuPage)

-- default

	UADisarm.Ui.RoundLoop.profiles = UADisarm.Ui.RoundLoop.profiles or {

    [1] = { icon = "base:texture/ui/Leaderboard_Commando.tga", name = l"oth088", teamColor = "blue", color = { 0.85, 0.15, 0.04 }, 
		details = "base:texture/ui/Detail_LineBlueTeam.tga", detailsHeader = "base:texture/ui/Detail_HeaderBlue.tga" },
    [2] = { icon = "base:texture/ui/Leaderboard_Terrorist.tga", name = l"oth089", teamColor = "red", color = { 0.05, 0.53, 0.84 }, 
		details = "base:texture/ui/Detail_LineRedTeam.tga", detailsHeader = "base:texture/ui/Detail_HeaderRed.tga" },
    [3] = { icon = "base:texture/ui/Leaderboard_Terrorist.tga", name = l"oth090", teamColor = "red", color = { 0.05, 0.53, 0.84 }, 
		details = "base:texture/ui/Detail_LineRedTeam.tga", detailsHeader = "base:texture/ui/Detail_HeaderRed.tga" },

	}

-- __ctor -------------------------------------------------------------------

function UADisarm.Ui.RoundLoop:__ctor(...)

	-- label

    self.uiLabel = self:AddComponent(UILabel:New(), "uiLabel")
    self.uiLabel.fontColor = UIComponent.colors.black
    self.uiLabel.rectangle = { 300, 0, 700, 80 }

    ------------------------------------------------
    -- AFP TEST
    ------------------------------------------------

    activity.uiAFP = self:AddComponent(UIAFP:New(), "uiAFP")
    activity.uiAFP:MoveTo(20, 40)

    ------------------------------------------------
    -- create a team for commandos
    ------------------------------------------------

	activity.match.challengers = {}

	local terrorists = UTTeam:New()
	terrorists.index = 1
    terrorists.profile = self.profiles[2]
    terrorists.data.heap.score = 1
	table.insert(activity.match.challengers, terrorists)

	local commandos = UTTeam:New()
	commandos.index = 2
    commandos.profile = self.profiles[1]
    commandos.data.heap.score = 0
    table.insert(activity.match.challengers, commandos)
	
	for _, player in ipairs(activity.players) do

		if (player.terrorist) then 
			table.insert(terrorists.players, player)	
			player.team = terrorists
		else
			table.insert(commandos.players, player)
			player.team = commandos
		end

	end	
	activity.teams = activity.match.challengers
	if (#terrorists.players > 1) then terrorists.profile = self.profiles[3]
	end

    ------------------------------------------------
    -- LEADERBOARD TERRORISTS
    ------------------------------------------------

    self.uiLeaderboard = self:AddComponent(UILeaderboard:New(), "uiLeaderboard")
    self.uiLeaderboard:MoveTo(550, 40)

    -- key / icon / position / justification

	if (activity.scoringField) then
		for i, field in ipairs(activity.scoringField) do
			self.uiLeaderboard:RegisterField(unpack(field))
		end
	end

	self.uiLeaderboard.showRanking = false
    self.uiLeaderboard:Build(activity.match.challengers, "heap")
    
end

-- __dtor -------------------------------------------------------------------

function UADisarm.Ui.RoundLoop:__dtor()    
end

-- Update -------------------------------------------------------------------

function UADisarm.Ui.RoundLoop:Update()
end