
--[[--------------------------------------------------------------------------
--
-- File:            UTGame.Ui.Loading.lua
--                  Copyright (c) Ubisoft Entertainment. All rights reserved.
--
-- Project:         Ubitoys.Tag
-- Date:            July 27, 2010
--
------------------------------------------------------------------------------
--
-- Description:     ...
--
----------------------------------------------------------------------------]]

--[[ Dependencies ----------------------------------------------------------]]

require "UI/UIMenuWindow"
require "UI/UITitledPanel"
require "UI/UIProgress"
require "Ui/UIBitmap"

require "UTBasics"

--[[ Class -----------------------------------------------------------------]]

UTGame.Ui = UTGame.Ui or {}
UTGame.Ui.Loading = UTClass(UIMenuWindow)

-- default

UTGame.Ui.Loading.basicsLayout = {

    rectangleBitmap = { 140, 175, 300 + 400, 220 + 300 },
    rectangleText = { 200, 500, 200 + 600, 500 + 100 },
    fontColor = UIComponent.colors.darkgray,
    font = UIComponent.fonts.default,
    fontJustification = quartz.system.drawing.justification.topleft + quartz.system.drawing.justification.wordbreak,

}

UTGame.Ui.Loading.uiProgressSize = { 655, 24 }

-- __ctor --------------------------------------------------------------------

function UTGame.Ui.Loading:__ctor(...)

	-- window settings

	self.uiWindow.title = l "oth031"
	self.uiWindow.icon = "base:video/uianimatedbutton_settings.avi"

    -- contents,

	self.uiPanel = self.uiWindow:AddComponent(UIPanel:New(), "uiPanel")
	self.uiPanel.rectangle = self.clientRectangle

    self.uiContents = self.uiPanel:AddComponent(UIPanel:New(), "uiContents")
    self.uiContents.background = "base:texture/ui/components/uipanel01.tga"
    self.uiContents.rectangle = { 20, 20, 695, 435 }

    self.uiContents.clientRectangle = {}

    for i = 1, 4 do 
        self.uiContents.clientRectangle[i] = self.uiWindow.rectangle[i] + self.clientRectangle[i] + self.uiContents.rectangle[i]
    end    

    -- progress

	self.uiProgress = self.uiPanel:AddComponent(UIProgress:New(), "uiProgress")
	self.uiProgress.rectangle = { 20, 20, 695, 20 + UITitledPanel.headerSize }

--[[

    -- random slide from the basics

    UTBasics:Initialize()

    math.randomseed(quartz.system.time.gettimemicroseconds())
    self.basicsSlide = UTBasics.slides[math.random(#UTBasics.slides)]

    local bitmap = self.basicsSlide.bitmaps and self.basicsSlide.bitmaps[1]
    if (bitmap) then

        self.uiBitmap = self.uiContents:AddComponent(UIBitmap:New(bitmap))

        -- scaling

        local text = self.basicsSlide.texts and self.basicsSlide.texts[1]
        if (text) then

            local rectangle = { 40, 50, 675 - 40, 390 - 20 }
            local fontJustification = quartz.system.drawing.justification.wordbreak

            quartz.system.drawing.loadfont(UIComponent.fonts.default)

            local _, height = quartz.system.drawing.gettextdimensions(text, fontJustification, unpack(rectangle) )
            local scale = (self.uiBitmap.rectangle[4] - height - UITitledPanel.headerSize) / self.uiBitmap.rectangle[4]

            self.uiBitmap.rectangle[3] = self.uiBitmap.rectangle[3] * scale
            self.uiBitmap.rectangle[4] = self.uiBitmap.rectangle[4] * scale

            local offset = 0.5 * (675 - self.uiBitmap.rectangle[3])
            self.uiBitmap:MoveTo(offset + 10, UITitledPanel.headerSize)

        else
            self.uiBitmap:MoveTo(10, UITitledPanel.headerSize)
        end

    end

--]]

end

-- __dtor --------------------------------------------------------------------

function UTGame.Ui.Loading:__dtor()
end

-- Draw ----------------------------------------------------------------------

function UTGame.Ui.Loading:Draw()

    UIMenuWindow.Draw(self)

    -- contents,

    quartz.system.drawing.pushcontext()
    quartz.system.drawing.loadtranslation(unpack(self.uiContents.clientRectangle))
    quartz.system.drawing.loadtranslation(0, UITitledPanel.headerSize)
    
    -- logo

	quartz.system.drawing.loadcolor3f(unpack(UIComponent.colors.white))
	quartz.system.drawing.loadtexture("base:texture/ui/Loading_Logo.tga")
	quartz.system.drawing.drawtexture(0, 30)    

--[[
    -- basics

    if (self.basicsSlide) then

        local fontJustification = quartz.system.drawing.justification.bottomleft + quartz.system.drawing.justification.wordbreak
        local rectangle = { 40, 50, 675 - 40, 390 - 20 }

        local text = self.basicsSlide.texts and self.basicsSlide.texts[1]
        if (text) then

            quartz.system.drawing.loadcolor3f(unpack(self.fontColor))
            quartz.system.drawing.loadfont(UIComponent.fonts.default)
            quartz.system.drawing.drawtextjustified(text, fontJustification, unpack(rectangle) )

        end

    end
--]]

    quartz.system.drawing.pop()

end
