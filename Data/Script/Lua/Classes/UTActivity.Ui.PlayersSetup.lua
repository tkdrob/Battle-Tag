
--[[--------------------------------------------------------------------------
--
-- File:            UTActivity.Ui.PlayersSetup.lua
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

require "UI/UIMenuWindow"

	require "Ui/UIPlayerSlotGrid"
	require "UTActivity.Ui.ManualLaunch"


--[[ Class -----------------------------------------------------------------]]

UTActivity.Ui = UTActivity.Ui or {}
UTActivity.Ui.PlayersSetup = UTClass(UIMenuWindow)

-- default

UTActivity.Ui.PlayersSetup.padding = { horizontal = 15, vertical = 20 }

-- __ctor -------------------------------------------------------------------

function UTActivity.Ui.PlayersSetup:__ctor(...)

    assert(activity)
    
	-- animate	
	
	self.slideBegin = game.settings.UiSettings.slideBegin
	self.slideEnd = game.settings.UiSettings.slideEnd

	-- window settings

	self.uiWindow.title = l"titlemen015"

    -- panel 

		self.uiPanel = self.uiWindow:AddComponent(UIPanel:New(), "uiPanel")
		self.uiPanel.rectangle = self.clientRectangle

    if (game.settings.UiSettings.playerslotgrid == 0) then
    	-- picture and text on left

    	self.uiPicture1 = self.uiPanel:AddComponent(UIPicture:New(), "uiPicture1")
		self.uiPicture1.color = UIComponent.colors.white
		self.uiPicture1.rectangle = { 20, 0, 20 + 350, 0 + 350 }
		self.uiPicture1.texture = "base:texture/ui/TBlaster_Connect.tga"

    	self.uiLabel1 = self.uiPanel:AddComponent(UILabel:New(), "uiLabel1")
		self.uiLabel1.font = UIComponent.fonts.default
		self.uiLabel1.fontColor = UIComponent.colors.darkgray
		self.uiLabel1.fontJustification = quartz.system.drawing.justification.topleft + quartz.system.drawing.justification.wordbreak
		self.uiLabel1.rectangle = { 40, 360, 325, 440 }
		self.uiLabel1.text = l"pm006"
		
		-- my slot grid

		self.slotGrid = self.uiPanel:AddComponent(UIPlayerSlotGrid:New(activity.maxNumberOfPlayer, activity.settings.numberOfTeams), "slotGrid")
		self.slotGrid:MoveTo( 390, 10 )
		
	else

    	-- my slot grid

		self.slotGrid = self.uiPanel:AddComponent(UIPlayerSlotGrid:New(activity.maxNumberOfPlayer, activity.settings.numberOfTeams), "slotGrid")
		if (game.settings.UiSettings.nbplayerslot > 18) then
			self.slotGrid:MoveTo( 15, -20 )
		else
			self.slotGrid:MoveTo( 15, 10 )
		end
	end
		for i, player in ipairs(activity.match.players) do
			if (not player.primary) then
				local slot = self.slotGrid:AddSlot(player)
				slot.harnessFx = UIManager:AddFx("value", { timeOffsey = math.random(0.0, 0.2), duration = 0.6, __self = slot , value = "icon", from = "base:texture/ui/icons/32x/harness_off.tga", to = "base:texture/ui/icons/32x/harness.tga", type = "blink"})
			end
		end

    -- buttons,

		-- uiButton1: back to player management

		self.uiButton1 = self:AddComponent(UIButton:New(), "uiButton1")
		self.uiButton1.rectangle = UIMenuWindow.buttonRectangles[1]
		self.uiButton1.text = l "but003"
		self.uiButton1.tip = l"tip006"

		self.uiButton1.OnAction = function()
		
			self:Back()
		end

		-- uiButton5: players ready for countdown

		self.uiButton5 = self:AddComponent(UIButton:New(), "uiButton5")
		self.uiButton5.rectangle = UIMenuWindow.buttonRectangles[5]
		self.uiButton5.text = l"but008"
		self.uiButton5.tip = l"tip020"
		self.uiButton5.enabled = false

		self.uiButton5.OnAction = function()
		
			self:Confirm()

		end

	self.setupFailed = false

end

-- OnClose -------------------------------------------------------------------

function UTActivity.Ui.PlayersSetup:OnClose()

   -- unregister to datachanged for player

	for i, player in ipairs(activity.match.players) do
		player._DataChanged:Remove(self, self.OnDataChanged)
	end
	self:Deactivate()

	engine.libraries.usb.proxy._DeviceRemoved:Remove(self, UTActivity.Ui.PlayersSetup.OnDeviceRemoved)

end

-- OnDataChanged -------------------------------------------------------------

function UTActivity.Ui.PlayersSetup:OnDataChanged(_entity, _key, _value)

	-- check harness

	if ("harnessOn" == _key) then

		for _, slot in ipairs(self.slotGrid.uiPlayerSlots) do

			if (slot.player and slot.player == _entity) then

				if (_value) then

					if (slot.harnessFx) then

						UIManager:RemoveFx(slot.harnessFx)
						slot.harnessFx = nil

					end

					slot.icon = "base:texture/ui/icons/32x/harness_on.tga"

				else
					if (not slot.harnessFx) then
						slot.harnessFx = UIManager:AddFx("value", { timeOffsey = math.random(0.0, 0.2), duration = 0.6, __self = slot , value = "icon", from = "base:texture/ui/icons/32x/harness_off.tga", to = "base:texture/ui/icons/32x/harness.tga", type = "blink"})
					end
				end

			end

		end

	end

end

-- OnDeviceRemoved -----------------------------------------------------------

function UTActivity.Ui.PlayersSetup:OnDeviceRemoved(device)

-- !! stop carrying about deconnection here ...


    -- lookup the player with the matching device,

    --[[for _, player in pairs(activity.match.players) do

        if (player.rfGunDevice == device) then

			-- deconnection : quit now 

			if (not self.setupFailed) then

				self.uiPopup = UIPopupWindow:New()

				self.uiPopup.title = l"con037"
				self.uiPopup.text = l"con048"

				-- buttons

				self.uiPopup.uiButton2 = self.uiPopup:AddComponent(UIButton:New(), "uiButton2")
				self.uiPopup.uiButton2.rectangle = UIPopupWindow.buttonRectangles[2]
				self.uiPopup.uiButton2.text = l "but019"

				self.uiPopup.uiButton2.OnAction = function ()

					UIManager.stack:Pop()
					activity:PostStateChange("end") 
					game:PostStateChange("title")

				end

				self.setupFailed = true
				UIManager.stack:Push(self.uiPopup)	

			end

        end

    end]]--


end

-- OnOpen --------------------------------------------------------------------

function UTActivity.Ui.PlayersSetup:OnOpen()

   -- register to datachanged for player

	for i, player in ipairs(activity.match.players) do
		player._DataChanged:Add(self, self.OnDataChanged)
	end
	self:Activate()
	
	gametypeloaded = directoryselected

	engine.libraries.usb.proxy._DeviceRemoved:Add(self, UTActivity.Ui.PlayersSetup.OnDeviceRemoved)

end

-- Update --------------------------------------------------------------------

function UTActivity.Ui.PlayersSetup:Update()

	-- display harness if needed by activity

	self.uiButton5.enabled = true
	if (activity.category ~= UTActivity.categories.single and game.settings.TestSettings.vestoverride == 0) then

		for i, player in ipairs(activity.match.players) do

			if (player.rfGunDevice and not player.data.heap.harnessOn and not player.primary) then
				self.uiButton5.enabled = false
			end
		end

	end

	if (#activity.teams == 0) then
		local numberOfPlayers = 0
		for i, player in ipairs(activity.match.challengers) do
			if (player.rfGunDevice and player.rfGunDevice.owner and not player.rfGunDevice.timedout) then
				numberOfPlayers = numberOfPlayers + 1
			end
		end
		if (numberOfPlayers <= 1) then
			self.uiButton5.enabled = false
			if (game.settings.GameSettings.unregister == 1) then
				activity:PostStateChange("playersmanagement")
			end
		end
	else
		for i = 1, activity.settings.numberOfTeams do
			local numberOfPlayers = 0
			for i, player in ipairs(activity.match.challengers[i].players) do
				if (player.rfGunDevice and player.rfGunDevice.owner and not player.rfGunDevice.timedout) then
					numberOfPlayers = numberOfPlayers + 1
				end
			end
			if (numberOfPlayers == 0) then
				self.uiButton5.enabled = false
				if (game.settings.GameSettings.unregister == 1) then
					activity:PostStateChange("playersmanagement")
				end
			end
		end
	end

	-- update

	self.slotGrid:Update()

end

function UTActivity.Ui.PlayersSetup:Back()

	quartz.framework.audio.loadsound("base:audio/ui/back.wav")
	quartz.framework.audio.loadvolume(game.settings.audio["volume:sfx"])
	quartz.framework.audio.playsound()
			
	UIMenuManager.stack:Pop()
	activity.matches = nil
	activity:PostStateChange("playersmanagement")
	--self.enabled = false
end

function UTActivity.Ui.PlayersSetup:Confirm()

	if (1 == game.settings.ActivitySettings.gameLaunch) then
		UIManager.stack:Push(UTActivity.Ui.ManualLaunch)
	else
		self:Deactivate()
		activity:PostStateChange("beginmatch")
	end
	--self.enabled = false
end

function UTActivity.Ui.PlayersSetup:Activate()

    if (not self.keyboardActive) then

        --game._Char:Add(self, self.Char)
        game._KeyDown:Add(self, self.KeyDown)
        self.keyboardActive = true

    end

end

function UTActivity.Ui.PlayersSetup:Deactivate()

    if (self.keyboardActive) then 
    
        --game._Char:Remove(self, self.Char)
        game._KeyDown:Remove(self, self.KeyDown)
        self.keyboardActive = false

    end

end

function UTActivity.Ui.PlayersSetup:KeyDown(virtualKeyCode, scanCode)
		
	if ((13 == virtualKeyCode or 53 == virtualKeyCode) and self.uiButton5.enabled) then
		if (self.hasPopup) then

			UIManager.stack:Pop()
			self:Deactivate()
			activity:PostStateChange("beginmatch")
		else
			self:Confirm()
		end

	end
	if (27 == virtualKeyCode or 49 == virtualKeyCode) then
		if (self.hasPopup) then
			quartz.framework.audio.loadsound("base:audio/ui/back.wav")
			quartz.framework.audio.loadvolume(game.settings.audio["volume:sfx"])
			quartz.framework.audio.playsound()
			UIManager.stack:Pop()
		else
			self:Back()
		end
	end

end