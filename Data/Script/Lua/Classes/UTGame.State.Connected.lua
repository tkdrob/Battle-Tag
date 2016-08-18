
--[[--------------------------------------------------------------------------
--
-- File:            UTGame.State.Connected.lua
--                  Copyright (c) Ubisoft Entertainment. All rights reserved.
--
-- Project:         Ubitoys.Tag
-- Date:            September 2, 2010
--
------------------------------------------------------------------------------
--
-- Description:     ...
--
----------------------------------------------------------------------------]]

--[[ Dependencies ----------------------------------------------------------]]

require "UTGame.Ui.Connected"

--[[ Class -----------------------------------------------------------------]]

UTGame.State.Connected = UTClass(UTState)

-- __ctor --------------------------------------------------------------------

function UTGame.State.Connected:__ctor (game, ...)

    assert(game)

end

-- Begin ---------------------------------------------------------------------

function UTGame.State.Connected:Begin()

    assert(engine.libraries.usb)
    assert(engine.libraries.usb.proxy)

    print("UTGame.State.Connected:Begin()")

    UIManager.stack:Pusha()
    UIMenuManager.stack:Pusha()

    UIMenuManager.stack:Push(UTGame.Ui.Connected)

    -- display the connection completion status,
    -- check whether the proxy's firmware revision is up to date

end

-- End -----------------------------------------------------------------------

function UTGame.State.Connected:End()

    print("UTGame.State.Connected:End()")

    UIMenuManager.stack:Popa()
    UIManager.stack:Popa()
    
    engine.libraries.usb.proxy:Unlock()

end