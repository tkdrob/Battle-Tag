
--[[--------------------------------------------------------------------------
--
-- File:            UACaptureMax.UILeaderboardItem.lua
--                  Copyright (c) Ubisoft Entertainment. All rights reserved.
--
-- Project:         Ubitoys.Tag
-- Date:            August 13, 2010
--
------------------------------------------------------------------------------
--
-- Description:     ...
--
----------------------------------------------------------------------------]]

--[[ Dependencies ----------------------------------------------------------]]

--[[ Class -----------------------------------------------------------------]]

UACaptureMax.UILeaderboardItem = UTClass(UILeaderboardItem)

-- default

UILeaderboardItem.teamColor = {
	{ "UIRedSlot_01.tga", "UIRedSlot_02.tga", "leaderboard_redline.tga" },
	{ "UIBlueSlot_01.tga", "UIBlueSlot_02.tga", "leaderboard_blueline.tga" },	
	{ "UIYellowSlot_01.tga", "UIYellowSlot_02.tga", "leaderboard_yellowline.tga" },	
	{ "UIGreenSlot_01.tga", "UIGreenSlot_02.tga", "leaderboard_greenline.tga" },
	{ "UISilverSlot_01.tga", "UISilverSlot_02.tga", "leaderboard_silverline.tga" },
	{ "UIPurpleSlot_01.tga", "UIPurpleSlot_02.tga", "leaderboard_purpleline.tga" },		
}

-- __ctor ------------------------------------------------------------------

function UACaptureMax.UILeaderboardItem:__ctor(leaderboard, challenger)

    self.uiLeaderboard = leaderboard
    self.challenger = challenger
    self.data = self.challenger.data[self.uiLeaderboard.data]
    self.animationData = {}
    self.columnsDescriptor = {}

	if (self.challenger:IsKindOf(UTPlayer)) then

		--self.uiPanel = self:AddComponent(UIPanel:New(), "uiPanel")
		self.uiPanel = {}
        self.uiPanel.background = "base:texture/ui/components/UILeaderboardPlayerTeamPanel.tga"
		if (#activity.players > 8) then
			self.uiPanel.rectangle = { 0, 18, 380, 46 }
		else
			self.uiPanel.rectangle = { 0, 0, 380, 60 }
		end

		if (self.challenger.gameplayData and self.challenger.rfGunDevice) then
			self.challenger.rfGunDevice.button = self:AddComponent(UIButton:New())
			if (#activity.teams >= 2) then
				self.challenger.rfGunDevice.button.rectangle = {25, 10, 55, 40}
			else
				self.challenger.rfGunDevice.button.rectangle = {10, 10, 50, 40}
			end
			self.challenger.rfGunDevice.button.tip = l"tip239"
			self.challenger.rfGunDevice.button.OnAction = function (_self) 
		
				if (self.challenger.gameplayData[2] == 7) then
					self.challenger.gameplayData[2] = 0
				else
					self.challenger.gameplayData[2] = 7
				end
			end
		end

	end

end

function UACaptureMax.UILeaderboardItem:__dtor()
end

-- CreateGrid --------------------------------------------------------------

function UACaptureMax.UILeaderboardItem:BuildItem()

    self.challenger._DataChanged:Add(self, self.OnDataChanged)

    if (self.challenger:IsKindOf(UTTeam)) then

		-- ITERATIF please

		self.rankedList = {}
        table.foreachi(self.challenger.players, function(index, player)

			player._DataChanged:Add(self, self.OnDataChanged)
			if (not player.primary) then
				local uiLeaderboardItem = self:AddComponent(UACaptureMax.UILeaderboardItem:New(self.uiLeaderboard, player), "uiLeaderboardItem" .. index)
				table.insert(self.rankedList, uiLeaderboardItem)
				uiLeaderboardItem.ranking = index
				uiLeaderboardItem.team = self
				uiLeaderboardItem:BuildItem()
			end

        end )
		self:Sort(true)

    end

end

-- Draw --------------------------------------------------------------------

function UACaptureMax.UILeaderboardItem:Draw()

    -- blend color is there to gray out disconnected players,
    -- warning: blend color has alpha and is a 4f component

    local blendColor = { 1.0, 1.0, 1.0, 1.0 }

    if (self.challenger:IsKindOf(UTPlayer)) then
        blendColor = self.challenger.rfGunDevice and blendColor or { 0.70, 0.65, 0.60, 0.85 }
        self.uiPanel.color = blendColor
    end

	-- special background

	if (self.challenger:IsKindOf(UTTeam)) then

		if (#activity.players > 8 and #activity.teams > 2) then

			quartz.system.drawing.pushcontext()
			quartz.system.drawing.loadtranslation(unpack(self.rectangle))
			quartz.system.drawing.loadcolor3f(unpack(UIComponent.colors.white))
			quartz.system.drawing.loadtexture("base:texture/ui/Leaderboard_Line_Bg.tga")
			quartz.system.drawing.drawtextureh(-35, 0, 385, 8 + 35 * self.numplayers)
			quartz.system.drawing.pop()

		end

        quartz.system.drawing.loadcolor4f(unpack(blendColor))
        quartz.system.drawing.loadtexture("base:texture/Ui/Icons/16x/FlagIcon" .. self.challenger.index .. ".tga")
        quartz.system.drawing.drawtexture(-400 + UIAFP.timeroffset + self.challenger.index * 50, 33 - UIAFP.timeroffset3, -384 + UIAFP.timeroffset + self.challenger.index * 50, 49 - UIAFP.timeroffset3)
        quartz.system.drawing.loadcolor3f(unpack(UIComponent.colors.black))
		quartz.system.drawing.loadfont(UIComponent.fonts.default)
        quartz.system.drawing.drawtext(self.challenger.data.heap.capturegoal, -375 + UIAFP.timeroffset + self.challenger.index * 50, 34 - UIAFP.timeroffset3)

	end

    UIMultiComponent.Draw(self)

    --

	quartz.system.drawing.pushcontext()
    quartz.system.drawing.loadtranslation(unpack(self.rectangle))

	-- panel

	if (self.uiPanel) then
		quartz.system.drawing.loadcolor3f(unpack(UIComponent.colors.white))
		quartz.system.drawing.loadtexture(self.uiPanel.background)
		quartz.system.drawing.drawtexture(unpack(self.uiPanel.rectangle))
	end

	if (not self.challenger.primary) then
		if (self.challenger:IsKindOf(UTTeam)) then
			if (#self.challenger.players > 0) then

			    -- score zone
		
			    if (#activity.players > 8 and #activity.teams > 2) then

				    local position = (25 + 16 * self.numplayers) - 50
				    quartz.system.drawing.loadcolor3f(unpack(UIComponent.colors.white))
				    quartz.system.drawing.loadtexture("base:texture/ui/Leaderboard_Score_Bg.tga")
				    quartz.system.drawing.drawtexture(-105, position + 35, -10, position + 94)

			    end

			    -- borders

			    quartz.system.drawing.loadcolor3f(unpack(UIComponent.colors.white))
			    quartz.system.drawing.loadtexture("base:texture/ui/components/" .. self.teamColor[self.challenger.index][1])
			    if (#activity.players > 8) then
				    if (#activity.teams <= 2) then
					    quartz.system.drawing.drawwindow(-45, 0, -5, 35 + 35 * self.numplayers)
				    else
					    quartz.system.drawing.drawwindow(-45, 0, -5, 8 + 35 * self.numplayers)
				    end
			    else
				    quartz.system.drawing.drawwindow(-45, 0, -5, 25 + 64 * self.numplayers)
			    end

			    quartz.system.drawing.loadcolor3f(unpack(UIComponent.colors.white))
			    quartz.system.drawing.loadtexture("base:texture/ui/components/" .. self.teamColor[self.challenger.index][2])
        
			    if (#activity.players > 8) then
				    if (#activity.teams <= 2) then
					    quartz.system.drawing.drawwindow(385, 0, 395, 35 + 35 * self.numplayers)
				    else
					    quartz.system.drawing.drawwindow(385, 0, 395, 8 + 35 * self.numplayers)
				    end
			    else
				    quartz.system.drawing.drawwindow(385, 0, 395, 25 + 64 * self.numplayers)
			    end

			    if (#activity.teams <= 2 or #activity.players <= 8) then
				    quartz.system.drawing.loadcolor3f(unpack(UIComponent.colors.white))
				    quartz.system.drawing.loadtexture("base:texture/ui/" .. self.teamColor[self.challenger.index][3])
				    quartz.system.drawing.drawtexture(2, 0, 380, 25)
			    end

			    -- name

			    if (#activity.players <= 8 or #activity.teams <= 2) then
				    quartz.system.drawing.loadcolor3f(unpack(UIComponent.colors.white))
				    quartz.system.drawing.loadfont(UIComponent.fonts.header)
				    quartz.system.drawing.drawtextjustified(self.challenger.profile.name, quartz.system.drawing.justification.left, unpack({12, 0, 252, 20 }))
			    end

			    --score

			    if (self.uiLeaderboard.showRanking) then

				    if (#activity.players <= 8 or #activity.teams <= 2) then
					    quartz.system.drawing.loadfont(UIComponent.fonts.header)
					    quartz.system.drawing.loadcolor3f(unpack(UIComponent.colors.darkgray))
					    quartz.system.drawing.drawtextjustified(self.challenger.data.heap.score, quartz.system.drawing.justification.right, unpack({305, 0, 375, 20 }))
				    else
					    local position = (25 + 16 * self.numplayers)
					    quartz.system.drawing.loadfont(UIComponent.fonts.header)
					    quartz.system.drawing.loadcolor3f(unpack(self.challenger.profile.color))
					    quartz.system.drawing.drawtextjustified(self.challenger.data.heap.score, quartz.system.drawing.justification.center, unpack({-105, position + 20,  -35, position + 40 }))	
				    end

			    end

			    -- some information

			    local offset = 0
			    table.foreachi(self.uiLeaderboard.fields, function(index, field)

			        if (field.icon) then

				        quartz.system.drawing.loadcolor3f(unpack(UIComponent.colors.white))
				        quartz.system.drawing.loadtexture(field.icon)
				        if (#activity.teams < 2 and #activity.players > 8 and game.settings.UiSettings.aspectratio == 2) then
					        quartz.system.drawing.drawtexture(200 + offset, 5, 232 + offset, 37)
				        elseif (#activity.players <= 8 or #activity.teams <= 2) then
					        quartz.system.drawing.drawtexture(200 + offset, 10, 232 + offset, 42)
				        else
					        quartz.system.drawing.drawtexture(200 + offset, -10, 232 + offset, 22)
				        end

			        end

				    offset = offset + 33

			    end )

			    -- icon

			    local position
			    if (#activity.players > 8) then
				    position = (25 + 16 * self.numplayers) - 50
			    else
				    position = (25 + 32 * self.numplayers) - 40
			    end
			    if not (#activity.players > 16 and #activity.teams <= 2) then
				    quartz.system.drawing.loadcolor3f(unpack(UIComponent.colors.white))
				    quartz.system.drawing.loadtexture(self.challenger.profile.icon)
				    quartz.system.drawing.drawtexture(-120, position, 0, position + 80)
			    end
		    end

		else
	
			-- hud + player name + icon

			local offset = 5

			quartz.system.drawing.loadcolor4f(unpack(blendColor))
			if ((self.challenger.rfGunDevice) and (not self.challenger.rfGunDevice.timedout)) then
                quartz.system.drawing.loadtexture("base:texture/ui/pictograms/64x/hud_" .. self.challenger.rfGunDevice.classId .. ".tga")
			else
                quartz.system.drawing.loadtexture("base:texture/ui/pictograms/64x/hud_guest.tga")
			end
			quartz.system.drawing.drawtexture(55, offset + 6, 87, offset + 38)

			if (game.settings.UiSettings.teamribbon == 2 and self.challenger.profile.team > 0) then
				quartz.system.drawing.loadcolor3f(unpack(UIComponent.colors.white))
				quartz.system.drawing.loadtexture("base:texture/ui/pictograms/48x/Team_" .. self.challenger.profile.team .. "_Circle.tga")
				if (0 < #activity.teams) then
					quartz.system.drawing.drawtexture(17, offset - 3, 63, offset + 43)
				else
					quartz.system.drawing.drawtexture(0, offset - 10, 60, offset + 50)
				end
			end
			quartz.system.drawing.loadcolor4f(unpack(blendColor))
			quartz.system.drawing.loadtexture("base:texture/Avatars/80x/" .. (self.challenger.data.heap.icon or self.challenger.profile.icon))
		
			quartz.system.drawing.drawtexture(10, offset - 10, 70, offset + 50)
			if (self.challenger.gameplayData[2] == 7) then
				local rectangle = { 60, offset, 70, offset + 10 }
				quartz.system.drawing.loadcolor3f(unpack(UIComponent.colors.white))
				quartz.system.drawing.loadtexture("base:texture/ui/icons/32x/harness_off.tga")	
				quartz.system.drawing.drawtexture(unpack(rectangle))
			elseif (self.challenger.vestconnect) then
				local rectangle = { 60, offset, 70, offset + 10 }
				quartz.system.drawing.loadcolor3f(unpack(UIComponent.colors.white))
				quartz.system.drawing.loadtexture("base:texture/ui/icons/32x/harness_on.tga")	
				quartz.system.drawing.drawtexture(unpack(rectangle))
			end
			if (self.challenger.secondary) then
				local rectangle = { 70, offset, 80, offset + 10 }
				quartz.system.drawing.loadcolor3f(unpack(UIComponent.colors.white))
				quartz.system.drawing.loadtexture("base:texture/ui/icons/32x/dual_guns.tga")	
				quartz.system.drawing.drawtexture(unpack(rectangle))
			end

			-- some information

			local offsetX = 0
			table.foreachi(self.uiLeaderboard.fields, function(index, field)

				if (not self.challenger.team and field.icon) then

					quartz.system.drawing.loadcolor4f(unpack(blendColor))
					quartz.system.drawing.loadtexture(field.icon)
					quartz.system.drawing.drawtexture(200 + offsetX, offset - 20, 232 + offsetX, offset + 12)

				end

				if (#activity.players <= 8) then
					quartz.system.drawing.loadcolor3f(unpack(self.challenger.rfGunDevice and field.color or UIComponent.colors.darkgray))
				else
					quartz.system.drawing.loadcolor3f(unpack(self.challenger.rfGunDevice and field.color or UIComponent.colors.black))
				end
				quartz.system.drawing.loadfont(field.font or UIComponent.fonts.default)

				local justification = field.justification or quartz.system.drawing.justification.center
				justification = quartz.system.bitwise.bitwiseor(justification, quartz.system.drawing.justification.singlelineverticalcenter)

				local rectangle = { (field.position or 200 + offsetX) - 44, offset + 16, (field.position or 200 + offsetX) + 72, offset + 34 }
				if (game.settings.UiSettings.aspectratio == 2 and #activity.teams < 2 and #activity.players > 8) then
					rectangle[2], rectangle[4] = rectangle[2] - 7, rectangle[4] - 7
				end

				local animationData = self.animationData[field.key]
				if (animationData) then

					local time = quartz.system.time.gettimemicroseconds()
					local elapsedTime = time - animationData.time
					animationData.time, animationData.angle = time, math.max(0.0, animationData.angle - elapsedTime * 0.000180 * 4)

					-- scaling depends on text justification

					local w, h = quartz.system.drawing.gettextdimensions(self.data[field.key])

					if (0 ~= quartz.system.bitwise.bitwiseand(justification, quartz.system.drawing.justification.right)) then rectangle[1] = rectangle[3] - w
					elseif (0 ~= quartz.system.bitwise.bitwiseand(justification, quartz.system.drawing.justification.center)) then rectangle[1], rectangle[3] = rectangle[1] + (rectangle[3] - rectangle[1] - w) * 0.5, rectangle[3] - (rectangle[3] - rectangle[1] - w) * 0.5
					else rectangle[3] = rectangle[1] + w
					end

					local scale = 1.0 + math.sin(animationData.angle * 3.141592625 / 180.0) * 0.5
					quartz.system.drawing.loadtextscale(scale)

				end

				quartz.system.drawing.drawtextjustified(self.data[field.key], justification, unpack(rectangle))

				if (animationData) then
					quartz.system.drawing.loadtextscale(1.0)
					if (0.0 >= animationData.angle) then self.animationData[field.key] = nil
					end
				end

				offsetX = offsetX + 35

			end )

			for i, flagdevice in ipairs(activity.flagdevices) do
                if (flagdevice == self.challenger.rfGunDevice) then
                    quartz.system.drawing.loadcolor3f(unpack(UIComponent.colors[UTTeam.profiles[i].teamColor]))
                    break
                elseif (#activity.players <= 8) then
				    quartz.system.drawing.loadcolor3f(unpack(UIComponent.colors.darkgray))
			    else
				    quartz.system.drawing.loadcolor3f(unpack(UIComponent.colors.black))
			    end
            end
			quartz.system.drawing.loadfont(UIComponent.fonts.default)
			quartz.system.drawing.drawtext(self.challenger.profile.name, 90, offset + 18 )

		end
	end

	quartz.system.drawing.pop()

end

-- OnDataChanged  ----------------------------------------------------------

function UACaptureMax.UILeaderboardItem:OnDataChanged(_entity, _key, _value)

	if (self.uiLeaderboard.itemsSortField == _key) then

		if (self.team) then
			self.team:Sort()
		else
			self.uiLeaderboard:Sort()
		end

	end

end

-- RemoveDataChangedEvents ------------------------------------------------

function UACaptureMax.UILeaderboardItem:RemoveDataChangedEvents()

	self.challenger._DataChanged:Remove(self, self.OnDataChanged)

    if (0 < #activity.teams) then

        table.foreachi(self.challenger.players, function(index, player)
            player._DataChanged:Remove(self, self.OnDataChanged)
        end )

    end

end

-- Sort ---------------------------------------------------------------------

function UACaptureMax.UILeaderboardItem:Sort(init)

	-- sorting now !

	function sorting(item1, item2)
		if (item1.data[self.uiLeaderboard.itemsSortField] > item2.data[self.uiLeaderboard.itemsSortField]) then 
			return true
		elseif (item1.data[self.uiLeaderboard.itemsSortField] == item2.data[self.uiLeaderboard.itemsSortField] and item1.ranking < item2.ranking) then 
			return true
		end
	end

	table.sort(self.rankedList, sorting)
	
	-- then compute new position

    for index, item in ipairs(self.rankedList) do

        item.ranking = index

		-- make a move ...

		if (init) then
			if (#activity.players > 8) then
				if (#activity.teams <= 2) then
					item:MoveTo(0, 27 + 35 * (index - 1))
				else
					item:MoveTo(0, 0 + 35 * (index - 1))
				end
			else
				item:MoveTo(0, 27 + 64 * (index - 1))
			end
		else

			if (item.mvtFx) then

				UIManager:RemoveFx(item.mvtFx)
				item.mvtFx = nil

			end
			if (#activity.players > 8) then
				item.mvtFx = UIManager:AddFx("position", { duration = 0.8, __self = item, from = { 0, item.rectangle[2]}, to = { 0, 27 + 35 * (index - 1) }, type = "descelerate" })
			else
				item.mvtFx = UIManager:AddFx("position", { duration = 0.8, __self = item, from = { 0, item.rectangle[2]}, to = { 0, 27 + 64 * (index - 1) }, type = "descelerate" })
			end
		end

	end

end