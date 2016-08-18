
--[[--------------------------------------------------------------------------
--
-- File:            UIOption.lua
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

require "Ui/UIMultiComponent"

--[[ Class -----------------------------------------------------------------]]

UTClass.UIOption(UIMultiComponent)

    require "Ui/UIOption.RadioButton"
    require "Ui/UIOption.RadioButtonLarge"
	require "Ui/UIOption.RadioButtonMedium"

-- defaults

UIOption.padding = { 2, 2 }
UIOption.margin = 15
UIOption.height = 21

-- mouse sensitivity,
-- for tips

-- __ctor --------------------------------------------------------------------

function UIOption:__ctor(option, value)

    self.option = option
    self.value = value

    self.uiLabel = self:AddComponent(UILabel:New({ 0, 0, 150, 24 }, option.label), "uiLabel")
    self.uiLabel.fontColor = UIComponent.colors.darkgray
    self.uiLabel.fontJustification = self.option.displayMode == "multiline" and quartz.system.drawing.justification.left or quartz.system.drawing.justification.right
    self.uiLabel.fontJustification = self.uiLabel.fontJustification + quartz.system.drawing.justification.singlelineverticalcenter

    self.rectangle = { 0, 0, 150, self.height }

    --

    if (option.tip) then self.tip = option.tip
    end

    self.width = (self.option.displayMode == "multiline" and 0) or (self.rectangle[3] - self.rectangle[1]) + self.padding[1]
    self.height = (self.option.displayMode == "multiline" and self.height*2 + self.padding[2]) or self.height
    self.verticalOffset = self.height - UIOption.RadioButton.rectangle[4]

    self.buttons = {}

    table.foreach(option.choices, function (index, content)

        -- create the good button according to the content's displayMode,
        -- some choices can be invisible if the condition is not satisfied

	    if (type(content.conditional) == "nil" and true or option.condition(self)) then
	    	if (type(content.conditional2) == "nil" and true or option.condition2(self)) then
	    		if (type(content.conditional3) == "nil" and true or option.condition3(self)) then
	    			if (type(content.conditional4) == "nil" and true or option.condition4(self)) then

                        if (self.option.displayMode2 == "extend" and index == 5) then
                            self.verticalOffset = self.verticalOffset + 26
                            self.width = self.width - 288
                        end
                        local class = UIOption.RadioButton.buttonDisplayModes[(content.displayMode or "small")]
	        			local uiRadioButton = self:AddButton(class, content)
	        
	        			uiRadioButton.tip = self.tip or content.tip -- tips
	        		end
	        	end
			end
	    end

	end)

end

-- __dtor --------------------------------------------------------------------

function UIOption:__dtor()
end

-- AddButton ----------------------------------------------------------------

function UIOption:AddButton(class, content)

    local button = self:AddComponent(class:New(), "radioButton" .. #self.buttons)  

    button.controled = (content.value == self.value)
    button.text = content.text or content.value
    button.icon = content.icon

    local __self = self  

    button.OnControled = function (self) 

        __self:ChangeValue(content.value)
        __self.value = content.value

        class.OnControled(self) 

    end

    -- move the button according to the displayMode

    button:MoveTo(self.width, self.verticalOffset)

    table.insert(self.buttons, button)

    -- increase the UIOption's width

    self.width = button.rectangle[3] + self.padding[1]
    self.rectangle[3] = math.max(self.rectangle[1] + self.width, self.uiLabel.rectangle[3])

    return button

end

-- ChangeValue ---------------------------------------------------------------

function UIOption:ChangeValue(value)
end

-- RegisterPickRegions -------------------------------------------------------

function UIOption:RegisterPickRegions(regions, left, top)

	if (self.sensitive and self.rectangle) then

		local region = {
			component = self,
			rectangle = { self.rectangle[1] + left, self.rectangle[2] + top, self.rectangle[3] + left, self.rectangle[4] + top }
		}

		table.insert(regions, region)

	end

    UIMultiComponent.RegisterPickRegions(self, regions, left, top)

end
