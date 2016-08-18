
--[[--------------------------------------------------------------------------
--
-- File:            UAOldFashionDuel.Ui.RoundLoop.lua
--                  Copyright (c) Ubisoft Entertainment. All rights reserved.
--
-- Project:         Ubitoys.Tag
-- Date:            September 03, 2010
--
------------------------------------------------------------------------------
--
-- Description:     ...
--
----------------------------------------------------------------------------]]

--[[ Dependencies ----------------------------------------------------------]]

require "UTActivity.Ui.RoundLoop"
require "Ui/UIAFP"
require "Ui/UILeaderboard"

--[[ Class -----------------------------------------------------------------]]

UAOldFashionDuel.Ui = UAOldFashionDuel.Ui or {}
UAOldFashionDuel.Ui.RoundLoop = UTClass(UIMenuPage)

-- __ctor -------------------------------------------------------------------

function UAOldFashionDuel.Ui.RoundLoop:__ctor(...)

	-- get players

	self.player = {}
	for i = 1, activity.minNumberOfPlayer do
		self.player[i] = activity.match.challengers[i]
	end
	
	-- big panel

	self.uiMainPanel = self:AddComponent(UIPanel:New(), "uiMainPanel")
	self.uiMainPanel.background = "base:texture/ui/components/uipanel05.tga"
	self.uiMainPanel.rectangle = { 100, 100, 860, 600 }

		self.uiMainPanel.uiTitlePanel = self.uiMainPanel:AddComponent(UIPanel:New(), "uiTitlePanel")
		self.uiMainPanel.uiTitlePanel.background = "base:texture/ui/components/uipanel08.tga"
		self.uiMainPanel.uiTitlePanel.rectangle = { 0, 0, 760, 40 }

		-- right player		

		self.uiMainPanel.uiRightBanner = self.uiMainPanel:AddComponent(UIPicture:New(), "uiRightBanner")
		self.uiMainPanel.uiRightBanner.texture = "base:texture/ui/Leaderboard_BlueLine_Duel.tga"
		self.uiMainPanel.uiRightBanner.rectangle = { 405, 5, 755, 25 }

		self.uiMainPanel.uiRightName = self.uiMainPanel:AddComponent(UILabel:New(), "uiRightName")
		self.uiMainPanel.uiRightName.font = UIComponent.fonts.header
		self.uiMainPanel.uiRightName.fontColor = UIComponent.colors.white
		self.uiMainPanel.uiRightName.text = self.player[2].profile.name
		self.uiMainPanel.uiRightName.fontJustification = quartz.system.drawing.justification.left
		self.uiMainPanel.uiRightName.rectangle = { 550, 3, 700, 33 }

		self.uiRightHud = self.uiMainPanel:AddComponent(UIPicture:New(), "uiRightHud")
		self.uiRightHud.color = UIComponent.colors.white
		if (self.player[2].rfGunDevice) then
			self.uiRightHud.texture = "base:texture/ui/pictograms/128x/Hud_" .. self.player[2].rfGunDevice.classId .. ".tga"
		else
			self.uiRightHud.texture = "base:texture/ui/pictograms/128x/Hud_1.tga"
		end
		self.uiRightHud.rectangle = { 455, -20, 519, 44 }
		if (game.settings.UiSettings.teamribbon == 2 and self.player[2].profile.team > 0) then
			self.uiMainPanel.uiRightIconbackground = self.uiMainPanel:AddComponent(UIPicture:New(), "uiRightIconbackground")
			self.uiMainPanel.uiRightIconbackground.texture = "base:texture/ui/pictograms/48x/Team_" .. self.player[2].profile.team .. "_Circle.tga"
			self.uiMainPanel.uiRightIconbackground.rectangle = { 380, -55, 478, 43 }
		end
		
		self.uiMainPanel.uiRightIcon = self.uiMainPanel:AddComponent(UIPicture:New(), "uiRightIcon")
		self.uiMainPanel.uiRightIcon.texture = "base:texture/Avatars/256x/" .. self.player[2].profile.icon
		self.uiMainPanel.uiRightIcon.rectangle = { 365, -70, 493, 58 }	

			
		-- left player

		self.uiMainPanel.uiLeftBanner = self.uiMainPanel:AddComponent(UIPicture:New(), "uiLeftBanner")
		self.uiMainPanel.uiLeftBanner.texture = "base:texture/ui/Leaderboard_RedLine_Duel.tga"
		self.uiMainPanel.uiLeftBanner.rectangle = { 5, 5, 355, 25 }

		self.uiMainPanel.uiLeftName = self.uiMainPanel:AddComponent(UILabel:New(), "uiLeftName")
		self.uiMainPanel.uiLeftName.font = UIComponent.fonts.header
		self.uiMainPanel.uiLeftName.fontColor = UIComponent.colors.white
		self.uiMainPanel.uiLeftName.text = self.player[1].profile.name
		self.uiMainPanel.uiLeftName.fontJustification = quartz.system.drawing.justification.left
		self.uiMainPanel.uiLeftName.rectangle = { 75, 3, 300, 33 }
		
		self.uiLeftHud = self.uiMainPanel:AddComponent(UIPicture:New(), "uiLeftHud")
		self.uiLeftHud.color = UIComponent.colors.white
		if (self.player[1].rfGunDevice) then
			self.uiLeftHud.texture = "base:texture/ui/pictograms/128x/Hud_" .. self.player[1].rfGunDevice.classId .. ".tga"
		else
			self.uiLeftHud.texture = "base:texture/ui/pictograms/128x/Hud_1.tga"
		end
		self.uiLeftHud.rectangle = { 230, -20, 294, 44 }

		if (game.settings.UiSettings.teamribbon == 2 and self.player[1].profile.team > 0) then
			self.uiMainPanel.uiLeftIconbackground = self.uiMainPanel:AddComponent(UIPicture:New(), "uiLeftIconbackground")
			self.uiMainPanel.uiLeftIconbackground.texture = "base:texture/ui/pictograms/48x/Team_" .. self.player[1].profile.team .. "_Circle.tga"
			self.uiMainPanel.uiLeftIconbackground.rectangle = { 272, -55, 370, 43 }
		end

		self.uiMainPanel.uiLeftIcon = self.uiMainPanel:AddComponent(UIPicture:New(), "uiLeftIcon")
		self.uiMainPanel.uiLeftIcon.texture = "base:texture/Avatars/256x/" .. self.player[1].profile.icon
		self.uiMainPanel.uiLeftIcon.rectangle = { 257, -70, 385, 58 }

		-- all rounds 

		self.uiRoundLeftPanel = {}
		self.uiRoundCenterPanel = {}
		self.uiRoundRightPanel = {}
		self.uiRoundArrowLeft = {}
		self.uiRoundArrowRight = {}
		self.uiRoundText = {}
		self.uiRoundNumber = {}
		
		for i = 1, activity.settings.numberOfRound do

			self.uiRoundLeftPanel[i] = self.uiMainPanel:AddComponent(UIPanel:New(), "uiRoundLeftPanel" .. i)
			self.uiRoundLeftPanel[i].background = "base:texture/ui/Duel_Border.tga"
			self.uiRoundLeftPanel[i].rectangle = { 38, 58 + 85 * (i - 1), 202, 132 + 85 * (i - 1) }

			self.uiRoundArrowLeft[i] = self.uiMainPanel:AddComponent(UIPicture:New(), "uiRoundCenterPanel" .. i)
			self.uiRoundArrowLeft[i].texture = "base:texture/ui/Duel_Arrow_Left.tga"
			self.uiRoundArrowLeft[i].rectangle = { 202, 60 + 85 * (i - 1), 330, 128 + 85 * (i - 1) }

			self.uiRoundArrowRight[i] = self.uiMainPanel:AddComponent(UIPicture:New(), "uiRoundCenterPanel" .. i)
			self.uiRoundArrowRight[i].texture = "base:texture/ui/Duel_Arrow_Right.tga"
			self.uiRoundArrowRight[i].rectangle = { 430 , 60 + 85 * (i - 1), 558, 128 + 85 * (i - 1) }

			self.uiRoundRightPanel[i] = self.uiMainPanel:AddComponent(UIPanel:New(), "uiRoundLeftPanel" .. i)
			self.uiRoundRightPanel[i].background = "base:texture/ui/Duel_Border.tga"
			self.uiRoundRightPanel[i].rectangle = { 558, 58 + 85 * (i - 1), 722, 132 + 85 * (i - 1) }

			self.uiRoundCenterPanel[i] = self.uiMainPanel:AddComponent(UIPanel:New(), "uiRoundCenterPanel" .. i)
			self.uiRoundCenterPanel[i].background = "base:texture/ui/Duel_RoundBackgroundGrey.tga"
			self.uiRoundCenterPanel[i].rectangle = { 316, 60 + 85 * (i - 1), 444, 128 + 85 * (i - 1) }

			-- text

			self.uiRoundNumber[i] = self.uiRoundCenterPanel[i]:AddComponent(UILabel:New(), "uiRoundNumber" .. i)
			self.uiRoundNumber[i].font = UIComponent.fonts.larger
			self.uiRoundNumber[i].fontColor = UIComponent.colors.white
			self.uiRoundNumber[i].fontJustification = quartz.system.drawing.justification.center
			self.uiRoundNumber[i].text = i
			self.uiRoundNumber[i].rectangle = { 0, 20, 128, 68 }

			self.uiRoundText[i] = self.uiRoundCenterPanel[i]:AddComponent(UILabel:New(), "uiRoundText" .. i)
			self.uiRoundText[i].font = UIComponent.fonts.header
			self.uiRoundText[i].fontColor = UIComponent.colors.darkgray
			self.uiRoundText[i].fontJustification = quartz.system.drawing.justification.center
			self.uiRoundText[i].text = l"oth001"
			self.uiRoundText[i].rectangle = { 0, 4, 128, 30 }

		end

	-- menu panel

    self.uiMenuPanel = self:AddComponent(UIPanel:New(), "uiMenuPanel")
    self.uiMenuPanel.background = "base:texture/ui/components/uipanel05.tga"
    self.uiMenuPanel.rectangle = UIMenuPage.panelMargin

		self.uiButton1 = self:AddComponent(UIButton:New(), "uiButton1")
		self.uiButton1.rectangle = UIMenuWindow.buttonRectangles[1]
		self.uiButton1.text = l"but016"
		self.uiButton1.tip = l"tip066"

		self.uiButton1.OnAction = function (self) 

			if (not activity.mainMenu) then
				activity.mainMenu = UTActivity.Ui.Menu:New()
				UIManager.stack:Push(activity.mainMenu) 
			end

		end

	if (game.settings.GameSettings.reconnect == 2) then
	    self.uiButton2 = self:AddComponent(UIButton:New(), "uiButton2")
	    self.uiButton2.rectangle = UIMenuWindow.buttonRectangles[2]
		self.uiButton2.text = l"but028"
		self.uiButton2.tip = l"tip194"
	
		self.uiButton2.OnAction = function (self) 
	
			engine.libraries.usb.proxy:Unlock()
		end
	end

	-- round

	self.round = 0
	self:AdvanceRound()
	self.finished = false

end

-- __dtor -------------------------------------------------------------------

function UAOldFashionDuel.Ui.RoundLoop:__dtor()    
end

-- AdvanceRound -------------------------------------------------------------

function UAOldFashionDuel.Ui.RoundLoop:AdvanceRound()
	
	if (0 < self.round and activity.settings.numberOfRound >= self.round) then

		self.uiRoundCenterPanel[self.round].background = "base:texture/ui/Duel_RoundBackgroundGrey.tga"
		self.uiRoundArrowLeft[self.round].color = UIComponent.colors.white
		self.uiRoundArrowRight[self.round].color = UIComponent.colors.white
		self.uiRoundNumber[self.round].text = self.round

	end

	if (self.round < activity.settings.numberOfRound) then

		self.round = self.round + 1

		self.uiRoundCenterPanel[self.round].background = "base:texture/ui/Duel_RoundBackgroundOrange.tga"
		self.uiRoundNumber[self.round].text = self.round
		self.blinkTimer = 0

	else

		self.finished = true

	end

end


-- Onclose --------------------------------------------------------------------

function UAOldFashionDuel.Ui.RoundLoop:OnClose()

	for i = 1, activity.minNumberOfPlayer  do
		self.player[i]._DataChanged:Remove(self, self.OnDataChanged)
	end

end


-- OnOpen --------------------------------------------------------------------

function UAOldFashionDuel.Ui.RoundLoop:OnOpen()

	for i = 1, activity.minNumberOfPlayer do
		self.player[i]._DataChanged:Add(self, self.OnDataChanged)
	end

end

-- OnDataChanged -------------------------------------------------------------

function UAOldFashionDuel.Ui.RoundLoop:OnDataChanged(_entity, _key, _value)

	if ("score" == _key and self.round <= activity.settings.numberOfRound and not self.finished) then

		-- a player has scored ... so display scores

		if (self.player[1] == _entity) then

			self.uiStar = self.uiRoundLeftPanel[self.round]:AddComponent(UIPicture:New(), "uiStar")
			self.uiStar.texture = "base:texture/ui/icons/64x/Star.tga"
			self.uiStar.rectangle = { 50, 0, 114, 64 }			
			self.uiStar = self.uiRoundRightPanel[self.round]:AddComponent(UIPicture:New(), "uiStar")
			self.uiStar.texture = "base:texture/ui/icons/64x/Cross.tga"
			self.uiStar.rectangle = { 50, 0, 114, 64 }	
			self:AdvanceRound()

		else

			self.uiStar = self.uiRoundRightPanel[self.round]:AddComponent(UIPicture:New(), "uiStar")
			self.uiStar.texture = "base:texture/ui/icons/64x/Star.tga"
			self.uiStar.rectangle = { 50, 0, 114, 64 }			
			self.uiStar = self.uiRoundLeftPanel[self.round]:AddComponent(UIPicture:New(), "uiStar")
			self.uiStar.texture = "base:texture/ui/icons/64x/Cross.tga"
			self.uiStar.rectangle = { 50, 0, 114, 64 }			
			self:AdvanceRound()
		
		end

	end

end

-- UpdateState ---------------------------------------------------------------

function UAOldFashionDuel.Ui.RoundLoop:UpdateState(txt, blink)

	if (0 < self.round and activity.settings.numberOfRound >= self.round and not self.finished) then

		self.uiRoundNumber[self.round].text = txt or self.round
		if (txt) then
			self.uiRoundNumber[self.round].font = UIComponent.fonts.header
			self.uiRoundNumber[self.round].rectangle = { 0, 30, 128, 68 }
		else
			self.uiRoundNumber[self.round].font = UIComponent.fonts.larger
			self.uiRoundNumber[self.round].rectangle = { 0, 20, 128, 68 }
		end

	end

	self.blink = blink

end

-- Update -------------------------------------------------------------------

function UAOldFashionDuel.Ui.RoundLoop:Update()

	if (activity.states["roundloop"].draw and not self.finished) then

		activity.states["roundloop"].draw = false
		self.uiStar = self.uiRoundRightPanel[self.round]:AddComponent(UIPicture:New(), "uiStar")
		self.uiStar.texture = "base:texture/ui/icons/64x/Cross.tga"
		self.uiStar.rectangle = { 50, 0, 114, 64 }			
		self.uiStar = self.uiRoundLeftPanel[self.round]:AddComponent(UIPicture:New(), "uiStar")
		self.uiStar.texture = "base:texture/ui/icons/64x/Cross.tga"
		self.uiStar.rectangle = { 50, 0, 114, 64 }			
		self:AdvanceRound()

	end

	if (self.blink) then
        if (0 < self.round and activity.settings.numberOfRound >= self.round and not self.finished) then

		    local elapsedTime = quartz.system.time.gettimemicroseconds() - (self.time or 0)
		    self.time = quartz.system.time.gettimemicroseconds()
		    self.blinkTimer = (self.blinkTimer or 0) + elapsedTime

		    if (self.blinkTimer > 500000) then
			    self.uiRoundArrowLeft[self.round].color = UIComponent.colors.white
			    self.uiRoundArrowRight[self.round].color = UIComponent.colors.white
		    else
			    self.uiRoundArrowLeft[self.round].color = UIComponent.colors.orange
			    self.uiRoundArrowRight[self.round].color = UIComponent.colors.orange
		    end

		    if (self.blinkTimer > 1000000) then self.blinkTimer = 0
		    end

        end
	end

end