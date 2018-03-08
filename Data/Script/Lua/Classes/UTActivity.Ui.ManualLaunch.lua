
--[[--------------------------------------------------------------------------
--
-- File:            UTActivity.Ui.ManualLaunch.lua
--                  Copyright (c) Ubisoft Entertainment. All rights reserved.
--
-- Project:         Ubitoys.Tag
-- Date:            September 20s, 2010
--
------------------------------------------------------------------------------
--
-- Description:     ...
--
----------------------------------------------------------------------------]]

--[[ Dependencies ----------------------------------------------------------]]

require "Ui/UIPopupWindow"

--[[ Class -----------------------------------------------------------------]]

UTActivity.Ui = UTActivity.Ui or {}
UTActivity.Ui.ManualLaunch = UTClass(UIPopupWindow)

-- __ctor -------------------------------------------------------------------

function UTActivity.Ui.ManualLaunch:__ctor(...)

    assert(activity)

	self.title = l"oth018"
	self.text = nil

	self.player = nil
	self.device = nil

	-- panel

	self.uiPanel = self:AddComponent(UIPanel:New(), "uiPanel")
	self.uiPanel.color = UIComponent.colors.lightgray
	self.uiPanel.background = "base:texture/ui/Components/UIPanel07.tga"
	self.uiPanel.rectangle = {
		self.clientRectangle[1],
		self.clientRectangle[2] + 25,
		self.clientRectangle[3] - 20,
		self.clientRectangle[2] + 25 + 15,
	}

	-- gun picture

	self.uiPicture1 = self:AddComponent(UIPicture:New(), "uiPicture1")
	self.uiPicture1.color = UIComponent.colors.white
	self.uiPicture1.texture = "base:texture/ui/gunbutton1.tga"
	self.uiPicture1.rectangle = {
		self.clientRectangle[3] - 220,
		self.clientRectangle[2],
		self.clientRectangle[3] - 220 + 241,
		self.clientRectangle[2] + 176,
	}
	
	-- FX !!!
	self.myFx = UIManager:AddFx("value", { duration = 0.6, __self = self.uiPicture1, value = "texture", from = "base:texture/ui/gunbutton1.tga", to = "base:texture/ui/gunbutton2.tga", type = "blink"})
		
	-- gun hud

	self.uiPicture2 = self.uiPanel:AddComponent(UIPicture:New(), "uiPicture2")
	self.uiPicture2.color = UIComponent.colors.white
	self.uiPicture2.texture = "base:texture/ui/pictograms/64x/Hud_1.tga"
	self.uiPicture2.rectangle = {
		0,
		-6,
		0 + 32,
		26,
	}	

	-- player icon

	self.uiPicture3 = self.uiPanel:AddComponent(UIPicture:New(), "uiPicture3")
	self.uiPicture3.color = UIComponent.colors.white
	
	self.uiPicture4 = self.uiPanel:AddComponent(UIPicture:New(), "uiPicture4")
	self.uiPicture4.color = UIComponent.colors.white
	self.uiPicture4.texture = ""
	self.uiPicture4.rectangle = {
		25,
		-26,
		25 + 64,
		-26 + 64,
	}

	-- player name

	self.uiLabel1 = self.uiPanel:AddComponent(UILabel:New(), "uiLabel1")
	self.uiLabel1.font = UIComponent.fonts.header
	self.uiLabel1.fontColor = UIComponent.colors.orange
	self.uiLabel1.text = ""
	self.uiLabel1.rectangle = {
		90,
		-5,
		210,
		20,
	}

	-- uiButton1: quit

    self.uiButton1 = self:AddComponent(UIButton:New(), "uiButton1")
    self.uiButton1.rectangle = UIPopupWindow.buttonRectangles[1]
	self.uiButton1.text = l"but018"
	self.uiButton1.tip = l"tip006"
    
	self.uiButton1.OnAction = function (_self) 
	
		quartz.framework.audio.loadsound("base:audio/ui/back.wav")
		quartz.framework.audio.loadvolume(game.settings.audio["volume:sfx"])
		quartz.framework.audio.playsound()
		UIManager.stack:Pop()
	end

	-- text

	self.uiLabel2 = self:AddComponent(UILabel:New(), "uiLabel2")
	self.uiLabel2.font = UIComponent.fonts.default
	self.uiLabel2.fontColor = UIComponent.colors.orange
	self.uiLabel2.fontJustification = quartz.system.drawing.justification.topleft + quartz.system.drawing.justification.wordbreak
	self.uiLabel2.text = l"oth064"
	self.uiLabel2.rectangle = {
		self.clientRectangle[1] + 20,
		self.clientRectangle[2] + 60,
		self.clientRectangle[3] - 215,
		self.clientRectangle[4],
	}
	
	-- uiButton2: force game start
    
    self.uiButton2 = self:AddComponent(UIButton:New(), "uiButton2")
    self.uiButton2.rectangle = UIPopupWindow.buttonRectangles[2]
	self.uiButton2.text = l"but008"
	self.uiButton2.tip = l"tip020"
    
	self.uiButton2.OnAction = function (_self) 
	
		UIManager.stack:Pop()
		activity:PostStateChange("beginmatch") 
	end
	
	if (activity.category ~= UTActivity.categories.single) then
		-- uiButton3: change player
	
	    self.uiButton3 = self:AddComponent(UIButton:New())
	    self.uiButton3.rectangle = { 17, 135, 37, 155 }
		self.uiButton3.tip = l"tip166"
	    
		self.uiButton3.OnAction = function (_self) 
		
			quartz.framework.audio.loadsound("base:audio/ui/validation.wav")
			quartz.framework.audio.loadvolume(game.settings.audio["volume:sfx"])
			quartz.framework.audio.playsound()
			game.manualdefaultplayer = nil
			self:GetFirstAvailableDevice()
		end
	end
	
	-- msg timer

	self.msgTimer = 0
	self.timer = quartz.system.time.gettimemicroseconds()
	self.warningMessage = 0
	self.done = false
	self.count = 1

end

-- GetFirstAvailableDevice ---------------------------------------------------

function UTActivity.Ui.ManualLaunch:GetFirstAvailableDevice()

	self.player = nil
	self.playercount = 0
	if (game.manualdefaultplayer and game.manualdefaultplayer.rfGunDevice.classId == 1) then
		self.count = 2
	end
	for _, player in ipairs(activity.match.players) do
		self.playercount = self.playercount + 1
		if (player.rfGunDevice and player.rfGunDevice.owner) then
			if (self.playercount == self.count) then 
				self.player = player
				if (#activity.players == self.count) then
					self.count = 0
				end
				self.count = self.count + 1
				break
			end
		end

	end
	self.player = game.manualdefaultplayer or self.player
	if (self.player) then

		self.device = self.player.rfGunDevice
		self.uiPicture2.texture = "base:texture/ui/pictograms/64x/Hud_" .. self.device.classId .. ".tga"
		if (game.settings.UiSettings.teamribbon == 2 and self.player.profile.team > 0) then
			self.uiPicture3.texture = "base:texture/ui/pictograms/48x/Team_" .. self.player.profile.team .. "_Circle.tga"
			self.uiPicture3.rectangle = { 30, -21, 20 + 64, -31 + 64 }
		else
			self.uiPicture3.rectangle = nil
		end
		self.uiPicture4.texture = "base:texture/Avatars/64x/" .. self.player.profile.icon
		self.uiLabel1.text = self.player.profile.name

	else

        self.uiPopup = UIPopupWindow:New()

        self.uiPopup.title = l"con037"
        self.uiPopup.text = l"con049"

        -- buttons

        self.uiPopup.uiButton2 = self.uiPopup:AddComponent(UIButton:New(), "uiButton2")
        self.uiPopup.uiButton2.rectangle = UIPopupWindow.buttonRectangles[2]
        self.uiPopup.uiButton2.text = l "but019"

        self.uiPopup.uiButton2.OnAction = function ()

            UIManager.stack:Pop()
			if (activity.category == UTActivity.categories.single) then
				activity:PostStateChange("endmatch")            
			else
				activity:PostStateChange("playersmanagement")
			end

        end

        UIManager.stack:Replace(self.uiPopup)		

	end
	game.manualdefaultplayer = nil

end

-- OnClose -------------------------------------------------------------------

function UTActivity.Ui.ManualLaunch:OnClose()

    if (engine.libraries.usb.proxy) then
    
		engine.libraries.usb.proxy._DispatchMessage:Remove(self, UTActivity.Ui.ManualLaunch.OnDispatchMessage)
	
	end
	game.manualdefaultplayer = self.player
	UIManager:RemoveFx(self.myFx)
	UTActivity.Ui.PlayersSetup.hasPopup = false

end

-- OnDispatchMessage ---------------------------------------------------------

function UTActivity.Ui.ManualLaunch:OnDispatchMessage(device, addressee, command, arg)

	if (0xC2 == command and not self.done) then

		-- can change team ?
		if (2 == arg[1]) then

			self.done = true
			manuallylaunched = true
			UIManager.stack:Pop() 
			activity:PostStateChange("beginmatch")

		end

	end

end

-- OnOpen --------------------------------------------------------------------

function UTActivity.Ui.ManualLaunch:OnOpen()

	-- register	to proxy message received

	engine.libraries.usb.proxy._DispatchMessage:Add(self, UTActivity.Ui.ManualLaunch.OnDispatchMessage)	

	-- get first available device

	self:GetFirstAvailableDevice()
	UTActivity.Ui.PlayersSetup.hasPopup = true

end

-- Update --------------------------------------------------------------------

function UTActivity.Ui.ManualLaunch:Update()

	if (not self.done) then

		local elapsedTime = quartz.system.time.gettimemicroseconds() - self.timer
		self.timer = quartz.system.time.gettimemicroseconds()

		self.msgTimer = self.msgTimer + elapsedTime
		if (self.msgTimer > 250000 and self.uiButton2.enabled) then
	
			-- test button msg
	
			self.msgTimer = 0
			if (self.device) then
	
				self.warningMessage = self.warningMessage  + 1
				if (self.warningMessage > 20) then
	
					self.warningMessage = 0
					self.msg = {0x04, self.device.radioProtocolId, 0xA1, 0x53, 0x44, 0x31, 0x37}
	
				else
					self.msg = {0x00, self.device.radioProtocolId, 0xC2, }
				end
				quartz.system.usb.sendmessage(engine.libraries.usb.proxy.handle, self.msg)
			
			end
	
		end

		-- check gun deconnection

		if (self.device and not self.device.owner) then

			self:GetFirstAvailableDevice()

		end

	end
	
	self.uiButton2.enabled = true
	
	if (#activity.teams == 0) then
		local numberOfPlayers = 0
		for i, player in ipairs(activity.match.challengers) do
			if (player.rfGunDevice and player.rfGunDevice.owner and not player.rfGunDevice.timedout) then
				numberOfPlayers = numberOfPlayers + 1
			elseif (game.settings.ActivitySettings.preventlaunch == 1 and game.settings.GameSettings.unregister == 0 and game.settings.TestSettings.vestoverride == 0) then
				self.uiButton2.enabled = false
			end
		end
		if (numberOfPlayers <= 1 and game.settings.GameSettings.unregister == 1) then
			UIManager.stack:Pop()
		end
	else
		for i = 1, activity.settings.numberOfTeams do
			local numberOfPlayers = 0
			for i, player in ipairs(activity.match.challengers[i].players) do
				if (player.rfGunDevice and player.rfGunDevice.owner and not player.rfGunDevice.timedout) then
					numberOfPlayers = numberOfPlayers + 1
				elseif (activity.category ~= UTActivity.categories.single and game.settings.ActivitySettings.preventlaunch == 1 and game.settings.GameSettings.unregister == 0 and game.settings.TestSettings.vestoverride == 0) then
					self.uiButton2.enabled = false
				end
			end
			if (numberOfPlayers == 0 and game.settings.GameSettings.unregister == 1) then
				UIManager.stack:Pop()
			end
		end
	end

end