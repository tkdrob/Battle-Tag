
--[[--------------------------------------------------------------------------
--
-- File:            UTGame.Ui.Settings.AddNewDevice.lua
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

require "Ui/UIOption"
require "Ui/UIPanel"
require "Ui/UITitledPanel"
require "Ui/UIPopupWindow"

--[[ Class -----------------------------------------------------------------]]

UTGame.Ui.Settings = UTGame.Ui.Settings or {}
UTGame.Ui.Settings.AddNewDevice = UTClass(UITitledPanel)

require "UTGame.Ui.Settings.AddNewDevice.Pairing"

UTGame.Ui.Settings.AddNewDevice.backgroundTexture = "base:texture/ui/Option_Device.tga"
UTGame.Ui.Settings.AddNewDevice.hasPopup = false
-- __ctor --------------------------------------------------------------------

function UTGame.Ui.Settings.AddNewDevice:__ctor()
    
    -- uiButton1: link
    
	self.uiButton1 = self:AddComponent(UIButton:New(), "uiButton1")
	self.uiButton1.rectangle = { 0, 0, 220, 34 }
	self.uiButton1:MoveTo(82,190)
	self.uiButton1.text = l"sett005"
	self.uiButton1.tip = l"tip079"
	self.uiButton1.direction = DIR_HORIZONTAL
	UTGame.Ui.Settings.AddNewDevice.hasPopup = false


	self.uiButton1.OnAction = function (_self) 
		
		UIManager.stack:Push(UTGame.Ui.Settings.AddNewDevice.Pairing)
	
		quartz.framework.audio.loadsound("base:audio/ui/validation.wav")
		quartz.framework.audio.loadvolume(game.settings.audio["volume:sfx"])
		quartz.framework.audio.playsound()
		UTGame.Ui.Settings.AddNewDevice.hasPopup = true
		
	end

    -- uiButton2: force revision
    
	self.uiButton2 = self:AddComponent(UIButton:New(), "uiButton2")
	self.uiButton2.rectangle = { 0, 0, 220, 34 }
	self.uiButton2:MoveTo(82,240)
	if (REG_FORCEREVISION) then
		self.uiButton2.text = l"sett032"
		self.uiButton2.tip = l"tip229"
	else
		self.uiButton2.text = l"sett031"
		self.uiButton2.tip = l"tip228"
	end
	self.uiButton2.direction = DIR_HORIZONTAL

	self.uiButton2.OnAction = function (_self) 
		
		if (REG_FORCEREVISION) then
			REG_FORCEREVISION = false
			self.uiButton2.text = l"sett031"
			self.uiButton2.tip = l"tip228"
		else
			REG_FORCEREVISION = true
			self.uiButton2.text = l"sett032"
			self.uiButton2.tip = l"tip229"
		end
	end
end

-- Draw ---------------------------------------------------------------------

function UTGame.Ui.Settings.AddNewDevice:Draw()

	UITitledPanel.Draw(self)
	
	local rectangle = {15, 35, 361, 180}

    quartz.system.drawing.loadcolor3f(unpack(UIComponent.colors.white))
    quartz.system.drawing.loadtexture("base:texture/ui/components/uipanel05.tga")
    quartz.system.drawing.drawwindow(unpack(rectangle))
	
    quartz.system.drawing.loadcolor3f(unpack(UIComponent.colors.white))
    quartz.system.drawing.loadtexture(self.backgroundTexture)
    quartz.system.drawing.drawtexture(30, 40)

end
