
--[[--------------------------------------------------------------------------
--
-- File:            UALiquidator.Ui.RoundLoop.lua
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

UALiquidator.Ui = UALiquidator.Ui or {}
UALiquidator.Ui.RoundLoop = UTClass(UIMenuPage)

-- default

	UALiquidator.Ui.RoundLoop.profiles = UALiquidator.Ui.RoundLoop.profiles or {

    [1] = { icon = "base:texture/ui/Leaderboard_Survivor.tga", name = l"oth072", teamColor = "red", color = { 0.85, 0.15, 0.04 }, 
		details = "base:texture/ui/Detail_LineRedTeam.tga", detailsHeader = "base:texture/ui/Detail_HeaderRed.tga" },
    [2] = { icon = "base:texture/ui/Leaderboard_Liquidator.tga", name = l"oth073", teamColor = "blue", color = { 0.05, 0.53, 0.84 }, 
		details = "base:texture/ui/Detail_LineBlueTeam.tga", detailsHeader = "base:texture/ui/Detail_HeaderBlue.tga" },
    [3] = { icon = "base:texture/ui/Leaderboard_Liquidator.tga", name = l"oth074", teamColor = "blue", color = { 0.05, 0.53, 0.84 }, 
		details = "base:texture/ui/Detail_LineBlueTeam.tga", detailsHeader = "base:texture/ui/Detail_HeaderBlue.tga" },

	}

-- __ctor -------------------------------------------------------------------

function UALiquidator.Ui.RoundLoop:__ctor(...)

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
    -- create a team for survivors
    ------------------------------------------------

	activity.match.challengers = {}

	local liquidators = UTTeam:New()
	liquidators.index = 2
    liquidators.profile = self.profiles[2]
    liquidators.data.heap.score = 1
	table.insert(activity.match.challengers, liquidators)

	local survivors = UTTeam:New()
	survivors.index = 1
    survivors.profile = self.profiles[1]
    survivors.data.heap.score = 0
    table.insert(activity.match.challengers, survivors)
	
	for _, player in ipairs(activity.players) do

		if (player.liquidator) then 
			table.insert(liquidators.players, player)	
			player.team = liquidators
		else
			table.insert(survivors.players, player)
			player.team = survivors
		end

	end	
	activity.teams = activity.match.challengers
	if (#liquidators.players > 1) then
		liquidators.profile = self.profiles[3]
	end

    ------------------------------------------------
    -- LEADERBOARD LIQUIDATORS
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

function UALiquidator.Ui.RoundLoop:__dtor()    
end

-- Update -------------------------------------------------------------------

function UALiquidator.Ui.RoundLoop:Update()
end