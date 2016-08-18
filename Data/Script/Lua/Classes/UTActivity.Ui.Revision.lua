
--[[--------------------------------------------------------------------------
--
-- File:            UTActivity.Ui.Revision.lua
--                  Copyright (c) Ubisoft Entertainment. All rights reserved.
--
-- Project:         Ubitoys.Tag
-- Date:            September 29, 2010
--
------------------------------------------------------------------------------
--
-- Description:     ...
--
----------------------------------------------------------------------------]]

--[[ Dependencies ----------------------------------------------------------]]

require "UI/UIPage"
require "UI/UIMenuPage"
require "UI/UIMenuWindow"

    require "UI/UITitledPanel"
    require "UI/UIProgress"

--[[ Class -----------------------------------------------------------------]]

assert(rawget(UTActivity, "Ui"))
UTActivity.Ui.Revision = UTClass(UIMenuWindow)

-- __ctor --------------------------------------------------------------------

function UTActivity.Ui.Revision:__ctor(...)

	-- animate	
	
	self.slideBegin = game.settings.UiSettings.slideBegin
	self.slideEnd = game.settings.UiSettings.slideEnd
	
	-- window settings

	self.uiWindow.title = l"oth014"
	self.uiWindow.icon = "base:video/uianimatedbutton_settings.avi"

	self.text = l"oth015"

    -- contents,

    self.uiPanel = self.uiWindow:AddComponent(UIPanel:New(), "uiPanel")
    self.uiPanel.rectangle = self.clientRectangle

    self.uiContents = self.uiPanel:AddComponent(UITitledPanel:New(), "uiContents")
    self.uiContents.rectangle = { 20, 20, 695, 435 }
    self.uiContents.title = ""

    self.uiContents.clientRectangle = {}

    for i = 1, 4 do 
        self.uiContents.clientRectangle[i] = self.uiWindow.rectangle[i] + self.clientRectangle[i] + self.uiContents.rectangle[i]
    end

    -- progress

    self.uiProgress = self.uiContents:AddComponent(UIProgress:New(), "uiProgress")
    self.uiProgress.rectangle = { 20, 20 + 25, 655, 48 + 25 }
    self.uiProgress.rectangle = { 20, self.uiContents.rectangle[4] - 28 - 30 - 60, 655, self.uiContents.rectangle[4] - 30 - 60}

    self.uiGlobalProgress = self.uiContents:AddComponent(UIProgress:New(), "uiProgress")
    self.uiGlobalProgress.rectangle = { 20, self.uiContents.rectangle[4] - 28 - 30, 655, self.uiContents.rectangle[4] - 30 }
	self.uiGlobalProgress.texture = "base:texture/ui/loadingred.tga"	

    self.uiGlobalProgress.color = UIComponent.colors.red

    assert(engine.libraries.usb)
    assert(engine.libraries.usb.proxy)
    assert(engine.libraries.usb.proxy.handle)

    -- buttons,

    -- uiButton5: continue

    self.uiButton5 = self:AddComponent(UIButton:New(), "uiButton5")
    self.uiButton5.rectangle = UIMenuWindow.buttonRectangles[5]
    self.uiButton5.text = l"but019"

    self.uiButton5.enabled = false

    self.uiButton5.OnAction = function (self) game:PostStateChange("bytecode") end

end

-- Draw ----------------------------------------------------------------------

function UTActivity.Ui.Revision:Draw()

    -- base

    UIMenuWindow.Draw(self)

    -- contents,

    quartz.system.drawing.pushcontext()
	quartz.system.drawing.loadtranslation(self.rectangle[1], self.rectangle[2])
    quartz.system.drawing.loadtranslation(unpack(self.uiContents.clientRectangle))
    quartz.system.drawing.loadtranslation(0, UITitledPanel.headerSize)

	-- logo

    quartz.system.drawing.loadcolor3f(unpack(UIComponent.colors.white))
    quartz.system.drawing.loadtexture("base:texture/ui/Loading_Logo.tga")
    quartz.system.drawing.drawtexture(120, 0, 120 + 433, 250)
    
    -- text

    local fontJustification = quartz.system.drawing.justification.center + quartz.system.drawing.justification.wordbreak
    local rectangle = { 40, 220, 675 - 40, 220 + 140 }

    quartz.system.drawing.loadcolor3f(unpack(self.fontColor))
    quartz.system.drawing.loadfont(UIComponent.fonts.default)
    quartz.system.drawing.drawtextjustified(self.text, fontJustification, unpack(rectangle) )

    quartz.system.drawing.pop()

end

-- OnClose -------------------------------------------------------------------

function UTActivity.Ui.Revision:OnClose()

    if (engine.libraries.usb.proxy) then
        engine.libraries.usb.proxy._DeviceRemoved:Remove(self, UTActivity.Ui.Revision.OnDeviceRemoved)
    end

end

-- OnDeviceRemoved -----------------------------------------------------------

function UTActivity.Ui.Revision.OnDeviceRemoved(device)
end

-- OnFocus -------------------------------------------------------------------

function UTActivity.Ui.Revision:OnFocus()

    self.flashMemoryManager = engine.libraries.usb.proxy.processes.deviceFlashMemoryManager
    assert(self.flashMemoryManager)

    self.uiGlobalProgress.minimum = 0
    self.uiGlobalProgress.maximum = self.flashMemoryManager.tasks and #self.flashMemoryManager.tasks or 100
    if (0 >= self.uiGlobalProgress.maximum) then
        self.uiGlobalProgress.maximum = 1
    end

end

-- OnOpen --------------------------------------------------------------------

function UTActivity.Ui.Revision:OnOpen()

    -- check for disconnected devices

    assert(engine.libraries.usb.proxy)
    engine.libraries.usb.proxy._DeviceRemoved:Add(self, UTActivity.Ui.Revision.OnDeviceRemoved)

end

-- Update --------------------------------------------------------------------

function UTActivity.Ui.Revision:Update()

    assert(self.flashMemoryManager)

    local text = self.flashMemoryManager.task and self.flashMemoryManager.task.text or "Updating ..."
    self.uiContents.title = text

    local progress = self.flashMemoryManager.task and self.flashMemoryManager.task.progress or 0
    self.uiProgress:SetProgress(progress)
    self.uiGlobalProgress:SetValue(self.uiGlobalProgress.maximum - #self.flashMemoryManager.tasks)

end
