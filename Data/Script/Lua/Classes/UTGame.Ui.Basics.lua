
--[[--------------------------------------------------------------------------
--
-- File:            UTGame.Ui.Basics.lua
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

require "UI/UISelector"
require "UTBasics"

--[[ Class -----------------------------------------------------------------]]

UTGame.Ui = UTGame.Ui or {}
UTGame.Ui.Basics = UTClass(UISelector)

    require "UTGame.Ui.Basics.Principle"

-- __ctor --------------------------------------------------------------------

function UTGame.Ui.Basics:__ctor(...)

	-- window settings

	self.uiWindow.title = l"menu05"
	self.uiWindow.icon = "base:video/uianimatedbutton_basics.avi"
	self.uiSelector.title = l"oth002"

    -- dedicated settings on the right side,

	self.uiBasics = {}
	self.headerText = {}

	local size = 0
    for index, slide in ipairs(UTBasics.slides) do

		self.headerText[index] = index
		self.uiBasics[index] = self.uiWindows:AddComponent(UTGame.Ui.Basics.Principle:New(slide))

		size = size + 1

    end

    -- contents

    self:Reserve(size, false)

    for index, uiBasic in ipairs(self.uiBasics) do

		uiBasic.rectangle = self.uiWindows.clientRectangle
		uiBasic.rectangleBitmap = {-14 + uiBasic.rectangle[1],20 + uiBasic.rectangle[2],-14 + uiBasic.rectangle[1] + 400,20 + uiBasic.rectangle[2] + 231}
		uiBasic.rectangleText = {uiBasic.rectangle[1] + 16, uiBasic.rectangle[4] - 170, uiBasic.rectangle[3] - 16, uiBasic.rectangle[4]}
		uiBasic.title = UTBasics.slides[index].title
		uiBasic.visible = false

		local properties = { text = uiBasic.title, headerText = self.headerText[index] }
		local item = self:AddItem(properties)

		item.Action = function ()

            if (self.uiActiveBasic ~= uiBasic) then

			    self.uiActiveBasic.visible = false

                self.uiActiveBasic = uiBasic
                self.uiActiveBasic.visible = true

			end
		end

	end

    -- buttons,

    -- uiButton1: back

    self.uiButton1 = self:AddComponent(UIButton:New(), "uiButton1")
    self.uiButton1.rectangle = UIMenuWindow.buttonRectangles[1]
    self.uiButton1.text = l"but003"
    self.uiButton1.tip = l"tip006"


    self.uiButton1.OnAction = function (self) 

		quartz.framework.audio.loadsound("base:audio/ui/back.wav")
		quartz.framework.audio.loadvolume(game.settings.audio["volume:sfx"])
		quartz.framework.audio.playsound()

		game:PostStateChange("title")

    end

	self.index = 1
	self:Scroll(0)

end

-- OnOpen --------------------------------------------------------------------

function UTGame.Ui.Basics:OnOpen()

    self.index = self.index or 1
    self.uiActiveBasic = self.uiBasics[self.index]
    self.uiActiveBasic.visible = true

end
