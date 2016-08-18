
--[[--------------------------------------------------------------------------
--
-- File:            UTActivity.State.BeginMatch.lua
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

require "UTActivity.Ui.BeginMatch"

--[[ Class -----------------------------------------------------------------]]

UTActivity.State.BeginMatch = UTClass(UTState)

-- __ctor --------------------------------------------------------------------

function UTActivity.State.BeginMatch:__ctor(activity, ...)

    assert(activity)

end

-- Begin ---------------------------------------------------------------------

function UTActivity.State.BeginMatch:Begin()

	--engine.libraries.usb.updateFrameRate = 10

	self.ui = UTActivity.Ui.BeginMatch:New()
	UIManager.stack:Push(self.ui)

	game.gameMaster:Begin()
	game.gameMaster:RegisterSound({ paths = {"base:audio/gamemaster/DLG_GM_GLOBAL_01.wav", "base:audio/gamemaster/DLG_GM_GLOBAL_02.wav"}, probas = {0.9, 0.1} })

    for i = 1, self.ui.countdownDuration do

		if (13 - i >= 10) then
			game.gameMaster:RegisterSound({ paths = {"base:audio/gamemaster/DLG_GM_GLOBAL_" ..  13 - i .. ".wav"}, offset = 0.8 + (self.ui.countdownDuration - i), })
		else
			game.gameMaster:RegisterSound({ paths = {"base:audio/gamemaster/DLG_GM_GLOBAL_0" ..  13 - i .. ".wav"}, offset = 0.8 + (self.ui.countdownDuration - i), })
		end

    end

    -- tracking

if (REG_TRACKING) then

    if (activity.matches and activity.matches.startup) then

        activity.matches.startup = false
        local delegate = engine.libraries.tracking.delegates["FPSCLIENT_START"]
        if (delegate) then
            delegate()
        end
    end

end

end

-- End -----------------------------------------------------------------------

function UTActivity.State.BeginMatch:End()

	game.gameMaster:End()
	
end

-- Update --------------------------------------------------------------------

function UTActivity.State.BeginMatch:Update()
end
