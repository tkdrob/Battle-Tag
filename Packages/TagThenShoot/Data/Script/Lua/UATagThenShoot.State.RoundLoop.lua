
--[[--------------------------------------------------------------------------
--
-- File:            UATagThenShoot.State.RoundLoop.lua
--                  Copyright (c) Ubisoft Entertainment. All rights reserved.
--
-- Project:         Ubitoys.Tag
-- Date:            September 23, 2010
--
------------------------------------------------------------------------------
--
-- Description:     ...
--
----------------------------------------------------------------------------]]

--[[ Dependencies ----------------------------------------------------------]]

require "UTActivity.State.RoundLoop"
require "UATagThenShoot.Ui.RoundLoop"

--[[ Class -----------------------------------------------------------------]]

UATagThenShoot.State.RoundLoop = UTClass(UTActivity.State.RoundLoop)

-- defaults ------------------------------------------------------------------

UATagThenShoot.State.RoundLoop.uiClass = UATagThenShoot.Ui.RoundLoop

-- __ctor --------------------------------------------------------------------

function UATagThenShoot.State.RoundLoop:__ctor(activity, ...)

    assert(activity)

end

-- Begin ---------------------------------------------------------------------

function UATagThenShoot.State.RoundLoop:Begin()

	UTActivity.State.RoundLoop.Begin(self)

	game.gameMaster:RegisterSound({ paths = {"base:audio/gamemaster/DLG_GM_GLOBAL_13.wav", 
											 "base:audio/gamemaster/DLG_GM_GLOBAL_14.wav", 
											 "base:audio/gamemaster/DLG_GM_GLOBAL_15.wav"}, probas = {0.8, 0.1, 0.1}})
						 
	game.gameMaster:RegisterSound({ paths = {"base:audio/gamemaster/DLG_GM_GLOBAL_46.wav"},
									offset = activity.settings.playtime * 60 - 30,})
						 
	game.gameMaster:RegisterSound({ paths = {"base:audio/gamemaster/DLG_GM_GLOBAL_48.wav",
											 "base:audio/gamemaster/DLG_GM_GLOBAL_49.wav"},
									offset = activity.settings.playtime * 60 - 27, priority = 3, proba = 0.333})
						 
	game.gameMaster:RegisterSound({ paths = {"base:audio/gamemaster/DLG_GM_GLOBAL_47.wav"},
									offset = activity.settings.playtime * 60 - 15,})
						 
	game.gameMaster:RegisterSound({ paths = {"base:audio/gamemaster/DLG_GM_GLOBAL_48.wav",
											 "base:audio/gamemaster/DLG_GM_GLOBAL_49.wav"},
									offset = activity.settings.playtime * 60 - 12, priority = 3, proba = 0.333})									
    -- timer

    self.time = quartz.system.time.gettimemicroseconds()
    activity.timer = activity.settings.playtime * 60 * 1000000
    
    -- current player

	self.player = activity.match.challengers[1]
	self.currentBase = 0

	-- msg timer

	self.msgTimer = quartz.system.time.gettimemicroseconds()

	-- data

	activity.gameplayData =  {quartz.system.bitwise.bitwiseand(self.player.data.heap.nbHit, 0xff00) / 256, quartz.system.bitwise.bitwiseand(self.player.data.heap.nbHit, 0x00ff)}

end

-- OnDeviceRemoved  ----------------------------------------------------------

function UATagThenShoot.State.RoundLoop:OnDeviceRemoved(device)

	if (self.canBeStopped and self.player.rfGunDevice == device) then

		self.uiPopup = UIPopupWindow:New()

		self.uiPopup.title = l"oth041"
		self.uiPopup.text = l"oth043"

		-- buttons

		self.uiPopup.uiButton2 = self.uiPopup:AddComponent(UIButton:New(), "uiButton2")
		self.uiPopup.uiButton2.rectangle = UIPopupWindow.buttonRectangles[2]
		self.uiPopup.uiButton2.text = l "but019"

		self.uiPopup.uiButton2.OnAction = function ()

			UIManager.stack:Pop()
			activity:PostStateChange("endmatch")

		end

		UIManager.stack:Push(self.uiPopup)	
		self.canBeStopped = false

	end

end

-- Message received from device  ----------------------------------------------

function UATagThenShoot.State.RoundLoop:OnDispatchMessage(device, addressee, command, arg)

	-- base

	UTActivity.State.RoundLoop.OnDispatchMessage(self)

	-- decode this msg !!

	if (0x95 == command) then

		-- get state : 0-3 for base 1-4

		if (device.owner == self.player) then

			local stage = (arg[2] * 256) + arg[3]
			local tagging = (arg[4] * 256) + arg[5]

			if (tagging ~= self.player.data.heap.tagging) then

				if (tagging == 1) then

					-- tagging now

					activity.uiAFP:PushLine(self.player.profile.name .. " " .. l"ingame008", UIComponent.colors.gray, "base:texture/Ui/Icons/16x/Ammunition.tga")
					game.gameMaster:RegisterSound({ paths = {"base:audio/gamemaster/DLG_GM_GLOBAL_88.wav", "base:audio/gamemaster/DLG_GM_GLOBAL_89.wav", "base:audio/gamemaster/DLG_GM_GLOBAL_90.wav"}, priority = 1,})
					self.player.data.heap.score = self.player.data.heap.score + 1
					self.player.data.heap.state = stage

				else

					-- shooting	now

					if (stage == 0) then
						activity.uiAFP:PushLine(self.player.profile.name .. " " .. l"ingame002", UIComponent.colors.gray, "base:texture/Ui/Icons/16x/respawn.tga")
					elseif (stage == 1) then
						activity.uiAFP:PushLine(self.player.profile.name .. " " .. l"ingame003", UIComponent.colors.gray, "base:texture/Ui/Icons/16x/respawn.tga")
					elseif (stage == 2) then
						activity.uiAFP:PushLine(self.player.profile.name .. " " .. l"ingame004", UIComponent.colors.gray, "base:texture/Ui/Icons/16x/respawn.tga")
					elseif (stage == 3) then
						activity.uiAFP:PushLine(self.player.profile.name .. " " .. l"ingame005", UIComponent.colors.gray, "base:texture/Ui/Icons/16x/respawn.tga")
					end
					game.gameMaster:RegisterSound({ paths = {"base:audio/gamemaster/DLG_GM_GLOBAL_" .. (72 + stage) .. ".wav"},priority = 1,})
					game.gameMaster:RegisterSound({ paths = {"base:audio/gamemaster/DLG_GM_GLOBAL_78.wav","base:audio/gamemaster/DLG_GM_GLOBAL_79.wav","base:audio/gamemaster/DLG_GM_GLOBAL_80.wav","base:audio/gamemaster/DLG_GM_GLOBAL_81.wav"}, offset = 0.5, priority = 1,})
					self.player.data.heap.score = self.player.data.heap.score + 1
					self.player.data.heap.state = nil

				end
				self.player.data.heap.tagging = tagging

			end

		end
	
	elseif (0xc3 == command) then

        -- ubiconnect hit

        if (engine.libraries.usb.proxy.radioProtocolId == addressee) then

            local device = engine.libraries.usb.proxy.devices.byRadioProtocolId[arg[2]]
            if (not (self.player.data.heap.state) and device) then

                local player = device.owner
                if (player == self.player) then

					--self.player.data.heap.state = self.currentBase
                    self.player.data.heap.nbHit = self.player.data.heap.nbHit + 1
                    activity.gameplayData =  {quartz.system.bitwise.bitwiseand(self.player.data.heap.nbHit, 0xff00) / 256, quartz.system.bitwise.bitwiseand(self.player.data.heap.nbHit, 0x00ff)}
                    --activity.gameplayData = { 0x00, self.player.data.heap.nbHit }

                end

            end

        end

	end	

end

-- Update ---------------------------------------------------------------------

function UATagThenShoot.State.RoundLoop:Update()

	UTActivity.State.RoundLoop.Update(self)

	-- end match

	if (activity.timer <= 0) then
		activity:PostStateChange("endround")
	end
	
end
