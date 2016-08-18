
--[[--------------------------------------------------------------------------
--
-- File:            UIEditBox.lua
--                  Copyright (c) Ubisoft Entertainment. All rights reserved.
--
-- Project:         Ubitoys.Tag
-- Date:            July 13, 2010
--
------------------------------------------------------------------------------
--
-- Description:     ...
--
----------------------------------------------------------------------------]]

--[[Dependencies ----------------------------------------------------------]]

--[[ Class -----------------------------------------------------------------]]

UTClass.UIEditBox(UIRegion)

-- defaults

UIEditBox.background = "base:texture/ui/components/UIPanel04.tga"
UIEditBox.fontJustification = quartz.system.drawing.justification.center + quartz.system.drawing.justification.singlelineverticalcenter
UIEditBox.fontColor = UIComponent.colors.orange
UIEditBox.font = UIComponent.fonts.header

-- !! NEED LOCALISATION !!

UIEditBox.allowedChars = "abcdefghijklmnopqrstuvwxyz0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ�������� \b"

UIEditBox.rectangle = { 0, 0, 220, 34 }

-- __ctor ------------------------------------------------------------------

function UIEditBox:__ctor(text, ...)

	self.editText = ""
	self.cursorText = ""
	self.cursorPos = 1
    self.maxChars = 11
    self.rectangle = UIEditBox.rectangle

	if (text) then

		self.editText = text
		self.cursorText = ""
		self.cursorPos = string.len(text) + 1

	end

end

-- __dtor -------------------------------------------------------------------

function UIEditBox:__dtor()
end


-- Activate ---------------------------------------------------------------

function UIEditBox:Activate()

    if (not self.keyboardActive) then

        game._Char:Add(self, self.Char)
        game._KeyDown:Add(self, self.KeyDown)
        self.keyboardActive = true

    end

end
-- Char ----------------------------------------------------------------

function UIEditBox:Char(char)

    if (string.find(UIEditBox.allowedChars, char, 1, true)) then

        if (char == '\b') then

			-- delete

			if (self.editText ~= "") then 

				if (1 < self.cursorPos) then

					if (string.len(self.editText) < self.cursorPos) then
   						self.editText = string.sub(self.editText, 1, string.len(self.editText) - 1) 
					else
   						self.editText = string.format("%s%s", string.sub(self.editText, 1, self.cursorPos - 2), string.sub(self.editText, self.cursorPos))
   					end
   					self.cursorPos = self.cursorPos - 1

				end

			end

		else

			-- add a char

			if (self.maxChars > string.len(self.editText)) then 

   	            if (1 == self.cursorPos) then
					self.editText = char .. self.editText 
				elseif (string.len(self.editText) < self.cursorPos) then
					self.editText = self.editText .. char
				else
   					self.editText = string.format("%s%s%s", string.sub(self.editText, 1, self.cursorPos - 1), char, string.sub(self.editText, self.cursorPos))
				end
   	            self.cursorPos = self.cursorPos + 1

			end

		end

    end

end

-- Deactivate ---------------------------------------------------------------

function UIEditBox:Deactivate()

    if (self.keyboardActive) then 
    
        game._Char:Remove(self, self.Char)
        game._KeyDown:Remove(self, self.KeyDown)
        self.keyboardActive = false

    end

end


-- Draw ---------------------------------------------------------------------

function UIEditBox:Draw()

   if (self.rectangle) then

        if (self.background) then

			local color = self.color or UIComponent.colors.white

            quartz.system.drawing.loadcolor3f(unpack(color))
            quartz.system.drawing.loadtexture(self.background)
            quartz.system.drawing.drawwindow(unpack(self.rectangle))

        end
        
        if (self.editText) then

            local fontColor = self.fontColor or UIComponent.colors.darkgray
            local fontJustification = self.fontJustification

            quartz.system.drawing.loadcolor3f(unpack(fontColor))
            quartz.system.drawing.loadfont(self.font)
            local text = ""
            if (1 == self.cursorPos) then
				text = string.format("%s%s", self.cursorText, self.editText)
            elseif (string.len(self.editText) < self.cursorPos) then
				self.cursorPos = string.len(self.editText) + 1
	            text = string.format("%s%s", self.editText, self.cursorText)
	        else
   	            text = string.format("%s%s%s", string.sub(self.editText, 1, self.cursorPos - 1), self.cursorText, string.sub(self.editText, self.cursorPos))
			end
			local width, height = quartz.system.drawing.gettextdimensions(self.cursorText, 0)
			local rect = {
				self.rectangle[1] + (width * 0.5),
				self.rectangle[2],
				self.rectangle[3] + (width * 0.5),
				self.rectangle[4],
			}
            quartz.system.drawing.drawtextjustified(text, fontJustification, unpack(rect))

        end

	 end

end

-- OnFocus -------------------------------------------------------------------

function UIEditBox:OnFocus()
end

-- OnFocusLost ---------------------------------------------------------------

function UIEditBox:OnFocusLost()
end

-- OnKeyDown -----------------------------------------------------------------

function UIEditBox:KeyDown(virtualKeyCode, scanCode)

	if (37 == virtualKeyCode) then

		-- left
		self.cursorPos = math.max(1, self.cursorPos - 1)
	
	elseif (39 == virtualKeyCode) then

		-- right
		self.cursorPos = self.cursorPos + 1
		
	elseif (27 == virtualKeyCode) then

		UIManager.stack:Pop()

	end

end

-- Update -----------------------------------------------------------------

function UIEditBox:Update()

	if (self.keyboardActive) then

		local elapsedTime = quartz.system.time.gettimemicroseconds() - (self.timer or quartz.system.time.gettimemicroseconds())
		self.timer = quartz.system.time.gettimemicroseconds()

		self.blinkTimer = (self.blinkTimer or 0) + elapsedTime
		if (self.blinkTimer < 250000) then

			self.cursorText = "|"

		else

			self.cursorText = ""
			if (self.blinkTimer > 500000) then self.blinkTimer = 0
			end

		end	

	end

end
