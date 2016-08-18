
--[[--------------------------------------------------------------------------
--
-- File:            UIOption.RadioButtonMedium.lua
--                  Copyright (c) Ubisoft Entertainment. All rights reserved.
--
-- Project:         Ubitoys.Tag
-- Date:            August 3, 2010
--
------------------------------------------------------------------------------
--
-- Description:     ...
--
----------------------------------------------------------------------------]]

--[[ Dependencies ----------------------------------------------------------]]

require "Ui/UIOption.RadioButton"

--[[ Class -----------------------------------------------------------------]]

UIOption.RadioButtonMedium = UTClass(UIOption.RadioButton)

-- default

UIOption.RadioButtonMedium.states = {

    [ST_DISABLED] = { texture = "base:texture/ui/components/uiradiobutton_large_off.tga" },
    [ST_DISABLED + ST_FOCUSED] = { texture = "base:texture/ui/components/uiradiobutton_large_off.tga" },

    [ST_ENABLED] = { texture = "base:texture/ui/components/uiradiobutton_large_off.tga" },
    [ST_ENABLED + ST_FOCUSED] = { texture = "base:texture/ui/components/uiradiobutton_large_on.tga" },
    [ST_ENABLED + ST_CONTROLED] = { texture = "base:texture/ui/components/uiradiobutton_large_on.tga" },
    [ST_ENABLED + ST_CLICKED] = { texture = "base:texture/ui/components/uiradiobutton_large_off.tga" },
    [ST_ENABLED + ST_FOCUSED + ST_CLICKED] = { texture = "base:texture/ui/components/uiradiobutton_large_on.tga" },
    [ST_ENABLED + ST_CONTROLED + ST_CLICKED] = { texture = "base:texture/ui/components/uiradiobutton_large_on.tga" },

}

UIOption.RadioButtonMedium.rectangle = { 0, 0, 50, 24 }
UIOption.RadioButtonMedium.text = "rbtn"

UIOption.RadioButton.buttonDisplayModes["medium"] = UIOption.RadioButtonMedium