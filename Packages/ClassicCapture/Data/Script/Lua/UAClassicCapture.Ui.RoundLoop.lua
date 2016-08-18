
--[[--------------------------------------------------------------------------
--
-- File:            UAClassicCapture.Ui.RoundLoop.lua
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

require "UTActivity.Ui.RoundLoop"
require "Ui/UIAFP"
require "Ui/UILeaderboard"
require "UAClassicCapture.UILeaderboardItem"

--[[ Class -----------------------------------------------------------------]]

UAClassicCapture.Ui = UAClassicCapture.Ui or {}
UAClassicCapture.Ui.RoundLoop = UTClass(UIMenuPage)

-- default

	UAClassicCapture.Ui.RoundLoop.profiles = UAClassicCapture.Ui.RoundLoop.profiles or {

    [1] = { icon = "base:texture/ui/leaderboard_captureredteam.tga", name = l"oth033", teamColor = "red", color = { 0.85, 0.15, 0.04 }, 
		details = "base:texture/ui/Detail_LineRedTeam.tga", detailsHeader = "base:texture/ui/Detail_HeaderRed.tga" },
    [2] = { icon = "base:texture/ui/leaderboard_captureblueteam.tga", name = l"oth034", teamColor = "blue", color = { 0.05, 0.53, 0.84 }, 
		details = "base:texture/ui/Detail_LineBlueTeam.tga", detailsHeader = "base:texture/ui/Detail_HeaderBlue.tga" },
    [3] = { icon = "base:texture/ui/leaderboard_captureyellowteam.tga", name = l"oth035", teamColor = "yellow", color = { 0.95, 0.72, 0.00 }, 
		details = "base:texture/ui/Detail_LineYellowTeam.tga", detailsHeader = "base:texture/ui/Detail_HeaderYellow.tga" },
    [4] = { icon = "base:texture/ui/leaderboard_capturegreenteam.tga", name = l"oth036", teamColor = "green", color = { 0.05, 0.64, 0.08 }, 
		details = "base:texture/ui/Detail_LineGreenTeam.tga", detailsHeader = "base:texture/ui/Detail_HeaderGreen.tga" },
    [5] = { icon = "base:texture/ui/leaderboard_capturesilverteam.tga", name = l"oth092", teamColor = "silver", color = { 0.75, 0.75, 0.75 }, 
		details = "base:texture/ui/Detail_LineSilverTeam.tga", detailsHeader = "base:texture/ui/Detail_HeaderSilver.tga" },
    [6] = { icon = "base:texture/ui/leaderboard_capturesilverteam.tga", name = l"oth093", teamColor = "purple", color = { 0.50, 0.00, 0.50 }, 
		details = "base:texture/ui/Detail_LinePurpleTeam.tga", detailsHeader = "base:texture/ui/Detail_HeaderPurple.tga" },

	}

-- __ctor -------------------------------------------------------------------

function UAClassicCapture.Ui.RoundLoop:__ctor(...)

	-- label

    self.uiLabel = self:AddComponent(UILabel:New(), "uiLabel")
    self.uiLabel.fontColor = UIComponent.colors.black
    self.uiLabel.rectangle = { 300, 0, 700, 80 }

    ------------------------------------------------
    -- AFP TEST
    ------------------------------------------------

    activity.uiAFP = self:AddComponent(UIAFP:New(), "uiAFP")
    activity.uiAFP:MoveTo(20, 40)

	-- change team icon

	for i, challenger in ipairs(activity.match.challengers) do
		--if (UILeaderboard.leader == challenger and challenger:IsKindOf(UTTeam)) then
			activity.match.challengers[i].profile = self.profiles[i]
		--end
	end

    ------------------------------------------------
    -- LEADERBOARD TEST
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

	self.uiLeaderboard:Build(activity.match.challengers, "heap")
end

function UAClassicCapture.Ui.RoundLoop:Update()
	
end
