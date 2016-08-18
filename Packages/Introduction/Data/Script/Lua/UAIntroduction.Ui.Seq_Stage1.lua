
--[[--------------------------------------------------------------------------
--
-- File:            UAIntroduction.Ui.Seq_Stage1.lua
--                  Copyright (c) Ubisoft Entertainment. All rights reserved.
--
-- Project:         Ubitoys.Tag
-- Date:            September 20, 2010
--
------------------------------------------------------------------------------
--
-- Description:     <Shoot the UbiConnect>
--
----------------------------------------------------------------------------]]

--[[ Dependencies ----------------------------------------------------------]]

require "Ui/UIMenuWindow"

    require "Ui/UIBitmap"

--[[ Class -----------------------------------------------------------------]]

UAIntroduction.Ui = UAIntroduction.Ui or {}
UAIntroduction.Ui.Seq_Stage1 = UTClass(UIMenuWindow)

-- __ctor -------------------------------------------------------------------

function UAIntroduction.Ui.Seq_Stage1:__ctor(state)

    assert(activity)
    assert(state)

	-- window settings

	self.uiWindow.title = activity.name

    -- contents,

    self.uiPanel = self.uiWindow:AddComponent(UIPanel:New(), "uiPanel")
    self.uiPanel.rectangle = self.clientRectangle

    self.uiContents = self.uiPanel:AddComponent(UITitledPanel:New(), "uiContents")
    self.uiContents.rectangle = { 20, 20, 695, 435 }
    self.uiContents.title = l "con021"

    self.uiContents.clientRectangle = {}

    for i = 1, 4 do 
        self.uiContents.clientRectangle[i] = self.uiWindow.rectangle[i] + self.clientRectangle[i] + self.uiContents.rectangle[i]
    end

    self.text = l "con022"

    -- bitmap on the left side

    self.uiBitmap = self.uiContents:AddComponent(UIBitmap:New("base:texture/ui/seq_roundloop_stage1.tga"))
    self.uiBitmap:MoveTo(0, UITitledPanel.headerSize)

    -- leaderboard

    self.uiLeaderboard = self.uiContents:AddComponent(UILeaderboard:New())
    self.uiLeaderboard:MoveTo(345, 40)
    self.uiLeaderboard.showRanking = false
    self.uiLeaderboard.smallPanel = true
	self.uiLeaderboard:RegisterField("shots", nil, nil, 220, quartz.system.drawing.justification.right, UIComponent.fonts.header, UIComponent.colors.orange)
    self.uiLeaderboard:Build(activity.match.challengers, "heap")    
    self.uiLeaderboard.itemsSortField = "shots"

    -- buttons,

	-- uiButton5: next

    self.uiButton5 = self:AddComponent(UIButton:New(), "uiButton5")
    self.uiButton5.rectangle = UIMenuWindow.buttonRectangles[5]
	self.uiButton5.text = l"but006"
	self.uiButton5.tip = l"tip005"

	self.uiButton5.OnAction = function ()
        state:Next()
	end

    self.uiButton5.enabled = false

    self.Update = function ()

        if (state.shots and (10 <= state.shots)) then

            if (not self.gmLocked and not self.gmLockedLocked) then
                self.gmLockedLocked = true
                game.gameMaster:Play("base:audio/gamemaster/dlg_gm_init_12.wav", function () self.uiButton5.enabled = true end)
            end
        end

    end

    -- gm lock

    self.gmLocked = true
    game.gameMaster:Play("base:audio/gamemaster/dlg_gm_init_11.wav", function () self.gmLocked = false end)

end

-- Draw ---------------------------------------------------------------------

function UAIntroduction.Ui.Seq_Stage1:Draw()

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