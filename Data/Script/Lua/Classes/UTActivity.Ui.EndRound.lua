
--[[--------------------------------------------------------------------------
--
-- File:            UTActivity.Ui.RoundEnd.lua
--                  Copyright (c) Ubisoft Entertainment. All rights reserved.
--
-- Project:         Ubitoys.Tag
-- Date:            July 28, 2010
--
------------------------------------------------------------------------------
--
-- Description:     ...
--
----------------------------------------------------------------------------]]

--[[ Dependencies ----------------------------------------------------------]]

require "Ui/UIMenuPage"

--[[ Class -----------------------------------------------------------------]]

UTActivity.Ui = UTActivity.Ui or {}
UTActivity.Ui.RoundEnd = UTClass(UIMenuPage)

-- __ctor -------------------------------------------------------------------

function UTActivity.Ui.RoundEnd:__ctor(...)

	-- label

    self.uiLabel = self:AddComponent(UILabel:New(), "uiLabel")
    self.uiLabel.fontColor = UIComponent.colors.black
    self.uiLabel.rectangle = { 300, 350, 700, 380 }
    self.uiLabel.text = "" .. activity.name

    -- fake skip button to end match
    
    self.uiButton5 = self:AddComponent(UIButton:New(), "uiButton5")
    self.uiButton5.rectangle = { 410, 420, 547, 454 }
    self.uiButton5.text = "Skip to End Match"
    
    self.uiButton5.OnAction = function (self) activity:PostStateChange("endmatch") end
    
    -- fake skip button to round begin
    
    self.uiButton3 = self:AddComponent(UIButton:New(), "uiButton3")
    self.uiButton3.rectangle = { 410, 480, 547, 514 }
    self.uiButton3.text = "Skip to Begin Round"
    
    self.uiButton3.OnAction = function (self) activity:PostStateChange("roundbegin") end

end
