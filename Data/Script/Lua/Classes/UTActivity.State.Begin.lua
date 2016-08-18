
--[[--------------------------------------------------------------------------
--
-- File:            UTActivity.State.Begin.lua
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

--[[ Class -----------------------------------------------------------------]]

UTActivity.State.Begin = UTClass(UTState)

-- __ctor --------------------------------------------------------------------

function UTActivity.State.Begin:__ctor(activity, ...)

    assert(activity)

end

-- Begin ---------------------------------------------------------------------

function UTActivity.State.Begin:Begin()

    -- ?? TO BE DEFINED: HOW DO WE LOAD ALL ACTIVITY'S DATA
    -- ?? HOW DO WE RELEASE SCRIPTS & RESOURCES WHEN THE ACTIVITY GETS DELETED/ DISCARDED
    -- ?? ALL 'REQUIRE' DEPENDENCIES MUST BE ERASED !!

end

-- End -----------------------------------------------------------------------

function UTActivity.State.Begin:End()
end

-- Update --------------------------------------------------------------------

function UTActivity.State.Begin:Update()

    self:PostStateChange("loading", (activity.forward or activity.forward2) or "title")

end
