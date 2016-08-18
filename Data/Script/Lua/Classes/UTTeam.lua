
--[[--------------------------------------------------------------------------
--
-- File:            UTTeam.lua
--                  Copyright (c) Ubisoft Entertainment. All rights reserved.
--
-- Project:         Ubitoys.Tag
-- Date:            August 2, 2010
--
------------------------------------------------------------------------------
--
-- Description:     Generic team, as a list of players (UTPlayer).
--
----------------------------------------------------------------------------]]

--[[ Dependencies ----------------------------------------------------------]]

require "UTEntity"

--[[ Class -----------------------------------------------------------------]]

UTClass.UTTeam(UTEntity)

-- default

UTTeam.profiles = nil

-- __ctor --------------------------------------------------------------------

function UTTeam:__ctor(...)

	UTTeam.profiles = UTTeam.profiles or {

    [1] = { icon = "base:texture/ui/leaderboard_redteam.tga", name = l"oth033", teamColor = "red", color = { 0.85, 0.15, 0.04 }, 
		details = "base:texture/ui/Detail_LineRedTeam.tga", detailsHeader = "base:texture/ui/Detail_HeaderRed.tga" },
    [2] = { icon = "base:texture/ui/leaderboard_blueteam.tga", name = l"oth034", teamColor = "blue", color = { 0.05, 0.53, 0.84 }, 
		details = "base:texture/ui/Detail_LineBlueTeam.tga", detailsHeader = "base:texture/ui/Detail_HeaderBlue.tga" },
    [3] = { icon = "base:texture/ui/leaderboard_yellowteam.tga", name = l"oth035", teamColor = "yellow", color = { 0.95, 0.72, 0.00 }, 
		details = "base:texture/ui/Detail_LineYellowTeam.tga", detailsHeader = "base:texture/ui/Detail_HeaderYellow.tga" },
    [4] = { icon = "base:texture/ui/leaderboard_greenteam.tga", name = l"oth036", teamColor = "green", color = { 0.05, 0.64, 0.08 }, 
		details = "base:texture/ui/Detail_LineGreenTeam.tga", detailsHeader = "base:texture/ui/Detail_HeaderGreen.tga" },
    [5] = { icon = "base:texture/ui/leaderboard_silverteam.tga", name = l"oth092", teamColor = "silver", color = { 0.75, 0.75, 0.75 }, 
		details = "base:texture/ui/Detail_LineSilverTeam.tga", detailsHeader = "base:texture/ui/Detail_HeaderSilver.tga" },
    [6] = { icon = "base:texture/ui/leaderboard_purpleteam.tga", name = l"oth093", teamColor = "purple", color = { 0.50, 0.00, 0.50 }, 
		details = "base:texture/ui/Detail_LinePurpleTeam.tga", detailsHeader = "base:texture/ui/Detail_HeaderPurple.tga" },
    
    default = { icon = "base:texture/ui/leaderboard_redteam.tga", name = "UTTeam", teamColor = "red", color = { 0.85, 0.15, 0.04 },
		details = "base:texture/ui/Detail_LineRedTeam.tga", detailsHeader = "base:texture/ui/Detail_HeaderRed.tga" },
	}
    -- profile

    self.profile = UTTeam.profiles.default

    -- listof players within the team

    self.players = {}

    UTTeam.profilesbak = UTTeam.profiles

end

-- __dtor --------------------------------------------------------------------

function UTTeam:__dtor()
end