
--[[--------------------------------------------------------------------------
--
-- File:            UTActivity.Ui.Details.lua
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

require "UI/UISelector"

	require "UI/UIButton"
	require "UI/UIPicture"
	require "UI/UILabel"
	require "UI/UIScrollBar"

--[[ Class -----------------------------------------------------------------]]

UTActivity.Ui = UTActivity.Ui or {}
UTActivity.Ui.Details = UTClass(UISelector)

-- default

UTActivity.Ui.Details.TeamDetails = {
	"texture/ui/Detail_TeamRed.tga",
	"texture/ui/Detail_TeamBlue.tga",
	"texture/ui/Detail_TeamYellow.tga",
	"texture/ui/Detail_TeamGreen.tga",
	"texture/ui/Detail_TeamSilver.tga",
	"texture/ui/Detail_TeamPurple.tga",
}

-- __ctor -------------------------------------------------------------------

function UTActivity.Ui.Details:__ctor(...)

    assert(activity)

	self.transparent = false

	-- window settings

	self.uiWindow.title = l"oth019"
    self.uiSelector.title = l"oth020"

    -- contents,

    self:Reserve(9, --[[ --?? SCROLLBAR ]] true)
    
    -- activity description on the right side,

    self.uiDetails = self.uiWindows:AddComponent(UITitledPanel:New(), "uiDetails")
    self.uiDetails.rectangle = self.uiWindows.clientRectangle
    self.uiDetails.title = ""
    self.uiDetails.visible = false

	-- small panel for player's icon and name

    self.uiHeader = self.uiDetails:AddComponent(UIPanel:New(), "uiHeader")
    self.uiHeader.color = UIComponent.colors.white
    self.uiHeader.background = "base:texture/ui/Detail_HeaderOrange.tga"
    self.uiHeader.rectangle = { 0, 0, self.uiDetails.rectangle[3] - self.uiDetails.rectangle[1], 25}

	-- small panel for player's information

    self.uiInformation = self.uiDetails:AddComponent(UIPicture:New(), "uiInformation")
    self.uiInformation.color = UIComponent.colors.white
    self.uiInformation.texture = "base:texture/ui/Detail_GreyBackground.tga"
	self.uiInformation.rectangle = { 0, 25, self.uiDetails.rectangle[3] - self.uiDetails.rectangle[1], 80}

	-- current player name

	self.uiPlayerName = self.uiDetails:AddComponent(UILabel:New(), "uiPlayerName")
	self.uiPlayerName.font = UIComponent.fonts.title
	self.uiPlayerName.fontColor = UIComponent.colors.white
	self.uiPlayerName.text = ""
	self.uiPlayerName.rectangle = { 95, -2, 95 + 200, -2 + 40}

	-- current player icon

	self.uiPlayerIconbackground = self.uiWindows:AddComponent(UIPicture:New(), "uiPlayerIconbackground")
	self.uiPlayerIconbackground.texture = ""
	self.uiPlayerIconbackground.rectangle = { self.uiWindows.clientRectangle[1] - 15, self.uiWindows.clientRectangle[2] - 25, self.uiWindows.clientRectangle[1] + 83, self.uiWindows.clientRectangle[2] + 73}

	self.uiPlayerIcon = self.uiWindows:AddComponent(UIPicture:New(), "uiPlayerIcon")
	self.uiPlayerIcon.texture = ""
	self.uiPlayerIcon.rectangle = { self.uiWindows.clientRectangle[1] - 30, self.uiWindows.clientRectangle[2] - 40, self.uiWindows.clientRectangle[1] + 98, self.uiWindows.clientRectangle[2] + 88}

	-- grid label : frag and team frag

	self.uiDetails.fragLabel = self.uiDetails:AddComponent(UILabel:New(), "uiDetailsFragLabel")
	self.uiDetails.fragLabel.font = UIComponent.fonts.header
	self.uiDetails.fragLabel.fontColor = UIComponent.colors.orange
	self.uiDetails.fragLabel.text = l"oth067"

    -- buttons,

    -- uiButton1: back

    self.uiButton1 = self:AddComponent(UIButton:New(), "uiButton1")
    self.uiButton1.rectangle = UIMenuWindow.buttonRectangles[1]
    self.uiButton1.text = l"but003"
    self.uiButton1.tip = l"tip006"

    self.uiButton1.OnAction = function (self) 
		quartz.framework.audio.loadsound("base:audio/ui/back.wav")
		quartz.framework.audio.loadvolume(game.settings.audio["volume:sfx"])
		quartz.framework.audio.playsound()
		UIMenuManager.stack:Pop()
    end

    -- uiButton5: replay

    self.uiButton5 = self:AddComponent(UIButton:New(), "uiButton5")
    self.uiButton5.rectangle = UIMenuWindow.buttonRectangles[5]
    self.uiButton5.text = l"but022"
	self.uiButton5.tip = l"tip067"
	self.uiButton5.enabled = false

    self.uiButton5.OnAction = function (self) 

    	-- save team information

		activity:SaveTeamInformation()	

		quartz.framework.audio.loadsound("base:audio/ui/validation.wav")
		quartz.framework.audio.loadvolume(game.settings.audio["volume:sfx"])
		quartz.framework.audio.playsound()
		UIMenuManager.stack:Pop()
		activity:PostStateChange("playersmanagement") 
    end

	-- a scroll bar may be necessary ...

	self.uiScrollBarDetails = self:AddComponent(UIScrollBar:New({ 808, 300 }, 270), "uiScrollBarDetails")

	self.uiScrollBarDetails.OnActionUp = function(_self)  self:ScrollDetails(-1) end
	self.uiScrollBarDetails.OnActionDown = function(_self)	self:ScrollDetails(1) end

	self.maxSlot = math.min(#activity.players - 1, 8)
	self.uiScrollBarDetails:SetSize(#activity.players - 1, 8)
	self.currentIndex = 1

end

-- DisplaySelectedPlayer -----------------------------------------------------

function UTActivity.Ui.Details:DisplaySelectedPlayer(player)

	-- information

    self.uiDetails.visible = true
    if (player.team) then
		self.uiHeader.background = player.team.profile.detailsHeader
	end
    self.uiPlayerName.text = player.profile.name
	if (game.settings.UiSettings.teamribbon == 2 and player.profile.team > 0) then
		self.uiPlayerIconbackground.texture = "base:texture/ui/pictograms/48x/Team_" .. player.profile.team .. "_Circle.tga"
		self.uiPlayerIconbackground.rectangle = { self.uiWindows.clientRectangle[1] - 15, self.uiWindows.clientRectangle[2] - 25, self.uiWindows.clientRectangle[1] + 83, self.uiWindows.clientRectangle[2] + 73}
    else
        self.uiPlayerIconbackground.rectangle = nil
	end
	self.uiPlayerIcon.texture = "base:texture/avatars/256x/" .. player.profile.icon 

    self.player = player

    -- remove old components

	if (self.uiInformation.data) then
	
		for i, info in ipairs(self.uiInformation.data) do

			self.uiInformation:RemoveComponent(self.uiInformation.data[i].panel)
			self.uiInformation:RemoveComponent(self.uiInformation.data[i].icon)
			self.uiInformation:RemoveComponent(self.uiInformation.data[i].label)

		end

		self.uiInformation.data = nil

	end

	if (activity.detailsDescriptor) then

		-- grid with scroll

		self:ScrollDetails(0)

		-- pos and size and grid label !

		self.uiDetails.fragLabel.rectangle = { 40, 90 }

		-- player's information: panel, icon and value for each information needed

		self.uiInformation.data = {}
		local location = self.uiInformation.rectangle[3] - self.uiInformation.rectangle[1] - 20
		for i, info in ipairs(activity.detailsDescriptor.information) do
		
			self.uiInformation.data[i] = {}

			-- panel
			self.uiInformation.data[i].panel = self.uiDetails:AddComponent(UIPanel:New(), "uiInformationPanel")
			self.uiInformation.data[i].panel.color = UIComponent.colors.lightgray
			self.uiInformation.data[i].panel.background = "base:texture/ui/components/uipanel01.tga"
			self.uiInformation.data[i].panel.rectangle = { location - 120, 35, location, 35 + 40 }
			self.uiInformation.data[i].panel.tip = info.tip
			self.uiInformation.data[i].panel.RegisterPickRegions = UIButton.RegisterPickRegions
			self.uiInformation.data[i].panel.sensitive = true

			-- icon
			self.uiInformation.data[i].icon = self.uiDetails:AddComponent(UIPicture:New(), "uiInformationIcon")
			self.uiInformation.data[i].icon.texture = info.icon
			self.uiInformation.data[i].icon.rectangle = { location - 120, 40, location - 120 + 32, 40 + 32 }

			-- label
			self.uiInformation.data[i].label = self.uiDetails:AddComponent(UILabel:New(), "uiInformationLabel")
			self.uiInformation.data[i].label.font = UIComponent.fonts.header
			self.uiInformation.data[i].label.fontColor = UIComponent.colors.orange
			self.uiInformation.data[i].label.fontJustification = quartz.system.drawing.justification.center
			self.uiInformation.data[i].label.rectangle = { location - 90, 45, location, 45 + 20 }
			self.uiInformation.data[i].label.text = self.player.data.baked[info.key]

			-- reflexion
			self.uiInformation.data[i].reflexion = self.uiDetails:AddComponent(UIPicture:New(), "uiInformationReflexion")
			self.uiInformation.data[i].reflexion.texture = "base:texture/ui/Detail_Reflection.tga"
			self.uiInformation.data[i].reflexion.rectangle = { location - 120, 35, location, 35 + 40 }
			

			-- next one
			location = location - (140 * i)

		end
		
		self.uiInformation.details = {}
		local rectangle = { 40 - 10, 75, 40 - 10 + 32, 75 + 32 }
		for i, descriptor in ipairs(activity.detailsDescriptor.details) do

			if (descriptor.icon) then
			
				-- icon
				
				self.uiInformation.details[i] = self.uiDetails:AddComponent(UIPicture:New(), "uiInformationIcon")
				self.uiInformation.details[i].texture = descriptor.icon
				self.uiInformation.details[i].rectangle = {rectangle[1], 10 + rectangle[2], rectangle[3], 10 + rectangle[4]}
				if (descriptor.tip) then
					self.uiInformation.details[i].tip = descriptor.tip
					self.uiInformation.details[i].RegisterPickRegions = UIButton.RegisterPickRegions
					self.uiInformation.details[i].sensitive = true
				end
			
			end
			rectangle[1] = rectangle[1] + descriptor.width
			rectangle[3] = rectangle[3] + descriptor.width
			
		end		

	end

end

-- Draw ----------------------------------------------------------------------

function UTActivity.Ui.Details:Draw()

    UIPage.Draw(self)

    --

    if (self.player) then

        quartz.system.drawing.pushcontext()

        quartz.system.drawing.loadtranslation(unpack(self.uiWindows.rectangle))
        quartz.system.drawing.loadtranslation(unpack(self.uiWindow.rectangle))
        quartz.system.drawing.loadtranslation(unpack(self.clientRectangle))
        
        -- special reward

		if (self.player.data.baked.reward) then

			quartz.system.drawing.loadfont(UIComponent.fonts.header)
			quartz.system.drawing.loadcolor3f(unpack(UIComponent.colors.darkgray))
			quartz.system.drawing.drawtextjustified(self.player.data.baked.reward, quartz.system.drawing.justification.right, unpack({150, 0, 350, 50}))

		end

        -- all header icons
--[[
		if (activity.detailsDescriptor) then

			local rectangle = { 40 - 10, 100, 40 - 10 + 32, 100 + 32 }
			for i, descriptor in ipairs(activity.detailsDescriptor.details) do

				if (descriptor.icon) then


					quartz.system.drawing.loadcolor3f(unpack(UIComponent.colors.white))
					quartz.system.drawing.loadtexture(descriptor.icon)
					quartz.system.drawing.drawtexture(unpack(rectangle))

				end
				rectangle[1] = rectangle[1] + descriptor.width
				rectangle[3] = rectangle[3] + descriptor.width

			end

		end
	]]--	
        quartz.system.drawing.pop()

    end

end

-- OnOpen --------------------------------------------------------------------

function UTActivity.Ui.Details:OnOpen()

    for i, player in ipairs(activity.players) do
		if (not player.primary) then
			_headerIcon = "base:texture/avatars/64x/" .. player.profile.icon
			_headerIconBackground = "base:texture/ui/pictograms/48x/Team_" .. player.profile.team .. "_Circle.tga"
			local properties
			if (player.team) then
				if (game.settings.UiSettings.teamribbon == 2 and player.profile.team > 0) then
					properties = { iconText = i, iconColor = UIComponent.colors.white, iconCategory = self.TeamDetails[player.team.index], headerIcon = _headerIcon, headerIconBackground = _headerIconBackground, text = player.profile.name, userData = player }
				else
					properties = { iconText = i, iconColor = UIComponent.colors.white, iconCategory = self.TeamDetails[player.team.index], headerIcon = _headerIcon, text = player.profile.name, userData = player }
				end
			elseif (game.settings.UiSettings.teamribbon == 2 and player.profile.team > 0) then
				properties = { iconText = i, iconColor = UIComponent.colors.darkgray, headerIcon = _headerIcon, headerIconBackground = _headerIconBackground, text = player.profile.name, userData = player }
			else
				properties = { iconText = i, iconColor = UIComponent.colors.darkgray, headerIcon = _headerIcon, text = player.profile.name, userData = player }
			end

			local item = self:AddItem(properties)

			item.Action = function ()

				if (item.userData) then
					self:DisplaySelectedPlayer(item.userData)
				end
			end
		end
    end

    self.index = 1
    self:Scroll(0)
    self:DisplaySelectedPlayer(activity.players[1])

end

-- ScrollDetails -------------------------------------------------------------

function UTActivity.Ui.Details:ScrollDetails(value)

	-- scroll

	self.currentIndex = self.currentIndex + value
    if (self.currentIndex < 1) then
	    self.currentIndex = 1
	elseif (self.currentIndex > #activity.players - 1 - self.maxSlot) then
		self.currentIndex = math.max(1, #activity.players - 1 - self.maxSlot + 1)
	end

	-- delete and recreate

    if (self.uiGridFrag) then
		self.uiDetails:RemoveComponent(self.uiGridFrag)
    end	
	self.uiGridFrag = self.uiDetails:AddComponent(UIGrid:New(activity.detailsDescriptor.details), "uiGridFrag")

	-- add correct line

	local number = 1
	local numTeamFrag = 1	
	local i = 0
	while (number <= self.maxSlot) do
		local player = activity.players[self.currentIndex + i]
		i = i + 1
		if (player) then

			if (player ~= self.player and not player.primary and (player.team ~= self.player.team or activity.settings.teamFrag == 1 or #activity.teams < 2)) then

				local index = 2 + math.mod(numTeamFrag,2)
				numTeamFrag = numTeamFrag + 1
				self.uiGridFrag:AddLine(self.player.data.details[player.nameId], 16, "base:texture/ui/components/uigridline_background0" .. index .. ".tga")				
				number = number + 1

			end

		else
			break
		end

	end

	-- set padding

	self.uiGridFrag:MoveTo(40, 125)
	self.uiGridFrag:SetRowsPadding(1)

end

-- Update --------------------------------------------------------------------

function UTActivity.Ui.Details:Update()

	UISelector.Update(self)

	if (activity.states["finalrankings"].isReady) then 

		self.uiButton5.enabled = true

	end

	self.uiScrollBarDetails:Update()

end