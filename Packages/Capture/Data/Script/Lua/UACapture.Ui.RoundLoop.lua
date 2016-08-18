
--[[--------------------------------------------------------------------------
--
-- File:            UACapture.Ui.RoundLoop.lua
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

--require "UTActivity.Ui.RoundLoop"
require "Ui/UIAFP"
--require "Ui/UILeaderboard"
require "UACapture.UILeaderboardItem"

--[[ Class -----------------------------------------------------------------]]

UACapture.Ui = UACapture.Ui or {}
UACapture.Ui.RoundLoop = UTClass(UIMenuPage)

-- default

	UACapture.Ui.RoundLoop.profiles = UACapture.Ui.RoundLoop.profiles or {

    [1] = { icon = "base:texture/ui/leaderboard_captureredteam.tga", name = l"oth033", teamColor = "red", color = { 0.85, 0.15, 0.04 }, 
		details = "base:texture/ui/Detail_LineRedTeam.tga", detailsHeader = "base:texture/ui/Detail_HeaderRed.tga" },
    [2] = { icon = "base:texture/ui/leaderboard_captureblueteam.tga", name = l"oth034", teamColor = "blue", color = { 0.05, 0.53, 0.84 }, 
		details = "base:texture/ui/Detail_LineBlueTeam.tga", detailsHeader = "base:texture/ui/Detail_HeaderBlue.tga" },

	}

-- __ctor -------------------------------------------------------------------

function UACapture.Ui.RoundLoop:__ctor(...)

	-- label

    self.uiLabel = self:AddComponent(UILabel:New(), "uiLabel")
    self.uiLabel.fontColor = UIComponent.colors.black
    self.uiLabel.rectangle = { 300, 0, 700, 80 }

    ------------------------------------------------
    -- AFP TEST
    ------------------------------------------------

    activity.uiAFP = self:AddComponent(UIAFP:New(), "uiAFP")
    activity.uiAFP:MoveTo(20, 40)

    local theAFP = self.uiAFP
    local count = 0

	-- change team icon

	activity.match.challengers[1].profile = self.profiles[1]
	activity.match.challengers[2].profile = self.profiles[2]

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

    self.uiLeaderboard.uiItem = UACapture.UILeaderboardItem
    self.uiLeaderboard:Build(activity.match.challengers, "heap")
end

-- __dtor -------------------------------------------------------------------

function UACapture.Ui.RoundLoop:__dtor()    

end

-- Update -------------------------------------------------------------------

function UACapture.Ui.RoundLoop:Update()
end

-- OnClose -------------------------------------------------------------------

function UACapture.Ui.RoundLoop:OnClose()

	if (self.uiLeaderboard) then
	
		self.uiLeaderboard:RemoveDataChangedEvents()
	
	end

end