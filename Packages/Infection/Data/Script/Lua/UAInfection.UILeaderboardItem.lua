
--[[--------------------------------------------------------------------------
--
-- File:            UAInfection.UILeaderboardItem.lua
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

UAInfection.UILeaderboardItem = UTClass(UILeaderboardItem)

-- __ctor ------------------------------------------------------------------

function UAInfection.UILeaderboardItem:__ctor(leaderboard, challenger)

end

-- Draw --------------------------------------------------------------------

function UAInfection.UILeaderboardItem:Draw()

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
		if (self.challenger.zombie) then
			quartz.system.drawing.loadtexture("base:texture/ui/components/UILeaderboardWolfPanel.tga")
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

	-- wolf

	if (self.challenger.zombie) then
		quartz.system.drawing.loadcolor3f(unpack(UIComponent.colors.white))
		quartz.system.drawing.loadtexture("base:texture/ui/pictograms/128x/Infection_Arrow.tga")
		if (#activity.players <= 8) then 
			quartz.system.drawing.drawtexture(-128, offset - 44, 0, offset + 84)
		else
			quartz.system.drawing.drawtexture(220, -5, 294, 69)
		end
	end		

	quartz.system.drawing.loadcolor4f(unpack(blendColor))
	if (self.challenger.rfGunDevice) then
		quartz.system.drawing.loadtexture("base:texture/ui/pictograms/64x/hud_" .. self.challenger.rfGunDevice.classId .. ".tga")
	else
		quartz.system.drawing.loadtexture("base:texture/ui/pictograms/64x/hud_guest.tga")
	end
	quartz.system.drawing.drawtexture(55, offset + 6, 87, offset + 38)

	if (game.settings.UiSettings.teamribbon == 2) then
		quartz.system.drawing.loadcolor3f(unpack(UIComponent.colors.white))
		quartz.system.drawing.loadtexture("base:texture/ui/pictograms/48x/Team_" .. self.challenger.profile.team .. "_Circle.tga")
		quartz.system.drawing.drawtexture(0, offset - 10, 60, offset + 50)
	end

	quartz.system.drawing.loadcolor4f(unpack(blendColor))
	quartz.system.drawing.loadtexture("base:texture/Avatars/80x/" .. (self.challenger.data.heap.icon or self.challenger.profile.icon))
	if (self.challenger.team) then
		quartz.system.drawing.drawtexture(10, offset - 10, 70, offset + 50)
	else
		quartz.system.drawing.drawtexture(-10, offset - 20, 70, offset + 60)
	end

	if (self.challenger.zombie) then
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
				quartz.system.drawing.drawtexture(200 + offsetX, offset - 20, 232 + offsetX, offset + 12)

			end

			quartz.system.drawing.loadcolor3f(unpack(UIComponent.colors.orange))
			quartz.system.drawing.loadfont(field.font or UIComponent.fonts.default)
							
			if (field.font == UIComponent.fonts.header) then
				quartz.system.drawing.drawtextjustified(self.data[field.key], field.justification or quartz.system.drawing.justification.center, unpack({(field.position or (200 + offsetX)) - 44, offset + 14, (field.position or (200 + offsetX)) + 72, offset + 36}))
			else
				quartz.system.drawing.drawtextjustified(self.data[field.key], field.justification or quartz.system.drawing.justification.center, unpack({(field.position or (200 + offsetX)) - 44, offset + 16, (field.position or (200 + offsetX)) + 72, offset + 38}))
			end				

			offsetX = offsetX + 40

		end )

	-- blood

	if (self.challenger.zombie) then

		quartz.system.drawing.loadcolor3f(unpack(UIComponent.colors.white))
		quartz.system.drawing.loadtexture("base:texture/ui/Blood.tga")
		local size = math.min(20 * (self.challenger.wolfTimer or 0) / 1500000, 20)
		quartz.system.drawing.drawtexture(335, offset + 32, 355, offset + 32 + size)

	end

	quartz.system.drawing.pop()

end