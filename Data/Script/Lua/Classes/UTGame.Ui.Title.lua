
--[[--------------------------------------------------------------------------
--
-- File:            UTGame.Ui.Title.lua
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

require "Ui/UIPage"
require "Ui/UIAnimatedButton"

--[[ Class -----------------------------------------------------------------]]

UTGame.Ui = UTGame.Ui or {}
UTGame.Ui.Title = UTClass(UIPage)

-- defaults

UTGame.Ui.Title.rectangle = { 0, 0, 960, 720 }
UTGame.Ui.Title.foreground = "base:texture/ui/mainmenu_line.tga"
UTGame.Ui.Title.foregroundRectangle = { -160, 354, 1280 - 160, 354 + 330 }
UTGame.Ui.Title.foregroundInit = { - 160, 720 }

UTGame.Ui.Title.blinkPlayTexture = "base:texture/ui/mainmenu_linelight.tga"
UTGame.Ui.Title.spotLightTexture = "base:texture/ui/mainmenu_spotlignt.tga"

-- background video

UTGame.Ui.Title.backvideo = "base:video/background.avi"
UTGame.Ui.Title.backvideoTexture = "base:texture/ui/mainmenu_background.tga"

UIWindow.iconTexture = "base:texture/ui/mainmenu_settings.tga"

-- animated buttons

UTGame.Ui.Title.buttonsSize = { 68, 68 }
UTGame.Ui.Title.videosSize = { 50, 50 }
UTGame.Ui.Title.hasPopup = false

-- __ctor --------------------------------------------------------------------

function UTGame.Ui.Title:__ctor(...)

	self.blinkPlay = 0
	self.spotLight = 0
	self.spotLightX = 1300
	
	if (self.backvideo) then

	    local scale, translation = 1.0, { 0.0, 0.0 }

	    local viewportWidth, viewportHeight = quartz.system.drawing.getviewportdimensions()

	    local result = quartz.system.drawing.loadvideo(self.backvideo)
	    if (not result and self.backvideoTexture) then
	        result = quartz.system.drawing.loadtexture(self.backvideoTexture)
	    end

	    if (result) then

	        local textureWidth, textureHeight = quartz.system.drawing.gettexturedimensions()
        		
	        local viewportAspectRatio = viewportHeight / viewportWidth
	        local textureAspectRatio = textureHeight / textureWidth

	        if (viewportAspectRatio < textureAspectRatio) then

	            scale = viewportWidth / textureWidth
	            translation[2] = (viewportHeight - scale * textureHeight) / 2.0

	        else

	            scale = viewportHeight / textureHeight
	            translation[1] = (viewportWidth - scale * textureWidth) / 2.0

	        end

            self.backVideoRectangle = { translation[1], translation[2], translation[1] + textureWidth * scale, translation[2] + textureHeight * scale}

        end
    end
	
    self.uiMultiComponent = self:AddComponent(UIMultiComponent:New(), "uiMultiComponent")
    self.uiMultiComponent.rectangle = self.foregroundRectangle

    -- optionSystem

    self.uiButtonSettings = self.uiMultiComponent:AddComponent(UIAnimatedButton:New(self.buttonSize, "base:video/uianimatedbutton_settings.avi", self.videosSize, "base:texture/ui/mainmenu_settings.tga"), "uiButtonSettings")
    self.uiButtonSettings:MoveTo(194 - self.uiMultiComponent.rectangle[1], 515 - self.uiMultiComponent.rectangle[2])
    self.uiButtonSettings.text = l "menu03"
    self.uiButtonSettings.tip = l "tip011"

    self.uiButtonSettings.OnAction = function (self)

		quartz.framework.audio.loadsound("base:audio/ui/validation.wav")
		quartz.framework.audio.loadvolume(game.settings.audio["volume:sfx"])
		quartz.framework.audio.playsound()
		uiSettingprev = 1
		
        game:PostStateChange("settings")

    end

    -- tutorial  

    self.uiButtonProfile = self.uiMultiComponent:AddComponent(UIAnimatedButton:New(self.buttonSize, "base:video/uianimatedbutton_profile.avi", self.videosSize, "base:texture/ui/mainmenu_profiles.tga"), "uiButtonSettings")
    self.uiButtonProfile:MoveTo(320 - self.uiMultiComponent.rectangle[1], 515 - self.uiMultiComponent.rectangle[2])
    self.uiButtonProfile.text = l "menu04"
    self.uiButtonProfile.tip = l "tip008"

    self.uiButtonProfile.OnAction = function (self)

		quartz.framework.audio.loadsound("base:audio/ui/validation.wav")
		quartz.framework.audio.loadvolume(game.settings.audio["volume:sfx"])
		quartz.framework.audio.playsound()
		
		local nfo = {

            __directory = "Introduction",
            class = "UAIntroduction",

        }
	    game:PostStateChange("session", nfo)

    end


    -- activity selector

    self.uiButtonSelector = self.uiMultiComponent:AddComponent(UIAnimatedButton:New(self.buttonSize, "base:video/uianimatedbutton_games.avi", self.videosSize, "base:texture/ui/mainmenu_games.tga"), "uiButtonSelector")
    self.uiButtonSelector:MoveTo(446 - self.uiMultiComponent.rectangle[1], 515 - self.uiMultiComponent.rectangle[2])
    self.uiButtonSelector.text = l "menu02"
    self.uiButtonSelector.tip = l "tip010"

    self.uiButtonSelector.OnAction = function (self) 

		quartz.framework.audio.loadsound("base:audio/ui/validation.wav")
		quartz.framework.audio.loadvolume(game.settings.audio["volume:sfx"])
		quartz.framework.audio.playsound()
		uiSettingprev = nil

		game:PostStateChange("selector")

    end

    -- Play!   

    self.uiButtonPlay = self.uiMultiComponent:AddComponent(UIAnimatedButton:New(self.buttonSize, "base:video/uianimatedbutton_playnow.avi", self.videosSize, "base:texture/ui/mainmenu_play.tga"), "uiButtonSettings")
    self.uiButtonPlay:MoveTo(446 - self.uiMultiComponent.rectangle[1], 371 - self.uiMultiComponent.rectangle[2])
    self.uiButtonPlay.text = l "menu01"
    self.uiButtonPlay.tip = l "tip009"

    self.uiButtonPlay.OnAction = function ()

		quartz.framework.audio.loadsound("base:audio/ui/validation.wav")
		quartz.framework.audio.loadvolume(game.settings.audio["volume:sfx"])
		quartz.framework.audio.playsound()

        -- launch the starter frag game

        local nfo = { __directory = "StarterFrag", class = "UAStarterFrag", }
        game:PostStateChange("session", nfo, "advertised")

    end

    -- basics

    self.uiButtonBasics = self.uiMultiComponent:AddComponent(UIAnimatedButton:New(self.buttonSize, "base:video/uianimatedbutton_basics.avi", self.videosSize, "base:texture/ui/mainmenu_basics.tga"), "uiButtonSelector")
    self.uiButtonBasics:MoveTo(572 - self.uiMultiComponent.rectangle[1], 515 - self.uiMultiComponent.rectangle[2])
    self.uiButtonBasics.text = l "menu05"
    self.uiButtonBasics.tip = l "tip012"

    self.uiButtonBasics.OnAction = function (self) 

		quartz.framework.audio.loadsound("base:audio/ui/validation.wav")
		quartz.framework.audio.loadvolume(game.settings.audio["volume:sfx"])
		quartz.framework.audio.playsound()
		
		game:PostStateChange("basics")

    end

    -- exit  

    self.uiButtonQuit = self.uiMultiComponent:AddComponent(UIAnimatedButton:New(self.buttonSize, "base:video/uianimatedbutton_quit.avi", self.videosSize, "base:texture/ui/mainmenu_quit.tga"), "uiButtonSelector")
    self.uiButtonQuit:MoveTo(698 - self.uiMultiComponent.rectangle[1], 515 - self.uiMultiComponent.rectangle[2])
    self.uiButtonQuit.text = l "menu06"
    self.uiButtonQuit.tip = l "tip013"

    self.uiButtonQuit.OnAction = function (self) 

		quartz.framework.audio.loadsound("base:audio/ui/validation.wav")
		quartz.framework.audio.loadvolume(game.settings.audio["volume:sfx"])
		quartz.framework.audio.playsound()
		
		local uiPopup = UIPopupWindow:New()
		uiPopup.icon = "base:/video/uianimatedbutton_quit.avi"

        uiPopup.title = l "menu06"
        uiPopup.text = string.format(l "menu06pop")
        
        local uiButtonYes = uiPopup:AddComponent(UIButton:New(), "uiButtonYes")
        uiButtonYes.text = l "but001"
		uiButtonYes.tip = l "tip013"
        uiButtonYes.rectangle = uiPopup.buttonRectangles[1]
        uiButtonYes.OnAction = function (self) 
			
		UTGame.Ui.Title.hasPopup = false
        application.postbreakexecution() 
        end

        local uiButtonNo = uiPopup:AddComponent(UIButton:New(), "uiButtonNo")
        uiButtonNo.text = l "but002"
		uiButtonNo.tip = l "tip006"
        uiButtonNo.rectangle = uiPopup.buttonRectangles[2]
        uiButtonNo.OnAction = function (self) 
		UTGame.Ui.Title.hasPopup = false
        UIManager.stack:Pop() 
        end

		UTGame.Ui.Title.hasPopup = true
        UIManager.stack:Push(uiPopup)

    end

    self.uiMultiComponent:MoveTo(self.foregroundInit[1], self.foregroundInit[2])

    -- revision

    local label = self.uiMultiComponent:AddComponent(UILabel:New())

    label.rectangle = { 0, 0, 960 - 8, 330 }
    label:MoveTo(- self.foregroundRectangle[1], -24)
    label.fontcolor = UIComponent.colors.red
    label.fontJustification = quartz.system.drawing.justification.bottomright
    label.text = string.format("%d.%d.%03d %s", IS_MAJORREVISION or 1, IS_MINORREVISION or 0, REG_BUILD or 0, REG_BUILDBETA or "")

end

-- Draw ----------------------------------------------------------------------

function UTGame.Ui.Title:Draw()

    -- drawing background first

    local desktopWidth, desktopHeight = quartz.system.drawing.getviewportdimensions()
    
    --quartz.system.drawing.loadcolor3f(unpack(UIComponent.colors.white))
    --quartz.system.drawing.loadfont(UIComponent.fonts.default)
    --quartz.system.drawing.drawtext("[UTGame.Ui.Title]", 0, 0)

    if (self.backvideo and self.backVideoRectangle) then

        quartz.system.drawing.pushcontext()
        quartz.system.drawing.loadidentity()
		quartz.system.drawing.loadcolor3f(unpack(UIComponent.colors.white))
		
		if (quartz.system.drawing.loadvideo(self.backvideo)) then
		    quartz.system.drawing.drawvideo(unpack(self.backVideoRectangle))
        else
		    quartz.system.drawing.loadtexture(self.backvideoTexture)
		    quartz.system.drawing.drawtexture(unpack(self.backVideoRectangle))
		end

        quartz.system.drawing.pop()

    end

    if (self.foreground) then

        quartz.system.drawing.loadtexture(self.foreground)
		quartz.system.drawing.loadcolor3f(unpack(UIComponent.colors.white))
        quartz.system.drawing.drawtexture(self.uiMultiComponent.rectangle[1], self.uiMultiComponent.rectangle[2])--unpack(self.uiMultiComponent.rectangle))

    end
	
	quartz.system.drawing.loadcolor3f(unpack(UIComponent.colors.white))
	
	
	if (self.blinkPlay == 1) then
	
        quartz.system.drawing.loadtexture(self.blinkPlayTexture)
        quartz.system.drawing.drawtexture(352,354)
        
	end
	
	if (self.spotLight == 1) then	
	
        quartz.system.drawing.loadtexture(self.spotLightTexture)
        quartz.system.drawing.drawtexture(self.spotLightX,500)
        
	end
	
    --

    UIPage.Draw(self)

end

-- Load ----------------------------------------------------------------------

function UTGame.Ui.Title:Load()
end

-- OnClose -------------------------------------------------------------------

function UTGame.Ui.Title:OnClose()
	
    if (self.backvideo) then

		quartz.system.drawing.loadvideo(self.backvideo)
		quartz.system.drawing.stopvideo()

    end
    
	UIManager:RemoveFx(self.myFx)
	UIManager:RemoveFx(self.myFx2)

end

-- OnOpen --------------------------------------------------------------------

function UTGame.Ui.Title:OnOpen()

    if (self.backvideo) then

		quartz.system.drawing.loadvideo(self.backvideo)
		quartz.system.drawing.playvideo(true)

    end

    UIManager:AddFx("position", { duration = 0.8, __self = self.uiMultiComponent, from = self.foregroundInit, to = { self.foregroundRectangle[1], self.foregroundRectangle[2] }, type = "descelerate" })
	self.myFx = UIManager:AddFx("value", { timeOffset = 0.8, duration = 0.8, __self = self, value = "blinkPlay", from = 0, to = 1, type = "blink"})

	self.myFx2 = UIManager:AddFx("callback", { timeOffset = 0.8, 
	__function = function() 
	
		self.spotLight = 1 
	
	end})
end

-- Update --------------------------------------------------------------------

function UTGame.Ui.Title:Update()

	if (self.spotLight == 1) then
	
		self.spotLightX = self.spotLightX - 32
		if (self.spotLightX < -2000) then
			self.spotLightX = 1300 + math.random(5000)
		end
	
	end

end