
--[[--------------------------------------------------------------------------
--
-- File:            UISelector.Item.lua
--                  Copyright (c) Ubisoft Entertainment. All rights reserved.
--
-- Project:         Ubitoys.Tag
-- Date:            September 9, 2010
--
------------------------------------------------------------------------------
--
-- Description:     ...
--
----------------------------------------------------------------------------]]

--[[ Dependencies ----------------------------------------------------------]]

require "UI/UIRegion"

--[[ Class -----------------------------------------------------------------]]

assert(UISelector)

UISelector.Item = UTClass(UIRegion)

UISelector.Item.rectangle = { 0, 0, 256, 16 }
UISelector.Item.height = 16

ST_INDEXED = 8

UISelector.Item.states = {

    [ST_DISABLED] = { color = UIComponent.colors.lightgray, texture = "base:texture/ui/components/uipanel01.tga" },
    [ST_DISABLED + ST_FOCUSED] = { color = UIComponent.colors.lightgray, texture = "base:texture/ui/components/uipanel01.tga" },

    [ST_ENABLED] = { color = UIComponent.colors.white, texture = "base:texture/ui/components/uipanel01.tga" },
    [ST_ENABLED + ST_FOCUSED] = { color = UIComponent.colors.orange, fontColor = UIComponent.colors.white, texture = "base:texture/ui/components/uipanel01.tga" },
    [ST_ENABLED + ST_CLICKED] = { color = UIComponent.colors.orange, fontColor = UIComponent.colors.white, texture = "base:texture/ui/components/uipanel01.tga" },
    [ST_ENABLED + ST_FOCUSED + ST_CLICKED] = { color = UIComponent.colors.orange, fontColor = UIComponent.colors.white, offset = { 2, 2 }, texture = "base:texture/ui/components/uipanel01.tga" },

    [ST_INDEXED] = { color = { 1.00, 0.59, 0.16 } , fontColor = UIComponent.colors.white, texture = "base:texture/ui/components/uipanel01.tga" },
}

UISelector.Item.enabled = false

-- __ctor --------------------------------------------------------------------

function UISelector.Item:__ctor(...)

    self.color = nil
    self.header = nil -- { icon = nil, text = nil }
    self.text = nil
	self.iconType = nil

    --self.color = UIComponent.colors.red
    --self.header = { i_con = "base:texture/ui/icons/16x/yellowstar.tga", text = "1" }
    --self.text = "jean-sébastien"

end

-- __dtor --------------------------------------------------------------------

function UISelector.Item:__dtor()
end

-- Draw ----------------------------------------------------------------------

function UISelector.Item:Draw()

	if (self.visible) then

	    if (self.rectangle) then

            local index = (self.enabled and ST_ENABLED or ST_DISABLED) + (self.focused and ST_FOCUSED or 0) + (self.clicked and ST_CLICKED or 0)
            local state = self.states[index] or self.states[ST_ENABLED]

            if (self.indexed and not self.clicked and not self.focused) then
                state = self.states[ST_INDEXED]
            end

            assert(state)

            local rectangle = { self.rectangle[1], self.rectangle[2], self.rectangle[3], self.rectangle[4] }

            if (state.offset) then
                rectangle[1] = rectangle[1] + state.offset[1]
                rectangle[2] = rectangle[2] + state.offset[2]
                rectangle[3] = rectangle[3] + state.offset[1]
                rectangle[4] = rectangle[4] + state.offset[2]
            end

            --quartz.system.drawing.loadcolor3f(unpack(UIComponent.colors.black))
            --quartz.system.drawing.loadtexture("base:texture/ui/components/uipanel07.tga")
            --quartz.system.drawing.drawtexture(unpack(rectangle))

            if (self.iconCategory or self.iconText) then

                rectangle[1] = rectangle[1] + 20

				if (self.iconCategory) then

					quartz.system.drawing.loadcolor3f(unpack(UIComponent.colors.white))
					quartz.system.drawing.loadtexture("base:" .. self.iconCategory)
					quartz.system.drawing.drawtexture(rectangle[1] - 27,rectangle[2] - 8)

				end

				if (self.iconText) then

					quartz.system.drawing.loadcolor3f(unpack(self.iconColor))
                    quartz.system.drawing.loadfont(UIComponent.fonts.title)
                    quartz.system.drawing.drawtextjustified(self.iconText, quartz.system.drawing.justification.center, rectangle[1] - 27,rectangle[2] - 10, rectangle[1] + 18, rectangle[2] + 14)

				end

				rectangle[1] = rectangle[1] + 5

            end

            -- background

            if (self.enabled) then

                if (self.header) then

                    local rectangle1 = rectangle[1]

                    rectangle[1] = rectangle[1] + self.height + 10 + 2

                    local rectangle = { rectangle1, rectangle[2], rectangle1 + self.height + 10 + 10 + 2, rectangle[4] }

                    quartz.system.drawing.loadcolor3f(unpack(UIComponent.colors.white))
                    quartz.system.drawing.loadtexture("base:texture/ui/components/uigridline_background01.tga")
                    quartz.system.drawing.drawtextureh(unpack(rectangle))
					if (self.header.iconbackground) then
                        quartz.system.drawing.loadcolor3f(unpack(UIComponent.colors.white))
                        quartz.system.drawing.loadtexture(self.header.iconbackground)
                        local textureWidth, textureHeight = quartz.system.drawing.gettexturedimensions()

							rectangle[1] = rectangle[1] + 18
							rectangle[3] = rectangle[3] - 4

                        if (self.iconType) then

							quartz.system.drawing.drawtexture(rectangle[1] - 10, rectangle[2] - textureHeight * 0.5 + 5)

						else

							quartz.system.drawing.drawtexture(unpack(rectangle))
						end

                    end

                    if (self.header.icon) then

                        quartz.system.drawing.loadcolor3f(unpack(UIComponent.colors.white))
                        quartz.system.drawing.loadtexture(self.header.icon)
                        local textureWidth, textureHeight = quartz.system.drawing.gettexturedimensions()

							if (self.header.iconbackground) then
								rectangle[1] = rectangle[1] - 8
								rectangle[3] = rectangle[3] - 25
							else
								rectangle[1] = rectangle[1] + 10
								rectangle[3] = rectangle[3] - 12
							end

                        if (self.iconType) then

							quartz.system.drawing.drawtexture(rectangle[1] - 10, rectangle[2] - (textureHeight * 0.5) + 5)

						else

							quartz.system.drawing.drawtexture(unpack(rectangle))

                        end

                    elseif (self.header.text) then

                        local fontJustification = quartz.system.drawing.justification.singlelineverticalcenter + quartz.system.drawing.justification.center

                        quartz.system.drawing.loadcolor3f(unpack(UIComponent.colors.orange))
                        quartz.system.drawing.loadfont(UIComponent.fonts.default)
                        quartz.system.drawing.drawtextjustified(self.header.text, fontJustification, unpack(rectangle))

                    end
                end

                if (self.text) then

                    quartz.system.drawing.loadcolor3f(unpack(state.color))
                    quartz.system.drawing.loadtexture("base:texture/ui/components/uigridline_background02.tga")
                    quartz.system.drawing.drawtextureh(unpack(rectangle))

                    local fontColor = state.fontColor or UIComponent.colors.darkgray
                    local fontJustification = quartz.system.drawing.justification.singlelineverticalcenter

                    rectangle[1] = rectangle[1] + 16

                    quartz.system.drawing.loadcolor3f(unpack(fontColor))
                    quartz.system.drawing.loadfont(UIComponent.fonts.default)
                    quartz.system.drawing.drawtextjustified(self.text, fontJustification, unpack(rectangle))

                end

            else

                quartz.system.drawing.loadcolor3f(unpack(state.color))
                quartz.system.drawing.loadtexture("base:texture/ui/components/uigridline_background02.tga")
                quartz.system.drawing.drawtextureh(unpack(rectangle))

            end

        end
    end
    
end

function UISelector.Item:OnFocus()

	if (self.enabled) then
	
		quartz.framework.audio.loadsound("base:audio/ui/rollover.wav")
		quartz.framework.audio.loadvolume(game.settings.audio["volume:sfx"])
		quartz.framework.audio.playsound()

	end

	UIComponent.OnFocus(self)

end