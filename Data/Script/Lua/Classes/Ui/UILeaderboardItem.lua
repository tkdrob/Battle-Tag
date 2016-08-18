
--[[--------------------------------------------------------------------------
--
-- File:            UILeaderboardItem.lua
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

require "Ui/UIPanel"
require "Ui/UIGrid"

--[[ Class -----------------------------------------------------------------]]

UTClass.UILeaderboardItem(UIMultiComponent)

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

function UILeaderboardItem:__ctor(leaderboard, challenger)

    self.uiLeaderboard = leaderboard
    self.challenger = challenger
    self.data = self.challenger.data[self.uiLeaderboard.data]
    self.animationData = {}
    self.columnsDescriptor = {}

	if (self.challenger:IsKindOf(UTPlayer)) then

		self.uiPanel = {}
        self.uiPanel.color = unpack(UIComponent.colors.white)
		if (self.challenger.team or not self.uiLeaderboard.largePanel) then
			if (#activity.players > 8) then
				--self.uiPanel.background = "base:texture/ui/components/UILeaderboardPlayerTeamSmallPanel.tga"
                self.uiPanel.background = "base:texture/ui/Ranking_Banner_MiddleBG.tga"
				if (MultiColumn and #activity.teams > 2) then
					if (#activity.teams == 3) then
                        self.uiPanel.rectangle = { 0, 18, 220, 40 }
                    end
					if (#activity.teams == 4) then
                        self.uiPanel.rectangle = { 0, 18, 160, 40 }
                    end 
				else
				    self.uiPanel.rectangle = { 0, 13, 380, 41 }
                end
			else
				self.uiPanel.background = "base:texture/ui/components/UILeaderboardPlayerTeamPanel.tga"
				self.uiPanel.rectangle = { 0, 0, 380, 60 }
			end
		else
			self.uiPanel.background = "base:texture/ui/components/UILeaderboardPlayerPanel.tga"
            if (game.settings.UiSettings.aspectratio == 2 and #activity.players > 8) then
				if (self.uiLeaderboard.smallPanel) then
					--self.uiPanel.background = "base:texture/ui/components/UILeaderboardPlayerSmallPanel.tga"
					self.uiPanel.rectangle = { 0, 0, 310, 58 }
				else
					self.uiPanel.rectangle = { 0, 0, 380, 58 }
				end
			else
				if (self.uiLeaderboard.smallPanel) then
					--self.uiPanel.background = "base:texture/ui/components/UILeaderboardPlayerSmallPanel.tga"
					self.uiPanel.rectangle = { 0, 0, 310, 70 }
				else
					self.uiPanel.rectangle = { 0, 0, 380, 70 }
				end			
			end
		end

		if (self.challenger.gameplayData and self.challenger.rfGunDevice) then
			self.challenger.rfGunDevice.button = self:AddComponent(UIButton:New())
			self.challenger.rfGunDevice.button.rectangle = {25, 10, 55, 40}
            if (#activity.teams == 1) then
				self.challenger.rfGunDevice.button.rectangle = {10, 10, 50, 40}
			end
            if (MultiColumn and #activity.teams > 2) then
                self.challenger.rfGunDevice.button.rectangle = {-25, 10, 0, 40}
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

-- __dtor ------------------------------------------------------------------

function UILeaderboardItem:__dtor()
end

-- CreateGrid --------------------------------------------------------------

function UILeaderboardItem:BuildItem()

    self.challenger._DataChanged:Add(self, self.OnDataChanged)

    if (self.challenger:IsKindOf(UTTeam)) then

		-- ITERATIF please

		self.rankedList = {}
        table.foreachi(self.challenger.players, function(index, player)

			player._DataChanged:Add(self, self.OnDataChanged)
			if (not player.primary) then
				local uiLeaderboardItem = self:AddComponent(UILeaderboardItem:New(self.uiLeaderboard, player), "uiLeaderboardItem" .. index)
				table.insert(self.rankedList, uiLeaderboardItem)
				uiLeaderboardItem.ranking = index
				uiLeaderboardItem.team = self
				uiLeaderboardItem:BuildItem()
			end

        end )
		self:Sort(true)

    end

end

function UILeaderboardItem:Draw()

    -- blend color is there to gray out disconnected players,
    -- warning: blend color has alpha and is a 4f component

    local blendColor = { 1.0, 1.0, 1.0, 1.0 }

    if (activity.category ~= UTActivity.categories.single and self.challenger:IsKindOf(UTPlayer)) then
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
			if (MultiColumn and #activity.teams > 2) then
                --if (#activity.teams == 2) then quartz.system.drawing.drawtexture(-35, 25, 385, 8 + 35 * self.numplayers) end
				if (#activity.teams == 3) then quartz.system.drawing.drawtexture(-35, 25, 220, 33 + 35 * self.numplayers) end
				if (#activity.teams == 4) then quartz.system.drawing.drawtexture(-35, 25, 165, 33 + 35 * self.numplayers) end
			elseif (#activity.teams >= 2 and #activity.players > 12) then
                quartz.system.drawing.drawtexture(-35, 0, 385, 35 + 35 * self.numplayers)
            else
                quartz.system.drawing.drawtexture(-35, 25, 380, 8 + 35 * self.numplayers)
			end
			quartz.system.drawing.pop()

		end

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
		
			    if (#activity.players > 8 and #activity.teams > 2 and game.settings.UiSettings.aspectratio < 2) then
				    local position = (25 + 16 * self.numplayers) - 50
				    quartz.system.drawing.loadcolor3f(unpack(UIComponent.colors.white))
				    quartz.system.drawing.loadtexture("base:texture/ui/Leaderboard_Score_Bg.tga")
				    quartz.system.drawing.drawtexture(-105, position + 35, -10, position + 94)
			    end

			    -- borders

			    quartz.system.drawing.loadcolor3f(unpack(UIComponent.colors.white))
			    quartz.system.drawing.loadtexture("base:texture/ui/components/" .. self.teamColor[self.challenger.index][1])
			    if (#activity.players > 8) then
				    if (MultiColumn and #activity.teams > 2) then
					    --quartz.system.drawing.drawwindow(-45, 0, -5, 35 + 35 * self.numplayers)
				        quartz.system.drawing.loadtexture("base:texture/ui/components/" .. self.teamColor[self.challenger.index][2])
					    quartz.system.drawing.drawwindow(-45, 0, -40, 35 + 35 * self.numplayers)
				    else
                        --quartz.system.drawing.drawwindow(-45, 0, -5, 35 + 35 * self.numplayers)
					    quartz.system.drawing.drawwindow(-45, 0, -5, 35 + 35 * self.numplayers)
				    end
			    else
				    quartz.system.drawing.drawwindow(-45, 0, -5, 25 + 64 * self.numplayers)
			    end

			    quartz.system.drawing.loadcolor3f(unpack(UIComponent.colors.white))
			    quartz.system.drawing.loadtexture("base:texture/ui/components/" .. self.teamColor[self.challenger.index][2])
        
			    if (#activity.players > 8) then
                    if (MultiColumn and #activity.teams > 2) then
						if (#activity.teams == 3) then
                            quartz.system.drawing.drawwindow(220, 0, 225, 35 + 35 * self.numplayers)
                        end
						if (#activity.teams == 4) then
                            quartz.system.drawing.drawwindow(165, 0, 170, 35 + 35 * self.numplayers)
                        end
				    elseif (#activity.teams <= 2) then
					    quartz.system.drawing.drawwindow(385, 0, 395, 35 + 35 * self.numplayers)
				    else
					    quartz.system.drawing.drawwindow(385, 0, 395, 35 + 35 * self.numplayers)
				    end
			    else
				    quartz.system.drawing.drawwindow(385, 0, 395, 25 + 64 * self.numplayers)
			    end

				quartz.system.drawing.loadcolor3f(unpack(UIComponent.colors.white))
				quartz.system.drawing.loadtexture("base:texture/ui/" .. self.teamColor[self.challenger.index][3])
				if (MultiColumn and #activity.teams > 2) then
				    if (#activity.teams == 3) then
                        quartz.system.drawing.drawtexture(-35, 0, 217, 25)
                    end
				    if (#activity.teams == 4) then
                        quartz.system.drawing.drawtexture(-35, 0, 162, 25)
                    end
				else    
				    quartz.system.drawing.drawtexture(2, 0, 380, 25)
				end

			    -- name

				quartz.system.drawing.loadcolor3f(unpack(UIComponent.colors.white))
				quartz.system.drawing.loadfont(UIComponent.fonts.header)
                if (MultiColumn and #activity.teams > 2) then
                    quartz.system.drawing.loadfont(UIComponent.fonts.default)
				    if(#activity.teams == 3) then
                        quartz.system.drawing.drawtextjustified(self.challenger.profile.name, quartz.system.drawing.justification.left, unpack({-32, 5, 210, 25 }))
                    end
				    if(#activity.teams == 4) then
                        quartz.system.drawing.drawtextjustified(self.challenger.profile.name, quartz.system.drawing.justification.left, unpack({-32, 5, 155, 25 }))
                    end
                elseif (#activity.players <= 8 or #activity.teams <= 2) then
				    quartz.system.drawing.drawtextjustified(self.challenger.profile.name, quartz.system.drawing.justification.left, unpack({12, 0, 252, 20 }))
			    end

			    --score

			    --quartz.system.drawing.loadcolor3f(unpack(self.challenger.profile.color))
			    if (self.uiLeaderboard.showRanking) then

				    quartz.system.drawing.loadfont(UIComponent.fonts.header)
                    quartz.system.drawing.loadcolor3f(unpack(UIComponent.colors.darkgray))
				    if (MultiColumn and #activity.teams > 2) then
				    	if (#activity.teams == 3) then
                            quartz.system.drawing.drawtextjustified(self.challenger.data.heap.score, quartz.system.drawing.justification.right, unpack({107, 2, 215, 22 }))
                        end
				    	if (#activity.teams == 4) then
                            quartz.system.drawing.drawtextjustified(self.challenger.data.heap.score, quartz.system.drawing.justification.right, unpack({053, 2, 160, 22 }))
                        end
				    elseif (#activity.players <= 8 or #activity.teams <= 2) then
					    quartz.system.drawing.drawtextjustified(self.challenger.data.heap.score, quartz.system.drawing.justification.right, unpack({300, 0, 370, 20 }))
				    else
					    local position = (25 + 16 * self.numplayers)
					    quartz.system.drawing.loadcolor3f(unpack(self.challenger.profile.color))
					    quartz.system.drawing.drawtextjustified(self.challenger.data.heap.score, quartz.system.drawing.justification.center, unpack({-110, position + 20, -40, position + 40 }))	
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
				        elseif not (MultiColumn and #activity.teams > 2) then
					        quartz.system.drawing.drawtexture(200 + offset, -10, 232 + offset, 22)
				        end

			        end

				    offset = offset + 40

			    end )

			    -- icon

			    local yposition 
			    local xposition = -120
			    local yheight = 80
			    if (#activity.players > 8) then
			        if (MultiColumn) then
			            yposition = -45
			            yheight = 60
			            if (#activity.teams == 2) then xposition = 130 end
			            if (#activity.teams == 3) then xposition = 40 end
			            if (#activity.teams == 4) then xposition = 12 end
			        else
				        yposition = (25 + 16 * self.numplayers) - 50
				    end  
			    else
				    yposition = (25 + 32 * self.numplayers) - 40
			    end
				quartz.system.drawing.loadcolor3f(unpack(UIComponent.colors.white))
				quartz.system.drawing.loadtexture(self.challenger.profile.icon)
				quartz.system.drawing.drawtexture(xposition, yposition, xposition+120, yposition + yheight)
			end

		else
	
			-- hud + player name + icon

			local offset = 10
			if (self.challenger.team or not self.uiLeaderboard.largePanel) then
				offset = 5
			end
            local Xoffset = 0

			quartz.system.drawing.loadcolor4f(unpack(blendColor))
			if (self.challenger.rfGunDevice and not self.challenger.rfGunDevice.timedout) then
                quartz.system.drawing.loadtexture("base:texture/ui/pictograms/64x/hud_" .. self.challenger.rfGunDevice.classId .. ".tga")
			else
                quartz.system.drawing.loadtexture("base:texture/ui/pictograms/64x/hud_guest.tga")
			end
			if (MultiColumn and #activity.teams > 2) then
			    quartz.system.drawing.drawtexture(5, offset, 25, offset + 20)
			else
			    quartz.system.drawing.drawtexture(55, offset + 6, 87, offset + 38)
			end

			if (game.settings.UiSettings.teamribbon == 2 and self.challenger.profile.team > 0) then
				quartz.system.drawing.loadcolor3f(unpack(UIComponent.colors.white))
				quartz.system.drawing.loadtexture("base:texture/ui/pictograms/48x/Team_" .. self.challenger.profile.team .. "_Circle.tga")
				if (0 < #activity.teams) then
					if (#activity.teams == 2 or #activity.players <= 16 or game.settings.UiSettings.aspectratio ~= 2) then
						quartz.system.drawing.drawtexture(10, offset - 3, 56, offset + 43)
					elseif (MultiColumn and #activity.teams > 2) then
                        quartz.system.drawing.drawtexture(-37, offset, 3, offset + 40)
                    else
						quartz.system.drawing.drawtexture(-35, offset, 5, offset + 40)
					end	
				else
					quartz.system.drawing.drawtexture(0, offset - 10, 60, offset + 50)
				end
			end
			quartz.system.drawing.loadcolor4f(unpack(blendColor))
			quartz.system.drawing.loadtexture("base:texture/Avatars/80x/" .. (self.challenger.data.heap.icon or self.challenger.profile.icon))
			if (self.challenger.team) then
				-- compress to save space for 3 & 4 team games
				if (MultiColumn and #activity.teams > 2) then
                    quartz.system.drawing.drawtexture(-52, offset - 10, 18, offset + 50)
					Xoffset = -37
                else
                    quartz.system.drawing.drawtexture(Xoffset - 2, offset - 10, Xoffset + 68, offset + 50)
				end
					
				quartz.system.drawing.loadcolor3f(unpack(UIComponent.colors.white))
                local rectangle = { Xoffset + 60, offset, Xoffset + 70, offset + 10 }
                if (self.challenger.gameplayData[2] == 7) then
					quartz.system.drawing.loadtexture("base:texture/ui/icons/32x/harness_off.tga")	
					quartz.system.drawing.drawtexture(unpack(rectangle))
				elseif (self.challenger.vestconnect) then
					quartz.system.drawing.loadtexture("base:texture/ui/icons/32x/harness_on.tga")	
					quartz.system.drawing.drawtexture(unpack(rectangle))
				end
				if (self.challenger.secondary) then
					local rectangle = { Xoffset + 70, offset, Xoffset + 80, offset + 10 }
					quartz.system.drawing.loadtexture("base:texture/ui/icons/32x/dual_guns.tga")	
					quartz.system.drawing.drawtexture(unpack(rectangle))
				end
			else
				quartz.system.drawing.drawtexture(-10, offset - 20, 70, offset + 60)
				if (activity.category ~= UTActivity.categories.single) then
                    if (self.challenger.gameplayData) then
					    local rectangle = { 40, offset - 10, 50, offset }
					    quartz.system.drawing.loadcolor3f(unpack(UIComponent.colors.white))
				        if (self.challenger.gameplayData[2] == 7) then
					        quartz.system.drawing.loadtexture("base:texture/ui/icons/32x/harness_off.tga")	
					        quartz.system.drawing.drawtexture(unpack(rectangle))
				        elseif (self.challenger.vestconnect) then
					        quartz.system.drawing.loadtexture("base:texture/ui/icons/32x/harness_on.tga")	
					        quartz.system.drawing.drawtexture(unpack(rectangle))
				        end
                    end
				end
				if (self.challenger.secondary) then
					local rectangle = { 50, offset - 10, 60, offset }
					quartz.system.drawing.loadcolor3f(unpack(UIComponent.colors.white))
					quartz.system.drawing.loadtexture("base:texture/ui/icons/32x/dual_guns.tga")	
					quartz.system.drawing.drawtexture(unpack(rectangle))
				end
			end

			quartz.system.drawing.loadfont(UIComponent.fonts.default)
            local offsetY = offset
            --[[if (#activity.teams >= 2 and #activity.players > 8) then
                offsetY = offsetY - 7
            --elseif (MultiColumn or #activity.teams > 2 and #activity.players > 8) then
            elseif (MultiColumn) then
                offsetY = offsetY - 4
            end]]
            if (#activity.teams >= 2 and #activity.players > 8) then
                offsetY = offsetY - 4
            end
            if (#activity.players <= 8) then
				quartz.system.drawing.loadcolor3f(unpack(UIComponent.colors.darkgray))
			else
				quartz.system.drawing.loadcolor3f(unpack(UIComponent.colors.black))
			end
            if (MultiColumn and #activity.teams > 2) then
                quartz.system.drawing.drawtext(self.challenger.profile.name, 10, offsetY + 20)
            elseif (#activity.teams == 0) then
                quartz.system.drawing.drawtext(self.challenger.profile.name, 90, offsetY + 11)
            else
                quartz.system.drawing.drawtext(self.challenger.profile.name, 90, offsetY + 18)
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

				--[[if (field.font == UIComponent.fonts.header) then rectangle = { (field.position or 200 + offsetX) - 44, offset + 14, (field.position or 200 + offsetX) + 72, offset + 36 }
				else rectangle = { (field.position or 200 + offsetX) - 44, offset + 16, (field.position or 200 + offsetX) + 72, offset + 38 }
				end]]

				local rectangle = { (field.position or 200 + offsetX) - 44, offsetY + 16, (field.position or 200 + offsetX) + 72, offsetY + 34 }

				if (MultiColumn and #activity.teams > 2) then				
				    if (#activity.teams == 3) then
                        rectangle = { 160, offset + 14.5, 210, offset + 32.5 }
                    end
				    if (#activity.teams == 4) then
                        rectangle = { 100, offset + 14.5, 150, offset + 32.5 }
                    end
				end  
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

					--if (0 ~= quartz.system.bitwise.bitwiseand(justification, quartz.system.drawing.justification.bottom)) then rectangle[2] = rectangle[4] - h
					--elseif (0 ~= quartz.system.bitwise.bitwiseand(justification, quartz.system.drawing.justification.singlelineverticalcenter)) then rectangle[2] , rectangle[4] = rectangle[2] + (rectangle[4] - rectangle[2] - h) * 0.5, rectangle[4] - (rectangle[4] - rectangle[2] - h) * 0.5
					--else rectangle[4] = rectangle[2] + h
					--end

					if (0 ~= quartz.system.bitwise.bitwiseand(justification, quartz.system.drawing.justification.right)) then rectangle[1] = rectangle[3] - w
					elseif (0 ~= quartz.system.bitwise.bitwiseand(justification, quartz.system.drawing.justification.center)) then rectangle[1], rectangle[3] = rectangle[1] + (rectangle[3] - rectangle[1] - w) * 0.5, rectangle[3] - (rectangle[3] - rectangle[1] - w) * 0.5
					else rectangle[3] = rectangle[1] + w
					end

					--justification = quartz.system.drawing.justification.center + quartz.system.drawing.justification.singlelineverticalcenter

					--quartz.system.drawing.loadtexture("base:texture/ui/components/uipanel07.tga")
					--quartz.system.drawing.drawtexture(unpack(rectangle))

					local scale = 1.0 + math.sin(animationData.angle * 3.141592625 / 180.0) * 0.5
					quartz.system.drawing.loadtextscale(scale)

				end
				if (MultiColumn and #activity.teams > 2) then				
					offsetX = 0
					if (field.font == UIComponent.fonts.header) then 
					    quartz.system.drawing.drawtextjustified(self.data[field.key], justification, unpack(rectangle))
					end      
				else
					quartz.system.drawing.drawtextjustified(self.data[field.key], justification, unpack(rectangle))	
					offsetX = offsetX + 40
				end
				if (animationData) then
					quartz.system.drawing.loadtextscale(1.0) -- restore original scaling
					if (0.0 >= animationData.angle) then self.animationData[field.key] = nil -- kill animation when over
					end
				end

			end )

		end
	end

	quartz.system.drawing.pop()

end

-- OnDataChanged  ----------------------------------------------------------

function UILeaderboardItem:OnDataChanged(_entity, _key, _value)

	if (self.uiLeaderboard.itemsSortField == _key) then

		if (self.team) then
			self.team:Sort()
		else
			self.uiLeaderboard:Sort()
		end

	end

    --[[
    local field = nil
    for _, _field in ipairs(self.uiLeaderboard.fields) do
        if (_field.key == _key) then field = _field ; break
        end
    end

    if (field) then
        local animationData = self.animationData[_key]
        if (not animationData) then
            self.animationData[_key] = { angle = 180.0, time = quartz.system.time.gettimemicroseconds() }
        else
            animationData.angle = math.max(animationData.angle, 180.0 - animationData.angle)
            --animationData.angle = 90.0
            animationData.time = quartz.system.time.gettimemicroseconds()
        end
    end
    --]]

end

-- RemoveDataChangedEvents ------------------------------------------------

function UILeaderboardItem:RemoveDataChangedEvents()

	self.challenger._DataChanged:Remove(self, self.OnDataChanged)

    if (0 < #activity.teams) then

        table.foreachi(self.challenger.players, function(index, player)
            player._DataChanged:Remove(self, self.OnDataChanged)
        end )

    end

end

-- Sort ---------------------------------------------------------------------

function UILeaderboardItem:Sort(init)

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
				item:MoveTo(0, 20 + 35 * (index - 1))
			else
				item:MoveTo(0, 27 + 64 * (index - 1))
			end
		else

			if (item.mvtFx) then

				UIManager:RemoveFx(item.mvtFx)
				item.mvtFx = nil

			end
			if (#activity.players > 8) then
				item.mvtFx = UIManager:AddFx("position", { duration = 0.8, __self = item, from = { 0, item.rectangle[2]}, to = { 0, 20 + 35 * (index - 1) }, type = "descelerate" })
			else
				item.mvtFx = UIManager:AddFx("position", { duration = 0.8, __self = item, from = { 0, item.rectangle[2]}, to = { 0, 27 + 64 * (index - 1) }, type = "descelerate" })
			end
		end

	end

end