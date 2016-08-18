
--[[--------------------------------------------------------------------------
--
-- File:            UAIntroduction.Ui.Seq_Stage6.lua
--                  Copyright (c) Ubisoft Entertainment. All rights reserved.
--
-- Project:         Ubitoys.Tag
-- Date:            September 20, 2010
--
------------------------------------------------------------------------------
--
-- Description:     <How to use the T-Boxes>
--
----------------------------------------------------------------------------]]

--[[ Dependencies ----------------------------------------------------------]]

require "Ui/UIMenuWindow"

    require "Ui/UIPlayerSlotGrid"

--[[ Class -----------------------------------------------------------------]]

UAIntroduction.Ui = UAIntroduction.Ui or {}
UAIntroduction.Ui.Seq_Stage6 = UTClass(UIMenuWindow)

-- __ctor -------------------------------------------------------------------

function UAIntroduction.Ui.Seq_Stage6:__ctor(state)

    assert(activity)
    assert(state)

	-- window settings

	self.uiWindow.title = activity.name

    -- contents,

    self.uiPanel = self.uiWindow:AddComponent(UIPanel:New(), "uiPanel")
    self.uiPanel.rectangle = self.clientRectangle

    self.uiContents = self.uiPanel:AddComponent(UITitledPanel:New(), "uiContents")
    self.uiContents.rectangle = { 20, 20, 695, 435 }
    self.uiContents.title = l "con012"

    self.uiContents.clientRectangle = {}

    for i = 1, 4 do 
        self.uiContents.clientRectangle[i] = self.uiWindow.rectangle[i] + self.clientRectangle[i] + self.uiContents.rectangle[i]
    end

    self.text = l "con013"

    -- bitmap on the left side

    self.uiBitmap = self.uiContents:AddComponent(UIBitmap:New("base:texture/ui/seq_roundloop_stage6.tga"))
    self.uiBitmap:MoveTo(0, UITitledPanel.headerSize)

    -- players on the right side

    self.uiPlayersPanel = self.uiContents:AddComponent(UIPanel:New(), "uiPanel")
    self.uiPlayersPanel.rectangle = { 335, UITitledPanel.headerSize + 25, 655, 320 }

	self.uiPlayerSlotGrid = self.uiPlayersPanel:AddComponent(UIPlayerSlotGrid:New(4, 0), "uiPlayerSlotGrid")
	self.uiPlayerSlotGrid:MoveTo( 10, 20 )
	
    for _, player in ipairs(activity.match.players) do

        local slot = self.uiPlayerSlotGrid:AddSlot(player, false)

        slot.icon = nil
        player._DataChanged:Add(self, self.OnDataChanged)

    end

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

	    self.uiButton5.enabled = not self.gmLocked
        for _, player in ipairs(activity.match.players) do
            self.uiButton5.enabled = self.uiButton5.enabled and player.data.heap.scan
        end

        self.uiButton5.enabled = self.uiButton5.enabled and not self.gmScanLocked

        if (self.uiButton5.enabled) then
            if (not self.gmCheckLocked) then
                self.gmCheckLocked, self.gmLockedLocked = true, true
                game.gameMaster:Play("base:audio/gamemaster/dlg_gm_init_23.wav", function () self.gmLockedLocked = false end)
            end
            self.uiButton5.enabled = not self.gmLockedLocked
        end

	end

    -- gm lock

    self.gmLocked = true
    game.gameMaster:Play("base:audio/gamemaster/dlg_gm_init_17.wav", function () self.gmLocked = false end)

end

-- OnClose -------------------------------------------------------------------

function UAIntroduction.Ui.Seq_Stage6:OnClose()

    for _, player in ipairs(activity.match.players) do
        player._DataChanged:Remove(self, self.OnDataChanged)
    end

end

-- OnDataChanged  ------------------------------------------------------------

function UAIntroduction.Ui.Seq_Stage6:OnDataChanged(_entity, _key, _value)

	if (_key == "scan") then
        for _, slot in pairs(self.uiPlayerSlotGrid.uiPlayerSlots) do

            if (slot.player == _entity) then
				if (65431 == _value) then
					slot.icon = "base:texture/ui/pictograms/64x/RF01.tga"
				elseif (65432 == _value) then
					slot.icon = "base:texture/ui/pictograms/64x/RF02.tga"
                end
                break
            end

        end
    elseif (_key == "errScan") then
        if (_value and (_value <= -3) and (not self.gmLocked) and (not self.gmLockedLocked)) then
            print(_key, _value)
            for _, slot in pairs(self.uiPlayerSlotGrid.uiPlayerSlots) do

                if (slot.player == _entity) then
	                if (not self.gmScanLocked and not _entity.data.heap.scan) then

	                    slot.icon = nil
	                    self.gmScanLocked = true
	                    game.gameMaster:Play("base:audio/gamemaster/dlg_gm_init_19.wav", function () self.gmScanLocked = false end)

	                end
	                break
                end

            end
        end
	end

end

-- OnOpen --------------------------------------------------------------------

function UAIntroduction.Ui.Seq_Stage6:OnOpen()
end

-- Draw ---------------------------------------------------------------------

function UAIntroduction.Ui.Seq_Stage6:Draw()

    UIMenuWindow.Draw(self)

    -- contents,

    quartz.system.drawing.pushcontext()
    quartz.system.drawing.loadtranslation(unpack(self.uiContents.clientRectangle))
    quartz.system.drawing.loadtranslation(0, UITitledPanel.headerSize)

    if (self.text) then

        local fontJustification = quartz.system.drawing.justification.bottomleft + quartz.system.drawing.justification.wordbreak
        local rectangle = { 40, 50, 675 - 40, 390 - 20 }

        quartz.system.drawing.loadcolor3f(unpack(self.fontColor))
        quartz.system.drawing.loadfont(UIComponent.fonts.default)
        quartz.system.drawing.drawtextjustified(self.text, fontJustification, unpack(rectangle) )

    end

    quartz.system.drawing.pop()

end
