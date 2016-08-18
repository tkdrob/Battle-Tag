
--[[--------------------------------------------------------------------------
--
-- File:            UIMenuWindow.lua
--                  Copyright (c) Ubisoft Entertainment. All rights reserved.
--
-- Project:         Ubitoys.Tag
-- Date:            July 15, 2010
--
------------------------------------------------------------------------------
--
-- Description:     ...
--
----------------------------------------------------------------------------]]

--[[ Dependencies ----------------------------------------------------------]]

require "Ui/UIButton"
require "Ui/UILabel"
require "Ui/UIPanel"
require "Ui/UIWindow"
require "Ui/UIBackgroundBanner"

--[[ Class -----------------------------------------------------------------]]

UTClass.UIMenuWindow(UIMenuPage)

-- defaults

UIMenuWindow.buttonRectangles = { 

    [1] = { 118, 618, 255, 652 },
    [2] = { 268, 618, 405, 652 },
    [3] = { 417, 618, 554, 652 },
    [4] = { 567, 618, 704, 652 },
    [5] = { 716, 618, 853, 652 },

}

UIMenuWindow.fontColor = UIComponent.colors.darkgray
UIMenuWindow.margin = { left = 20, top = 10, right = 20, bottom = 10 }

-- __ctor -------------------------------------------------------------------

function UIMenuWindow:__ctor(...)

    -- background window

    self.uiWindow = self:AddComponent(UIWindow:New(), "uiWindow")

    local marginx = 20
    local margin = 10

    self.clientRectangle = { 13 + UIMenuWindow.margin.left, 87 + UIMenuWindow.margin.top, 768 - UIMenuWindow.margin.right, 608 - 12 - UIMenuWindow.margin.bottom - 34 }

end

-- __dtor -------------------------------------------------------------------

function UIMenuWindow:__dtor()
end

-- Update --------------------------------------------------------------------

function UIMenuWindow:Update()

end
