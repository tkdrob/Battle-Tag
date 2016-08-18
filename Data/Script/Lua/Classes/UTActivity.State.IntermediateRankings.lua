
--[[--------------------------------------------------------------------------
--
-- File:            UTActivity.State.IntermediateRankings.lua
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

require "UTActivity.Ui.IntermediateRankings"

--[[ Class -----------------------------------------------------------------]]

UTActivity.State.IntermediateRankings = UTClass(UTState)

-- __ctor --------------------------------------------------------------------

function UTActivity.State.IntermediateRankings:__ctor(activity, ...)

    assert(activity)

end

-- Begin ---------------------------------------------------------------------

function UTActivity.State.IntermediateRankings:Begin()

	-- pop gameover 

	UIManager.stack:Pop()	

	-- can leave ...

    self.timer = quartz.system.time.gettimemicroseconds()
	for _, player in ipairs(activity.players) do
		if (player.rfGunDevice) then player.rfGunDevice.acknowledge = false
		end
	end
	self.isReady = false

	-- respond to proxy message

	engine.libraries.usb.proxy._DispatchMessage:Add(self, UTActivity.State.FinalRankings.OnDispatchMessage)	
	
end

-- End -----------------------------------------------------------------------

function UTActivity.State.IntermediateRankings:End()

	UIMenuManager.stack:Pop() 

	-- no longer respond to proxy message

	engine.libraries.usb.proxy._DispatchMessage:Remove(self, UTActivity.State.FinalRankings.OnDispatchMessage)	

end

-- OnDispatchMessage ---------------------------------------------------------

function UTActivity.State.IntermediateRankings:OnDispatchMessage(device, addressee, command, arg)

	-- acknowledge answers 

	if (0x94 == command) then
		if (device and not device.acknowledge) then device.acknowledge = true
		end
	end

end

-- Update --------------------------------------------------------------------

function UTActivity.State.IntermediateRankings:Update()

	local elapsedTime = quartz.system.time.gettimemicroseconds() - (self.time or quartz.system.time.gettimemicroseconds())
	self.time = quartz.system.time.gettimemicroseconds()
	
	self.msgTimer = (self.msgTimer or 0) + elapsedTime
	if (not self.isReady and self.msgTimer > 250000) then

		-- gameover msg

		self.msgTimer = 0
		self.isReady = true
		for _, player in ipairs(activity.match.players) do

			if (player.rfGunDevice and not player.rfGunDevice.acknowledge) then

				local msg = { 0x06, player.rfGunDevice.radioProtocolId, 0x94, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 }
				quartz.system.usb.sendmessage(engine.libraries.usb.proxy.handle, msg)
				self.isReady = false

			end

		end

	end

end
