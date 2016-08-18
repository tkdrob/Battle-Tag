
--[[--------------------------------------------------------------------------
--
-- File:            UAIntroduction.Ui.Seq_Ready.lua
--                  Copyright (c) Ubisoft Entertainment. All rights reserved.
--
-- Project:         Ubitoys.Tag
-- Date:            September 21, 2010
--
------------------------------------------------------------------------------
--
-- Description:     <You're ready to play>
--
----------------------------------------------------------------------------]]

--[[ Dependencies ----------------------------------------------------------]]

require "Ui/UIMenuWindow"

--[[ Class -----------------------------------------------------------------]]

UAIntroduction.Ui = UAIntroduction.Ui or {}
UAIntroduction.Ui.Seq_Ready = UTClass(UIMenuWindow)

-- __ctor -------------------------------------------------------------------

function UAIntroduction.Ui.Seq_Ready:__ctor(...)

    assert(activity)

	-- window settings

	self.uiWindow.title = activity.name

    -- contents,

    self.uiPanel = self.uiWindow:AddComponent(UIPanel:New(), "uiPanel")
    self.uiPanel.rectangle = self.clientRectangle

    self.uiContents = self.uiPanel:AddComponent(UITitledPanel:New(), "uiContents")
    self.uiContents.rectangle = { 20, 20, 695, 435 }
    self.uiContents.title = l "con023"

    self.uiContents.clientRectangle = {}

    for i = 1, 4 do 
        self.uiContents.clientRectangle[i] = self.uiWindow.rectangle[i] + self.clientRectangle[i] + self.uiContents.rectangle[i]
    end

    self.text = l "con024"

    -- buttons,

    -- uiButton5: next

    self.uiButton5 = self:AddComponent(UIButton:New(), "uiButton5")
    self.uiButton5.rectangle = { UIMenuWindow.buttonRectangles[5][1] - 10, UIMenuWindow.buttonRectangles[5][2], UIMenuWindow.buttonRectangles[5][3], UIMenuWindow.buttonRectangles[5][4], }
	self.uiButton5.text = l"but020"
	self.uiButton5.tip = l"tip007"
	self.uiButton5.direction = DIR_HORIZONTAL
	self.uiButton5.enabled = false

	self.uiButton5.OnAction = function ()

        game.settings.registers.firstTime = false
        REG_FIRSTTIME = false

        game:SaveSettings()
        game:PostStateChange("title")

	end

    -- gm lock
    
    self.gmLocked = true
    game.gameMaster:Play("base:audio/gamemaster/dlg_gm_init_18.wav", function () self.gmLocked = false end)

end

-- Draw ---------------------------------------------------------------------

function UAIntroduction.Ui.Seq_Ready:Draw()

    UIMenuWindow.Draw(self)

    -- contents,

    quartz.system.drawing.pushcontext()
    quartz.system.drawing.loadtranslation(unpack(self.uiContents.clientRectangle))
    quartz.system.drawing.loadtranslation(0, UITitledPanel.headerSize)

    -- bitmap

    quartz.system.drawing.loadcolor3f(unpack(UIComponent.colors.white))
    quartz.system.drawing.loadtexture("base:texture/ui/seq_ready01.tga")
    quartz.system.drawing.drawtexture(0, 0)

    -- text

    local fontJustification = quartz.system.drawing.justification.bottomleft + quartz.system.drawing.justification.wordbreak
    local rectangle = { 40, 40, 675 - 40, 390 }

    quartz.system.drawing.loadcolor3f(unpack(self.fontColor))
    quartz.system.drawing.loadfont(UIComponent.fonts.default)
    quartz.system.drawing.drawtextjustified(self.text, fontJustification, unpack(rectangle) )

    quartz.system.drawing.pop()    

end

-- Update --------------------------------------------------------------------

function UAIntroduction.Ui.Seq_Ready:Update()

    local empty = true
    self.uiButton5.enabled = not self.gmLocked

    for _, player in pairs(activity.players) do
        if not (player.rfGunDevice) then
            -- if a player has no device (is disconnected) then he does not count
        elseif not (player.data.heap.gameover) then
            -- else if the player did not receive the gameover message then we shall wait a little bit longer
            self.uiButton5.enabled = false
            return
        else
            -- else this player is ready to move on
            empty = false
        end
    end

    if (empty) then
        self.uiButton5.OnAction()
    end

end