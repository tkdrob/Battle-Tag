
--[[--------------------------------------------------------------------------
--
-- File:            UAHostageSituation.Ui.RoundLoop.lua
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

--[[ Class -----------------------------------------------------------------]]

UAHostageSituation.Ui = UAHostageSituation.Ui or {}
UAHostageSituation.Ui.RoundLoop = UTClass(UIMenuPage)

-- default

	UAHostageSituation.Ui.RoundLoop.profiles = UAHostageSituation.Ui.RoundLoop.profiles or {

    [1] = { icon = "base:texture/ui/leaderboard_Commando.tga", name = l"oth088", teamColor = "red", color = { 0.85, 0.15, 0.04 }, 
		details = "base:texture/ui/Detail_LineRedTeam.tga", detailsHeader = "base:texture/ui/Detail_HeaderRed.tga" },
    [2] = { icon = "base:texture/ui/leaderboard_Terrorist.tga", name = l"oth090", teamColor = "blue", color = { 0.05, 0.53, 0.84 }, 
		details = "base:texture/ui/Detail_LineBlueTeam.tga", detailsHeader = "base:texture/ui/Detail_HeaderBlue.tga" },
    [3] = { icon = "base:texture/ui/leaderboard_Terrorist.tga", name = l"oth090", teamColor = "red", color = { 0.85, 0.15, 0.04 }, 
		details = "base:texture/ui/Detail_LineRedTeam.tga", detailsHeader = "base:texture/ui/Detail_HeaderRed.tga" },
    [4] = { icon = "base:texture/ui/leaderboard_Commando.tga", name = l"oth088", teamColor = "blue", color = { 0.05, 0.53, 0.84 }, 
		details = "base:texture/ui/Detail_LineBlueTeam.tga", detailsHeader = "base:texture/ui/Detail_HeaderBlue.tga" },

	}

-- __ctor -------------------------------------------------------------------

function UAHostageSituation.Ui.RoundLoop:__ctor(...)

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

	if (activity.settings.defendingteam == 1) then
		activity.match.challengers[1].profile = self.profiles[3]
		activity.match.challengers[2].profile = self.profiles[4]
	else
		activity.match.challengers[1].profile = self.profiles[1]
		activity.match.challengers[2].profile = self.profiles[2]
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

    self.uiLeaderboard.showRanking = false
	self.uiLeaderboard:Build(activity.match.challengers, "heap")
end

-- __dtor -------------------------------------------------------------------

function UAHostageSituation.Ui.RoundLoop:__dtor()    

	-- unregister to all data heap
	--for i, challenger in ipairs(activity.match.challengers) do
--
		--challenger._DataChanged:Remove(_UTActivityTest.Ui.RoundLoop, _UTActivityTest.Ui.RoundLoop.OnDataChanged)
		--if (challenger:IsKindOf(UTTeam)) then
--
			--for j, player in ipairs(challenger.players) do
				--player._DataChanged:Remove(_UTActivityTest.Ui.RoundLoop, _UTActivityTest.Ui.RoundLoop.OnDataChanged)
			--end
		--end
	--end

end

-- Update -------------------------------------------------------------------

function UAHostageSituation.Ui.RoundLoop:Update()
end