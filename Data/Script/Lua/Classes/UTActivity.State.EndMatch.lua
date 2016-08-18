
--[[--------------------------------------------------------------------------
--
-- File:            UTActivity.State.EndMatch.lua
--                  Copyright (c) Ubisoft Entertainment. All rights reserved.
--
-- Project:         Ubitoys.Tag
-- Date:            July 28, 2010
--
------------------------------------------------------------------------------
--
-- Description:     ...
--
----------------------------------------------------------------------------]]

--[[ Dependencies ----------------------------------------------------------]]

require "UTActivity.Ui.EndMatch"

--[[ Class -----------------------------------------------------------------]]

UTActivity.State.EndMatch = UTClass(UTState)

-- __ctor --------------------------------------------------------------------

function UTActivity.State.EndMatch:__ctor(activity, ...)

    assert(activity)

end

-- Begin ---------------------------------------------------------------------

function UTActivity.State.EndMatch:Begin()
	
	game.gameMaster:Begin()
	game.gameMaster:RegisterSound({ paths = activity.gameoverSound, probas = {0.8, 0.1, 0.1}, offset = 0.4, })
	
	-- broadcast a gameover message to all devices : wait for an acknowledge before enable continue button in ui

    self.timer = quartz.system.time.gettimemicroseconds()
	for _, player in ipairs(activity.match.players) do
		if (player.rfGunDevice) then player.rfGunDevice.acknowledge = false
		end
	end
	self.isReady = false

	engine.libraries.usb.proxy._DispatchMessage:Add(self, UTActivity.State.EndMatch.OnDispatchMessage)	

	-- intermediate or final ranking ?
	
	activity.finalRanking = true
	if ((activity.category ~= UTActivity.categories.closed) and (0 < #activity.matches)) then
		activity.finalRanking = false
	end	

	-- if the main menu is opened, then close it

	if (activity.mainMenu) then 
		UIManager.stack:Pop()
		activity.mainMenu = nil
	end

    -- ui

	UIManager.stack:Push(UTActivity.Ui.EndMatch)

    -- tracking

if (REG_TRACKING) then

    if (activity.matches and (0 == #activity.matches)) then
        local delegate = engine.libraries.tracking.delegates["FPSCLIENT_STOP"]
        if (delegate) then
            delegate()
        end
    end

end

end

-- End -----------------------------------------------------------------------

function UTActivity.State.EndMatch:End()
    
	game.gameMaster:End()
	
    if (engine.libraries.usb.proxy) then
    
		-- no longer respond to proxy message

		engine.libraries.usb.proxy._DispatchMessage:Remove(self, UTActivity.State.EndMatch.OnDispatchMessage)	
	
	end

end

-- message received on proxy --------------------------------------------------------------------

function UTActivity.State.EndMatch:OnDispatchMessage(device, addressee, command, arg)

	-- acknowledge answers 

	if (0x94 == command) then
		if (device and not device.acknowledge) then device.acknowledge = true
		end
	end

end

-- Update --------------------------------------------------------------------

function UTActivity.State.EndMatch:Update()

	local elapsedTime = quartz.system.time.gettimemicroseconds() - self.timer
	if (not self.isReady and (elapsedTime > 250000)) then

		-- gameover msg

		self.timer = quartz.system.time.gettimemicroseconds()
		self.isReady = true
		for _, player in ipairs(activity.match.players) do

			if (player.rfGunDevice and not player.rfGunDevice.acknowledge and not player.rfGunDevice.timedout) then

				-- need to check winners/looser

				local color = 0x02
				if (0 < #activity.teams) then
					if (player.team.data.heap.score == activity.match.challengers[1].data.heap.score) then color = 0x01
					end					
				else
					if (player.data.heap.score == activity.match.challengers[1].data.heap.score) then color = 0x01
					end
				end

				local msg = { 0x06, player.rfGunDevice.radioProtocolId, 0x94, 0x01, color, unpack(activity.gameoverSnd) }
				quartz.system.usb.sendmessage(engine.libraries.usb.proxy.handle, msg)
				self.isReady = false

			end

		end

	end

end