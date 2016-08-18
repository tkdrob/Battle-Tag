
--[[--------------------------------------------------------------------------
--
-- File:            UTGame.State.Ignition.lua
--                  Copyright (c) Ubisoft Entertainment. All rights reserved.
--
-- Project:         Ubitoys.Tag
-- Date:            June 17, 2010
--
------------------------------------------------------------------------------
--
-- Description:     ...
--
----------------------------------------------------------------------------]]

--[[ Dependencies ----------------------------------------------------------]]

--[[ Class -----------------------------------------------------------------]]

UTGame.State.Ignition = UTClass(UTState)

-- __ctor --------------------------------------------------------------------

function UTGame.State.Ignition:__ctor (game, ...)

    assert(game)

end

-- Begin ---------------------------------------------------------------------

function UTGame.State.Ignition:Begin()

    print("UTGame.State.Ignition:Begin()")

end

-- End -----------------------------------------------------------------------

function UTGame.State.Ignition:End()

    print("UTGame.State.Ignition:End()")

    -- load the game settings

	game:LoadSettings()

	print("game.settings.registers.firstTime", game.settings.registers.firstTime)
	REG_FIRSTTIME = REG_FIRSTTIME or game.settings.registers.firstTime

    -- game ignition complete,
    -- restart ui state machine & resume process

    game.ui:Restart()
    game.ui:Resume()

end

-- Update --------------------------------------------------------------------

function UTGame.State.Ignition:Update()

    self:PostStateChange("connection")

end
