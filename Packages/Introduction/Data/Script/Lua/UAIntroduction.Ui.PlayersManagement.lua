
--[[--------------------------------------------------------------------------
--
-- File:            UAIntroduction.Ui.PlayersManagement.lua
--                  Copyright (c) Ubisoft Entertainment. All rights reserved.
--
-- Project:         Ubitoys.Tag
-- Date:            September 16, 2010
--
------------------------------------------------------------------------------
--
-- Description:     <Turn on all your T-Blasters>
--
----------------------------------------------------------------------------]]

--[[ Dependencies ----------------------------------------------------------]]

require "Ui/UIMenuWindow"

    require "Ui/UIBitmap"

--[[ Class -----------------------------------------------------------------]]

UAIntroduction.Ui = UAIntroduction.Ui or {}
UAIntroduction.Ui.PlayersManagement = UTClass(UIMenuWindow)

-- __ctor -------------------------------------------------------------------

function UAIntroduction.Ui.PlayersManagement:__ctor(...)

    assert(activity)

	-- window settings

	self.uiWindow.title = activity.name

    -- contents,

    self.uiPanel = self.uiWindow:AddComponent(UIPanel:New(), "uiPanel")
    self.uiPanel.rectangle = self.clientRectangle

    self.uiContents = self.uiPanel:AddComponent(UITitledPanel:New(), "uiContents")
    self.uiContents.rectangle = { 20, 20, 695, 435 }
    self.uiContents.title = l "con025"

    self.uiContents.clientRectangle = {}

    for i = 1, 4 do 
        self.uiContents.clientRectangle[i] = self.uiWindow.rectangle[i] + self.clientRectangle[i] + self.uiContents.rectangle[i]
    end

    self.text = l "con030"

    -- bitmap on the left side

    self.uiBitmap = self.uiContents:AddComponent(UIBitmap:New("base:texture/ui/seq_playersmanagement01.tga"))
    --self.uiBitmap = self.uiContents:AddComponent(UIBitmap:New("base:texture/ui/seq_roundloop_stage3.tga"))
    self.uiBitmap:MoveTo(0, UITitledPanel.headerSize)

    -- players on the right side

    self.uiPlayersPanel = self.uiContents:AddComponent(UIPanel:New(), "uiPanel")
    self.uiPlayersPanel.rectangle = { 335, UITitledPanel.headerSize + 25, 655, 320 }

	self.uiPlayerSlotGrid = self.uiPlayersPanel:AddComponent(UIPlayerSlotGrid:New(5, 0), "uiPlayerSlotGrid")
	self.uiPlayerSlotGrid:MoveTo( 10, 20 )

    -- buttons,

if not (REG_FIRSTTIME) then

	-- uiButton1:
	-- exit the introduction sequence

    self.uiButton1 = self:AddComponent(UIButton:New(), "uiButton1")
	self.uiButton1.rectangle = UIMenuWindow.buttonRectangles[1]
	self.uiButton1.text = l"but018"
	self.uiButton1.tip = l"tip013"

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

            UIManager.stack:Pop()
			engine.libraries.audio:Play("base:audio/musicmenu.ogg",game.settings.audio["volume:music"])
            game:PostStateChange("title")

        end

        uiPopup.uiButton2 = uiPopup:AddComponent(UIButton:New())
        uiPopup.uiButton2.rectangle = UIPopupWindow.buttonRectangles[2]
        uiPopup.uiButton2.text = l "but004"

        uiPopup.uiButton2.OnAction = function ()

            UIManager.stack:Pop()

        end

        UIManager.stack:Push(uiPopup)

	end
	
end

	-- uiButton5:
	-- move forward to bytecode upload

    self.uiButton5 = self:AddComponent(UIButton:New(), "uiButton5")
	self.uiButton5.rectangle = UIMenuWindow.buttonRectangles[5]
	self.uiButton5.text = l"but006"
	self.uiButton5.tip = l"tip005"

	self.uiButton5.OnAction = function (self)

        -- switch to next state when two guns are connected,
        -- else invite the lone player to switch on the second gun

        if (2 <= #activity.players) then

            -- check whether any of the required gun devices needs to be updated
            -- possible updates include: firmware, data banks

            local updateRequired = false

            for _, player in pairs(activity.players) do
                updateRequired = updateRequired or (player.rfGunDevice and player.rfGunDevice.updateRequired)
            end

            if (updateRequired) then

                -- lock the usb proxy so as to refuse any further connection requests

                engine.libraries.usb.proxy:Lock()

                -- create a popup to warn user(s) about the pending updates
                -- the popup offers no other choice than to accept the updates

                local uiPopup = UIPopupWindow:New()

                uiPopup.title = ""
                uiPopup.text = l "oth017"

                -- buttons

                uiPopup.uiButton2 = uiPopup:AddComponent(UIButton:New(), "uiButton2")
                uiPopup.uiButton2.rectangle = UIPopupWindow.buttonRectangles[2]
                uiPopup.uiButton2.text = l "but006"

                uiPopup.uiButton2.OnAction = function ()

                    UIManager.stack:Pop()
                    activity:PostStateChange("revision", "bytecode")

                end

                UIManager.stack:Push(uiPopup)

            else

	            activity:PostStateChange("bytecode")

            end

	    elseif (1 == #activity.players) then

            local uiPopup = UIPopupWindow:New()

            uiPopup.title = l "con035"
            uiPopup.text = l "con036"

            -- buttons

            uiPopup.uiButton2 = uiPopup:AddComponent(UIButton:New(), "uiButton2")
            uiPopup.uiButton2.rectangle = UIPopupWindow.buttonRectangles[2]
            uiPopup.uiButton2.text = l "but003"

            uiPopup.uiButton2.OnAction = function ()
                UIManager.stack:Pop()
            end

            UIManager.stack:Push(uiPopup)

	    end

	end

    -- gm lock
    
    self.gmLocked = true
    if (self.uiButton1) then self.uiButton1.enabled = false end
    self.uiButton5.enabled = false

end

-- Draw ----------------------------------------------------------------------

function UAIntroduction.Ui.PlayersManagement:Draw()

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

-- OnClose -------------------------------------------------------------------

function UAIntroduction.Ui.PlayersManagement:OnClose()

	-- stop pairing

    if (engine.libraries.usb.proxy) then

        assert(engine.libraries.usb.proxy.handle)
        quartz.system.usb.sendmessage(engine.libraries.usb.proxy.handle, { 0x01, 0x00, 0x13, 0x00 })

    end

	-- check updating profile

	for i = 1, #self.uiPlayerSlotGrid.uiPlayerSlots do
		if (self.uiPlayerSlotGrid.uiPlayerSlots[i].profileUpdated and 
		self.uiPlayerSlotGrid.uiPlayerSlots[i].player and 
		self.uiPlayerSlotGrid.uiPlayerSlots[i].player.rfGunDevice) then
			self.uiPlayerSlotGrid.uiPlayerSlots[i]._ProfileUpdated:Remove(self, UAIntroduction.Ui.PlayersManagement.OnProfileUpdated)
		end
	end

    activity.states["playersmanagement"]._PlayerAdded:Remove(self, self.OnPlayerAdded)
    activity.states["playersmanagement"]._PlayerRemoved:Remove(self, self.OnPlayerRemoved)

    UIMenuWindow.Close(self)

end

-- OnOpen --------------------------------------------------------------------

UAIntroduction.Ui.PlayersManagement.seqPairing = false

function UAIntroduction.Ui.PlayersManagement:OnOpen()

    if (REG_FIRSTTIME and not UAIntroduction.Ui.PlayersManagement.seqPairing) then

        UAIntroduction.Ui.PlayersManagement.seqPairing = true
        UIMenuManager.stack:Push(UAIntroduction.Ui.Seq_Pairing)

    end

    activity.states["playersmanagement"]._PlayerAdded:Add(self, self.OnPlayerAdded)
    activity.states["playersmanagement"]._PlayerRemoved:Add(self, self.OnPlayerRemoved)

end

-- OnPlayerAdded -------------------------------------------------------------

function UAIntroduction.Ui.PlayersManagement:OnPlayerAdded(player)

    assert(player:IsKindOf(UTPlayer))
	local slot = self.uiPlayerSlotGrid:AddSlot(player, true)
	slot._ProfileUpdated:Add(self, UAIntroduction.Ui.PlayersManagement.OnProfileUpdated)
	slot.profileUpdated = true

end

-- OnPlayerRemoved -----------------------------------------------------------

function UAIntroduction.Ui.PlayersManagement:OnPlayerRemoved(player)

    assert(player:IsKindOf(UTPlayer))
    local slot = self.uiPlayerSlotGrid:RemoveSlot(player)
    if (slot.profileUpdated) then
		slot._ProfileUpdated:Remove(self, UAIntroduction.Ui.PlayersManagement.OnProfileUpdated)
		slot.profileUpdated = false
	end
	
	self.uiButton5.enabled = activity.players and (0 < #activity.players) and not self.gmLocked

	-- !! TO CORRECT AFTER RELEASE : unlock proxy 

	--if (#activity.players < activity.maxNumberOfPlayer) then engine.libraries.usb.proxy:Unlock()
	--end

end

-- OnProfileUpdated ----------------------------------------------------------

function UAIntroduction.Ui.PlayersManagement:OnProfileUpdated(slot)

    self.uiButton5.enabled = activity.players and (0 < #activity.players) and not self.gmLocked

	-- !! TO CORRECT AFTER RELEASE :  lock proxy 

	--if (#activity.players >= activity.maxNumberOfPlayer) then engine.libraries.usb.proxy:Lock()
	--end

end

-- Update --------------------------------------------------------------------

function UAIntroduction.Ui.PlayersManagement:Update()

    if (not self.gmLockedLocked) then

        self.gmLockedLocked = true

        local delegate = function ()

            self.gmLocked = false
            if (self.uiButton1) then self.uiButton1.enabled = true end
            self.uiButton5.enabled = activity.players and (0 < #activity.players)
			-- self.uiButton1.enabled = true

        end

        game.gameMaster:Play("base:audio/gamemaster/dlg_gm_init_09.wav", delegate) 

    end

end