
--[[--------------------------------------------------------------------------
--
-- File:            UTGame.Ui.Settings.AddNewDevice.Pairing.lua
--                  Copyright (c) Ubisoft Entertainment. All rights reserved.
--
-- Project:         Ubitoys.Tag
-- Date:            September 21, 2010
--
------------------------------------------------------------------------------
--
-- Description:     ...
--
----------------------------------------------------------------------------]]

--[[ Dependencies ----------------------------------------------------------]]

require "Ui/UIPopupWindow"  

--[[ Class -----------------------------------------------------------------]]

UTGame.Ui.Settings.AddNewDevice = UTGame.Ui.Settings.AddNewDevice or {}
UTGame.Ui.Settings.AddNewDevice.Pairing = UTClass(UIPopupWindow)

-- __ctor -------------------------------------------------------------------

function UTGame.Ui.Settings.AddNewDevice.Pairing:__ctor(...)

	self.title = l"pair003" .. " ..."
	self.text = l"pair001"
	
end
-- OnOpen -------------------------------------------------------------------

function UTGame.Ui.Settings.AddNewDevice.Pairing:OnOpen()

	-- !! START PAIRING
	
	assert(engine.libraries.usb.proxy)
	assert(engine.libraries.usb.proxy.handle)
	
	engine.libraries.usb.proxy:Unlock()
	quartz.system.usb.sendmessage(engine.libraries.usb.proxy.handle, { 0x01, 0x00, 0x13, 0x01 })

    engine.libraries.usb.proxy._DeviceAdded:Add(self, UTGame.Ui.Settings.AddNewDevice.OnDeviceAdded)
	
	-- uiButton2: quit

    self.uiButton2 = self:AddComponent(UIButton:New(), "uiButton2")
    self.uiButton2.rectangle = UIPopupWindow.buttonRectangles[2]
	self.uiButton2.text = l"but018"
	self.isPairing = true
    
	self.uiButton2.OnAction = function (_self) 
		
		-- !! STOP PAIRING
		
		if (self.isPairing == true) then
		
			quartz.system.usb.sendmessage(engine.libraries.usb.proxy.handle, { 0x01, 0x00, 0x13, 0x00 })
			engine.libraries.usb.proxy:Lock()
			self.isPairing = false
		end
		
		engine.libraries.usb.proxy._DeviceAdded:Remove(self, UTGame.Ui.Settings.AddNewDevice.OnDeviceAdded)
		engine.libraries.usb.proxy:WhiteList()
    
		UTGame.Ui.Settings.AddNewDevice.hasPopup = false
		UIManager.stack:Pop()
		self:Deactivate()

	end
	
	self:Activate()
	self:KeyDown(virtualKeyCode, scanCode)

end

-- OnDeviceAdded -------------------------------------------------------------

function UTGame.Ui.Settings.AddNewDevice:OnDeviceAdded(device)

	--self.text = l"pair002"
	--self.isPairing = false
	
	--quartz.system.usb.sendmessage(engine.libraries.usb.proxy.handle, { 0x01, 0x00, 0x13, 0x00 })
	--engine.libraries.usb.proxy:Lock()
	--engine.libraries.usb.proxy:WhiteList(tostring(device.reference), device)
	
	quartz.framework.audio.loadsound("base:audio/ui/gundetect.wav")
	quartz.framework.audio.loadvolume(game.settings.audio["volume:sfx"])
	quartz.framework.audio.playsound()
		
	--self.uiButton2.text = l"but024"

end

function UTGame.Ui.Settings.AddNewDevice.Pairing:KeyDown(virtualKeyCode, scanCode)
		
	if (27 == virtualKeyCode) then

		-- !! STOP PAIRING
		
		if (self.isPairing == true) then
		
			quartz.system.usb.sendmessage(engine.libraries.usb.proxy.handle, { 0x01, 0x00, 0x13, 0x00 })
			engine.libraries.usb.proxy:Lock()
			self.isPairing = false
		end
		
		engine.libraries.usb.proxy._DeviceAdded:Remove(self, UTGame.Ui.Settings.AddNewDevice.OnDeviceAdded)
		engine.libraries.usb.proxy:WhiteList()
    
		UTGame.Ui.Settings.AddNewDevice.hasPopup = false
		UIManager.stack:Pop()
		self:Deactivate()

	end

end

-- Activate ---------------------------------------------------------------

function UTGame.Ui.Settings.AddNewDevice.Pairing:Activate()

    if (not self.keyboardActive) then

        game._KeyDown:Add(self, self.KeyDown)
        self.keyboardActive = true

    end

end

-- Deactivate ---------------------------------------------------------------

function UTGame.Ui.Settings.AddNewDevice.Pairing:Deactivate()

    if (self.keyboardActive) then 
    
        game._KeyDown:Remove(self, self.KeyDown)
        self.keyboardActive = false

    end

end