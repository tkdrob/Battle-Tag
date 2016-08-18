
--[[--------------------------------------------------------------------------
--
-- File:            UAInfection.Ui.RoundLoop.lua
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
	require "UAInfection.UILeaderboardItem"

--[[ Class -----------------------------------------------------------------]]

UAInfection.Ui = UAInfection.Ui or {}
UAInfection.Ui.RoundLoop = UTClass(UIMenuPage)

-- __ctor -------------------------------------------------------------------

function UAInfection.Ui.RoundLoop:__ctor(...)

	-- label

    self.uiLabel = self:AddComponent(UILabel:New(), "uiLabel")
    self.uiLabel.fontColor = UIComponent.colors.black
    self.uiLabel.rectangle = { 300, 0, 700, 80 }

    ------------------------------------------------
    -- AFP
    ------------------------------------------------

    activity.uiAFP = self:AddComponent(UIAFP:New(), "uiAFP")
    activity.uiAFP:MoveTo(20, 40)

    ------------------------------------------------
    -- LEADERBOARD
    ------------------------------------------------

    self.uiLeaderboard = self:AddComponent(UILeaderboard:New(), "uiLeaderboardTest")
    self.uiLeaderboard.showSlotEmpty = true
    self.uiLeaderboard:MoveTo(550, 40)

    -- key / icon / position / justification

	if (activity.scoringField) then
		for i, field in ipairs(activity.scoringField) do
			self.uiLeaderboard:RegisterField(unpack(field))
		end
	end

    self.uiLeaderboard.uiItem = UAInfection.UILeaderboardItem
    self.uiLeaderboard:Build(activity.match.challengers, "heap")
end

-- __dtor -------------------------------------------------------------------

function UAInfection.Ui.RoundLoop:__dtor()    
end