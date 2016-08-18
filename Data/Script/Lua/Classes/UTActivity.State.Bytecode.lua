
--[[--------------------------------------------------------------------------
--
-- File:            UTActivity.State.Bytecode.lua
--                  Copyright (c) Ubisoft Entertainment. All rights reserved.
--
-- Project:         Ubitoys.Tag
-- Date:            July 27, 2010
--
------------------------------------------------------------------------------
--
-- Description:     ...
--
----------------------------------------------------------------------------]]

--[[ Dependencies ----------------------------------------------------------]]

require "UTActivity.Ui.Bytecode"

--[[ Class -----------------------------------------------------------------]]

UTActivity.State.Bytecode = UTClass(UTState)

-- __ctor --------------------------------------------------------------------

function UTActivity.State.Bytecode:__ctor(activity, ...)

    assert(activity)

end

-- Begin ---------------------------------------------------------------------

function UTActivity.State.Bytecode:Begin()

	-- load bytecode
	local path = activity.bytecodePath
    local chunk, message = loadfile(path)
    self.result, self.byteCode = pcall(chunk)
	if (self.result) then
		self.CODE_LENGTH = #self.byteCode
	end
	
	print("CODE LENGTH : " .. self.CODE_LENGTH .. " -------------------------------------------")
	
	-- UI

    UIMenuManager.stack:Push(UTActivity.Ui.Bytecode)

	-- initialise command

	self.command = 0x86
	self.lockFlash = 0;

	-- TOC for flash mem : header(4 o) number(1 o) entry(4 o) offset(2 o) size(2 o) size(2 o)

	self.TOC = {0x43, 0x4f, 0x44, 0x45, 0x01, 0x44, 0x46, 0x4c, 0x54, 0x0d, 0x00, 
			quartz.system.bitwise.bitwiseand(self.CODE_LENGTH, 0x00ff), quartz.system.bitwise.bitwiseand(self.CODE_LENGTH, 0xff00) / 256,
			quartz.system.bitwise.bitwiseand(self.CODE_LENGTH, 0x00ff), quartz.system.bitwise.bitwiseand(self.CODE_LENGTH, 0xff00) / 256}
	self.flashMemory = {0x00, 0x00, 0x40, 0x00}

	-- add magic number 

	self.byteCode[self.CODE_LENGTH + 1] = 0x22
	self.byteCode[self.CODE_LENGTH + 2] = 0x04
	self.byteCode[self.CODE_LENGTH + 3] = 0x19
	self.byteCode[self.CODE_LENGTH + 4] = 0x86

	-- initialise message

	self.msgTotalSize = self.CODE_LENGTH + #self.TOC + 4
	self:CreateNextMessage()
	self.step = 0
	self.maxStep = 2 + math.ceil((self.CODE_LENGTH + #self.TOC + 4) / 58)

	-- register	to proxy message received

    assert(engine.libraries.usb)
    assert(engine.libraries.usb.proxy)

    -- decrease the timings on the device pinger,
    -- so that we can detect device deconnections a little bit faster

    assert(engine.libraries.usb.proxy.processes.devicePinger)
    --engine.libraries.usb.proxy.processes.devicePinger:Reset(2000000, 4000000, 500000)
    engine.libraries.usb.proxy.processes.devicePinger:Reset(4000000, 8000000, 500000)

	-- event from proxy

	engine.libraries.usb.proxy._DispatchMessage:Add(self, UTActivity.State.Bytecode.OnMessageReceived)	
    engine.libraries.usb.proxy._DeviceRemoved:Add(self, UTActivity.State.Bytecode.OnDeviceRemoved)

	-- stop bytecode sending

	self.stopSending = false	

end

-- CreateNextMessage ---------------------------------------------------------

function UTActivity.State.Bytecode:CreateNextMessage()

	-- init timer

	self.timer = quartz.system.time.gettimemicroseconds()

	-- create message

	if (self.command == 0x81) then

		-- erase page
		self.msg = {0x04, 0xff, self.command, self.flashMemory[1], self.flashMemory[2], self.flashMemory[3], self.flashMemory[4]}

	elseif (self.command == 0x82) then

		-- init write sequence
		self.msg = {0x06, 0xff, self.command, self.flashMemory[1], self.flashMemory[2], self.flashMemory[3], self.flashMemory[4],
			 quartz.system.bitwise.bitwiseand(self.msgTotalSize, 0xff00) / 256, quartz.system.bitwise.bitwiseand(self.msgTotalSize, 0x00ff)}

	elseif (self.command == 0x83) then

		-- info for this message : nb data, broadcast, command, offset and length

		local msgSize = math.min(self.msgTotalSize - self.offset, 58)
		self.msg = {msgSize + 3, 0xff, self.command, quartz.system.bitwise.bitwiseand(self.offset, 0xff00) / 256, quartz.system.bitwise.bitwiseand(self.offset, 0x00ff), msgSize}

		-- write msg
		for i = 1, msgSize do

			if (i + self.offset <= #self.TOC) then
				self.msg[i + 6] = self.TOC[i]
			else
				self.msg[i + 6] = self.byteCode[i + self.offset - #self.TOC]
			end

		end

		-- next offset
		self.offset = self.offset + msgSize

	elseif (self.command == 0x86) then

		-- lock flash
		self.msg = {0x01, 0xff, self.command, self.lockFlash}

	end

	-- init answers

	for _, player in ipairs(activity.players) do

		if (player.rfGunDevice) then player.rfGunDevice.acknowledge = false 
		end

	end

end

-- End -----------------------------------------------------------------------

function UTActivity.State.Bytecode:End()

    -- reset the timings on the device pinger,

    if (engine.libraries.usb.proxy) then
    
		assert(engine.libraries.usb.proxy.processes.devicePinger)
		engine.libraries.usb.proxy.processes.devicePinger:Reset()
		
		-- unregister to proxy message received

		engine.libraries.usb.proxy._DispatchMessage:Remove(self, UTActivity.State.Bytecode.OnMessageReceived)	
		engine.libraries.usb.proxy._DeviceRemoved:Remove(self, UTActivity.State.Bytecode.OnDeviceRemoved)

	end
	-- pop menu

	UIMenuManager.stack:Pop() 

end

-- OnDeviceRemoved -----------------------------------------------------------

function UTActivity.State.Bytecode:OnDeviceRemoved(device)

	-- a device from my list has been removed : STOP right now and go back to main menu

	if (not self.stopSending) then

		for _, player in ipairs(activity.players) do
		
			if (player.rfGunDevice and player.rfGunDevice == device) then
				
					self.uiPopup = UIPopupWindow:New()

					self.uiPopup.title = l"con046"
					self.uiPopup.text = l"con048"

					-- buttons

					self.uiPopup.uiButton2 = self.uiPopup:AddComponent(UIButton:New(), "uiButton2")
					self.uiPopup.uiButton2.rectangle = UIPopupWindow.buttonRectangles[2]
					self.uiPopup.uiButton2.text = l "but019"

					self.uiPopup.uiButton2.OnAction = function ()

						UIManager.stack:Pop()
						UIMenuManager.stack:Pop()
						activity.matches = nil
						activity:PostStateChange("playersmanagement")
						self.enabled = false

					end

					self.stopSending = true
					UIManager.stack:Push(self.uiPopup)	
				
				break

			end
		
		end

	end

end

-- OnMessageReceived----------------------------------------------------------

function UTActivity.State.Bytecode:OnMessageReceived(device, addressee, command, arg)

	-- test command !

	if (command == self.command) then

		if (device and not device.acknowledge) then

			-- acknowledge answers 

			if (0x83 == command) then

				local answerOffset = (arg[1] * 256) + arg[2]			
				if (answerOffset == self.offset) then
					device.acknowledge = true
				end

			else
				device.acknowledge = true
			end

			-- every device has answered ?

            local acknowledge = true
	        for _, player in ipairs(activity.players) do

        		if (player.rfGunDevice and not player.rfGunDevice.acknowledge) then 

        		    acknowledge = false
        		    break

		        end

	        end
	        
			if (acknowledge) then
				
				self.step = self.step + 1
				if (command == 0x81) then

					self.command = 0x82 
					self:CreateNextMessage()

				elseif (command == 0x82) then

					self.command		= 0x83 
					self.offset			= 0	
					self:CreateNextMessage()		

				elseif (command == 0x83) then

					if (self.offset == self.msgTotalSize) then

						self.command = 0x86
						self.lockFlash = 1

					end				
					self:CreateNextMessage()

				elseif (command == 0x86) then

					if (0 == self.lockFlash) then

						self.command = 0x81 
						self:CreateNextMessage()		

					else

						-- go now
						activity:PostStateChange("matchmaking")				

					end

				end

			end

		end 

	end

end

-- Update --------------------------------------------------------------------

function UTActivity.State.Bytecode:Update()

	-- send msg each 250ms

	local interval = 250000
    local numberOfPlayers = 0
	for _, player in ipairs(activity.players) do
		if (not player.rfGunDevice.timedout) then
		    numberOfPlayers = numberOfPlayers + 1
		end
	end
	interval = 21000 + (numberOfPlayers*16000)

    local elapsedTime = quartz.system.time.gettimemicroseconds() - self.timer
    if (elapsedTime > interval) then

		-- send current msg

		self.timer = quartz.system.time.gettimemicroseconds()
		quartz.system.usb.sendmessage(engine.libraries.usb.proxy.handle, self.msg)

    end

end
