
--[[--------------------------------------------------------------------------
--
-- File:            UAClassicCapture.UILeaderboardItem.lua
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

--[[ Class -----------------------------------------------------------------]]

UAClassicCapture.UILeaderboardItem = UTClass(UILeaderboardItem)

-- __ctor ------------------------------------------------------------------

function UAClassicCapture.UILeaderboardItem:__ctor(leaderboard, challenger)

end

-- Draw --------------------------------------------------------------------

function UAClassicCapture.UILeaderboardItem:Draw()

    -- blend color is there to gray out disconnected players,
    -- warning: blend color has alpha and is a 4f component

    local blendColor = { 1.0, 1.0, 1.0, 1.0 }

    if (activity.category ~= UTActivity.categories.single and self.challenger:IsKindOf(UTPlayer)) then
        blendColor = self.challenger.rfGunDevice and blendColor or { 0.70, 0.65, 0.60, 0.85 }
        self.uiPanel.color = blendColor
    end
    
    UIMultiComponent.Draw(self)

    --

	quartz.system.drawing.pushcontext()
    quartz.system.drawing.loadtranslation(unpack(self.rectangle))

	-- panel

	if(self.uiPanel) then
		quartz.system.drawing.loadcolor3f(unpack(UIComponent.colors.white))
		if (self.challenger.gameplayData[2] == 1) then
			quartz.system.drawing.loadtexture("base:texture/ui/components/UILeaderboardgrey.tga")
		else
			quartz.system.drawing.loadtexture(self.uiPanel.background)
		end
		quartz.system.drawing.drawtexture(unpack(self.uiPanel.rectangle))
	end

	-- hud + player name + icon

	local offset = 10
	if (self.challenger.team or not self.uiLeaderboard.largePanel) then
		offset = 5
	end

	--[[ infected arrow. To be replaced with team flag indicator later.
	if (self.challenger.gameplayData[2] == 1) then
		quartz.system.drawing.loadcolor3f(unpack(UIComponent.colors.white))
		quartz.system.drawing.loadtexture("base:texture/ui/pictograms/128x/Infection_Arrow.tga")
		quartz.system.drawing.drawtexture(-128, offset - 44, -128 + 128, offset - 44 + 128)
	end		]]--

	quartz.system.drawing.loadcolor4f(unpack(blendColor))
	if (self.challenger.rfGunDevice) then
		quartz.system.drawing.loadtexture("base:texture/ui/pictograms/64x/hud_" .. self.challenger.rfGunDevice.classId .. ".tga")
	else
		quartz.system.drawing.loadtexture("base:texture/ui/pictograms/64x/hud_guest.tga")
	end
	quartz.system.drawing.drawtexture(55, offset + 6, 55 + 32, offset + 6 + 32)

	quartz.system.drawing.loadcolor4f(unpack(blendColor))
	quartz.system.drawing.loadtexture("base:texture/Avatars/80x/" .. (self.challenger.data.heap.icon or self.challenger.profile.icon))
	
	if (self.challenger.team) then
		quartz.system.drawing.drawtexture(10, offset - 10, 10 + 60, offset + 50)
	else
		quartz.system.drawing.drawtexture(-10, offset - 20, -10 + 80, offset - 20 + 80)
	end

	if (self.challenger.gameplayData[2] == 1) then
		quartz.system.drawing.loadcolor3f(unpack(UIComponent.colors.white))
	else
		quartz.system.drawing.loadcolor3f(unpack(UIComponent.colors.darkgray))
	end
	
	quartz.system.drawing.loadfont(UIComponent.fonts.default)
	quartz.system.drawing.drawtext(self.challenger.profile.name, 90, offset + 18 )

	-- some informations

		local offsetX = 0
		table.foreachi(self.uiLeaderboard.fields, function(index, field)

			if (not self.challenger.team and field.icon) then

				quartz.system.drawing.loadcolor4f(unpack(blendColor))
				quartz.system.drawing.loadtexture(field.icon)
				quartz.system.drawing.drawtexture(200 + offsetX, offset - 20, 200 + offsetX + 32, offset - 20 + 32)

			end

			quartz.system.drawing.loadcolor3f(unpack(UIComponent.colors.orange))
			quartz.system.drawing.loadfont(field.font or UIComponent.fonts.default)
			
			if (field.font == UIComponent.fonts.header) then
				quartz.system.drawing.drawtextjustified(self.data[field.key], field.justification or quartz.system.drawing.justification.center, unpack({(field.position or 200 + offsetX) - 44, offset + 14, (field.position or 200 + offsetX) + 72, offset + 14 + 22}))
			else
				quartz.system.drawing.drawtextjustified(self.data[field.key], field.justification or quartz.system.drawing.justification.center, unpack({(field.position or 200 + offsetX) - 44, offset + 16, (field.position or 200 + offsetX) + 72, offset + 16 + 22}))
			end				

			offsetX = offsetX + 40

		end )

	if (self.challenger.gameplayData[2] == 1) then

		quartz.system.drawing.loadcolor3f(unpack(UIComponent.colors.white))
		quartz.system.drawing.loadtexture("base:texture/ui/Blood.tga")
		local size = math.min(20 * (self.challenger.wolfTimer or 0) / 1500000, 20)
		quartz.system.drawing.drawtexture(335, offset + 32, 335 + 20, offset + 32 + size)

	end

	quartz.system.drawing.pop()

end