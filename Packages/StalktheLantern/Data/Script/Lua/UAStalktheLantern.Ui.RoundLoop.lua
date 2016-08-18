
--[[--------------------------------------------------------------------------
--
-- File:            UAStalktheLantern.Ui.RoundLoop.lua
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

UAStalktheLantern.Ui = UAStalktheLantern.Ui or {}
UAStalktheLantern.Ui.RoundLoop = UTClass(UIMenuPage)

-- default

	UAStalktheLantern.Ui.RoundLoop.profiles = UAStalktheLantern.Ui.RoundLoop.profiles or {

    [1] = { icon = "base:texture/ui/Leaderboard_Stalker.tga", name = l"oth114", teamColor = "red", color = { 0.85, 0.15, 0.04 }, 
		details = "base:texture/ui/Detail_LineRedTeam.tga", detailsHeader = "base:texture/ui/Detail_HeaderRed.tga" },
    [2] = { icon = "base:texture/ui/Leaderboard_Defender.tga", name = l"oth113", teamColor = "blue", color = { 0.05, 0.53, 0.84 }, 
		details = "base:texture/ui/Detail_LineBlueTeam.tga", detailsHeader = "base:texture/ui/Detail_HeaderBlue.tga" },
    [3] = { icon = "base:texture/ui/Leaderboard_Defender.tga", name = l"oth115", teamColor = "blue", color = { 0.05, 0.53, 0.84 }, 
		details = "base:texture/ui/Detail_LineBlueTeam.tga", detailsHeader = "base:texture/ui/Detail_HeaderBlue.tga" },

	}


-- __ctor -------------------------------------------------------------------

function UAStalktheLantern.Ui.RoundLoop:__ctor(...)

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
    -- create a team for stalkers
    ------------------------------------------------

	activity.match.challengers = {}

	local defenders = UTTeam:New()
	defenders.index = 1
    defenders.profile = self.profiles[2]
    defenders.data.heap.score = 1
	table.insert(activity.match.challengers, defenders)

	local stalkers = UTTeam:New()
	stalkers.index = 2
    stalkers.profile = self.profiles[1]
    stalkers.data.heap.score = 0
    table.insert(activity.match.challengers, stalkers)
	
	for _, player in ipairs(activity.players) do

		if (player.defender) then 
			table.insert(defenders.players, player)	
			player.team = defenders
		else
			table.insert(stalkers.players, player)
			player.team = stalkers
		end

	end	
	activity.teams = activity.match.challengers
	if (#defenders.players > 1) then
		defenders.profile = self.profiles[3]
	end

    ------------------------------------------------
    -- LEADERBOARD DEFENDERS
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

function UAStalktheLantern.Ui.RoundLoop:__dtor()    
end

-- Update -------------------------------------------------------------------

function UAStalktheLantern.Ui.RoundLoop:Update()
end