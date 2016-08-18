
--[[--------------------------------------------------------------------------
--
-- File:            UTActivity.Ui.Bytecode.lua
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

require "Ui/UIMenuWindow"

    require "UI/UIProgress"

-- require "UTBasics"

--[[ Class -----------------------------------------------------------------]]

UTActivity.Ui = UTActivity.Ui or {}
UTActivity.Ui.Bytecode = UTClass(UIMenuWindow)

-- default

-- __ctor -------------------------------------------------------------------

function UTActivity.Ui.Bytecode:__ctor(...)

    assert(activity)
    
	-- animate	
	
	self.slideBegin = game.settings.UiSettings.slideBegin
	self.slideEnd = game.settings.UiSettings.slideEnd
    
	-- window settings

	self.uiWindow.title = l "oth024"
	self.text = l "oth025"

	-- contents,

    self.uiPanel = self.uiWindow:AddComponent(UIPanel:New(), "uiPanel")
    self.uiPanel.rectangle = self.clientRectangle

    self.uiContents = self.uiPanel:AddComponent(UITitledPanel:New(), "uiContents")
    self.uiContents.rectangle = { 20, 20, 695, 435 }
    self.uiContents.title = l "oth031"

    self.uiContents.clientRectangle = {}

    for i = 1, 4 do 
        self.uiContents.clientRectangle[i] = self.uiWindow.rectangle[i] + self.clientRectangle[i] + self.uiContents.rectangle[i]
    end

    -- buttons,

	-- uiButton1: cancel

		self.uiButton1 = self:AddComponent(UIButton:New(), "uiButton1")
		self.uiButton1.rectangle = UIMenuWindow.buttonRectangles[1]
		self.uiButton1.text = l "but004"
		self.uiButton1.tip = l "tip006"
		self.uiButton1.OnAction = function (self) 

			quartz.framework.audio.loadsound("base:audio/ui/back.wav")
			quartz.framework.audio.loadvolume(game.settings.audio["volume:sfx"])
			quartz.framework.audio.playsound()
		
			activity:PostStateChange("playersmanagement")

		end

if (GEAR_CFG_COMPILE == GEAR_COMPILE_DEBUG) then

	-- button5: fake skip button screen !!

    self.uiButton5 = self:AddComponent(UIButton:New(), "uiButton5")
    self.uiButton5.rectangle = UIMenuWindow.buttonRectangles[5]
	self.uiButton5.text = l "but007"

    if (engine.libraries.usb.proxy.devices.byClass[0x02000020]) then
		self.uiButton5.enabled = false
	end

	self.uiButton5.OnAction = function (self) activity:PostStateChange("matchmaking") end

end

    -- progress

    self.uiProgress = self.uiContents:AddComponent(UIProgress:New(), "uiProgress")
    self.uiProgress.rectangle = { 20, self.uiContents.rectangle[4] - 28 - 30, 655, self.uiContents.rectangle[4] - 30 }
	self.uiProgress.minimum = 0
    self.uiProgress.maximum = 100
    self.uiProgress.progress = 0

end

-- Draw ----------------------------------------------------------------------

function UTActivity.Ui.Bytecode:Draw()

    -- base

    UIMenuWindow.Draw(self)

    -- contents,

    quartz.system.drawing.pushcontext()
		quartz.system.drawing.loadtranslation(self.rectangle[1], self.rectangle[2])
    quartz.system.drawing.loadtranslation(unpack(self.uiContents.clientRectangle))
    quartz.system.drawing.loadtranslation(0, UITitledPanel.headerSize)

    -- bitmap

    if (activity.bitmap) then
        quartz.system.drawing.loadcolor3f(unpack(UIComponent.colors.white))
        quartz.system.drawing.loadtexture(activity.bitmap)
        quartz.system.drawing.drawtexture(0, 0)
    end

    -- progress

    local rectangle = { 40, self.uiProgress.rectangle[2] - 30 - 20, 675 - 40, self.uiProgress.rectangle[2] - 30 }
    local progress = string.format("%02d%%", self.uiProgress.progress)
    local fontJustification = quartz.system.drawing.justification.center

    quartz.system.drawing.loadcolor3f(unpack(UIComponent.colors.darkgray))
    quartz.system.drawing.loadfont(UIComponent.fonts.header)
    quartz.system.drawing.drawtextjustified(progress, fontJustification, unpack(rectangle)) 

    -- text

    if (self.text) then

        rectangle[2] = rectangle[2] - 30
        rectangle[4] = rectangle[4] - 30

        quartz.system.drawing.loadcolor3f(unpack(UIComponent.colors.red))
        quartz.system.drawing.drawtextjustified(self.text, fontJustification, unpack(rectangle)) 

    end

    if (activity.name) then

        rectangle[2] = self.uiContents.rectangle[2] - 12

        fontJustification = quartz.system.drawing.justification.top + quartz.system.drawing.justification.center

        quartz.system.drawing.loadcolor3f(unpack(UIComponent.colors.orange))
        quartz.system.drawing.loadfont(UIComponent.fonts.larger)
        quartz.system.drawing.drawtextjustified(activity.name, fontJustification, unpack(rectangle))

    end

    quartz.system.drawing.pop()

end

-- Update -------------------------------------------------------------------

function UTActivity.Ui.Bytecode:Update()

    -- progress

	local percent = math.ceil(100 * activity.states["bytecode"].step / activity.states["bytecode"].maxStep)	
	self.uiProgress:SetValue(percent)
    --self.uiContents.title = string.format("%02d%%", self.uiProgress.progress)

    UIMenuWindow.Update(self)
 
end