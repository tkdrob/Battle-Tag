
--[[--------------------------------------------------------------------------
--
-- File:            UTActivity.State.Revision.lua
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

-- interfaces

require "UTActivity.Ui.Revision"
require "UTActivity.Ui.RevisionCheck"

--[[ Class -----------------------------------------------------------------]]

UTActivity.State.Revision = UTClass(UTState)

-- __ctor --------------------------------------------------------------------

function UTActivity.State.Revision:__ctor(activity, ...)

    assert(activity)

end

-- Begin ---------------------------------------------------------------------

function UTActivity.State.Revision:Begin(arg)

    self.arg = arg

print("0000000000")

    assert(engine.libraries.usb)
    assert(engine.libraries.usb.proxy)

    self.flashMemoryManager = engine.libraries.usb.proxy.processes.deviceFlashMemoryManager
    assert(self.flashMemoryManager)

    -- check for major revisions,
    -- we check for data updates only when we have major revisions

    self.majorRevisionDevices = nil

    -- let the flash memory manager handle all the revision updates

    self.flashMemoryManager:Clear()

    for _, player in pairs(activity.players) do

        local device = player.rfGunDevice
        if (device and device.updateRequired) then

            -- firmware revision,
            -- or flash memory bank revision as well

            if (device.revisionCandidate) then

                self.flashMemoryManager:Upload(device, device.revisionCandidate.path, 0x78000)

                -- check for major revisions,
                -- we check for data updates only when we have major revisions

                local masterRevision = string.format("0x%04x0000", REG_MAJORREVISION)
                local deviceRevision = string.format("0x%04x0000", quartz.system.bitwise.rshift(device.revisionNumber, 16))

                if not (masterRevision == deviceRevision) or REG_FORCEREVISION then

                    print("major revision detected for device " .. tostring(device.reference))

                    self.majorRevisionDevices = self.majorRevisionDevices or {}
                    table.insert(self.majorRevisionDevices, device)

                end

            end

        end
    end

    self.flashMemoryManager.lastResult = "undefined"
    -- self.flashMemoryManager:Restart()

    --

    UIManager.stack:Pusha()
    UIMenuManager.stack:Pusha()

    UIMenuManager.stack:Push(UTActivity.Ui.Revision)

    --

    engine.libraries.usb.proxy._DeviceRemoved:Add(self, UTActivity.State.Revision.OnDeviceRemoved)

    if (self.majorRevisionDevices) then

        -- check for major revisions,
        -- we check for data updates only when we have major revisions
print("1111111111")
        local uiRevisionCheck = UTActivity.Ui.RevisionCheck:New(self)
        UIMenuManager.stack:Push(uiRevisionCheck)

    else

        self.flashMemoryManager:Restart()

    end

end

-- End -----------------------------------------------------------------------

function UTActivity.State.Revision:End()

    UIManager.stack:Popa()
    UIMenuManager.stack:Popa()

    if (engine.libraries.usb.proxy) then

        engine.libraries.usb.proxy._DeviceRemoved:Remove(self, UTActivity.State.Revision.OnDeviceRemoved)

        -- clear the whitelist,
        -- definitely forbid any new connections

        engine.libraries.usb.proxy:WhiteList()

    end

end

-- OnDeviceRemoved -----------------------------------------------------------

function UTActivity.State.Revision:OnDeviceRemoved(device)

    if (self.majorRevisionDevices) then
        for _, majorRevisionDevice in pairs(self.majorRevisionDevices) do
            if (majorRevisionDevice == device) then

                self.flashMemoryManager.lastResult = "fail"
                self.flashMemoryManager:Suspend()

                self.majorRevisionDevices = nil

                break
            end
        end
    end

end

-- OnDispatchMessage ---------------------------------------------------------

function UTActivity.State.Revision.OnDispatchMessage(device, addressee, command, arg)
end

-- Update --------------------------------------------------------------------

function UTActivity.State.Revision:Update()

    -- check for major revisions,
    -- we check for data updates only when we have major revisions

    if (self.majorRevisionDevices) then return
    end

    -- when the flash memory manager gets suspended,
    -- that means all tasks are complete

    assert(self.flashMemoryManager)

    if (not self.uiPopup) then
        if (self.flashMemoryManager.status == UTProcess.Suspended) then

            local result = self.flashMemoryManager.lastResult
            if (result == "complete") then

                self.uiPopup = UIPopupWindow:New()
 
                self.uiPopup.title = l "con044"
                self.uiPopup.text = l "con043"

                -- buttons

                --[[self.uiPopup.uiButton2 = self.uiPopup:AddComponent(UIButton:New(), "uiButton2")
                self.uiPopup.uiButton2.rectangle = UIPopupWindow.buttonRectangles[2]
                self.uiPopup.uiButton2.text = l "but019"

                self.uiPopup.uiButton2.OnAction = function ()

                    UIManager.stack:Pop()

                    if (self.arg) then self:PostStateChange(unpack(self.arg))
                    else self:PostStateChange("bytecode")
                    end

                end]]

                UIManager.stack:Push(self.uiPopup)

            else

                self.uiPopup = UIPopupWindow:New()

                self.uiPopup.title = l "con046"
                self.uiPopup.text = l "con045"

                -- buttons

                self.uiPopup.uiButton2 = self.uiPopup:AddComponent(UIButton:New(), "uiButton2")
                self.uiPopup.uiButton2.rectangle = UIPopupWindow.buttonRectangles[2]
                self.uiPopup.uiButton2.text = l "but019"

                self.uiPopup.uiButton2.OnAction = function ()

                    UIManager.stack:Pop()
                    game:PostStateChange("title")

                end

                UIManager.stack:Push(self.uiPopup)

            end
            
        end
    end

end
