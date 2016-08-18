
--[[--------------------------------------------------------------------------
--
-- File:            UTActivity.Ui.RevisionCheck.lua
--                  Copyright (c) Ubisoft Entertainment. All rights reserved.
--
-- Project:         Ubitoys.Tag
-- Date:            October 13, 2010
--
------------------------------------------------------------------------------
--
-- Description:     ...
--
----------------------------------------------------------------------------]]

--[[ Dependencies ----------------------------------------------------------]]

require "UI/UIPage"
require "UI/UIMenuPage"
require "UI/UIMenuWindow"

    require "UI/UITitledPanel"
    require "UI/UIProgress"

--[[ Class -----------------------------------------------------------------]]

assert(rawget(UTActivity, "Ui"))
UTActivity.Ui.RevisionCheck = UTClass(UIMenuPage)

-- defaults,
-- this is just a fake window displayed on to of the true revision ui

UTActivity.Ui.RevisionCheck.transparent = true

-- banks

UTActivity.Ui.RevisionCheck.banks = {

    ["DSN1"] = 0x05000,
    ["DSN2"] = 0x15000,
    ["DSN3"] = 0x25000,
    ["DSN4"] = 0x35000,
    ["DSN5"] = 0x45000,

    ["DANI"] = 0x02000,

}

-- __ctor --------------------------------------------------------------------

function UTActivity.Ui.RevisionCheck:__ctor(state)

	-- animate	
	
	self.slideBegin = true
	self.slideEnd = false
	
	self.text = ""
    self.clientRectangle = { 13 + UIMenuWindow.margin.left, 87 + UIMenuWindow.margin.top, 768 - UIMenuWindow.margin.right, 608 - 12 - UIMenuWindow.margin.bottom - 34 }

    self.clientRectangle[1] = self.clientRectangle[1] + UIWindow.rectangle[1]
    self.clientRectangle[2] = self.clientRectangle[2] + UIWindow.rectangle[2]
    self.clientRectangle[3] = self.clientRectangle[3] + UIWindow.rectangle[1]
    self.clientRectangle[4] = self.clientRectangle[4] + UIWindow.rectangle[2]

    -- contents,

    self.uiPanel = self:AddComponent(UIPanel:New(), "uiPanel")
    self.uiPanel.rectangle = self.clientRectangle

    self.uiContents = self.uiPanel:AddComponent(UITitledPanel:New(), "uiContents")
    self.uiContents.rectangle = { 20, 20, 695, 435 }
    self.uiContents.title = l"oth044" .. " ..."

    self.uiContents.clientRectangle = {}

    for i = 1, 4 do 
        self.uiContents.clientRectangle[i] = self.rectangle[i] + self.clientRectangle[i] + self.uiContents.rectangle[i]
    end

--[[
    -- progress

    self.uiProgress = self.uiContents:AddComponent(UIProgress:New(), "uiProgress")
    self.uiProgress.rectangle = { 20, 20 + 25, 655, 48 + 25 }

    self.uiGlobalProgress = self.uiContents:AddComponent(UIProgress:New(), "uiProgress")
    self.uiGlobalProgress.rectangle = { 20, 20 + 25 + 60, 655, 48 + 25 + 60 }
    self.uiGlobalProgress.color = UIComponent.colors.red
--]]

    -- state

    assert(state)
    assert(state.majorRevisionDevices)

    self.state = state

end

-- LookupForRevision ---------------------------------------------------------

function UTActivity.Ui.RevisionCheck:LookupForRevision(revision)

    -- lookup most recent revision for the given bank

    assert(self.target)
    assert(self.targetBank)

    local class = quartz.system.bitwise.bitwiseand(self.target.reference[1], 0x0f00fff0)
    local directory = string.format("game:../system/revision/0x%08x/banks/%s", class, string.lower(self.targetBank))
    local wildcard = self.targetBank .. "-" .. (game.locale.locale or "en") .. "??.bin"

    -- print("LookupForRevision", directory, wildcard)

    local revisions = quartz.system.filesystem.directory(directory , wildcard)
    if (revisions) then

        -- one or many bank files have been found,
        -- compare current revision with the most recent file
        
        table.sort(revisions)

        local lastRevision = string.lower(string.format("game:../system/revision/0x%08x/banks/%s/%s-%s", class, self.targetBank, self.targetBank, revision))
        local bestRevision = string.lower(revisions[#revisions])

        -- shorten paths because aliases may have been discarded along the way

        local f, l = string.find(bestRevision, "banks")
        local shortBestRevision = string.sub(bestRevision, l + 2)
        local shortLastRevision = string.lower(string.format("%s/%s-%s.bin", self.targetBank, self.targetBank, revision))

        print("^^" .. shortLastRevision .. " # ^^" .. shortBestRevision)

        if not (shortBestRevision == shortLastRevision) or (REG_FORCEREVISION) then

            -- push the upload request,
            -- the flash memory manager shall handle all binary uploads

            local address = UTActivity.Ui.RevisionCheck.banks[self.targetBank]
            if (address) then

                assert(self.flashMemoryManager)
                self.flashMemoryManager:Upload(self.target, bestRevision, address)

                print("pushing new request", bestRevision, address)

            end

        end
    end

end

-- Draw ----------------------------------------------------------------------

function UTActivity.Ui.RevisionCheck:Draw()

    -- base

    UIMenuPage.Draw(self)

    -- contents,

    quartz.system.drawing.pushcontext()
    quartz.system.drawing.loadtranslation(unpack(self.uiContents.clientRectangle))
    quartz.system.drawing.loadtranslation(0, UITitledPanel.headerSize)

    -- text

    local fontJustification = quartz.system.drawing.justification.bottomleft + quartz.system.drawing.justification.wordbreak
    local rectangle = { 40, 320, 675 - 40, 390 - 20 }

    quartz.system.drawing.loadcolor3f(unpack(self.fontColor))
        quartz.system.drawing.loadcolor3f(unpack(UIComponent.colors.red))
    quartz.system.drawing.loadfont(UIComponent.fonts.default)
    quartz.system.drawing.drawtextjustified(self.text, fontJustification, unpack(rectangle) )

    quartz.system.drawing.pop()

end

-- OnClose -------------------------------------------------------------------

function UTActivity.Ui.RevisionCheck:OnClose()

    if (engine.libraries.usb.proxy) then

        engine.libraries.usb.proxy._DispatchMessage:Remove(self, UTActivity.Ui.RevisionCheck.OnDispatchMessage)

    end

end

-- OnDispatchMessage ---------------------------------------------------------

function UTActivity.Ui.RevisionCheck:OnDispatchMessage(device, addressee, command, arg)

    if (device == self.target and command == 0x85) then

        print("data bank revision received:", self.targetBank, unpack(arg))

        local revision = string.format("%c%c%c%c", arg[1], arg[2], arg[3], arg[4])
        
        if (self.targetBank) then
			self:LookupForRevision(revision)
        end

        self.targetBank = nil
        self.message = nil

    end

end

-- OnOpen --------------------------------------------------------------------

function UTActivity.Ui.RevisionCheck:OnOpen()

    assert(engine.libraries.usb)
    assert(engine.libraries.usb.proxy)
    assert(engine.libraries.usb.proxy.handle)

    engine.libraries.usb.proxy._DispatchMessage:Add(self, UTActivity.Ui.RevisionCheck.OnDispatchMessage)

    self.flashMemoryManager = engine.libraries.usb.proxy.processes.deviceFlashMemoryManager
    assert(self.flashMemoryManager)

    --

    assert(self.state)
    assert(self.state.majorRevisionDevices)

    self.targets = {}
    for _, device in pairs(self.state.majorRevisionDevices) do table.insert(self.targets, device)
    end

end

-- Update --------------------------------------------------------------------

function UTActivity.Ui.RevisionCheck:Update()

    if (not self.target) then

        -- pickup the next device,
        -- for which we shall check all data revisions

        self.target = table.remove(self.targets)
        if (not self.target) then

            -- if all the devices have been checked,
            -- then pop the current ui and garbage collect the table ...

            UIMenuManager.stack:Pop()
            self.state.majorRevisionDevices = nil

            -- ... and launch the flash updates at last

            self.flashMemoryManager:Restart()

            return

        end

print("2222222222")

        -- configure the new target,
        -- save all the data banks that must be checked

        self.targetBanks, self.targetBank = {}, nil
        for bankName, bankAddress in pairs(UTActivity.Ui.RevisionCheck.banks) do table.insert(self.targetBanks, bankName) end

    else

        -- pickup some bank identification from the list of all the data banks to be checked

        if (not self.targetBank) then

            self.targetBank = table.remove(self.targetBanks)
            if (not self.targetBank) then

                -- when all banks have been checked,
                -- then we garbage collect the target to move on to the next one

                self.target = nil

                -- send a ping message just for the sake of it ? ...

                quartz.system.usb.sendmessage(engine.libraries.usb.proxy.handle, { 0x00, 0xff, 0x05 })
                print("ping **")

                return

            end

			if (self.target.revision and self.target.revisionNumber) then

				local majorRevision = quartz.system.bitwise.rshift(self.target.revisionNumber, 16)
				if (0 == majorRevision) then

					print("data bank revision was force-checked for device " .. tostring(self.target.reference))

					self:LookupForRevision(0)
					self.targetBank = nil
					
					return

				end

			end

            -- format the message that is to be sent,
            -- and reset the timer

            self.message = { 0x04, self.target.radioProtocolId, 0x85 }
            for byte = 1, 4 do table.insert(self.message, string.byte(self.targetBank, byte)) end

            self.timeInterval = 250000
            self.time = quartz.system.time.gettimemicroseconds() - self.timeInterval

        end

        if (self.message) then

            -- send the request message,
            -- every while ...

            local time = quartz.system.time.gettimemicroseconds()
            if (self.timeInterval <= time - self.time) then
            
                self.time = time
                quartz.system.usb.sendmessage(engine.libraries.usb.proxy.handle, self.message)
            
            end
        end

    end

end
