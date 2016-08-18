
--[[--------------------------------------------------------------------------
--
-- File:            UAIntroduction.Ui.Title.lua
--                  Copyright (c) Ubisoft Entertainment. All rights reserved.
--
-- Project:         Ubitoys.Tag
-- Date:            July 26, 2010
--
------------------------------------------------------------------------------
--
-- Description:     <Welcome>
--
----------------------------------------------------------------------------]]

--[[ Dependencies ----------------------------------------------------------]]

require "Ui/UIMenuWindow"

--[[ Class -----------------------------------------------------------------]]

UAIntroduction.Ui = UAIntroduction.Ui or {}
UAIntroduction.Ui.Title = UTClass(UIMenuWindow)

-- defaults

-- __ctor -------------------------------------------------------------------

function UAIntroduction.Ui.Title:__ctor(...)

    assert(activity)

	-- window settings

	self.uiWindow.title = activity.name 

    -- contents,

    self.uiPanel = self.uiWindow:AddComponent(UIPanel:New(), "uiPanel")
    self.uiPanel.rectangle = self.clientRectangle

    self.uiContents = self.uiPanel:AddComponent(UITitledPanel:New(), "uiContents")
    self.uiContents.rectangle = { 20, 20, 695, 435 }
    self.uiContents.title = l "con010"

    self.uiContents.clientRectangle = {}

    for i = 1, 4 do 
        self.uiContents.clientRectangle[i] = self.uiWindow.rectangle[i] + self.clientRectangle[i] + self.uiContents.rectangle[i]
    end

	self.text = l "con011"

    self.uiBitmap = self.uiContents:AddComponent(UIBitmap:New("base:texture/ui/seq_welcome.tga"))
    self.uiBitmap:MoveTo(0, UITitledPanel.headerSize)

    -- buttons,

    if (not REG_FIRSTTIME) then

	    -- uiButton1:
	    -- exit activity and get back to title screen

        self.uiButton1 = self:AddComponent(UIButton:New(), "uiButton1")
        self.uiButton1.rectangle = UIMenuWindow.buttonRectangles[1]
	    self.uiButton1.text = l"but003"
		self.uiButton1.tip = l"tip007"

	    self.uiButton1.OnAction = function (self) 
			engine.libraries.audio:Play("base:audio/musicmenu.ogg",game.settings.audio["volume:music"])
			game:PostStateChange("title") 
	    end

	end

	-- uiButton5:
	-- move forward to batteries sequence

    self.uiButton5 = self:AddComponent(UIButton:New(), "uiButton5")
	self.uiButton5.rectangle = UIMenuWindow.buttonRectangles[5]
	self.uiButton5.text = l"but006"
	self.uiButton5.tip = l"tip005"

	self.uiButton5.OnAction = function (self) activity:PostStateChange("ui", UAIntroduction.Ui.Seq_Batteries) end

	self.uiButton5.enabled = false
	game.gameMaster:Play("base:audio/gamemaster/dlg_gm_init_01.wav", function () self.uiButton5.enabled = true end)

end

-- __dtor -------------------------------------------------------------------

function UAIntroduction.Ui.Title:__dtor()
end

-- Draw ---------------------------------------------------------------------

function UAIntroduction.Ui.Title:Draw()

    UIMenuWindow.Draw(self)

    -- contents,

    quartz.system.drawing.pushcontext()
    quartz.system.drawing.loadtranslation(unpack(self.uiContents.clientRectangle))
    quartz.system.drawing.loadtranslation(0, UITitledPanel.headerSize)

    -- text

    local fontJustification = quartz.system.drawing.justification.bottomleft + quartz.system.drawing.justification.wordbreak
    local rectangle = { 40, 50, 675 - 40, 390 - 20 }

    quartz.system.drawing.loadcolor3f(unpack(self.fontColor))
    quartz.system.drawing.loadfont(UIComponent.fonts.default)
    quartz.system.drawing.drawtextjustified(self.text, fontJustification, unpack(rectangle) )

    quartz.system.drawing.pop()

end