
--[[--------------------------------------------------------------------------
--
-- File:            UILeaderboard.lua
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

require "Ui/UILeaderboardItem"
require "Ui/UILeaderboardEmptySlot"

--[[ Class -----------------------------------------------------------------]]

UTClass.UILeaderboard(UIMultiComponent)

UILeaderboard.showRanking = true
UILeaderboard.smallPanel = false
UILeaderboard.largePanel = true

UILeaderboard.uiItem = UILeaderboardItem

-- sort mode 

UILeaderboard.itemsSortField = "score"

UILeaderboard.TeamColor = 
{
	["red"] = 1,
	["blue"] = 2,
	["yellow"] = 3,
	["green"] = 4,	
	["silver"] = 5,
	["purple"] = 6,
}

-- __ctor --------------------------------------------------------------------

function UILeaderboard:__ctor()

    self.rectangle = { 0, 0, 400, 0 }
    self.showSlotEmpty = false

end

-- __dtor --------------------------------------------------------------------

function UILeaderboard:__dtor()

    -- remove datachanged event

end

-- Build ---------------------------------------------------------------------

function UILeaderboard:Build(challengers, data)

	-- set in activity

	activity.uiLeaderboard = self

	-- ranking

	self.uiRankingbitmap = {}
    table.foreachi(challengers, function(index, challenger) 

		if (self.showRanking and index <= 6) then

			self.uiRankingbitmap[index] = self:AddComponent(UIPicture:New(), "uiRankingbitmap" .. index)
			self.uiRankingbitmap[index].color = UIComponent.colors.white
			self.uiRankingbitmap[index].texture = "base:texture/ui/afp_number_" .. index .. ".tga"

		end

	end)
	
	-- data used on challenger (baked or heap)

	self.data = data or "heap"

	-- create an item for each challenger 

    self.rankedList = {}
    table.foreachi(challengers, function (index, challenger) 
		if (challenger:IsKindOf(UTPlayer) or challenger:IsKindOf(UTTeam) and #challenger.players > 0) then
        
			local uiLeaderboardItem = self:AddComponent(self.uiItem:New(self, challenger), "uiLeaderboardItem" .. #self.rankedList + 1)
			uiLeaderboardItem.ranking = index
			uiLeaderboardItem:BuildItem()
			table.insert(self.rankedList, uiLeaderboardItem)
		end

	end )

	self:Sort(true)

	self.uiSlotEmpty = {}

	if (self.showSlotEmpty == true) then
		self.uiSlotEmpty = self:AddComponent(UILeaderboardEmptySlot:New(self), "uiSlotEmpty")
	end

    -- leadership

    self.uiLeadership = UIMultiComponent:New()

    self.uiLeadership.background = self.uiLeadership:AddComponent(UIBitmap:New("base:texture/ui/leaderboard_blueleader.tga"))
    self.uiLeadership.rectangle = self.uiLeadership.background.rectangle

    self.uiLeadership.title = self.uiLeadership:AddComponent(UILabel:New({ 10, 32, 354, 69 }, "The Blue Team"))
    self.uiLeadership.title.font = UIComponent.fonts.title
    self.uiLeadership.title.fontJustification = quartz.system.drawing.justification.right + quartz.system.drawing.justification.singlelineverticalcenter

    self.uiLeadership.bitmap = self.uiLeadership:AddComponent(UIBitmap:New("base:texture/ui/leaderboard_blueteam.tga"))
    self.uiLeadership.bitmap.rectangle = { 58 - self.uiLeadership.bitmap.rectangle[3] * 0.5, self.uiLeadership.rectangle[4] * 0.5 - self.uiLeadership.bitmap.rectangle[4] * 0.5, 58 + self.uiLeadership.bitmap.rectangle[3] * 0.5, self.uiLeadership.rectangle[4] * 0.5 + self.uiLeadership.bitmap.rectangle[4] * 0.5 }

    self.uiLeadership.text = self.uiLeadership:AddComponent(UILabel:New({ 4, 76, 408, 96 }, "takes the lead"))
    self.uiLeadership.fontColor = UIComponent.colors.black
    self.uiLeadership.text.fontJustification = quartz.system.drawing.justification.right + quartz.system.drawing.justification.singlelineverticalcenter

    self.uiLeadership.visible = false

end

-- Build ---------------------------------------------------------------------

function UILeaderboard:Draw()

    UIMultiComponent.Draw(self)
    
    if (self.uiLeadership.visible) then

        quartz.system.drawing.pushcontext()
        quartz.system.drawing.loadidentity()

        self.uiLeadership:Draw()

        quartz.system.drawing.pop()

    end

end

-- RegisterFields ------------------------------------------------------------

function UILeaderboard:RegisterField(fieldKey, fieldIcon, fieldRules, fieldPosition, fieldJustification, fieldFont, fieldColor )

    assert(type(fieldKey) == "string", "Assertion failed in UILeaderboard:RegisterField() : key is not a string")

    self.fields = self.fields or {}
    local fieldDescriptor = { key = fieldKey, icon = fieldIcon, position = fieldPosition, justification = fieldJustification , font = fieldFont, color = fieldColor}
    table.insert(self.fields, fieldDescriptor)

end

-- RemoveDataChangedEvents -----------------------------------------------

function UILeaderboard:RemoveDataChangedEvents()

    table.foreachi(self.rankedList, function (index, item)

        item:RemoveDataChangedEvents()

    end )

end

-- Sort ----------------------------------------------------------------------

function UILeaderboard:Sort(init)

	-- sorting now !

	function sorting(item1, item2)
		if (item1.challenger.data[self.data][self.itemsSortField] > item2.challenger.data[self.data][self.itemsSortField]) then 
			return true
		elseif (item1.challenger.data[self.data][self.itemsSortField] == item2.challenger.data[self.data][self.itemsSortField] and item1.ranking < item2.ranking) then 
			return true
		end
	end

	table.sort(self.rankedList, sorting)
	
	-- then compute new position

	local itemOffset = 0
    local XitemOffset = -290
	if (game.settings.UiSettings.aspectratio == 2) then
		if (#activity.teams >= 2 and #activity.players > 16) then
			itemOffset = -270
		elseif (#activity.teams < 2 and #activity.players > 8) then
			itemOffset = -30
        else
            itemOffset = -35
		end
	end
    for index, item in ipairs(self.rankedList) do

		-- make a move ...

		if (init) then

	        item.ranking = index
			if (game.settings.UiSettings.aspectratio == 2) then
				if (#activity.teams >= 2 and #activity.players > 16) then
					item:MoveTo(itemOffset, 0)
				elseif (#activity.teams < 2 and #activity.players > 8) then
					if (index <= 12) then
						item:MoveTo(-220, itemOffset)
					else
						item:MoveTo(165, itemOffset - 708)
					end
				else
					item:MoveTo(0, itemOffset)
				end
			else
				item:MoveTo(0, itemOffset)
			end

		else

			if (item.ranking ~= index) then

				local currank = item.ranking
				item.ranking = index

				if (item.mvtFx) then

					UIManager:RemoveFx(item.mvtFx)
					item.mvtFx = nil

				end

				if (activity.uiAFP and #activity.teams <= 0 and itemOffset <= 0) then

					activity.uiAFP:PushLine(item.challenger.profile.name .. " " .. l"ingame001", UIComponent.colors.orange, "base:texture/Ui/Icons/16x/Star.tga")

				end

				if (activity.uiAFP and item.challenger:IsKindOf(UTTeam) and game and game.gameMaster and game.gameMaster.ingame and not activity.dontDisplayScore and itemOffset <= 0) then

					activity.uiAFP:PushLine(l("ingame0" .. 55 + UILeaderboard.TeamColor[item.challenger.profile.teamColor]), UIComponent.colors[item.challenger.profile.teamColor], "base:texture/Ui/Icons/16x/Star" .. item.challenger.profile.teamColor .. ".tga")
					game.gameMaster:RegisterSound({ paths = {"base:audio/gamemaster/DLG_GM_FRAG_TEAM_0" .. UILeaderboard.TeamColor[item.challenger.profile.teamColor] ..".wav"}, priority = 2})
					self:UpdateLeadership(item.challenger)

				end

				--if (#activity.teams == 2 and #activity.players > 16 and game.settings.UiSettings.aspectratio == 2) then
                if (MultiColumn) then
					item.mvtFx = UIManager:AddFx("position", { duration = 0.8, __self = item, from = {item.rectangle[1], 0}, to = { itemOffset, 0 }, type = "descelerate" })
				elseif (#activity.teams < 2 and #activity.players > 8 and game.settings.UiSettings.aspectratio == 2) then
					item.mvtFx = UIManager:AddFx("position", { duration = 0.8, __self = item, from = {-220 + math.floor(currank / 13) * 385, item.rectangle[2] - math.floor(currank / 13) * 708}, to = {-220 + math.floor(index / 13) * 385, itemOffset - math.floor(index / 13) * 708}, type = "descelerate" })
				else
					item.mvtFx = UIManager:AddFx("position", { duration = 0.8, __self = item, from = {0, item.rectangle[2]}, to = { 0, itemOffset }, type = "descelerate" })
				end

			end

		end
		
        -- ranking

		if (self.showRanking and index <= 3) then

			if (item.challenger:IsKindOf(UTTeam)) then
				self.uiRankingbitmap[index].rectangle = {
					-140,
					itemOffset,
					-90,
					itemOffset + 50,
				}
			else
				self.uiRankingbitmap[index].rectangle = {
					-60,
					itemOffset,
					-10,
					itemOffset + 50,
				}
			end
            if (MultiColumn) then
                self.uiRankingbitmap[index].rectangle = { XitemOffset, -40, XitemOffset + 50 , 5 }
            end
			--if (game.settings.UiSettings.aspectratio == 2 and (#activity.players > 16 and #activity.teams == 2 or #activity.players > 8 and #activity.teams < 2)) then
            if (game.settings.UiSettings.aspectratio == 2 and #activity.players > 8 and #activity.teams < 2) then
				self.uiRankingbitmap[index].rectangle = nil
			end

		end

		-- next one

		item.numplayers = 0
		if (item.challenger:IsKindOf(UTTeam)) then
			for i, player in ipairs(item.challenger.players) do
				if (not player.primary) then
					item.numplayers = item.numplayers + 1
				end
			end
		else
			for i, player in ipairs(item.challenger) do
				if (not player.primary) then
					item.numplayers = item.numplayers + 1
				end
			end
		end
		if (item.challenger:IsKindOf(UTTeam)) then
			if (#activity.players > 8) then
				if (#activity.players > 16) then
					if (MultiColumn) then
				 	  	if (#activity.teams <= 2) then
							itemOffset = itemOffset + 440
							XitemOffset = XitemOffset + 450					
						end
						if (#activity.teams == 3) then
							itemOffset = itemOffset + 280
							XitemOffset = XitemOffset + 280 
						end
						if (#activity.teams == 4) then
						   	itemOffset = itemOffset + 220
						   	XitemOffset = XitemOffset + 220
						end
					else
						itemOffset = itemOffset + 440
					end
				elseif (#activity.teams >= 2 and #activity.players > 12) then
                    itemOffset = itemOffset + 40 + (35 * item.numplayers)
                else
					itemOffset = itemOffset + 45 + (35 * item.numplayers)
				end
			else
				itemOffset = itemOffset + 30 + (64 * item.numplayers)
			end
		elseif (not item.challenger.primary) then
			if (#activity.players > 8 and game.settings.UiSettings.aspectratio == 2) then
				if (self.largePanel) then
					itemOffset = itemOffset + 59
				else
					itemOffset = itemOffset + 45
				end
			else
				if (self.largePanel) then
					itemOffset = itemOffset + 80
				else
					itemOffset = itemOffset + 65
				end
			end
		end

	end

end

-- UpdateLeadership ----------------------------------------------------------

function UILeaderboard:UpdateLeadership(challenger)

    self.leader = challenger

    if (challenger and challenger:IsKindOf(UTTeam)) then
        if (not self.uiLeadership.visible) then

            local viewportWidth, viewportHeight, inverseScale = quartz.system.drawing.getviewportdimensions()
            local viewportAspectRatio = viewportHeight / viewportWidth

	        local textureAspectRatio = 720 / 960
	        if (viewportAspectRatio > textureAspectRatio) then
				inverseScale = viewportWidth / 960
	        else
				inverseScale = viewportHeight / 720
			end

            --print("���������������������������������������������������")
            --print("viewportWidth", viewportWidth)
            --print("viewportHeight", viewportHeight)
            --print("viewportAspectRatio", viewportAspectRatio)
            --print("textureAspectRatio", textureAspectRatio)
            --print("inverseScale", inverseScale)

            self.uiLeadership.leader = challenger
            self.uiLeadership.visible = true

            self.uiLeadership.background.bitmap = "base:texture/ui/leaderboard_" .. challenger.profile.teamColor .. "leader.tga"
            quartz.system.drawing.loadtexture(self.uiLeadership.background.bitmap)
            local width, height = quartz.system.drawing.gettexturedimensions()
                width, height = width * inverseScale, height * inverseScale
            self.uiLeadership.background.rectangle = { 0, 0, width, height }
            self.uiLeadership.rectangle = self.uiLeadership.background.rectangle

            self.uiLeadership.title.text = challenger.profile.name
            self.uiLeadership.title.font = UIComponent.fonts.title
            self.uiLeadership.title.fontJustification = quartz.system.drawing.justification.right + quartz.system.drawing.justification.singlelineverticalcenter
            self.uiLeadership.title.rectangle = { 10 * inverseScale, 32 * inverseScale, 354 * inverseScale, 69 * inverseScale }

            self.uiLeadership.bitmap.bitmap = challenger.profile.icon
            quartz.system.drawing.loadtexture(self.uiLeadership.bitmap.bitmap)
            local _width, _height = quartz.system.drawing.gettexturedimensions()
                _width, _height = _width * inverseScale, _height * inverseScale
            local _scale = 1.5 * 0.5
            self.uiLeadership.bitmap.rectangle = { 80 - _width * _scale, 110 - _height * _scale, 80 + _width * _scale, 110 + _height * _scale }
            for i = 1, 4 do self.uiLeadership.bitmap.rectangle[i] = self.uiLeadership.bitmap.rectangle[i] * inverseScale end

            self.uiLeadership.text.text = l "ingame001"
            self.uiLeadership.text.font = UIComponent.fonts.header
            self.uiLeadership.text.fontColor = UIComponent.colors.darkgray
            self.uiLeadership.text.fontJustification = quartz.system.drawing.justification.right + quartz.system.drawing.justification.singlelineverticalcenter
            self.uiLeadership.text.rectangle = { 4 * inverseScale, 76 * inverseScale, 408 * inverseScale, 96 * inverseScale }

            self.uiLeadership:MoveTo((viewportWidth - width) * 0.5, (viewportHeight - height) * 0.5)

            self.uiLeadership.delegate = function ()

                self.uiLeadership.visible = false
                self.uiLeadership.fx = nil

                if (self.leader ~= self.uiLeadership.leader) then
                    self:UpdateLeadership(self.leader)
                end
            end

            local positions = {
                { self.uiLeadership.rectangle[1] + viewportWidth, self.uiLeadership.rectangle[2] },
                { self.uiLeadership.rectangle[1], self.uiLeadership.rectangle[2] },
                { self.uiLeadership.rectangle[1] - viewportWidth, self.uiLeadership.rectangle[2] },
            }

            self.uiLeadership.fx = {
                UIManager:AddFx("position", { duration = 1.0, __self = self.uiLeadership, from = positions[1], to = positions[2], type = "descelerate" }),
                UIManager:AddFx("position", { duration = 1.0, __self = self.uiLeadership, from = positions[2], to = positions[3], type = "accelerate", timeOffset = 1.5 }),
                UIManager:AddFx("callback", { timeOffset = 3.0, __function = self.uiLeadership.delegate })
            }

        end
    end

end