
--[[--------------------------------------------------------------------------
--
-- File:            UTPlayer.lua
--                  Copyright (c) Ubisoft Entertainment. All rights reserved.
--
-- Project:         Ubitoys.Tag
-- Date:            August 2, 2010
--
------------------------------------------------------------------------------
--
-- Description:     Generic player.
--                  May be part of a team (UTTeam) of players.
--
----------------------------------------------------------------------------]]

--[[ Dependencies ----------------------------------------------------------]]

require "UTEntity"

--[[ Class -----------------------------------------------------------------]]

UTClass.UTPlayer(UTEntity)

-- default

UTPlayer.profiles = nil
UTPlayer.maxProfile = 32

-- __ctor --------------------------------------------------------------------

function UTPlayer:__ctor(...)

    UTPlayer.profiles = UTPlayer.profiles or
	{    
		default = { icon = "bear.tga", name = "utplayer", team = 0, public = false },
		guest = { icon = "puma.tga", name = l"oth006", team = 0, public = false },
	}
    -- profile

    self.profile = {}
    self.profile.icon = UTPlayer.profiles.guest.icon
    self.profile.name = UTPlayer.profiles.guest.name
	self.profile.team = UTPlayer.profiles.guest.team
    self.profile.public = false

    -- the player inherits its data from the base entity (cf. "UTEntity"),
    -- some more data remain specific to the player

    self.data.bytecode = {}

    -- bindings

    self.team = nil -- a player may be a member of a team, or not ...
    self.rfGunDevice = nil -- a player may own a gun device, or not ...


	-- updating

	self._ProfileUpdated = UTEvent:New()

end

-- __dtor --------------------------------------------------------------------

function UTPlayer:__dtor()
end

-- BindDevice ----------------------------------------------------------------

function UTPlayer:BindDevice(device)

    if (self.rfGunDevice) then 
		self.rfGunDevice.owner = nil
    end

	self.rfGunDevice = device

	if (device) then

	    if (device.owner) then
            if (device.owner.__instance and device.owner:IsKindOf(UTPlayer)) then
                device.owner:BindDevice()
            end
	    end

	    device.owner = self

	end

end

-- OnProfileUpdated ----------------------------------------------------------

function UTPlayer:OnProfileUpdated(device, profile)

	-- update player profile 

	if (profile) then

		self.profile.name = profile.name
		self.profile.icon = profile.icon
		self.profile.team = profile.team

	else

		self.profile.name = UTPlayer.profiles.guest.name
		self.profile.icon = UTPlayer.profiles.guest.icon
		self.profile.team = UTPlayer.profiles.guest.team

	end

	-- and remove event

	self.rfGunDevice._PlayerProfileUpdated:Remove(self, UTPlayer.OnProfileUpdated)

	-- remove fx 

	if (self.myFx) then UIManager:RemoveFx(self.myFx)
	end

	-- event

	self._ProfileUpdated:Invoke(self)

end

-- UnBindDevice --------------------------------------------------------------

function UTPlayer:UnBindDevice(device)

    if (device and self.rfGunDevice == device) then
        self:BindDevice()
    end

end

-- UpdateProfile -------------------------------------------------------------

function UTPlayer:UpdateProfile()

	self.profile.icon = nil
	self.myFx = UIManager:AddFx("value", { duration = 0.6, __self = self.profile, value = "name", from = l"oth044", to = "", type = "blink"})
	self.rfGunDevice._PlayerProfileUpdated:Add(self, UTPlayer.OnProfileUpdated)

end
