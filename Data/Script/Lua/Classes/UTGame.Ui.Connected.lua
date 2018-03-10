
--[[--------------------------------------------------------------------------
--
-- File:            UTGame.Ui.Connected.lua
--                  Copyright (c) Ubisoft Entertainment. All rights reserved.
--
-- Project:         Ubitoys.Tag
-- Date:            September 2, 2010
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
require "UI/UIPopupWindow"

--[[ Class -----------------------------------------------------------------]]

UTGame.Ui = UTGame.Ui or {}
UTGame.Ui.Connected = UTClass(UIMenuWindow)

-- defaults

UTGame.Ui.Connected.fontColor = UIComponent.colors.darkgray

-- __ctor --------------------------------------------------------------------

function UTGame.Ui.Connected:__ctor(...)

	-- window settings

	self.uiWindow.title = l "con001"
	self.uiWindow.icon = "base:video/uianimatedbutton_settings.avi"

	self.text = l "con005"
	--[[ clement 
	if (REG_FIRSTTIME) then
	    self.text = self.text .. "\n\n" .. l "con003"
	end
	]]--

    -- contents,

    self.uiPanel = self.uiWindow:AddComponent(UIPanel:New(), "uiPanel")
    self.uiPanel.rectangle = self.clientRectangle

    self.uiContents = self.uiPanel:AddComponent(UITitledPanel:New(), "uiContents")
    self.uiContents.rectangle = { 20, 20, 695, 435 }
    -- self.uiContents.title = "Plug in your UbiConnect™"
    self.uiContents.title = l "con002"

    self.uiContents.clientRectangle = {}

    for i = 1, 4 do 
        self.uiContents.clientRectangle[i] = self.uiWindow.rectangle[i] + self.clientRectangle[i] + self.uiContents.rectangle[i]
    end

    -- buttons,

    if (REG_FIRSTTIME) then

	    -- uiButton4: next

        self.uiButton4 = self:AddComponent(UIButton:New(), "uiButton4")
        self.uiButton4.rectangle = UIMenuWindow.buttonRectangles[4]
	    self.uiButton4.text = l"but006"
	    self.uiButton4.tip = l"tip005"

        self.uiButton4.enabled = true

        -- !! IF THE APPLICATION WAS LAUNCHED FOR THE FIRST TIME,
        -- !! THEN WE SHALL LAUNCH SOME INTRODUCTION SEQUENCE

	    --self.uiButton4.OnAction = function (self) game:PostStateChange("title") end

        local nfo = {

            __directory = "Introduction",
            class = "UAIntroduction",

        }

	    self.uiButton4.OnAction = function (self) game:PostStateChange("session", nfo) end

    else

        self.timer = 250000
        self.counter = 6

    end

end

-- __dtor --------------------------------------------------------------------

function UTGame.Ui.Connected:__dtor()
end

-- CheckForRevisionCandidate -------------------------------------------------

function UTGame.Ui.Connected:CheckForRevisionCandidate()

    assert(engine.libraries.usb.proxy)
    assert(engine.libraries.usb.proxy.revision)

    print("candidate:", engine.libraries.usb.proxy.revisionCandidate)

    if (engine.libraries.usb.proxy.revisionCandidate) then

        -- if revision candidate is major then ask for user confirmation,
        -- else proceed with revision update

        local confirmation = false

        if (confirmation) then
        end

        -- switch de proxy device into bootloading mode ...

        engine.libraries.usb.proxy:PostStateChange("bootloader")

        -- ... then warn the user the device must be unplugged

        local uiPopup = UIPopupWindow:New()
        uiPopup.icon = "base:video/uianimatedbutton_settings.avi"

        uiPopup.title = l "con006"
        uiPopup.text = l "con007"

        UIManager.stack:Push(uiPopup)
        game.gameMaster:Play("base:audio/gamemaster/dlg_gm_init_03.wav")

    elseif (self.uiButton4) then

        self.uiButton4.enabled = false
        game.gameMaster:Play("base:audio/gamemaster/dlg_gm_init_04.wav", function () self.uiButton4.enabled = true end)

    end

end

-- Draw ----------------------------------------------------------------------

function UTGame.Ui.Connected:Draw()

    -- base

    UIPage.Draw(self)

    -- contents,

    quartz.system.drawing.pushcontext()
    quartz.system.drawing.loadtranslation(unpack(self.uiContents.clientRectangle))
    quartz.system.drawing.loadtranslation(0, UITitledPanel.headerSize)

    -- bitmap

    quartz.system.drawing.loadcolor3f(unpack(UIComponent.colors.white))
    quartz.system.drawing.loadtexture("base:texture/ui/connection_pluggedin.tga")
    quartz.system.drawing.drawtexture(0, 0)

    -- text

    local fontJustification = quartz.system.drawing.justification.bottomleft + quartz.system.drawing.justification.wordbreak
    local rectangle = { 40, 50, 675 - 40, 390 - 20 }

    quartz.system.drawing.loadcolor3f(unpack(self.fontColor))
    quartz.system.drawing.loadfont(UIComponent.fonts.default)
    quartz.system.drawing.drawtextjustified(self.text, fontJustification, unpack(rectangle) )

    --quartz.system.drawing.loadcolor3f(unpack(UIComponent.colors.black))
    --quartz.system.drawing.drawtexture(unpack(rectangle))

    quartz.system.drawing.pop()

end

-- OnOpen --------------------------------------------------------------------

function UTGame.Ui.Connected:OnOpen()

    -- if the proxy device is waiting for a revision update,
    -- push a notification and confirmation window

    if (engine.libraries.usb.proxy.revisionUpdate) then

        assert(not engine.libraries.usb.proxy.initialized)
        assert(0 == engine.libraries.usb.proxy.revisionUpdate)

        if (self.uiButton4) then self.uiButton4.enabled = false end

        local uiPopup = UIPopupWindow:New()
        uiPopup.icon = "base:video/uianimatedbutton_settings.avi"

        uiPopup.title = l "con006"
        uiPopup.text = l "con009"

        -- buttons

        uiPopup.uiButton2 = uiPopup:AddComponent(UIButton:New(), "uiButton2")
        uiPopup.uiButton2.rectangle = UIPopupWindow.buttonRectangles[2]
        uiPopup.uiButton2.text = l "but019"

        uiPopup.uiButton2.OnAction = function ()
            game:PostStateChange("revision")
        end

        UIManager.stack:Push(uiPopup)
        --game.gameMaster:Play("base:audio/gamemaster/dlg_gm_init_03.wav")

    elseif (not engine.libraries.usb.proxy.revision) then

    -- if we did not retrieve the proxy's firmware revision yet,
    -- push a notification window

        local uiPopup = UIPopupWindow:New()
        uiPopup.icon = "base:video/uianimatedbutton_settings.avi"

        uiPopup.title = l "con006"
        uiPopup.text = l "con008"

        uiPopup.Update = function ()

            -- wait for the revision ...

            if (engine.libraries.usb.proxy and engine.libraries.usb.proxy.revision) then

                UIManager.stack:Pop()
                self:CheckForRevisionCandidate()

            end
        end

        UIManager.stack:Push(uiPopup)

    else

        self:CheckForRevisionCandidate()

    end

end

-- Update --------------------------------------------------------------------

function UTGame.Ui.Connected:Update()

    if (self.timer) then

        local time = quartz.system.time.gettimemicroseconds()
        local elapsedTime = time - (self.time or quartz.system.time.gettimemicroseconds())

        self.timer = self.timer - elapsedTime
        self.time = time  
        
        if (0 >= self.timer) then

			if (0 == self.counter) then

				-- go to title screen

				assert(game)

				local resources = {

					["video"] = { "base:video/background.avi", "base:video/credits.avi", "base:video/uianimatedbutton_settings.avi", "base:video/uianimatedbutton_profile.avi", "base:video/uianimatedbutton_games.avi", "base:video/uianimatedbutton_playnow.avi", "base:video/uianimatedbutton_basics.avi", "base:video/uianimatedbutton_quit.avi" },
					["texture"] = { "base:texture/ui/Countdown_Top.tga", "base:texture/ui/Countdown_Bottom.tga", "base:texture/ui/GameOver_Top.tga", "base:texture/ui/GameOver_Bottom.tga", "base:texture/ui/Playground_Background.tga", "base:texture/ui/Ranking_Bg_Introduction.tga", "base:texture/ui/Ranking_Bg_Top.tga", "base:texture/ui/Ranking_Bg_Bottom.tga", "base:texture/ui/components/UIWindow_Popup.tga", "base:texture/ui/components/UIWindow_Popup2.tga", "base:texture/ui/components/UIWindow_Message.tga", "base:texture/ui/components/UIWindow_Popup_Large.tga", "base:texture/ui/components/uiwindow_main.tga", "base:texture/ui/components/uibutton_mainmenu.tga", "base:texture/ui/components/uibutton_mainmenu_focused.tga", "base:texture/ui/Background01.tga", "base:texture/ui/mainmenu_background.tga", "base:texture/ui/mainmenu_line.tga", "base:texture/ui/mainmenu_linelight.tga", "base:texture/ui/mainmenu_spotlignt.tga" },
					["font"] = { "base:larger.fontdef", "base:large.fontdef", "base:extralarge.fontdef"}
				
				}

				game:PostStateChange("loading", "title", resources)

			else

				-- send a ping message to check fake gun and REBOOT

				if (math.mod(self.counter, 2) == 0) then
					quartz.system.usb.sendmessage(engine.libraries.usb.proxy.handle, {0x01, 0xff, 0x86, 0x00})
				else
					quartz.system.usb.sendmessage(engine.libraries.usb.proxy.handle, {0x00, 0xff, 0x06})
				end

				self.timer = 500000
				self.counter = self.counter - 1

			end

        end
    end
    
end
