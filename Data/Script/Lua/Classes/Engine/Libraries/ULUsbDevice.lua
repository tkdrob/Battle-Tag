
--[[--------------------------------------------------------------------------
--
-- File:            ULUsbDevice.lua
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

require "UTReference"

--[[ Class -----------------------------------------------------------------]]

ULUsbDevice = UTClass(UTStateMachine)

-- defaults

-- state dependencies

ULUsbDevice.State = {}

    require "Engine/Libraries/ULUsbDevice.State.Boot"
    require "Engine/Libraries/ULUsbDevice.State.Profile"
    require "Engine/Libraries/ULUsbDevice.State.Revision"
    require "Engine/Libraries/ULUsbDevice.State.Upload"

-- __ctor --------------------------------------------------------------------

function ULUsbDevice:__ctor(handle, ...)

    -- backup proxy device handle

    print("ULUsbDevice:__ctor", handle)

    assert(handle)
    assert(type(handle) == "userdata")

    self.handle = handle

    -- identifications,

    -- genuine radio protocol id,
    -- unique per given proxy device handle
    self.radioProtocolId = nil

    -- class identification ranges from 1 to n,
    -- where n is the last maximum number of devices of the same class (ie. reference type & category),
    -- meaning there can multiple devices with the same class id, providing they all are of different categories
    self.classId = nil

    -- reference & revision

    self.referenced = false
    self.reference = nil
    self.revision = nil

    -- states

    self.states = {}

    self.states["boot"] = ULUsbDevice.State.Boot:New(self)
    self.states["revision"] = ULUsbDevice.State.Revision:New(self)
    self.states["profile"] = ULUsbDevice.State.Profile:New(self)
    self.states["upload"] = ULUsbDevice.State.Upload:New(self)

    -- events

    self._ProcessMessage = UTEvent:New()
    self._PlayerProfileUpdated = UTEvent:New()
    self._Referenced = UTEvent:New()

    -- message processors

    self.processors = {}

    self.processors[0x03] = ULUsbDevice.ProcessMessage0x03
    self.processors[0x04] = ULUsbDevice.ProcessMessage0x04
    self.processors[0x84] = ULUsbDevice.ProcessMessage0x84

end

-- __dtor --------------------------------------------------------------------

function ULUsbDevice:__dtor()

    print("ULUsbDevice:__dtor")

end

-- OnProcessMessage ----------------------------------------------------------

function ULUsbDevice:OnProcessMessage(addressee, command, arg)

    self._ProcessMessage:Invoke(self, addressee, command, arg)

end

-- OnReferenced --------------------------------------------------------------

function ULUsbDevice:OnReferenced()

    self._Referenced:Invoke(self, self.reference)

end

-- ProcessMessage ------------------------------------------------------------

function ULUsbDevice:ProcessMessage(addressee, command, arg)

    assert(addressee == self.radioProtocolId)

    local processor = self.processors and self.processors[command]

    if (processor) then
        processor(self, arg)
    end

    self.timeout = 0

    self:OnProcessMessage(addressee, command, arg)

end

-- ProcessMessage0x03 --------------------------------------------------------

function ULUsbDevice:ProcessMessage0x03(arg)

    self:Reference(arg)

end

-- ProcessMessage0x04 --------------------------------------------------------

function ULUsbDevice:ProcessMessage0x04(arg)

    if (not self.revision) then

        assert(4 == table.getn(arg))

        self.revisionCandidate = nil
        self.revisionNumber = quartz.system.bitwise.bitwiseor(quartz.system.bitwise.lshift(arg[1], 24), quartz.system.bitwise.lshift(arg[2], 16), quartz.system.bitwise.lshift(arg[3], 8), arg[4])
        self.revision = string.format("0x%08x", self.revisionNumber)

        print("revision = ", unpack(arg))
        print("revision = " .. self.revision)

        -- check for revision

        assert(self.reference)

        local class = quartz.system.bitwise.bitwiseand(self.reference[1], 0x0f00fff0)
        local directory = string.format("game:../system/revision/0x%08x", class)

        --[[ DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG
        if (class == 0x02000020) then
            self.revisionNumber = 0;
            self.revision = string.format("0x%08x", self.revisionNumber)
        end
        -- DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG --]]
        
        local revisions = quartz.system.filesystem.directory(directory , "*.bin")
        print(directory, "*.bin", revisions)
        if (revisions) then

            -- lookup most recent revision

            for i, path in ipairs(revisions) do

                local revision = string.lower(path)
                local offset = string.find(revision, '/', 1, true)
                while (offset) do
                    revision = string.sub(revision, offset + 1)
                    offset = string.find(revision, '/', 1, true)
                end

                offset = string.find(revision, '.bin', 1, true)
                revision = string.sub(revision, 1, offset - 1)

                -- revision candidates are checked against the game's major

                local lowerRevision = string.format("0x%04x0000", REG_MAJORREVISION)
                local upperRevision = string.format("0x%04x0000", REG_MAJORREVISION + 1)

                if (lowerRevision <= revision and revision < upperRevision) then
                    if (self.revision < revision) then

                        -- we have a revision candidate here

                        if (not self.revisionCandidate or self.revisionCandidate.revision < revision) then
                            self.revisionCandidate = { revision = revision, path = path }
                            print("we have a revision candidate here " .. self.revisionCandidate.revision)
                            print(self.revisionCandidate.path)
                        end

                    elseif REG_FORCEREVISION and (class == 0x02000020) then

                        if (not self.revisionCandidate or self.revisionCandidate.revision < revision) then
                            self.revisionCandidate = { revision = revision, path = path }
                            print("we have a *FORCED* revision candidate here " .. self.revisionCandidate.revision)
                            print(self.revisionCandidate.path)
                        end

                    end
                else
                    print("revision discarded : " .. revision)
                end
            end

            if (self.revisionCandidate) then
            
                self.revisionCandidate.checked = quartz.system.usb.loadbinary(self.revisionCandidate.path)
                if (not self.revisionCandidate.checked) then

                    print("revision check failed!")
                    self.revisionCandidate = nil

                end

            else
                print("revision is up to date")
            end

        end

    end

end

-- ProcessMessage0x84 --------------------------------------------------------

function ULUsbDevice:ProcessMessage0x84(arg)
	
    if (arg and 5 <= #arg) then

        local address = quartz.system.bitwise.bitwiseor(quartz.system.bitwise.lshift(arg[1], 24), quartz.system.bitwise.lshift(arg[2], 16), quartz.system.bitwise.lshift(arg[3], 8), arg[4])
        local size = arg[5]

        if (address == 0x00000011) then

            -- player profile

            local profile = {}
            
            local playerNameLength = arg[6]
            local playerIconLength = arg[6 + playerNameLength + 1]

            if (playerNameLength and 0 < playerNameLength and playerNameLength < 0x80) then
                profile.name = ""
                for i = 1, playerNameLength do
					if (arg[6 + i]) then profile.name = profile.name .. string.char(arg[6 + i])
					end
                end
            end

            if (playerIconLength and 0 < playerIconLength and playerIconLength < 0x80) then
                profile.icon = ""
                for i = 1, playerIconLength do
					if (arg[6 + playerNameLength + i + 1]) then profile.icon = profile.icon .. string.char(arg[6 + playerNameLength + i + 1])
					end
                end
				if (profile.icon:sub(2, 2) == "_") then
					profile.team = tonumber(profile.icon:sub(1, 1))
					profile.icon = profile.icon:sub(3, string.len(profile.icon)) .. ".tga"
				else
					profile.icon = profile.icon .. ".tga"
				end
            end

            if (profile.name and profile.icon) then
                self.playerProfile = profile
            end

			print("profile", profile.name, profile.icon)
            self._PlayerProfileUpdated:Invoke(self, self.playerProfile)

        else
        end

    end

end

-- Reference -----------------------------------------------------------------

function ULUsbDevice:Reference(arg)

    assert(8 == table.getn(arg))

    if (not self.referenced) then

        self.referenced = true
        self.reference = UTReference:New(arg)

        print("reference = " .. string.format("0x%08x", self.reference[1]) .. ", ".. string.format("0x%08x", self.reference[2]) .. " (big endian)")
        self:OnReferenced()

    end

end

