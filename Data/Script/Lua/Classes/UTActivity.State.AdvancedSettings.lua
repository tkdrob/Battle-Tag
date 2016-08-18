
--[[--------------------------------------------------------------------------
--
-- File:            UTActivity.State.AdvancedSettings.lua
--                  Copyright (c) Ubisoft Entertainment. All rights reserved.
--
-- Project:         Ubitoys.Tag
-- Date:            July 26, 2010
--
------------------------------------------------------------------------------
--
-- Description:     ...
--
----------------------------------------------------------------------------]]

--[[ Dependencies ----------------------------------------------------------]]

require "UTActivity.Ui.AdvancedSettings"

--[[ Class -----------------------------------------------------------------]]

UTActivity.State.AdvancedSettings = UTClass(UTState)

-- __ctor --------------------------------------------------------------------

function UTActivity.State.AdvancedSettings:__ctor (activity, ...)

    assert(activity)

end

-- Begin ---------------------------------------------------------------------

function UTActivity.State.AdvancedSettings:Begin()

    -- ui

    UIMenuManager.stack:Push(UTActivity.Ui.AdvancedSettings)

end

-- End -----------------------------------------------------------------------

function UTActivity.State.AdvancedSettings:End()

	UIMenuManager.stack:Pop() 

end
