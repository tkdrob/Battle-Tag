
--[[--------------------------------------------------------------------------
--
-- File:            UTGame.State.Session.lua
--                  Copyright (c) Ubisoft Entertainment. All rights reserved.
--
-- Project:         Ubitoys.Tag
-- Date:            July 27, 2010
--
------------------------------------------------------------------------------
--
-- Description:     Instanciates a new activity.
--                  Either launch the process upon success, or raise an error otherwise.
--
----------------------------------------------------------------------------]]

-- !! MOVE THE PATH REGISTRATION WITHIN THE CODE (CF. BEGIN),
-- !! WHEN ALL REQUIRE CALLS ARE REPLACED BY FILE LOADINGS

--quartz.system.filesystem.registerpath("game:../packages/wip/data/")
-- quartz.system.filesystem.registerpath("game:../packages/FreeForall/data/")
-- quartz.system.filesystem.registerpath("game:../packages/TeamFrag/data/")

--[[ Dependencies ----------------------------------------------------------]]

-- ?? QUELLE CONVENTION DE NOMAGE POUR LES ACTIVIT�S,
-- ?? ON N'UTILISE PAS DE UNDERSCORE NULLE PART AILLEURS

--require "UAWip"
-- require "UAFreeForAll"
-- require "UATeamFrag"

--[[ Class -----------------------------------------------------------------]]

UTGame.State.Session = UTClass(UTState)

-- __ctor --------------------------------------------------------------------

function UTGame.State.Session:__ctor (game, ...)

    assert(game)

end

-- Begin ---------------------------------------------------------------------

function UTGame.State.Session:Begin(arg)

    print("UTGame.State.Session:Begin()")

    assert(arg and arg[1] and type(arg[1]) == "table")

    -- retrieve the nfo descriptor,
    -- it is loaded by the UTGame.State.Selector's UTGame.UI.Selector
    self.nfo = arg[1]

if not (GEAR_CFG_COMPILE == GEAR_COMPILE_RETAIL) then
    for i,j in pairs(self.nfo) do print("nfo:", i, j) end -- debug
end

    assert(self.nfo.__directory)
    assert(self.nfo.class)

    -- load files,

    local directory = "game:../packages/" .. self.nfo.__directory .. "/data/"
    quartz.system.filesystem.registerpath(directory)
    
    directoryselected = directory

    require(self.nfo.class)

    -- instanciate new activity

    local class = rawget(_G, self.nfo.class)
    assert(class)

    activity = class:New()

    if (game and game.settings and game.settings.activities and game.settings.activities[activity.name]) then

        for key, value in pairs(game.settings.activities[activity.name]) do

			activity.settings[key] = value

			if (game.settings.addons.medkitPack == 0 and key == "numberOfBase" and value > 2) then
				activity.settings[key] = 2
			end
			if (game.settings.addons.customPack == 0 and key == "numberOfBase" and value > 4) then
				activity.settings[key] = 4
			end
			if (game.settings.addons.medkitPack == 0 and key == "medkit" and value > 0) then
				activity.settings[key] = 0
			end

        end
        
        if (game.settings.advactivities and game.settings.advactivities[activity.name]) then
        	for key, value in pairs(game.settings.advactivities[activity.name]) do

				activity.advancedsettings[key] = value

        	end
        	
        end

    end  


    assert(activity)

    if (activity) then

        activity.nfo = self.nfo

        -- optional forward screen,
        -- skips title after loading

        if (arg[2] == "playersmanagement") then activity.forward = "playersmanagement"
            print("FORWARD")
        elseif (arg[2] == "settings") then activity.forward2 = "settings"
            print("FORWARD")
        elseif (arg[2] == "advertised") then activity.advertised = true
            print("ADVERTISED")
        end

        -- register new process to game's listof<processes>

        table.insert(game.processes, activity)

    else
    end

    UIManager.stack:Pusha()
    UIMenuManager.stack:Pusha()

end

-- End -----------------------------------------------------------------------

function UTGame.State.Session:End(abort)

    print("UTGame.State.Session:End()", abort and "abort")

    if (abort) then return
    end

    UIMenuManager.stack:Popa()
    UIManager.stack:Popa()

    if (activity) then

        -- remove process from game's listof<processes>

        local removed = nil

        for index, __activity in pairs(game.processes) do
            if (__activity == activity) then
                removed = table.remove(game.processes, index)
            end
        end

        assert(removed)

        -- release all resources

        local directory = "game:../packages/" .. self.nfo.__directory .. "/data/"
        quartz.system.filesystem.unregisterpath(directory)

		if (game.gameMaster.inGame) then game.gameMaster:End()
        end
        game.gameMaster.watch = {}

        -- delete the activity, reset the nfo table
        
        activity = activity:Delete()
        self.nfo = nil

    end

    self.nfo = nil

end
