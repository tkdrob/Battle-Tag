
--[[--------------------------------------------------------------------------
--
-- File:            ULUsbProxy.lua
--                  Copyright (c) Ubisoft Entertainment. All rights reserved.
--
-- Project:         Ubitoys.Tag
-- Date:            August 2, 2010
--
------------------------------------------------------------------------------
--
-- Description:     ...
--
----------------------------------------------------------------------------]]

--[[ Dependencies ----------------------------------------------------------]]

require "Engine/Libraries/ULUsbDevice.FlashMemoryManager"
require "Engine/Libraries/ULUsbDevice.Pinger"

--[[ Class -----------------------------------------------------------------]]

ULUsbProxy = UTClass(ULUsbDevice)

-- defaults

-- state dependencies

ULUsbProxy.State = {}

    require "Engine/Libraries/ULUsbProxy.State.Bootloader"
    require "Engine/Libraries/ULUsbProxy.State.Initialize"
    require "Engine/Libraries/ULUsbProxy.State.Reference"
    require "Engine/Libraries/ULUsbProxy.State.Revision"
    require "Engine/Libraries/ULUsbProxy.State.Upload"

-- __ctor --------------------------------------------------------------------

function ULUsbProxy:__ctor(handle, ...)

    print("ULUsbProxy:__ctor")

    self.locked = true -- the proxy does not accept incoming connections requests

    -- the whitelist contains references of devices that are allowed to reconnect,
    --  even when the proxy is locked

    self.whiteList = {}

    -- message processors

    self.processors[0x01] = ULUsbProxy.ProcessMessage0x01 -- initialization completion
    self.processors[0x12] = ULUsbProxy.ProcessMessage0x12 -- remote device connection request
    self.processors[0x22] = ULUsbProxy.ProcessMessage0x22 -- firmware update

    -- states

    self.states["bootloader"] = ULUsbProxy.State.Bootloader:New(self)
    self.states["initialize"] = ULUsbProxy.State.Initialize:New(self)
    self.states["reference"] = ULUsbProxy.State.Reference:New(self)
    self.states["revision"] = ULUsbProxy.State.Revision:New(self)
    self.states["upload"] = ULUsbProxy.State.Upload:New(self)
    
    -- events
    
    self._Connected = UTEvent:New()
    self._DeviceAdded = UTEvent:New()
    self._DeviceRemoved = UTEvent:New()
    self._DispatchMessage = UTEvent:New()
    self._Initialized = UTEvent:New()
    self._Reset = UTEvent:New()

    --

    self.processes = {}

    self.processes.deviceFlashMemoryManager = ULUsbDevice.FlashMemoryManager:New(self)
    self.processes.deviceFlashMemoryManager:Suspend()

    self.processes.devicePinger = ULUsbDevice.Pinger:New(self)
    self.processes.devicePinger:Suspend()

    -- restart the state machine

    self:Reset()

    self:Restart("initialize")

end

-- __dtor --------------------------------------------------------------------

function ULUsbProxy:__dtor()

    print("ULUsbProxy:__dtor")

    if (self.initialized) then

        quartz.system.usb.sendmessage(self.handle, { 0x00, 0x00, 0x02 }) -- shutdown
        self.initialized = false

    end

end

-- Connect -------------------------------------------------------------------

function ULUsbProxy:Connect()

    assert(not self.connected)

    if (not self.connected) then

        self.connected = true

        -- notify

        self:OnConnected()

    end

end

-- DispatchMessage -----------------------------------------------------------

function ULUsbProxy:DispatchMessage(addressee, command, arg)

    -- lookup within listof remote devices ...
    
    if (self.devices) then

        local device = self.devices.byRadioProtocolId[addressee]

        if (device) then

            device:ProcessMessage(addressee, command, arg)
            self:OnDispatchMessage(device, addressee, command, arg)

        end
    end

end

-- Initialize ----------------------------------------------------------------

function ULUsbProxy:Initialize(arg)

    assert(not self.initialized)
    assert(arg and type(arg) == "number" and -1 < arg)

    self:Connect()

    if (not self.initialized) then

        self.initialized = true

        self.radioProtocolChannel = arg
        self.radioProtocolId = 0x01

        self:Register(self) -- register ourselves as a standard rf device

        -- notify

        self:OnInitialized()

    end

end

-- Lock ----------------------------------------------------------------------

function ULUsbProxy:Lock()

    self.locked = true

end

-- OnConnected ---------------------------------------------------------------

function ULUsbProxy:OnConnected()

    self._Connected:Invoke(self)

end

-- OnDispatchMessage ---------------------------------------------------------

function ULUsbProxy:OnDispatchMessage(device, addressee, command, arg)

    self._DispatchMessage:Invoke(device, addressee, command, arg)

end

-- OnInitialized -------------------------------------------------------------

function ULUsbProxy:OnInitialized()

    self._Initialized:Invoke(self, self.radioProtocolChannel)

end

-- OnReferenced --------------------------------------------------------------

function ULUsbProxy:OnReferenced()

    ULUsbDevice.OnReferenced(self)
    
    -- register ourselves as a standard rf device, again,
    -- because now we have a proper reference

    self:Register(self)

end

-- OnReset -------------------------------------------------------------------

function ULUsbProxy:OnReset()

    self._Reset:Invoke(self)

end

-- ProcessMessage ------------------------------------------------------------

function ULUsbProxy:ProcessMessage(addressee, command, arg)

    if (addressee == 0x00) then

        local processor = self.processors and self.processors[command]

        if (processor) then
            processor(self, arg)
        end

    else

        ULUsbDevice.ProcessMessage(self, addressee, command, arg)

    end

end

-- ProcessMessage0x01 --------------------------------------------------------

function ULUsbProxy:ProcessMessage0x01(arg)

    -- initialization report,
    -- retrieve rf channel from arguments & get initialized

    local radioProtocolChannel = arg and arg[2] or -1

    if (not self.initialized) then

        self:Initialize(radioProtocolChannel)

        -- setup the rf connection,
        -- we need to register the device first (possible since we do receive the device's reference)

        local reference = UTReference:New(arg, 2)

        self:Reference(reference.bytes)

        local message = { 0x0a, 0x00, 0x12, self.radioProtocolId, self.classId, unpack(self.reference.bytes) }
        print("MESSAGE D'INIT", unpack(message))
        quartz.system.usb.sendmessage(self.handle, message)

    else

        assert(radioProtocolChannel == self.radioProtocolChannel)

    end

end

-- ProcessMessage0x12 --------------------------------------------------------

function ULUsbProxy:ProcessMessage0x12(arg)

    -- remote device connection request,
    -- message contains both remote device's and paired proxy's references

    -- discard request if the proxy does not accept connections

    if (arg and 16 == #arg) then

        local deviceReference = UTReference:New(arg)
        local pairedReference = UTReference:New(arg, 8)

        if (self.reference == pairedReference) then

            -- accept connection

            -- only when not locked,
            -- or maybe if the device was white-listed

            local reference = tostring(deviceReference)
            local whiteListedReference = self.whiteList[reference]

            if (not self.locked or whiteListedReference and (not game.gameMaster.ingame or game.settings.GameSettings.reconnect == 1 or game.settings.GameSettings.reconnect == 3)) then

                if (game.settings.GameSettings.reconnect == 3) then
                    game.settings.GameSettings.reconnect = 2
                end
                if (whiteListedReference) then print(reference .. " *whitelisted*") end

                -- make sure the device was not created yet,
                -- (we don't know for sure our acknoledge was received, it's an acknowledge already)

                for radioProtocolId, device in pairs(self.devices.byRadioProtocolId) do
                    if (device.reference == deviceReference) then

                        -- the device is already mapped,
                        -- acknoledge the request anyway in case the last message did not get received ...

                        local message = { 0x0b, 0xff, 0x12, device.radioProtocolId, device.classId, self.radioProtocolId, unpack(device.reference.bytes) }
                        quartz.system.usb.sendmessage(self.handle, message)
                        
						if (game.gameMaster.ingame) then
							device.gamedatablock = true
							device.rejoin = true
						end
						device.timeout = 0
						device.timedout = false

                        -- if the device was white-listed,
                        -- it comes handy to dispatch the connexion message

                        --[[if (whiteListedReference) then

                            local arg = { device.radioProtocolId, device.classId, self.radioProtocolId, unpack(device.reference.bytes) }
                            self:DispatchMessage(device.radioProtocolId, 0x12, arg)

                            -- restart

                            device.revision = nil
                            device.revisionCandidate = nil
                            device.updateRequired = nil

                            device:Restart()

                        end]]

                        return

                    end
                end

                -- create new device

                local device = ULUsbDevice:New(self.handle)

                -- initialize new device,
                -- register new device (byRadioProtocolId(newone), byclass,

                device:Reference(deviceReference.bytes)

                --[[if (whiteListedReference) then

                    --print("//////////////////////////////////////////////////////////////////")
                    --print(self.devices.byRadioProtocolId[whiteListedReference.radioProtocolId])
                    --print(whiteListedReference.owner)

                    -- if the device was whitelisted,
                    -- then we shall retrieve its former settings

                    device.radioProtocolChannel = whiteListedReference.radioProtocolChannel
                    device.radioProtocolId = whiteListedReference.radioProtocolId

                    self:Register(device)

                else]]

                    for radioProtocolId = 2, 254 do

                        if (not self.devices.byRadioProtocolId[radioProtocolId]) then

                            device.radioProtocolChannel = self.radioProtocolChannel
                            device.radioProtocolId = radioProtocolId

                            self:Register(device)

                            self:WhiteList(reference, device)

                            break

                        end
                    end

                --end

                assert(device.radioProtocolChannel)
                assert(device.radioProtocolId)

                assert(device == self.devices.byRadioProtocolId[device.radioProtocolId])

                -- acknoledge the request

                local message = { 0x0a, 0xff, 0x12, device.radioProtocolId, device.classId, self.radioProtocolId, unpack(device.reference.bytes) }
                quartz.system.usb.sendmessage(self.handle, message)

            end

        else print("ULUsbProxy", "receiving connection request from *unpaired* device")
        end

    end

end

-- ProcessMessage0x22 --------------------------------------------------------

function ULUsbProxy:ProcessMessage0x22(arg)

    if (not self.connected) then

        assert(arg and 0x0a == #arg)
        self.revisionUpdate = quartz.system.bitwise.lshift(arg[1], 8) + arg[2]

        self:Connect()

        self.reference = UTReference:New(arg, 2) 

    else

        assert(arg and 0x02 <= #arg)
        self.revisionUpdate = quartz.system.bitwise.lshift(arg[1], 8) + arg[2]

    end

end

-- Reset ---------------------------------------------------------------------

function ULUsbProxy:Register(device)

    assert(device and device:IsKindOf(ULUsbDevice))
    assert(device.radioProtocolId and type(device.radioProtocolId) == "number")

    -- byRadioProtocolId

    assert(not self.devices.byRadioProtocolId[device.radioProtocolId] or device == self.devices.byRadioProtocolId[device.radioProtocolId])
    self.devices.byRadioProtocolId[device.radioProtocolId] = device

    -- byClass,

    if (device.reference) then

        -- the class is just the device's reference being masked,
        -- we keep the category and the major type

        local class = quartz.system.bitwise.bitwiseand(device.reference[1], 0x0f00fff0)

        self.devices.byClass[class] = self.devices.byClass[class] or {} -- may have to create new table there

        device.classId = 1
        devicemodcount = 0
        while (self.devices.byClass[class][device.classId]) do
            device.classId = device.classId + 1
            if (game.settings.GameSettings.playernumbermod == 1 and device.classId == 10) then
            	device.classId = 16
            end
            if (device.classId >= 10) then
            	devicemodcount = devicemodcount + 1
            	devicenumberflag = true
            end
        end

        self.devices.byClass[class][device.classId] = device

        -- notify, only fully referenced devices ...

        print("Register", "device added, reference = " .. tostring(device.reference), "classId = " .. device.classId)
        self._DeviceAdded:Invoke(device)

        if (class ~= 0x01000010) then

            -- if the device is not a ubiconnect,
            -- then boot the device

            device:PostStateChange("boot")

            -- start monitoring the devices,
            -- the process disconnects timed out devices

            self.processes.devicePinger:Resume()

        end
    
    end
    
    device.teamdefault = true

end

-- Reset ---------------------------------------------------------------------

function ULUsbProxy:Reset()

    self:OnReset()

    -- reset

    self.radioProtocolChannel = -1

    if (self.devices) then
    end

    self.devices = {

        byClass = {},
        byRadioProtocolId = {},
    }

end

-- TranslateMessage ----------------------------------------------------------

function ULUsbProxy:TranslateMessage(message)

    return unpack(message) -- kiss

end

-- Unlock --------------------------------------------------------------------

function ULUsbProxy:Unlock()

    self.locked = false

end

-- Unregister ----------------------------------------------------------------

function ULUsbProxy:Unregister(device, reason)

    print("Unregister")
    assert(device)

    assert(device.radioProtocolId)
    assert(device.reference)

    -- remove device from lists

    local class = quartz.system.bitwise.bitwiseand(device.reference[1], 0x0f00fff0)

    if (self.devices.byClass[class] and self.devices.byClass[class][device.classId]) then

        assert(self.devices.byClass[class][device.classId] == device)
        if (device.classId >= 10) then
        	devicemodcount = devicemodcount - 1
        	if (devicemodcount == 0) then
        		devicenumberflag = false
        	end
        end
        self.devices.byClass[class][device.classId] = nil

        -- destroy table if there are no remaining devices left

        local remaining = 0
        for _, device in pairs(self.devices.byClass[class]) do
            remaining = remaining + 1
        end

        if (0 == remaining) then
            self.devices.byClass[class] = nil
            nbgunsdisconnect = 0
        end

    end

    if (self.devices.byRadioProtocolId[device.radioProtocolId]) then

        assert(self.devices.byRadioProtocolId[device.radioProtocolId] == device)
        self.devices.byRadioProtocolId[device.radioProtocolId] = nil

        -- notify

        print("Unregister", "device removed, reference = " .. tostring(device.reference), "classId = " .. device.classId)
        self._DeviceRemoved:Invoke(device)

        device:Delete() -- just for the sake of it ...

    end

end

-- Update --------------------------------------------------------------------

function ULUsbProxy:Update()

    -- message loop

    local result, message = quartz.system.usb.peekmessage(self.handle)
    while (message) do

        local addressee, command, arg = self:TranslateMessage(message)

        --if (arg) then print("message", addressee, command, unpack(arg))
        --else print("message", addressee, command, '-')
        --end

        if (0x00 == addressee) then

            -- this message is targeted to the proxy itself,
            -- process it

            self:ProcessMessage(addressee, command, arg)

        else

            -- dispatch,
            -- find who to forward the message to

            self:DispatchMessage(addressee, command, arg)

        end
        
        result, message = quartz.system.usb.peekmessage(self.handle)

    end

    -- update all gun devices

    local devices = self.devices.byClass[0x02000020]
    if (devices) then

        for _, device in pairs(devices) do
            device:Update()
        end
    end

	-- processes

    for _, process in pairs(self.processes) do
	    if not (process.status == UTProcess.Suspended) then process:Update()
	    end
	end

    -- base

    ULUsbDevice.Update(self)

end

-- WhiteList -----------------------------------------------------------------

function ULUsbProxy:WhiteList(reference, device)

    if (reference) then
        self.whiteList[reference] = device and reference
    else
        self.whiteList = {}
    end

end
