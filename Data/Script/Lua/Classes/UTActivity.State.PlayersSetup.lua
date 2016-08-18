
--[[--------------------------------------------------------------------------
--
-- File:            UTActivity.State.PlayersSetup.lua
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

require "UTActivity.Ui.PlayersSetup"

--[[ Class -----------------------------------------------------------------]]

UTActivity.State.PlayersSetup = UTClass(UTState)

-- defaults

UTActivity.State.PlayersSetup.uiClass = UTActivity.Ui.PlayersSetup

-- __ctor --------------------------------------------------------------------

function UTActivity.State.PlayersSetup:__ctor(activity, ...)

    assert(activity)

    -- override silent mode to skip ui,
    -- when there are no configuration data

    self.silent = false

end

-- Begin ---------------------------------------------------------------------

function UTActivity.State.PlayersSetup:Begin()

    assert(activity.match)
    assert(activity.match.challengers and 0 < #activity.match.challengers)
    assert(activity.match.players and 0 < #activity.match.players)


    -- decrease the timings on the device pinger,
    -- so that we can detect device deconnections a little bit faster

    assert(engine.libraries.usb.proxy.processes.devicePinger)
    engine.libraries.usb.proxy.processes.devicePinger:Reset(2000000, 4000000, 500000)

    -- heap data are intermediate ones,
    -- they live throughout the duration of a single match (cf. "matchmaking"),
    -- they are initialized each time when a new match is begun (cf. "beginmatch")

	for index, challenger in ipairs(activity.match.challengers) do

		-- init heap data

		activity:InitEntityHeapData(challenger, index)

		-- the player has not rfGun ... so give him one : for single game only !

		if (activity.category == UTActivity.categories.single) then

			if (challenger:IsKindOf(UTPlayer) and not challenger.rfGunDevice) then

				for _, player in ipairs(activity.players) do

					if (player.rfGunDevice) then

						local device = player.rfGunDevice
						player:BindDevice()
						challenger:BindDevice(device)
						break

					end

				end

			end

			-- check gun presence	

			if (challenger:IsKindOf(UTPlayer) and not challenger.rfGunDevice) then

				self.uiPopup = UIPopupWindow:New()

				self.uiPopup.title = l"con037"
				self.uiPopup.text = l"con049"

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
					--UIManager.stack:Pop()
					--game:PostStateChange("title")

				end

				UIManager.stack:Push(self.uiPopup)	
		
			end

		end

	end

    self.messaging = false

    if (activity.configData) then self.messaging = true end
    --if (not (activity.category == UTActivity.categories.single) and not self.silent) then self.messaging = true end
	if (not self.silent) then self.messaging = true end

    if (self.messaging) then

        -- clear silent mode when there are configuration data to be sent,
        -- clear silent mode when harness is to be checked

        self.silent = false

	    -- the configuration message must be sent to the current match's players only,
	    -- must retrieve the list of bound devices


	    self.timer = quartz.system.time.gettimemicroseconds()

		self.configDone = false
		for _, player in ipairs(activity.match.players) do

			if (player.rfGunDevice) then

				player.rfGunDevice.acknowledge = false
				player.data.heap.harnessOn = false

			end
		end

	    -- register	to proxy message received
	    engine.libraries.usb.proxy._DispatchMessage:Add(self, UTActivity.State.PlayersSetup.OnDispatchMessage)	

        -- ui depending from game category

		if (self.uiClass) then
			UIMenuManager.stack:Push(self.uiClass)
		end

    end
    
    uploadbytecode = false

end

-- End -----------------------------------------------------------------------

function UTActivity.State.PlayersSetup:End()

    -- reset the timings on the device pinger,

    if (engine.libraries.usb.proxy) then
    
		--assert(engine.libraries.usb.proxy.processes.devicePinger)
		--engine.libraries.usb.proxy.processes.devicePinger:Reset()

		if (self.messaging) then

			-- unregister to proxy message received
			engine.libraries.usb.proxy._DispatchMessage:Remove(self, UTActivity.State.PlayersSetup.OnDispatchMessage)	

		end
		
	end

	-- warning: do not pop the ui page ever,
	-- it is the 'beginmatch' ui that pops its underlying page after its curtains are closed

    -- in silent mode, there is nothing to be popped ...

	--UIMenuManager.stack:Pop() 

end

-- OnDispatchMessage --------------------------------------------------------------------

function UTActivity.State.PlayersSetup:OnDispatchMessage(device, addressee, command, arg)

	if (0x92 == command) then

        -- receive acknowledgement on a per device basis,
        -- configuration data is sent to one device at a time (index = 1)

		device.acknowledge = true

	elseif (0xc1 == command) then

        -- harness connection ack.
        if (device.owner) then 
			device.owner.data.heap.harnessOn = (1 == arg[1])
        end

	end

end

-- Update -------------------------------------------------------------------

function UTActivity.State.PlayersSetup:Update()

	for _, player in ipairs(activity.match.players) do
		if (player.rfGunDevice.timedout) then
			self.configDone = false
			player.rfGunDevice.acknowledge = false
		end
	end
    
    if (not self.messaging or not engine.libraries.usb.proxy) then return
    end

	-- send some message every 250 ms

	local elapsedTime = quartz.system.time.gettimemicroseconds() - (self.timer or quartz.system.time.gettimemicroseconds())
	self.timer = quartz.system.time.gettimemicroseconds()

	self.msgTimer = (self.msgTimer or 0) + elapsedTime
	if (self.msgTimer > 250000) then

		self.msgTimer = 0

		if (self.configDone) then

			-- harness check message

			if not (activity.category == UTActivity.categories.single) then

				self.message = {0x00, 0xff, 0xc1, }
				quartz.system.usb.sendmessage(engine.libraries.usb.proxy.handle, self.message)

			end

		else

			self.configDone = true

			for _, player in ipairs(activity.match.players) do

				if (player.rfGunDevice and not player.rfGunDevice.acknowledge) then

					self.configDone = false

					-- send the configuration message,
					-- when applicable

					-- full message data = sound volume + beam power + configuration data 

					if (activity.advancedsettings.classes) then
						self.message = { 3 + #activity.configData * 2, player.rfGunDevice.radioProtocolId, 0x92, player.data.heap.audio, player.data.heap.beamPower, #activity.configData}
					else
						self.message = { 3 + #activity.configData * 2, player.rfGunDevice.radioProtocolId, 0x92, game.settings.audio["volume:blaster"], game.settings.ActivitySettings.beamPower, #activity.configData}
					end
					for i = 1, #activity.configData do

						self.message[2 * i + 5] = quartz.system.bitwise.bitwiseand(player.data.heap[activity.configData[i]], 0xff00) / 256
						self.message[2 * i + 6] = quartz.system.bitwise.bitwiseand(player.data.heap[activity.configData[i]], 0x00ff)

					end

				end

				quartz.system.usb.sendmessage(engine.libraries.usb.proxy.handle, self.message)

			end

		end

	end

end
