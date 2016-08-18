
--[[--------------------------------------------------------------------------
--
-- File:            ULUsbDevice.Pinger.lua
--                  Copyright (c) Ubisoft Entertainment. All rights reserved.
--
-- Project:         Ubitoys.Tag
-- Date:            September 30, 2010
--
------------------------------------------------------------------------------
--
-- Description:     ...
--
----------------------------------------------------------------------------]]

--[[ Dependencies ----------------------------------------------------------]]

--[[ Class -----------------------------------------------------------------]]

ULUsbDevice.Pinger = UTClass(UTProcess)

-- defaults

ULUsbDevice.Pinger.startSuspended = true
ULUsbDevice.Pinger.updateFrameRate = 0

ULUsbDevice.Pinger.timeouts = {

    lo = 5000000, hi = 10000000, interval = 1000000,

}

-- __ctor --------------------------------------------------------------------

function ULUsbDevice.Pinger:__ctor(proxy)

    assert(proxy)
    assert(proxy.handle)

    self.proxy = proxy
    self.handle = self.proxy.handle

    --

    self.timeout = {
        lo = ULUsbDevice.Pinger.timeouts.lo,
        hi = ULUsbDevice.Pinger.timeouts.hi,
        interval = ULUsbDevice.Pinger.timeouts.interval,
    }

end

-- OnResumed -----------------------------------------------------------------

function ULUsbDevice.Pinger:OnResumed()

    print("ULUsbDevice.Pinger:OnResumed()")
    
    -- reset all devices' timers

    local devices = self.proxy.devices.byClass[0x02000020]
    if (devices) then

        for _, device in pairs(devices) do
            device.timeout = 0
            --device.timedout = false
        end
    end

    self.time, self.interval = quartz.system.time.gettimemicroseconds(), 0
    self.pingMessage = { 0x00, 0xff, 0x05 }

end

-- OnSuspended ---------------------------------------------------------------

function ULUsbDevice.Pinger:OnSuspended()

    print("ULUsbDevice.Pinger:OnSuspended()")

end

-- OnUpdate ------------------------------------------------------------------

function ULUsbDevice.Pinger:OnUpdate()

    if (self.protectedMode) then return
    end

    assert(engine.libraries.usb.proxy)
    assert(engine.libraries.usb.proxy.handle)

    local time = quartz.system.time.gettimemicroseconds()
    local elapsedTime = time - self.time

    self.time = time

    local devices = self.proxy.devices.byClass[0x02000020]
    if (devices) then

        local ping = false

        for _, device in pairs(devices) do

            device.timeout = (device.timeout or 0) + elapsedTime
            if (device.timeout >= self.timeout.hi) then
            	if (not device.timedout) then
					quartz.framework.audio.loadsound("base:audio/ui/gundisconnected.wav")
					quartz.framework.audio.loadvolume(game.settings.audio["volume:gd"])
					quartz.framework.audio.playsound()
            	end
            	device.timedout = true
            	if (device.timeout >= 80000000 and game.gameMaster.ingame or not game.gameMaster.ingame) then

                	-- device definitely timed out,
                	-- force disconnection

                	if (not self.protectedMode and (not game.gameMaster.ingame or game.settings.GameSettings.protectedmode ~= 1)) then

                   		if (game.settings.GameSettings.unregister == 1 or game.gameMaster.ingame or unregisterguns) then
                   			self.proxy:Unregister(device, "timedout")
                   			return
                   		end

                	else

                    	-- under protected mode,
                   		-- just ignore the timeout and give the device another chance
                   		
                    	device.timeout = 0
                    	--device.timedout = 0
                    	print("[protectedMode] device should have been disconnected", tostring(device.reference))
                    end

                end

            elseif (device.timeout >= self.timeout.lo) then

                -- device has not acknowledged itself for quite some time,
                -- send a ping signal to force an acknowledge

                ping = true

            end
        end

        -- broadcast ping signal,
        -- check for interval so as not to flood the rf

        if (ping) then

            self.interval = self.interval - elapsedTime
            if (self.interval <= 0) then

                self.interval = self.timeout.interval
                quartz.system.usb.sendmessage(self.handle, self.pingMessage)

                print("ping")

            end
        end

    else

        self:Suspend()

    end

end

-- Reset ---------------------------------------------------------------------

function ULUsbDevice.Pinger:Reset(lo, hi, interval, protectedMode)

    self.protectedMode = false

    if (lo and hi and interval) then

        self.timeout = {
            lo = lo,
            hi = hi,
            interval = interval,
        }

        self.protectedMode = protectedMode

    else

        self.timeout = {
            lo = ULUsbDevice.Pinger.timeouts.lo,
            hi = ULUsbDevice.Pinger.timeouts.hi,
            interval = ULUsbDevice.Pinger.timeouts.interval,
        }

        self.protectedMode = false

    end

    -- reset all devices' timers

    self.time = quartz.system.time.gettimemicroseconds()
    local devices = self.proxy.devices.byClass[0x02000020]
    if (devices) then

        for _, device in pairs(devices) do
            device.timeout = 0
            device.timedout = false
        end
    end

end