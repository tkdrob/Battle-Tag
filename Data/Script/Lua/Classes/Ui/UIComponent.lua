
--[[--------------------------------------------------------------------------
--
-- File:            UIComponent.lua
--                  Copyright (c) Ubisoft Entertainment. All rights reserved.
--
-- Project:         Ubitoys.Tag
-- Date:            July 7, 2010
--
------------------------------------------------------------------------------
--
-- Description:     ...
--
----------------------------------------------------------------------------]]

--[[ Dependencies ----------------------------------------------------------]]

--[[ Class -----------------------------------------------------------------]]

UTClass.UIComponent()

-- defaults

UIComponent.enabled = true
UIComponent.clicked = false
UIComponent.focused = false
UIComponent.controled = false
UIComponent.visible = true

-- metrics

UIComponent.metrics = {

    panelMargin = { left = 30, top = 30, right = 30, bottom = 30, },
    windowMargin = { left = 20, top = 10, right = 20, bottom = 56, },

}

-- mouse support

UIComponent.opaque = true
UIComponent.sensitive = false

-- styles

UIComponent.colors = {

    black = { 0.00, 0.00, 0.00 },
    blue = { 0.05, 0.53, 0.84 },
    darkgray = { 0.51, 0.51, 0.51 },
    gray = { 0.55, 0.50, 0.50 },
    green = { 0.05, 0.64, 0.08 },
    lightgray = { 0.89, 0.89, 0.89 },
    backcolor = { 0.57, 0.59, 0.68 },
    orange = { 0.97, 0.40, 0.08 },
    red = { 0.85, 0.15, 0.04 },
    yellow = { 0.95, 0.72, 0.00 },
    white = { 1.00, 1.00, 1.00 },
    silver = { 0.75, 0.75, 0.75 },
    purple = { 0.50, 0.00, 0.50 },
    
}

UIComponent.fonts = {

    default = "base:default.fontdef",
    header = "base:medium.fontdef",
    title = "base:large.fontdef",
    larger = "base:larger.fontdef",
    backgroundBanner = "base:extralarge.fontdef",

}

UIComponent.font = UIComponent.fonts.default
UIComponent.fontColor = UIComponent.colors.white
UIComponent.fontJustification = quartz.system.drawing.justification.center + quartz.system.drawing.justification.singlelineverticalcenter

-- __ctor --------------------------------------------------------------------

function UIComponent:__ctor(...)   
 
	self.alpha = 1
	
end

-- __dtor --------------------------------------------------------------------

function UIComponent:__dtor()
end

-- AddComponent --------------------------------------------------------------

function UIComponent:AddComponent(component, id)

	self.components = self.components or {}
	table.insert(self.components, component)

	component.parent = self
	component.id = id

	-- add to indexed list as well

	self._components = self._components or {}
	self._components[id or tostring(component)] = component

	return component, id

end

-- Draw ----------------------------------------------------------------------

function UIComponent:Draw()

    if (self.visible) then

	    if (self.components and 0 < #self.components) then

            if (self.rectangle) then

    	        quartz.system.drawing.pushcontext()
				quartz.system.drawing.loadalpha(self.alpha)
	            quartz.system.drawing.loadtranslation(self.rectangle[1], self.rectangle[2])

	            table.foreach(self.components, function (_, component) if (component.visible) then component:Draw() end end)

	            quartz.system.drawing.pop()

	        else

	            table.foreach(self.components, function (_, component) if (component.visible) then component:Draw() end end)

            end
	    end
    end

end

-- Focus ---------------------------------------------------------------------

function UIComponent:Focus(focused)

    if (self.focused ~= focused) then

        self.focused = focused

        if (self.focused) then
            self:OnFocus()
            if (self.tip) then UIManager.tip = self.tip
            end
        else
            self:OnFocusLost()
            if (self.tip) then UIManager.tip = nil
            end
        end

    end

end

-- GetComponentById ----------------------------------------------------------

function UIComponent:GetComponentById(id)

	if (self._components and id) then
		return self._components[id]
	end

end

function UIComponent:MoveTo(x, y)


   self.rectangle = self.rectangle or { 0, 0, 0, 0 }
    
        -- this one was relative
        --self.rectangle = { self.rectangle[1] + x, self.rectangle[2] + y, self.rectangle[3] + x, self.rectangle[4] + y }
        
    self.rectangle = { x, y, self.rectangle[3] - self.rectangle[1] + x, self.rectangle[4] - self.rectangle[2] + y }

end

-- OnFocus -------------------------------------------------------------------

function UIComponent:OnFocus()
end

-- OnFocusLost ---------------------------------------------------------------

function UIComponent:OnFocusLost()
end

-- RegisterPickRegions -------------------------------------------------------

function RegisterPickRegions(regions, left, top)
end

-- RemoveComponent -----------------------------------------------------------

function UIComponent:RemoveComponent(component)

	if (self._components) then

		-- remove from indexed list

		self._components[component.id or tostring(component)] = nil

	end

	if (self.components) then

		if (type(component) == "number") then

			-- by index

			if (0 < component and component <= #self.components) then

				self.components[component].parent = nil
				table.remove(self.components, i)

				return component

			end

		elseif (type(component) == "string") then

			-- by id

			for index, value in ipairs(self.components) do

				if (component == value.id) then

					component.parent = nil
					table.remove(self.components, index)

					return component

				end
			end
		end

		-- by reference

		for index, value in ipairs(self.components) do

			if (component == value) then

				component.parent = nil
				table.remove(self.components, index)

				return index

			end
		end
	end

end
