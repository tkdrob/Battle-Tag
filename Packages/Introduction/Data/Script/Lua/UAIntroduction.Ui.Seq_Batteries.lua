
--[[--------------------------------------------------------------------------
--
-- File:            UAIntroduction.Ui.Seq_Batteries.lua
--                  Copyright (c) Ubisoft Entertainment. All rights reserved.
--
-- Project:         Ubitoys.Tag
-- Date:            September 16, 2010
--
------------------------------------------------------------------------------
--
-- Description:     <How to put batteries in your T-Blaster>
--
----------------------------------------------------------------------------]]

--[[ Dependencies ----------------------------------------------------------]]

require "Ui/UIMenuWindow"

--[[ Class -----------------------------------------------------------------]]

UAIntroduction.Ui = UAIntroduction.Ui or {}
UAIntroduction.Ui.Seq_Batteries = UTClass(UIMenuWindow)

-- __ctor -------------------------------------------------------------------

function UAIntroduction.Ui.Seq_Batteries:__ctor(...)

    assert(activity)

	-- window settings

	self.uiWindow.title = activity.name

    -- contents,

    self.uiPanel = self.uiWindow:AddComponent(UIPanel:New(), "uiPanel")
    self.uiPanel.rectangle = self.clientRectangle

    self.uiContents = self.uiPanel:AddComponent(UITitledPanel:New(), "uiContents")
    self.uiContents.rectangle = { 20, 20, 695, 435 }
    self.uiContents.title = l "con027"

    self.uiContents.clientRectangle = {}

    for i = 1, 4 do 
        self.uiContents.clientRectangle[i] = self.uiWindow.rectangle[i] + self.clientRectangle[i] + self.uiContents.rectangle[i]
    end

    --

    self.stage = 1
    self.stages = {

        [1] = { bitmap = "base:texture/ui/seq_batteries01.tga", text = l "con031", gmFile = "base:audio/gamemaster/dlg_gm_init_05.wav", },
        [2] = { bitmap = "base:texture/ui/seq_batteries02.tga", text = l "con032", gmFile = "base:audio/gamemaster/dlg_gm_init_06.wav", },
        [3] = { bitmap = "base:texture/ui/seq_batteries03.tga", text = l "con033", gmFile = "base:audio/gamemaster/dlg_gm_init_07.wav", },
    }

    -- buttons,

    -- uiButton5: next

    self.uiButton5 = self:AddComponent(UIButton:New(), "uiButton5")
    self.uiButton5.rectangle = UIMenuWindow.buttonRectangles[5]
	self.uiButton5.text = l"but006"
	self.uiButton5.tip = l"tip005"

	self.uiButton5.OnAction = function ()

        self.stage = self.stage + 1
        
        if (self.stage >= 4) then

            activity:PostStateChange("playersmanagement")
            self.stage = 3
            
        else
        
            -- gm lock
        
            local stage = self.stages[self.stage]
            if (stage and stage.gmFile) then
                self.uiButton5.enabled = false
                game.gameMaster:Play(stage.gmFile, function () self.uiButton5.enabled = true end)
            else
                self.uiButton5.enabled = true
            end
        
        end
	end

    -- gm lock

    local stage = self.stages[1]
    if (stage and stage.gmFile) then
        self.uiButton5.enabled = false
        game.gameMaster:Play(stage.gmFile, function () self.uiButton5.enabled = true end)
    else
        self.uiButton5.enabled = true
    end
    
end

-- Draw ---------------------------------------------------------------------

function UAIntroduction.Ui.Seq_Batteries:Draw()

    UIMenuWindow.Draw(self)
    
    -- contents,

    quartz.system.drawing.pushcontext()
    quartz.system.drawing.loadtranslation(unpack(self.uiContents.clientRectangle))
    quartz.system.drawing.loadtranslation(0, UITitledPanel.headerSize)

    -- bitmap

    local bitmap = self.stages[self.stage].bitmap

    quartz.system.drawing.loadcolor3f(unpack(UIComponent.colors.white))
    quartz.system.drawing.loadtexture(bitmap)
    quartz.system.drawing.drawtexture(0, 0)

    --if (self.stage >= 2) then
--
        --local bitmap = self.stages[1].bitmap
        --local rectangle = { 0, 0, 160, 160 }
--
        --quartz.system.drawing.loadtexture(bitmap)
        --quartz.system.drawing.drawtexture(unpack(rectangle))
        --
        --if (self.stage >= 3) then
--
            --local bitmap = self.stages[2].bitmap
            --local rectangle = { 0, 160, 160, 320 }
--
            --quartz.system.drawing.loadtexture(bitmap)
            --quartz.system.drawing.drawtexture(unpack(rectangle))
--
        --end
    --end

    -- text

    local text = self.stages[self.stage].text
    local fontJustification = quartz.system.drawing.justification.bottomleft + quartz.system.drawing.justification.wordbreak
    local rectangle = { 40, 50, 675 - 40, 390 - 20 }

    quartz.system.drawing.loadcolor3f(unpack(self.fontColor))
    quartz.system.drawing.loadfont(UIComponent.fonts.default)
    quartz.system.drawing.drawtextjustified(text, fontJustification, unpack(rectangle) )

    quartz.system.drawing.pop()    

end
