
--[[--------------------------------------------------------------------------
--
-- File:            UTGame.Ui.Settings.lua
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

require "UI/UISelector"

--[[ Class -----------------------------------------------------------------]]

UTGame.Ui = UTGame.Ui or {}
UTGame.Ui.Settings = UTClass(UISelector)

require "UTGame.Ui.Settings.Sound"
require "UTGame.Ui.Settings.TboxesManagement"
require "UTGame.Ui.Settings.AddNewDevice"
require "UTGame.Ui.Settings.Credits"
require "UTGame.Ui.Settings.GameSettings"
require "UTGame.Ui.Settings.ActivitySettings"
require "UTGame.Ui.Settings.UiSettings"
require "UTGame.Ui.Settings.TestSettings"

-- __ctor --------------------------------------------------------------------

function UTGame.Ui.Settings:__ctor(...)

	-- window settings

	self.uiWindow.title = l "menu03"
	self.uiWindow.icon = "base:video/uianimatedbutton_settings.avi"
	self.uiSelector.title = l "oth011"

    -- dedicated settings on the right side,

 	self.labels = {l "sett004", l "sett001", l "sett003", l "sett014", l "sett017", l "sett025", l "sett037", l "sett006"}

	self.uiSettings = {

	    [1] = self.uiWindows:AddComponent(UTGame.Ui.Settings.AddNewDevice:New()),
	    [2] = self.uiWindows:AddComponent(UTGame.Ui.Settings.Sound:New()),
	    [3] = self.uiWindows:AddComponent(UTGame.Ui.Settings.TBoxesManagement:New()),
	    [4] = self.uiWindows:AddComponent(UTGame.Ui.Settings.GameSettings:New()),
	    [5] = self.uiWindows:AddComponent(UTGame.Ui.Settings.ActivitySettings:New()),
	    [6] = self.uiWindows:AddComponent(UTGame.Ui.Settings.UiSettings:New()),
        [7] = self.uiWindows:AddComponent(UTGame.Ui.Settings.TestSettings:New()),
	    [8] = self.uiWindows:AddComponent(UTGame.Ui.Settings.Credits:New()),

	}

	self.uiSettingsTips = {

	    [1] = l "tip075",
	    [2] = l "tip074",
	    [3] = l "tip076",
	    [4] = l "tip154",
	    [5] = l "tip176",
	    [6] = l "tip196",
        [7] = l "tip251",
	    [8] = nil,

	}

    -- contents

    self:Reserve(math.max(#self.uiSettings, 14), false)

    for index, uiSetting in ipairs(self.uiSettings) do

        print(index, uiSetting)

		uiSetting.rectangle = self.uiWindows.clientRectangle
		uiSetting.title = self.labels[index] or '-'
		uiSetting.visible = false

		local properties = { text = uiSetting.title, }
		local item = self:AddItem(properties)
		
		item.Action = function ()
            
            if (self.uiActiveSetting ~= uiSetting) then
			
				quartz.system.drawing.loadvideo("base:video/credits.avi")
				quartz.system.drawing.stopvideo()
				quartz.system.drawing.playvideo(true)
    
			    self.uiActiveSetting.visible = false			    
                self.uiActiveSetting = uiSetting
                self.uiActiveSetting.visible = true
			    
			end
		end

        item.tip = self.uiSettingsTips[index]

	end
	
    -- buttons,
    
    -- uiButton1: Menu

    self.uiButton2 = self:AddComponent(UIButton:New(), "uiButton1")
    self.uiButton2.rectangle = UIMenuWindow.buttonRectangles[1]
    self.uiButton2.text = l "but016"
	self.uiButton2.tip = l "tip007"

    self.uiButton2.OnAction = function (_self) 
    
		quartz.framework.audio.loadsound("base:audio/ui/validation.wav")
		quartz.framework.audio.loadvolume(game.settings.audio["volume:sfx"])
		quartz.framework.audio.playsound()

		game:SaveSettings()
		
		if (activity) then
			uiSettingprev = nil
			UIManager.stack:Pop()
			slideanimation = false
			activity:PostStateChange("playersmanagement")
		else
			uiSettingprev = 1
			game:PostStateChange("title")
		end

    end

	self.index = 1
	self:Scroll(0)

end

-- OnClose --------------------------------------------------------------------

function UTGame.Ui.Settings:OnClose()
	
	if (UTGame.Ui.Settings.AddNewDevice.hasPopup) then
	
		UTGame.Ui.Settings.AddNewDevice.hasPopup = false
		UIManager.stack:Pop() 
		
	end

end


-- OnOpen --------------------------------------------------------------------

function UTGame.Ui.Settings:OnOpen()

    self.index = uiSettingprev or 1
    self.uiActiveSetting = self.uiSettings[self.index]
    self.uiActiveSetting.visible = true

end