
--[[--------------------------------------------------------------------------
--
-- File:            UIPlayerSlotGrid.lua
--                  Copyright (c) Ubisoft Entertainment. All rights reserved.
--
-- Project:         Ubitoys.Tag
-- Date:            September 06, 2010
--
------------------------------------------------------------------------------
--
-- Description:     Display a list of UIPlayerSlot as a grid
--
----------------------------------------------------------------------------]]

--[[Dependencies ----------------------------------------------------------]]

	require "UI/UIScrollBar"

--[[ Class -----------------------------------------------------------------]]

UTClass.UIPlayerSlotGrid(UIMultiComponent)

-- default

UIPlayerSlotGrid.horizontalPadding = 50

UIPlayerSlotGrid.maxSlot = game.settings.UiSettings.nbplayerslot + (game.settings.UiSettings.nbplayerslot * game.settings.UiSettings.playerslotgrid)
local horizPadding = {50, 50, 50, 50, 50, 50, 50, 52, 47, 43, 40, 36, 33, 31, 28, 26, 25, 25, 24, 24, 23, 22, 21, 20, 18, 18, 18, 16, 16, 16, 16, 16}

UIPlayerSlotGrid.teamColor = {
	{ "UIRedSlot_01.tga", "UIRedSlot_02.tga" },
	{ "UIBlueSlot_01.tga", "UIBlueSlot_02.tga" },	
	{ "UIYellowSlot_01.tga", "UIYellowSlot_02.tga" },	
	{ "UIGreenSlot_01.tga", "UIGreenSlot_02.tga" },
	{ "UISilverSlot_01.tga", "UISilverSlot_02.tga" },
	{ "UIPurpleSlot_01.tga", "UIPurpleSlot_02.tga" },		
}

-- __ctor -------------------------------------------------------------------

function UIPlayerSlotGrid:__ctor( numberOfSlot, numberOfTeam ) 

	UIPlayerSlotGrid.horizontalPadding = horizPadding[game.settings.UiSettings.nbplayerslot]
    UIPlayerSlotGrid.slots = game.settings.UiSettings.nbplayerslot
    UIPlayerSlotGrid.playeroffset = 0
	
	-- team panel ...

	self.uiTeamSlots = {}
	self.uiTeamSlots2 = {}
	for i = 1, numberOfTeam do

		self.uiTeamSlots[i] = {}
		self.uiTeamSlots2[i] = {}

		self.uiTeamSlots[i].left = self:AddComponent(UIPanel:New(), "uiTeamPanelLeft" .. i)
		self.uiTeamSlots[i].left.color = UIComponent.colors.white
		self.uiTeamSlots[i].left.background = "base:texture/ui/components/" .. self.teamColor[i][1]

		self.uiTeamSlots[i].right = self:AddComponent(UIPanel:New(), "uiTeamPanelRight" .. i)
		self.uiTeamSlots[i].right.color = UIComponent.colors.white
		self.uiTeamSlots[i].right.background = "base:texture/ui/components/" .. self.teamColor[i][2]

		self.uiTeamSlots2[i].left = self:AddComponent(UIPanel:New(), "uiTeamPanelLeft" .. i)
		self.uiTeamSlots2[i].left.color = UIComponent.colors.white
		self.uiTeamSlots2[i].left.background = "base:texture/ui/components/" .. self.teamColor[i][1]

		self.uiTeamSlots2[i].right = self:AddComponent(UIPanel:New(), "uiTeamPanelRight" .. i)
		self.uiTeamSlots2[i].right.color = UIComponent.colors.white
		self.uiTeamSlots2[i].right.background = "base:texture/ui/components/" .. self.teamColor[i][2]

	end

	-- all slots

	self.uiPlayerSlots = {}
	for i = 1, numberOfSlot do

		local slot = self:AddComponent(activity.playerSlot:New(), "uiPlayerSlot" .. i)
		slot.visible = false
		table.insert(self.uiPlayerSlots, slot)

	end   

	-- visible slots

	self.uiVisibleSlots = {}
	for i = 1, math.min(self.maxSlot, numberOfSlot) do

		local slot = self.uiPlayerSlots[i]
		slot.visible = true
		table.insert(self.uiVisibleSlots, slot)

	end

	-- a scroll bar may be necessary ...

	if (game.settings.UiSettings.playerslotgrid == 0) then
		self.uiScrollBar = self:AddComponent(UIScrollBar:New({ 308, 0 }, 410), "uiScrollBar")
	else
		self.uiScrollBar = self:AddComponent(UIScrollBar:New({ 690, 0 }, 410), "uiScrollBar")
	end

	self.uiScrollBar.OnActionUp = function(_self)  self:Scroll(-1) end
	self.uiScrollBar.OnActionDown = function(_self)	self:Scroll(1) end

	self.uiScrollBar:SetSize(0, self.maxSlot)
	self.maxIndex = 0
	self.curIndex = 0

	-- rearrange slots

	self:Rearrange()

end

-- __ctor -------------------------------------------------------------------

function UIPlayerSlotGrid:__dtor()
end

-- AddPlayer ----------------------------------------------------------------

function UIPlayerSlotGrid:AddSlot(player, button)

    assert(player:IsKindOf(UTPlayer))

    -- if there's an available slot : add the player to the list and update this slot

	local slot = nil
	for i = 1, #self.uiPlayerSlots do

		if (not self.uiPlayerSlots[i].player) then	

			slot = self.uiPlayerSlots[i]
			slot:SetPlayer(player, button)
			self.maxIndex = self.maxIndex + 1
			self.uiScrollBar:SetSize(self.maxIndex, self.maxSlot)
			break

		end

	end

	-- rearrange slots

	self:Rearrange()

	return slot

end

-- GetSlot -------------------------------------------------------------------

function UIPlayerSlotGrid:GetSlot(player)

	for i = 1, #self.uiPlayerSlots do
		if (player == self.uiPlayerSlots[i].player) then	
			return self.uiPlayerSlots[i]
		end
	end

end

-- Rearrange ----------------------------------------------------------------

function UIPlayerSlotGrid:Rearrange()

	-- earase

	for _, slot in ipairs(self.uiPlayerSlots)  do
		slot.visible = false
	end

	-- for team only

	if (0 < #activity.teams) then

		-- construct by team

		local teams = {}
		for i = 1, #activity.teams do
			teams[i] = {}
			self.uiTeamSlots[i].left.visible = false
            if (game.settings.UiSettings.playerslotgrid == 0) then
			    self.uiTeamSlots[i].right.visible = false
            end
			self.uiTeamSlots2[i].left.visible = false
			self.uiTeamSlots2[i].right.visible = false
		end

		-- add slot
		
		for i, slot in ipairs(self.uiPlayerSlots) do

			if (slot.player) then
				if (not slot.player.primary) then
					table.insert(teams[slot.player.team.index], slot)
				end
			else

				-- take for an empty team

				for i, team in ipairs(teams) do

					if (0 == #team) then
						table.insert(team, slot)
						break
					end

				end

			end

		end

		-- change display

		local teamOffset = 0
		local teamOffset2 = 0
		self.uiVisibleSlots = {}
		local index = 1
		for _, team in ipairs(teams) do
			for _, slot in ipairs(team) do
				if (index <= self.maxSlot + self.curIndex and 1 + self.curIndex <= index) then
					table.insert(self.uiVisibleSlots, slot)
					team.nbSlot = (team.nbSlot or 0) + 1
				end
				index = index + 1
			end
		end
		for i = (#self.uiVisibleSlots + 1), self.maxSlot do
			table.insert(self.uiVisibleSlots, self.uiPlayerSlots[i])
		end

		-- visible and correct pos

		for i, slot in ipairs(self.uiVisibleSlots) do
			slot.visible = true
			if (game.settings.UiSettings.playerslotgrid == 1 and i > self.maxSlot / 2) then
				slot:MoveTo( 390, self.horizontalPadding * (i - 1 - self.maxSlot / 2) )
			else
				slot:MoveTo( 0, self.horizontalPadding * (i - 1) )
			end
		end

		-- borders

		local totalsize = 0
		local curPadding = horizPadding[self.slots]
		for i, team in ipairs(teams) do
			if (team.nbSlot) then
				local teamsize = math.min(self.maxSlot, team.nbSlot)
				local size = math.min(teamsize, game.settings.UiSettings.nbplayerslot - totalsize)
				totalsize = totalsize + teamsize
                local size2 = math.min(teamsize, totalsize - game.settings.UiSettings.nbplayerslot)
				self.uiTeamSlots[i].left.visible = true
				self.uiTeamSlots2[i].left.visible = true
				if (self.maxSlot >= self.maxIndex) then
					self.uiTeamSlots[i].right.visible = true
					self.uiTeamSlots2[i].right.visible = true
				end
                if (totalsize - teamsize >= self.slots) then
					self.uiTeamSlots[i].left.rectangle = nil
					self.uiTeamSlots[i].right.rectangle = nil
                else
				    self.uiTeamSlots[i].left.rectangle = { -50, teamOffset, -10, teamOffset + curPadding + self.horizontalPadding * (size - 1) }
				    self.uiTeamSlots[i].right.rectangle = { 310, teamOffset, 330, teamOffset + curPadding + self.horizontalPadding * (size - 1) }
                    teamOffset = teamOffset + self.horizontalPadding * size
                end
                if (totalsize > game.settings.UiSettings.nbplayerslot) then
					self.uiTeamSlots2[i].left.rectangle = { 340, teamOffset2, 380, teamOffset2 + curPadding + self.horizontalPadding * (size2 - 1) }
					self.uiTeamSlots2[i].right.rectangle = { 700, teamOffset2, 720, teamOffset2 + curPadding + self.horizontalPadding * (size2 - 1) }
					teamOffset2 = teamOffset2 + self.horizontalPadding * size2
                end
			end
		end

	else

		-- no team

		for i, slot in ipairs(self.uiVisibleSlots) do
			slot = self.uiPlayerSlots[i + self.curIndex]
			slot.visible = true
			if (game.settings.UiSettings.playerslotgrid == 1 and i > self.maxSlot / 2) then
				slot:MoveTo( 385, self.horizontalPadding * (i - 1 - self.maxSlot / 2) )
			else
				slot:MoveTo( 0, self.horizontalPadding * (i - 1) )
			end
		end

	end

end

-- RemoveSlot ----------------------------------------------------------------

function UIPlayerSlotGrid:RemoveSlot(removedPlayer)

    assert(removedPlayer:IsKindOf(UTPlayer))

    -- search for player, delete and shift !

	local slot = nil
	for i = 1, #self.uiPlayerSlots do

		if (removedPlayer) then

			if (self.uiPlayerSlots[i].player == removedPlayer) then	

				removedPlayer = nil
				slot = self.uiPlayerSlots[i]
				self.uiPlayerSlots[i]:SetPlayer(nil)
				self.maxIndex = self.maxIndex - 1
				self.uiScrollBar:SetSize(self.maxIndex, self.maxSlot)

			end

		else

			self.uiPlayerSlots[i - 1]:SetPlayer(self.uiPlayerSlots[i].player, self.uiPlayerSlots[i].button)
			self.uiPlayerSlots[i - 1].updating = self.uiPlayerSlots[i].updating
			self.uiPlayerSlots[i]:SetPlayer(nil)

		end		

	end

	-- rearrange

	self:Scroll(-1)
	self:Rearrange()

	return slot

end

-- Scroll --------------------------------------------------------------------

function UIPlayerSlotGrid:Scroll(value)

	self.curIndex = self.curIndex + value
	self.curIndex = math.max(self.curIndex, 0)
	self.curIndex = math.min(self.curIndex, math.max(self.maxIndex - self.maxSlot, 0))

	self:Rearrange()

end

-- update --------------------------------------------------------------------

function UIPlayerSlotGrid:Update()

	-- update 

	if (self.uiScrollBar) then self.uiScrollBar:Update()
	end
	
	UIPlayerSlotGrid.maxSlot = self.slots + (self.slots * game.settings.UiSettings.playerslotgrid)

end