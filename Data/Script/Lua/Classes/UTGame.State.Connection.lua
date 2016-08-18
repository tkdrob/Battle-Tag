
--[[--------------------------------------------------------------------------
--
-- File:            UTGame.State.Connection.lua
--                  Copyright (c) Ubisoft Entertainment. All rights reserved.
--
-- Project:         Ubitoys.Tag
-- Date:            July 20, 2010
--
------------------------------------------------------------------------------
--
-- Description:     ...
--
----------------------------------------------------------------------------]]

--[[ Dependencies ----------------------------------------------------------]]

require "UTGame.Ui.Connection"

--[[ Class -----------------------------------------------------------------]]

UTGame.State.Connection = UTClass(UTState)

-- __ctor --------------------------------------------------------------------

function UTGame.State.Connection:__ctor (game, ...)

    assert(game)

end

-- Begin ---------------------------------------------------------------------

function UTGame.State.Connection:Begin()

    assert(engine.libraries.usb)

    print("UTGame.State.Connection:Begin()")

    -- if a connection has already been established, then skip to title
    -- else wait for a new connection ...

    UIMenuManager.stack:Pusha()

    if (engine.libraries.usb.connected) then

        self:PostStateChange("connected")

    else

        self.time = quartz.system.time.gettimemicroseconds()
        UIMenuManager.stack:Push(UTGame.Ui.Connection)

    end
    
    if (REG_FIRSTTIME ~= true) then
        engine.libraries.audio:Play("base:audio/musicmenu.ogg",game.settings.audio["volume:music"])
	end

	UIManager.drawBackground = true

end

-- End -----------------------------------------------------------------------

function UTGame.State.Connection:End()

    print("UTGame.State.Connection:End()")

	if (UTGame.Ui.Connection.hasPopup == true) then
        UIManager.stack:Pop() 	
	end
	
    UIMenuManager.stack:Popa()
	
    -- register some delegate to get notified when we are about to get disconnected
	
    engine.libraries.usb._Disconnected:Add(self, UTGame.State.Connection.OnDisconnected)

    self.gmLockedOnce = false

end

-- OnDisconnected ------------------------------------------------------------

function UTGame.State.Connection:OnDisconnected()

    engine.libraries.usb._Disconnected:Remove(self, UTGame.State.Connection.OnDisconnected)
    game:PostStateChange("connection")

    -- if we were running an activity the game would be in the dedicated state (cf. "session"),
    -- upon state change the activity would be *gracefully* aborted

end

-- Update --------------------------------------------------------------------

function UTGame.State.Connection:Update()

    -- wait until connected ...

    if (engine.libraries.usb.connected and not self.gmLocked) then
        game:PostStateChange("connected")
    end

    local time = quartz.system.time.gettimemicroseconds()
    if (time - self.time > 4000000 and not self.gmLockedOnce) then
        --self.gmLocked = true
        self.gmLockedOnce = true
        game.gameMaster:Play("base:audio/gamemaster/dlg_gm_init_02.wav", function () self.gmLocked = false end)
    end

end
