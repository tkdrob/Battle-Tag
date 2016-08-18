
--[[--------------------------------------------------------------------------
--
-- File:            UIScrollBar.lua
--                  Copyright (c) Ubisoft Entertainment. All rights reserved.
--
-- Project:         Ubitoys.Tag
-- Date:            Novermber 09, 2010
--
------------------------------------------------------------------------------
--
-- Description:     ...
--
----------------------------------------------------------------------------]]

--[[ Dependencies ----------------------------------------------------------]]

require	"UI/UIMultiComponent"

	require "UI/UIButton"

--[[ Class -----------------------------------------------------------------]]

UTClass.UIScrollBar(UIMultiComponent)

-- default

UIScrollBar.defaultOffset = 24

-- __ctor -------------------------------------------------------------------

function UIScrollBar:__ctor(location, height)

	self.location = location or { 0, 0 }
	self.height = height or 100

	-- up button

	self.uiButtonUp = self:AddComponent(UIButton:New(), "uiButtonUp")
    self.uiButtonUp.OnAction = function ()

		if (self.OnActionUp) then 

			quartz.framework.audio.loadsound("base:audio/ui/validation.wav")
			quartz.framework.audio.loadvolume(game.settings.audio["volume:sfx"])
			quartz.framework.audio.playsound()

			-- lift

			self.currentIndex = math.max(0, self.currentIndex - 1)
			self:SetLift(24 + self.currentIndex * self.offset)			

			if (self.OnActionUp) then self:OnActionUp()
			end

		end

    end

	self.uiButtonUp.states = {

		[ST_DISABLED] = { texture = "base:texture/ui/components/UIButton_ScrollArrowUp_Disabled.tga" },
		[ST_DISABLED + ST_FOCUSED] = { texture = "base:texture/ui/components/UIButton_ScrollArrowUp_Disabled.tga" },

		[ST_ENABLED] = { texture = "base:texture/ui/components/UIButton_ScrollArrowUp.tga" },
		[ST_ENABLED + ST_FOCUSED] = { texture = "base:texture/ui/components/UIButton_ScrollArrowUp_Focused.tga" },
		[ST_ENABLED + ST_CLICKED] = { texture = "base:texture/ui/components/UIButton_ScrollArrowUp_Focused.tga" },
		[ST_ENABLED + ST_FOCUSED + ST_CLICKED] = { texture = "base:texture/ui/components/UIButton_ScrollArrowUp__Entered.tga" },

	}

	self.uiButtonUp.rectangle = { self.location[1], self.location[2], self.location[1] + 24, self.location[2] + 24 }
	self.uiButtonUp.opaque = true
	self.uiButtonUp.sensitive = true

	-- down button

	self.uiButtonDown = self:AddComponent(UIButton:New(), "uiButtonDown")
    self.uiButtonDown.OnAction = function ()
		if (self.OnActionDown) then	

			quartz.framework.audio.loadsound("base:audio/ui/validation.wav")
			quartz.framework.audio.loadvolume(game.settings.audio["volume:sfx"])
			quartz.framework.audio.playsound()

			-- lift

			self.currentIndex = math.min(self.maxIndex, self.currentIndex + 1)
			self:SetLift(24 + self.currentIndex * self.offset)			

			if (self.OnActionDown) then self:OnActionDown()
			end

		end
    end

	self.uiButtonDown.states = {

		[ST_DISABLED] = { texture = "base:texture/ui/components/UIButton_ScrollArrowDown_Disabled.tga" },
		[ST_DISABLED + ST_FOCUSED] = { texture = "base:texture/ui/components/UIButton_ScrollArrowDown_Disabled.tga" },

		[ST_ENABLED] = { texture = "base:texture/ui/components/UIButton_ScrollArrowDown.tga" },
		[ST_ENABLED + ST_FOCUSED] = { texture = "base:texture/ui/components/UIButton_ScrollArrowDown_Focused.tga" },
		[ST_ENABLED + ST_CLICKED] = { texture = "base:texture/ui/components/UIButton_ScrollArrowDown_Focused.tga" },
		[ST_ENABLED + ST_FOCUSED + ST_CLICKED] = { texture = "base:texture/ui/components/UIButton_ScrollArrowDown_Entered.tga" },

	}

	self.uiButtonDown.rectangle = { self.location[1], self.location[2] + self.height, self.location[1] + 24, self.location[2] + self.height + 24 }
	self.uiButtonDown.opaque = true
	self.uiButtonDown.sensitive = true

	-- lift button

	self.height = self.height - 24
	self.uiButtonLift = self:AddComponent(UIButton:New(), "uiButtonLift")
    self.uiButtonLift.OnAction = function ()

    end

	self.uiButtonLift.states = {

--[[
		[ST_DISABLED] = { texture = "base:texture/ui/components/UIButton_ScrollBar_Focused.tga" },
		[ST_DISABLED + ST_FOCUSED] = { texture = "base:texture/ui/components/UIButton_ScrollBar_Focused.tga" },
		[ST_ENABLED] = { texture = "base:texture/ui/components/UIButton_ScrollBar_Focused.tga" },
		[ST_ENABLED + ST_FOCUSED] = { texture = "base:texture/ui/components/UIButton_ScrollBar_Focused.tga" },
		[ST_ENABLED + ST_CLICKED] = { texture = "base:texture/ui/components/UIButton_ScrollBar.tga" },
		[ST_ENABLED + ST_FOCUSED + ST_CLICKED] = { texture = "base:texture/ui/components/UIButton_ScrollBar.tga" },
--]]

		[ST_DISABLED] = { texture = "base:texture/ui/components/UIButton_ScrollBar.tga" },
		[ST_DISABLED + ST_FOCUSED] = { texture = "base:texture/ui/components/UIButton_ScrollBar.tga" },
		[ST_ENABLED] = { texture = "base:texture/ui/components/UIButton_ScrollBar.tga" },
		[ST_ENABLED + ST_FOCUSED] = { texture = "base:texture/ui/components/UIButton_ScrollBar.tga" },
		[ST_ENABLED + ST_CLICKED] = { texture = "base:texture/ui/components/UIButton_ScrollBar.tga" },
		[ST_ENABLED + ST_FOCUSED + ST_CLICKED] = { texture = "base:texture/ui/components/UIButton_ScrollBar_Focused.tga" },

	}

	self.refY = nil
	self.offset = self.defaultOffset
	self.currentIndex = 0
	self.maxIndex = 0
	self.liftSize = 64
	self:SetLift(24)
	self.uiButtonLift.opaque = true
	self.uiButtonLift.sensitive = true
	self.uiButtonLift.direction = DIR_VERTICAL
	
end

-- __dtor -------------------------------------------------------------------

function UIScrollBar:__dtor()
end

-- Draw ----------------------------------------------------------------------

function UIScrollBar:Draw()

	if (self.visible) then

		-- draw background

	   -- quartz.system.drawing.pushcontext()
--		quartz.system.drawing.loadtranslation(self.rectangle[1], self.rectangle[2])
--	    quartz.system.drawing.loadtranslation(unpack(self.uiContents.clientRectangle))
--	    quartz.system.drawing.loadtranslation(0, UITitledPanel.headerSize)

        quartz.system.drawing.loadcolor3f(unpack(UIComponent.colors.white))
        quartz.system.drawing.loadtexture("base:texture/ui/components/UIButton_ScrollBg.tga")
        quartz.system.drawing.drawtexture(self.location[1] + 3, self.location[2] + 12, self.location[1] + 3 + 18, self.location[2] + 36 + self.height)

		--quartz.system.drawing.pop()

	end

    -- base

    UIMultiComponent.Draw(self)

end

-- SetLift -------------------------------------------------------------------

function UIScrollBar:SetLift(pos)

	self.uiButtonLift.posY = pos
	self.uiButtonLift.rectangle = { 
		self.location[1], 
		self.location[2] + self.uiButtonLift.posY, 
		self.location[1] + 24, 
		self.location[2] + self.uiButtonLift.posY + self.liftSize 
	}

end

-- SetSize -------------------------------------------------------------------

function UIScrollBar:SetSize(number, max)

	self.maxIndex = math.max(0, number - max)
	--self.offset = self.height * 0.1
	self.offset = self.height * (1/(number - max + 6))
	self.liftSize = math.max(48 + (self.height * 0.05), self.height - self.maxIndex * self.offset)
	self.uiButtonLift.rectangle = { 
		self.location[1], 
		self.location[2] + self.uiButtonLift.posY, 
		self.location[1] + 24, 
		self.location[2] + self.uiButtonLift.posY + self.liftSize
	}

	if (number <= max) then
		self.visible = false
		self.uiButtonUp.visible = false
		self.uiButtonDown.visible = false
		self.uiButtonLift.visible = false
	else
		self.visible = true
		self.uiButtonUp.visible = true
		self.uiButtonDown.visible = true
		self.uiButtonLift.visible = true
	end

end

-- update --------------------------------------------------------------------

function UIScrollBar:Update()

	if (self.uiButtonLift and self.uiButtonLift.clicked) then	

		local mouse = UIManager.stack.mouse.cursor
		if (self.refY) then

			local pos = mouse.y - self.location[2] - self.refY 
			pos = math.max(24, pos)
			pos = math.min(self.height + 24 - self.liftSize, pos)

			-- action

			local index = math.floor((self.uiButtonLift.posY - 24) / (self.offset - 0.5))
			if (index > self.currentIndex) then 
				if (self.OnActionDown) then self:OnActionDown()
				end
			elseif (index < self.currentIndex) then 
				if (self.OnActionUp) then self:OnActionUp()
				end
			end
			self.currentIndex = index

			-- set new pos

			self:SetLift(pos)	

		else
			self.refY = mouse.y - self.location[2] - self.uiButtonLift.posY
		end
	else
		self.refY = nil
	end

end