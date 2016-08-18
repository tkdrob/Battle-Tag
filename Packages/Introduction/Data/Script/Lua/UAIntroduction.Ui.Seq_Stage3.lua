
--[[--------------------------------------------------------------------------
--
-- File:            UAIntroduction.Ui.Seq_Stage3.lua
--                  Copyright (c) Ubisoft Entertainment. All rights reserved.
--
-- Project:         Ubitoys.Tag
-- Date:            September 20, 2010
--
------------------------------------------------------------------------------
--
-- Description:     <Connect the T-Blasters to the sensor vests>
--
----------------------------------------------------------------------------]]

--[[ Dependencies ----------------------------------------------------------]]

require "Ui/UIMenuWindow"

    require "Ui/UIPlayerSlotGrid"

--[[ Class -----------------------------------------------------------------]]

UAIntroduction.Ui = UAIntroduction.Ui or {}
UAIntroduction.Ui.Seq_Stage3 = UTClass(UIMenuWindow)

-- __ctor -------------------------------------------------------------------

function UAIntroduction.Ui.Seq_Stage3:__ctor(state)

    assert(activity)
    assert(state)

	-- window settings

	self.uiWindow.title = activity.name

    -- contents,

    self.uiPanel = self.uiWindow:AddComponent(UIPanel:New(), "uiPanel")
    self.uiPanel.rectangle = self.clientRectangle

    self.uiContents = self.uiPanel:AddComponent(UITitledPanel:New(), "uiContents")
    self.uiContents.rectangle = { 20, 20, 695, 435 }
    self.uiContents.title = l "con018"

    self.uiContents.clientRectangle = {}

    for i = 1, 4 do 
        self.uiContents.clientRectangle[i] = self.uiWindow.rectangle[i] + self.clientRectangle[i] + self.uiContents.rectangle[i]
    end

    self.text = l"con050"

    -- bitmap on the left side

    self.uiBitmap = self.uiContents:AddComponent(UIBitmap:New("base:texture/ui/seq_roundloop_stage3.tga"))
    self.uiBitmap:MoveTo(0, UITitledPanel.headerSize)

    -- players on the right side

    self.uiPlayersPanel = self.uiContents:AddComponent(UIPanel:New(), "uiPanel")
    self.uiPlayersPanel.rectangle = { 335, UITitledPanel.headerSize + 25, 655, 320 }

    self.uiPlayerSlotGrid = self.uiPlayersPanel:AddComponent(UIPlayerSlotGrid:New(4, 0), "uiPlayerSlotGrid")
	self.uiPlayerSlotGrid:MoveTo( 10, 20 )

    for _, player in ipairs(activity.match.players) do

        local slot = self.uiPlayerSlotGrid:AddSlot(player, false)
		slot.harnessFx = UIManager:AddFx("value", { timeOffsey = math.random(0.0, 0.2), duration = 0.6, __self = slot , value = "icon", from = "base:texture/ui/icons/32x/harness_off.tga", to = "base:texture/ui/icons/32x/harness.tga", type = "blink"})
        player._DataChanged:Add(self, self.OnDataChanged)
        player.data.heap.harnessOn = false

    end

    -- buttons,

	-- uiButton1:
	-- exit the introduction sequence

    self.uiButton1 = self:AddComponent(UIButton:New(), "uiButton1")
	self.uiButton1.rectangle = UIMenuWindow.buttonRectangles[1]
	self.uiButton1.text = l"but018"
	self.uiButton1.tip = l"tip007"

	self.uiButton1.OnAction = function ()

        -- create a popup to warn user(s) about the pending updates
        -- the popup offers no other choice than to accept the updates

        local uiPopup = UIPopupWindow:New()

        uiPopup.title = l "con040"
        uiPopup.text = l "con039"

        -- buttons

        uiPopup.uiButton1 = uiPopup:AddComponent(UIButton:New())
        uiPopup.uiButton1.rectangle = UIPopupWindow.buttonRectangles[1]
        uiPopup.uiButton1.text = l "but018"

        uiPopup.uiButton1.OnAction = function ()

			-- launch last stage : gameover with no ui

			activity.states["roundloop"]:Next(true)

--			UIManager.stack:Pop()
--			engine.libraries.audio:Play("base:audio/musicmenu.ogg",game.settings.audio["volume:music"])
--			game:PostStateChange("title")

        end

        uiPopup.uiButton2 = uiPopup:AddComponent(UIButton:New())
        uiPopup.uiButton2.rectangle = UIPopupWindow.buttonRectangles[2]
        uiPopup.uiButton2.text = l "but004"

        uiPopup.uiButton2.OnAction = function ()

            UIManager.stack:Pop()

        end

        UIManager.stack:Push(uiPopup)

	end

	-- uiButton5: next

    self.uiButton5 = self:AddComponent(UIButton:New(), "uiButton5")
    self.uiButton5.rectangle = UIMenuWindow.buttonRectangles[5]
	self.uiButton5.text = l"but006"
	self.uiButton5.tip = l"tip005"

	self.uiButton5.OnAction = function ()
        state:Next()
	end

    self.uiButton5.enabled = false

    local delegate = function ()

        if (self.uibutton1) then self.uibutton1.enabled = true end
        self.gmLocked = false

    end

	self.Update = function ()

	    self.uiButton5.enabled = true

        for _, player in ipairs(activity.match.players) do
            self.uiButton5.enabled = self.uiButton5.enabled and player.data.heap.harnessOn
        end

        -- gm lock

        if (self.uiButton5.enabled and not self.gmLockedLocked) then
            self.gmLocked = true
            self.gmLockedLocked = true
            self.uiButton5.enabled = false
            game.gameMaster:Play("base:audio/gamemaster/dlg_gm_init_14.wav", delegate)
        end

        self.uiButton5.enabled = self.uiButton5.enabled and not self.gmLocked

	end

end

-- Draw ---------------------------------------------------------------------

function UAIntroduction.Ui.Seq_Stage3:Draw()

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

-- OnClose -------------------------------------------------------------------

function UAIntroduction.Ui.Seq_Stage3:OnClose()

    for _, player in ipairs(activity.match.players) do
        player._DataChanged:Remove(self, self.OnDataChanged)
    end

end

-- OnDataChanged  ----------------------------------------------------------

function UAIntroduction.Ui.Seq_Stage3:OnDataChanged(_entity, _key, _value)

	if ("harnessOn" == _key) then

		for _, slot in ipairs(self.uiPlayerSlotGrid.uiPlayerSlots) do

			if (slot.player == _entity) then

				if (_value) then

					if (slot.harnessFx) then

						UIManager:RemoveFx(slot.harnessFx)
						slot.harnessFx = nil

					end

					slot.icon = "base:texture/ui/icons/32x/harness_on.tga"

				else
					if (not slot.harnessFx) then
						slot.harnessFx = UIManager:AddFx("value", { timeOffsey = math.random(0.0, 0.2), duration = 0.6, __self = slot , value = "icon", from = "base:texture/ui/icons/32x/harness_off.tga", to = "base:texture/ui/icons/32x/harness.tga", type = "blink"})
					end
				end

			end

		end

	end

end

-- OnOpen --------------------------------------------------------------------

function UAIntroduction.Ui.Seq_Stage3:OnOpen()
end
