
--[[--------------------------------------------------------------------------
--
-- File:            UATagThenShoot.Ui.RoundLoop.lua
--                  Copyright (c) Ubisoft Entertainment. All rights reserved.
--
-- Project:         Ubitoys.Tag
-- Date:            September 23, 2010
--
------------------------------------------------------------------------------
--
-- Description:     ...
--
----------------------------------------------------------------------------]]

--[[ Dependencies ----------------------------------------------------------]]

	require "Ui/UIAFP"
	require "Ui/UILeaderboard"
    require "Ui/UIPlayerSlot"
    
--[[ Class -----------------------------------------------------------------]]

UATagThenShoot.Ui = UATagThenShoot.Ui or {}
UATagThenShoot.Ui.RoundLoop = UTClass(UIMenuPage)

-- __ctor -------------------------------------------------------------------

function UATagThenShoot.Ui.RoundLoop:__ctor(...)

	-- label

    self.uiLabel = self:AddComponent(UILabel:New(), "uiLabel")
    self.uiLabel.fontColor = UIComponent.colors.black
    self.uiLabel.rectangle = { 300, 0, 700, 80 }
   -- self.uiLabel.text = "Default game loop for " .. activity.name

    ------------------------------------------------
    -- AFP TEST
    ------------------------------------------------

    activity.uiAFP = self:AddComponent(UIAFP:New(), "uiAFP")
    activity.uiAFP:MoveTo(50, 40)

	-- current player

	self.player = activity.match.challengers[1]

	-- best score

	self.uiBestScorePanel = self:AddComponent(UIPanel:New(), "uiBestScorePanel")
	self.uiBestScorePanel.background = "base:texture/ui/components/uipanel05.tga"
	self.uiBestScorePanel.rectangle = { 520, 460, 920, 660 }

		self.uiBestScorePanel.uiTitlePanel = self.uiBestScorePanel:AddComponent(UIPanel:New(), "uiTitlePanel")
		self.uiBestScorePanel.uiTitlePanel.background = "base:texture/ui/components/uipanel08.tga"
		self.uiBestScorePanel.uiTitlePanel.rectangle = { 0, 0, 400, 30 }
		self.uiBestScorePanel.uiTitlePanel.color = UIComponent.colors.white

		self.uiBestScorePanel.uiTitleLabel = self.uiBestScorePanel:AddComponent(UILabel:New(), "uiTitleLabel")
		self.uiBestScorePanel.uiTitleLabel.fontColor = UIComponent.colors.orange
		self.uiBestScorePanel.uiTitleLabel.font = UIComponent.fonts.header
		self.uiBestScorePanel.uiTitleLabel.text = l"oth060"
		self.uiBestScorePanel.uiTitleLabel.rectangle = { 20, 2 }
	
		-- a list of 3 best players !!	

		local index = 1
		for i, player in ipairs(activity.players) do

			if (index <= 3 and player.data.baked.score > 0) then

				local slot = self.uiBestScorePanel:AddComponent(UIPlayerSlot:New(), "uiPlayerSlot" .. index)
				slot:SetPlayer(player)
				slot:MoveTo(70, 50 * index)

				-- draw text 

				local label = slot:AddComponent(UILabel:New(), "uiLabel" .. index)
				label.fontColor = UIComponent.colors.black
				label.fontJustification = quartz.system.drawing.justification.center
				label.rectangle = { 255, 8, 295, 45 }
				label.text = player.data.baked.score 
				
				index = index + 1

			end

		end

	-- player slot

	self.uiPlayerPanel = self:AddComponent(UIPanel:New(), "uiPlayerPanel")
	self.uiPlayerPanel.background = "base:texture/ui/components/uipanel05.tga"
	self.uiPlayerPanel.rectangle = { 520, 50, 920, 170 }

		self.uiPlayerPanel.uiTitlePanel = self.uiPlayerPanel:AddComponent(UIPanel:New(), "uiTitlePanel")
		self.uiPlayerPanel.uiTitlePanel.background = "base:texture/ui/components/uipanel08.tga"
		self.uiPlayerPanel.uiTitlePanel.rectangle = { 0, 0, 400, 30 }

		self.uiPlayerPanel.uiTitleLabel = self.uiPlayerPanel:AddComponent(UILabel:New(), "uiTitleLabel")
		self.uiPlayerPanel.uiTitleLabel.fontColor = UIComponent.colors.orange
		self.uiPlayerPanel.uiTitleLabel.font = UIComponent.fonts.header
		self.uiPlayerPanel.uiTitleLabel.text = l"oth066"
		self.uiPlayerPanel.uiTitleLabel.rectangle = { 20, 2 }
				
		self.uiPlayerPanel.uiPlayerPanel = self.uiPlayerPanel:AddComponent(UIPanel:New(), "uiPlayerPanel")
		self.uiPlayerPanel.uiPlayerPanel.background = "base:texture/ui/components/UIGridLine_Background01.tga"
		self.uiPlayerPanel.uiPlayerPanel.rectangle = { 80, 60, 380, 84 }

			self.uiPlayerPanel.uiPlayerHud = self.uiPlayerPanel.uiPlayerPanel:AddComponent(UIPicture:New(), "uiPlayerHud")
			self.uiPlayerPanel.uiPlayerHud.texture = "base:texture/ui/icons/32x/gunhud.tga"
			self.uiPlayerPanel.uiPlayerHud.rectangle = { 50, -5, 82, 27 }

			if (self.player.rfGunDevice) then

				self.uiPlayerPanel.uiPlayerClassId = self.uiPlayerPanel.uiPlayerPanel:AddComponent(UILabel:New(), "uiPlayerClassId")
				self.uiPlayerPanel.uiPlayerClassId.fontJustification = quartz.system.drawing.justification.center + quartz.system.drawing.justification.singlelineverticalcenter
				self.uiPlayerPanel.uiPlayerClassId.rectangle = { 50, -5, 82, 27 }
				self.uiPlayerPanel.uiPlayerClassId.font = UIComponent.fonts.default
				self.uiPlayerPanel.uiPlayerClassId.fontColor = UIComponent.colors.orange
				self.uiPlayerPanel.uiPlayerClassId.text = self.player.rfGunDevice.classId

			end
		
			self.uiPlayerPanel.uiPlayerLabel = self.uiPlayerPanel.uiPlayerPanel:AddComponent(UILabel:New(), "uiTitleLabel")
			self.uiPlayerPanel.uiPlayerLabel.fontColor = UIComponent.colors.darkgray
			self.uiPlayerPanel.uiPlayerLabel.font = UIComponent.fonts.header
			self.uiPlayerPanel.uiPlayerLabel.text = self.player.profile.name
			self.uiPlayerPanel.uiPlayerLabel.rectangle = { 100, 0 }

			if (game.settings.UiSettings.teamribbon == 2 and self.player.profile.team > 0) then
				self.uiPlayerPanel.uiPlayerPanelbackground = self.uiPlayerPanel.uiPlayerPanel:AddComponent(UIPicture:New(), "uiTitleLabel")
				self.uiPlayerPanel.uiPlayerPanelbackground.texture = "base:texture/ui/pictograms/48x/Team_" .. self.player.profile.team .. "_Circle.tga"
				self.uiPlayerPanel.uiPlayerPanelbackground.rectangle = { -49, -39, 49, 59 }
			end

			self.uiPlayerPanel.uiPlayerIcon = self.uiPlayerPanel.uiPlayerPanel:AddComponent(UIPicture:New(), "uiTitleLabel")
			self.uiPlayerPanel.uiPlayerIcon.texture = "base:texture/Avatars/256x/" .. self.player.profile.icon
			self.uiPlayerPanel.uiPlayerIcon.rectangle = { -64, -54, 64, 74 }
	
			self.uiPlayerPanel.uiPlayerScore = self.uiPlayerPanel.uiPlayerPanel:AddComponent(UILabel:New(), "uiTitleLabel")
			self.uiPlayerPanel.uiPlayerScore.fontColor = UIComponent.colors.orange
			self.uiPlayerPanel.uiPlayerScore.font = UIComponent.fonts.header
			self.uiPlayerPanel.uiPlayerScore.text = activity.match.challengers[1].data.heap.score
			self.uiPlayerPanel.uiPlayerScore.rectangle = { 255, 0 }

	-- bases

	self.uiBasePanel = {}
	if (4 == activity.settings.numberOfBase) then

		self.baseRectangle = {
			{ 520, 180, 710, 260 },
			{ 730, 180, 920, 260 },
			{ 520, 360, 710, 440 },
			{ 730, 360, 920, 440 },
		}
		self.ubiconnectRectangle = {
			{ 520, 270, 920, 350 },
		}

	else
	
		self.baseRectangle = {
			{ 520, 220, 710, 300 },
			{ 730, 220, 920, 300 },
		}
		self.ubiconnectRectangle = {
			{ 520, 330, 920, 410 },
		}
	
	end
		
	for i = 1, activity.settings.numberOfBase do

		self.uiBasePanel[i] = self:AddComponent(UIPanel:New(), "uiBasePanel" .. "1")
		self.uiBasePanel[i].background = "base:texture/ui/components/uipanel05.tga"
		self.uiBasePanel[i].rectangle = self.baseRectangle[i]

			self.uiBasePanel[i].uiTitlePanel = self.uiBasePanel[i]:AddComponent(UIPanel:New(), "uiTitlePanel")
			self.uiBasePanel[i].uiTitlePanel.background = "base:texture/ui/components/uipanel07.tga"
			self.uiBasePanel[i].uiTitlePanel.rectangle = { 0, 30, 190, 50 }

			self.uiBasePanel[i].uiBaseName = self.uiBasePanel[i]:AddComponent(UILabel:New(), "uiTitleLabel")
			self.uiBasePanel[i].uiBaseName.fontColor = UIComponent.colors.darkgray
			self.uiBasePanel[i].uiBaseName.font = UIComponent.fonts.header
			self.uiBasePanel[i].uiBaseName.text = l("oth05" .. (5 + i))
			self.uiBasePanel[i].uiBaseName.rectangle = { 5, 30 }

			self.uiBasePanel[i].uiBaseIcon = self.uiBasePanel[i]:AddComponent(UIPicture:New(), "uiTitleLabel")
			self.uiBasePanel[i].uiBaseIcon.texture = "base:texture/ui/pictograms/128x/RF0" .. (i + 2) .. "_White.tga"
			self.uiBasePanel[i].uiBaseIcon.rectangle = { 100, -5, 200, 85 }

	end

	-- UbiConnect

	self.uiUbiConnectPanel = self:AddComponent(UIPanel:New(), "uiBasePanel" .. "1")
	self.uiUbiConnectPanel.background = "base:texture/ui/components/uipanel05.tga"
	self.uiUbiConnectPanel.rectangle = self.ubiconnectRectangle[1]

		self.uiUbiConnectPanel.uiTitlePanel = self.uiUbiConnectPanel:AddComponent(UIPanel:New(), "uiTitlePanel")
		self.uiUbiConnectPanel.uiTitlePanel.background = "base:texture/ui/components/uipanel07.tga"
		self.uiUbiConnectPanel.uiTitlePanel.rectangle = { 0, 30, 400, 50 }

		self.uiUbiConnectPanel.uiBaseName = self.uiUbiConnectPanel:AddComponent(UILabel:New(), "uiTitleLabel")
		self.uiUbiConnectPanel.uiBaseName.fontColor = UIComponent.colors.darkgray
		self.uiUbiConnectPanel.uiBaseName.font = UIComponent.fonts.header
		self.uiUbiConnectPanel.uiBaseName.text = l"bas011"
		self.uiUbiConnectPanel.uiBaseName.rectangle = { 45, 30 }

		self.uiUbiConnectPanel.uiBaseIcon = self.uiUbiConnectPanel:AddComponent(UIPicture:New(), "uiTitleLabel")
		self.uiUbiConnectPanel.uiBaseIcon.texture = "base:texture/ui/pictograms/128x/RF09_White.tga"
		self.uiUbiConnectPanel.uiBaseIcon.rectangle = { 220, -5, 320, 85 }

end

-- __dtor -------------------------------------------------------------------

function UATagThenShoot.Ui.RoundLoop:__dtor()    
end

-- Onclose --------------------------------------------------------------------

function UATagThenShoot.Ui.RoundLoop:OnClose()

	self.player._DataChanged:Remove(self, self.OnDataChanged)

end


-- OnOpen --------------------------------------------------------------------

function UATagThenShoot.Ui.RoundLoop:OnOpen()

	self.player._DataChanged:Add(self, self.OnDataChanged)
	self.uiBasePanel[1].uiBaseIcon.texture = "base:texture/ui/pictograms/128x/RF03.tga"

end

-- OnDataChanged -------------------------------------------------------------

function UATagThenShoot.Ui.RoundLoop:OnDataChanged(_entity, _key, _value)

	if ("state" == _key) then

		for i = 1, activity.settings.numberOfBase do

			if (_value and self.player.data.heap.state == i - 1) then
				self.uiBasePanel[i].uiBaseIcon.texture = "base:texture/ui/pictograms/128x/RF0" .. (i + 2) .. ".tga"
			else
				self.uiBasePanel[i].uiBaseIcon.texture = "base:texture/ui/pictograms/128x/RF0" .. (i + 2) .. "_White.tga"		
			end

		end

		if (not _value) then
			self.uiUbiConnectPanel.uiBaseIcon.texture = "base:texture/ui/pictograms/128x/RF09.tga"
		else
			self.uiUbiConnectPanel.uiBaseIcon.texture = "base:texture/ui/pictograms/128x/RF09_White.tga"

		end
		
	elseif ("score" == _key) then

		self.uiPlayerPanel.uiPlayerScore.text = self.player.data.heap.score

	end

end
