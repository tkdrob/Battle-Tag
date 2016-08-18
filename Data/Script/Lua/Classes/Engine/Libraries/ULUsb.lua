
--[[--------------------------------------------------------------------------
--
-- File:            ULUsb.lua
--                  Copyright (c) Ubisoft Entertainment. All rights reserved.
--
-- Project:         Ubitoys.Tag
-- Date:            June 7, 2010
--
------------------------------------------------------------------------------
--
-- Description:     ...
--
----------------------------------------------------------------------------]]

--[[ Dependencies ----------------------------------------------------------]]

require "quartz.system.usb"

--[[ Class -----------------------------------------------------------------]]

UTClass.ULUsb(UELibrary)

-- defaults

ULUsb.updateFrameRate = 15

-- dependencies

    require "Engine/Libraries/ULUsbDevice" -- ref. device
    require "Engine/Libraries/ULUsbProxy" -- ubiconnect(tm) proxy device

-- state dependencies

ULUsb.State = {}

    require "Engine/Libraries/ULUsb.State.Connected"
    require "Engine/Libraries/ULUsb.State.Disconnected"

-- handles are managed by the c++ application,
-- each time a compatible usb device is plugged in or out,
-- then a new handle is created and the lua script gets notified

ULUsb.handles = {}

-- __ctor --------------------------------------------------------------------

function ULUsb:__ctor(engine, ...)

    -- before we open the library we should register two callbacks,
    -- to get notified when a compatible usb device is either plugged in or out

    -- OnDeviceArrival -------------------------------------------------------

    local function OnDeviceArrival(handle)

        -- register handle

        for index, value in ipairs(ULUsb.handles) do
            assert(value ~= handle)
        end

        table.insert(ULUsb.handles, handle)
        self:OnDeviceArrival(handle)

    end

    -- OnDeviceRemoveComplete-------------------------------------------------

    local function OnDeviceRemoveComplete(handle)

        local removed = nil

        -- remove the handle from the list,
        -- if the handle corresponds to a proxy device then close & discard the proxy

        for index, value in ipairs(ULUsb.handles) do
            if (value == handle) then

                removed = table.remove(ULUsb.handles, index)
                self:OnDeviceRemoveComplete(handle)

            end
        end

        assert(removed)

    end

    quartz.system.usb.setcallbackdevicearrival(OnDeviceArrival)
    quartz.system.usb.setcallbackdeviceremovecomplete(OnDeviceRemoveComplete)

    -- states

    self.states = {}

    self.states["connected"] = ULUsb.State.Connected:New(self)
    self.states["disconnected"] = ULUsb.State.Disconnected:New(self)

    self.default = "disconnected"

    -- wait for engine ignition before restarting the state machine

    engine._IgnitionComplete:Add(self, ULUsb.EngineIgnitionComplete)

    -- events

    self._DeviceArrival = UTEvent:New()
    self._DeviceRemoveComplete = UTEvent:New()

    self._Connected = UTEvent:New()
    self._Disconnected = UTEvent:New()

end

-- __dtor --------------------------------------------------------------------

function ULUsb:__dtor()

    self:Disconnect()

end

-- Close ---------------------------------------------------------------------

function ULUsb:Close()

    if (self.opened) then

        self:Disconnect()
        
        assert(self.module)
        assert(type(self.module) == "userdata")

        quartz.system.usb.close(self.module); self.module = nil

        UELibrary.Close(self)

    end

    return self.opened

end

-- Connect -------------------------------------------------------------------

function ULUsb:Connect(device)

    -- make sure we have a proxy there

    assert(device and device:IsKindOf(ULUsbProxy))

    assert(not self.proxy); self.proxy = device; self.connected = true

    -- we assume we are connected,
    -- while the proxy exists and is up and running ...

    self:PostStateChange("connected")
    self:OnConnected()

end

-- Disconnect ----------------------------------------------------------------

function ULUsb:Disconnect()

    if (self.proxy) then

        self:OnDisconnected()
        self.proxy:Delete(); self.proxy = nil; self.connected = false

        -- restart the state machine

        self:PostStateChange("disconnected")

    end

end

-- EngineIgnitionComplete ----------------------------------------------------

function ULUsb:EngineIgnitionComplete()

    -- engine ingition was complete,
    -- we can restart the state machine

    self:Restart()

end

-- OnConnected ---------------------------------------------------------------

function ULUsb:OnConnected()

    print("ULUsb:OnConnected")
    self._Connected:Invoke(self.proxy)

end

-- OnDeviceArrival -----------------------------------------------------------

function ULUsb:OnDeviceArrival(handle)

    print("ULUsb:OnDeviceArrival", handle)
    self._DeviceArrival:Invoke(handle)

end

-- OnDeviceRemoveComplete ----------------------------------------------------

function ULUsb:OnDeviceRemoveComplete(handle)

    print("ULUsb:OnDeviceRemoveComplete", handle)
    self._DeviceRemoveComplete:Invoke(handle)

end

-- OnDisconnected ------------------------------------------------------------

function ULUsb:OnDisconnected()

    print("ULUsb:OnDisconnected")
    self._Disconnected:Invoke(self.proxy)

end

-- OnUpdate ------------------------------------------------------------------

function ULUsb:OnUpdate()

    -- base

    UELibrary.OnUpdate(self)

end

-- Open ----------------------------------------------------------------------

function ULUsb:Open()

    if (not self.opened) then

        self.module = quartz.system.usb.open()

        if (self.module) then

            assert(self.module)
            assert(type(self.module) == "userdata")

            -- assume the library was opened

            UELibrary.Open(self)

        end
    end

    return self.opened

end

-- Reset ---------------------------------------------------------------------

function ULUsb:Reset()

    self:Disconnect()

end
