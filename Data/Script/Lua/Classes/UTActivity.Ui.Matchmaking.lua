
--[[--------------------------------------------------------------------------
--
-- File:            UTActivity.Ui.Matchmaking.lua
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

require "Ui/UIMenuWindow"

--[[ Class -----------------------------------------------------------------]]

UTActivity.Ui = UTActivity.Ui or {}
UTActivity.Ui.Matchmaking = UTClass(UIMenuWindow)

-- __ctor -------------------------------------------------------------------

function UTActivity.Ui.Matchmaking:__ctor(...)

    assert(activity)

	-- window settings

	self.uiWindow.title = ""
	self.uiWindow.text = ""

    -- buttons,

	-- uiButton5: accept 

    self.uiButton5 = self:AddComponent(UIButton:New(), "uiButton5")
    self.uiButton5.rectangle = UIMenuWindow.buttonRectangles[5]
	self.uiButton5.text = ""

	self.uiButton5.OnAction = function (self) activity:PostStateChange("playerssetup") end

end
