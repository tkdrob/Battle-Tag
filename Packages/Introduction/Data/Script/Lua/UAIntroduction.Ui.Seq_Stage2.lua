
--[[--------------------------------------------------------------------------
--
-- File:            UAIntroduction.Ui.Seq_Stage2.lua
--                  Copyright (c) Ubisoft Entertainment. All rights reserved.
--
-- Project:         Ubitoys.Tag
-- Date:            September 20, 2010
--
------------------------------------------------------------------------------
--
-- Description:     <Put on your sensor vest>
--
----------------------------------------------------------------------------]]

--[[ Dependencies ----------------------------------------------------------]]

require "Ui/UIMenuWindow"

--[[ Class -----------------------------------------------------------------]]

UAIntroduction.Ui = UAIntroduction.Ui or {}
UAIntroduction.Ui.Seq_Stage2 = UTClass(UIMenuWindow)

-- __ctor -------------------------------------------------------------------

function UAIntroduction.Ui.Seq_Stage2:__ctor(state)

    assert(activity)
    assert(state)

	-- window settings

	self.uiWindow.title = activity.name

    -- contents,

    self.uiPanel = self.uiWindow:AddComponent(UIPanel:New(), "uiPanel")
    self.uiPanel.rectangle = self.clientRectangle

    self.uiContents = self.uiPanel:AddComponent(UITitledPanel:New(), "uiContents")
    self.uiContents.rectangle = { 20, 20, 695, 435 }
    self.uiContents.title = l "con019"

    self.uiContents.clientRectangle = {}

    for i = 1, 4 do 
        self.uiContents.clientRectangle[i] = self.uiWindow.rectangle[i] + self.clientRectangle[i] + self.uiContents.rectangle[i]
    end

    self.text = l "con020"

    -- buttons,

	 -- uiButton5: next

    self.uiButton5 = self:AddComponent(UIButton:New(), "uiButton5")
    self.uiButton5.rectangle = UIMenuWindow.buttonRectangles[5]
	self.uiButton5.text = l "but006"
	self.uiButton5.tip = l"tip005"

	self.uiButton5.OnAction = function ()
        state:Next()
	end

    -- gm lock

    self.uiButton5.enabled = false
    game.gameMaster:Play("base:audio/gamemaster/dlg_gm_init_13.wav", function () self.uiButton5.enabled = true end)

end

-- Draw ---------------------------------------------------------------------

function UAIntroduction.Ui.Seq_Stage2:Draw()

    UIMenuWindow.Draw(self)

    -- contents,

    quartz.system.drawing.pushcontext()
    quartz.system.drawing.loadtranslation(unpack(self.uiContents.clientRectangle))
    quartz.system.drawing.loadtranslation(0, UITitledPanel.headerSize)

    -- bitmap

    quartz.system.drawing.loadcolor3f(unpack(UIComponent.colors.white))
    quartz.system.drawing.loadtexture("base:texture/ui/seq_roundloop_stage2.tga")
    quartz.system.drawing.drawtexture(0, 0)

    -- text

    local fontJustification = quartz.system.drawing.justification.bottomleft + quartz.system.drawing.justification.wordbreak
    local rectangle = { 40, 50, 675 - 40, 390 - 20 }

    quartz.system.drawing.loadcolor3f(unpack(self.fontColor))
    quartz.system.drawing.loadfont(UIComponent.fonts.default)
    quartz.system.drawing.drawtextjustified(self.text, fontJustification, unpack(rectangle) )

    quartz.system.drawing.pop()    

end