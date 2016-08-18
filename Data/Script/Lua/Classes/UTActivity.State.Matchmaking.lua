
--[[--------------------------------------------------------------------------
--
-- File:            UTActivity.State.Matchmaking.lua
--                  Copyright (c) Ubisoft Entertainment. All rights reserved.
--
-- Project:         Ubitoys.Tag
-- Date:            July 27, 2010
--
------------------------------------------------------------------------------
--
-- Description:     ...
--
----------------------------------------------------------------------------]]

--[[ Dependencies ----------------------------------------------------------]]

require "UTActivity.Ui.Matchmaking"

--[[ Class -----------------------------------------------------------------]]

UTActivity.State.Matchmaking = UTClass(UTState)

-- __ctor --------------------------------------------------------------------

function UTActivity.State.Matchmaking:__ctor(activity, ...)

    assert(activity)

end

-- Begin ---------------------------------------------------------------------

function UTActivity.State.Matchmaking:Begin()

    -- ?? WHAT HAPPENS WHEN GUNS GET DISCONNECTED
    -- ?? DO WE DISCARD INCOMPATIBLE/ CORRUPTED MATCHES

	-- get the next match from the list of matches,

	-- ?? GET THE MATCH BE PREPARED ? OR WAIT FOR BEGINMATCH

	print("nb match left .... ")
	if (activity.matches) then
		print(#activity.matches)
	end

	activity.match = self:Next()
	assert(activity.match)

    print("match", activity.match, activity.match.players, #activity.match.players)

    -- ?? DISPLAY CHAMPIONSHIP PROGRESS,
    -- ?? ELSE SKIP DIRECTLY TO PLAYERS SETUP

    UIMenuManager.stack:Pusha()

    --UIMenuManager.stack:Push(UTActivity.Ui.Matchmaking)
    activity:PostStateChange("playerssetup")

end

-- End -----------------------------------------------------------------------

function UTActivity.State.Matchmaking:End()

	UIMenuManager.stack:Popa() 

end

-- Fill ----------------------------------------------------------------------

function UTActivity.State.Matchmaking:Fill()

	if (not activity.matches) then

        assert(0 < #activity.players)
        assert((0 <= #activity.teams) and (#activity.teams <= 6))

		--- init challenger final data : for team or players if no team

		if (#activity.teams > 0) then
			
			for i, challenger in ipairs(activity.teams) do
				activity:InitEntityBakedData(challenger, i)
			end
		
		else
		
			for i, challenger in ipairs(activity.players) do
				activity:InitEntityBakedData(challenger, i)
			end

		end

		-- create a table containing all matches,

		activity.matches = {}
		if (activity.category == UTActivity.categories.closed) then

			-- closed game : 1 gun/harness per player and 1 match 

			local match = { challengers = {}, players = {}}

			if (0 < #activity.teams) then

				for i, team in ipairs(activity.teams) do

					table.insert(match.challengers, team)
					for j, player in ipairs(team.players) do
						table.insert(match.players, player)
					end

				end

			else

				for i, player in ipairs(activity.players) do
					table.insert(match.challengers, player)
					table.insert(match.players, player)
				end

			end

			table.insert(activity.matches, match)

		elseif (activity.category == UTActivity.categories.single) then

			-- single game : no harness 1 player per match 

			for i, player in ipairs(activity.players) do

				local match = { challengers = {}, players = {}}

				table.insert(match.challengers, player)
				table.insert(match.players, player)

				table.insert(activity.matches, match)

			end

		elseif (activity.category == UTActivity.categories.open) then

			-- open game : harness and numberOfPlayerPerGame per game ... 

			for i, player in ipairs(activity.players) do

				for j = (i + 1), #activity.players do

					local match = { challengers = {}, players = {}}

					table.insert(match.challengers, player)
					table.insert(match.players, player)

					table.insert(match.challengers, activity.players[j])
					table.insert(match.players, activity.players[j])

					table.insert(activity.matches, match)

				end

			end

		end

		-- shuffle all matches

		if (1 < #activity.matches) then

			function sortMatches(m1,m2)

				local val1 = 0
				for _, challenger  in ipairs(m1.challengers) do
					val1 = val1 + challenger.value
				end
				local val2 = 0
				for _, challenger  in ipairs(m2.challengers) do
					val2 = val2 + challenger.value
				end

				if (val1 < val2) then
					for _, challenger  in ipairs(m1.challengers) do
						challenger.value = challenger.value + 2
					end				
					return true
				else
					for _, challenger  in ipairs(m2.challengers) do
						challenger.value = challenger.value + 2
					end								
				end
			end

			for _, match  in ipairs(activity.matches) do
				for _, challenger  in ipairs(match.challengers) do
					challenger.value = 0
				end
			end
			table.sort(activity.matches, sortMatches)

			--[[
			function shortMatches(m1,m2)
				if m1.shuffle > m2.shuffle then
					return true
				end
			end

			for _, match  in ipairs(activity.matches) do
				match.shuffle = math.random(1, 100)
			end
			table.sort(activity.matches, shortMatches)
			--]]

		end
		
	end

	print("MATCH CREATED ---------------------")

end

-- Next ----------------------------------------------------------------------

function UTActivity.State.Matchmaking:Next()

    -- the matchmaker is responsible for the management of one or many matches,
    -- if we don't have a list of matches yet, then build it

    if (not activity.matches or (0 == #activity.matches)) then

        self:Fill()

        -- the startup flag indicates the game is just starting
        -- this is used in state "beginmatch" for tracking

        activity.matches.startup = true

    end

    -- ... otherwise just pop one match from the list

    return table.remove(activity.matches, 1)

end
