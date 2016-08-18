
--[[--------------------------------------------------------------------------
--
-- File:            UTActivity.Ui.Playground.lua
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

require "Ui/UIMenuWindow"
require "Ui/UILabel"
require "Ui/UIBitmap"
require "Ui/UIRegion"
require "Ui/UIArrowLeft"
require "Ui/UIArrowRight"

--[[ Class -----------------------------------------------------------------]]

UTActivity.Ui = UTActivity.Ui or {}
UTActivity.Ui.Playground = UTClass(UIMenuWindow)

-- default

UTActivity.Ui.Playground.Bitmap = {

    texture = "base:texture/ui/playground_background.tga",
    rectangle = { 90, 35, 90 + 530, 35 + 300 },
    defaultPictoSize = 64

}

UTActivity.Ui.Playground.MaterialPanel = {

    rectangle = { 90, 350, 90 + 530, 350 + 90 },
    background = "base:texture/ui/components/uipanel01.tga",
    tBaseRectangle = { 13, 13, 13 + 64, 13 + 64 },
    arrowLeft = { 166, 530 }, arrowRight = { 766, 530 }

}

-- __ctor -------------------------------------------------------------------

function UTActivity.Ui.Playground:__ctor(...)

    assert(activity)

	-- animate	
    
	self.slideBegin = game.settings.UiSettings.slideBegin
	self.slideEnd = game.settings.UiSettings.slideEnd
	
    __self = self

	-- window settings
	
	self.titleCommon = l"oth062"

	self.uiWindow.title = l "titlemen009"

	-- contents,

    self.uiPanel = self.uiWindow:AddComponent(UIPanel:New(), "uiPanel")
    self.uiPanel.rectangle = self.clientRectangle
    
    self.uiSubTitle = self.uiPanel:AddComponent(UILabel:New(), "uiSubTitle")
    self.uiSubTitle.rectangle = { self.Bitmap.rectangle[1], self.Bitmap.rectangle[2] - 30, self.Bitmap.rectangle[3], self.Bitmap.rectangle[2] }
    self.uiSubTitle.font = UIComponent.fonts.default
    self.uiSubTitle.fontColor = UIComponent.colors.orange

    self.uiPlaygroundPanel = self.uiPanel:AddComponent(UIPanel:New(), "uiPlaygroundPanel")
    self.uiPlaygroundPanel.rectangle = self.Bitmap.rectangle
    self.uiPlaygroundBitmap = self.uiPlaygroundPanel:AddComponent(UIBitmap:New(self.Bitmap.texture), "uiPlaygroundBitmap")
    
    self.uiMaterialPanel = self.uiPanel:AddComponent(UIPanel:New(), "uiMaterialPanel")
    self.uiMaterialPanel.rectangle = self.MaterialPanel.rectangle
    self.uiMaterialPanel.background = self.MaterialPanel.background

    self.uiTBasePanel = self.uiMaterialPanel:AddComponent(UIPanel:New(), "uiTBasePanel")
    self.uiTBasePanel.rectangle = self.MaterialPanel.tBaseRectangle

    -- playground content

    local numberOfTeams = (type(activity.settings.numberOfTeams) == "number") and activity.settings.numberOfTeams or 0

    if (activity.playground) then

        self.currentPlayground = (activity.playground.selection and activity.playground[activity.playground.selection(self)] or activity.playground[1])
        self.icons = {}
        local listIcons = {}

        if (self.currentPlayground) then

            -- temporary table to sort the icons


            table.foreach(self.currentPlayground, function(key, itemTable)

                if (type(itemTable.condition) == "nil" and true or itemTable.condition(self)) then
                
                    local size = itemTable.size or self.Bitmap.defaultPictoSize

                    table.foreach(itemTable.positions, function(index, position)

                        local bitmap = "base:texture/ui/pictograms/" .. size .. "x/" .. key .. ".tga"
                        local rectangle = { 0, 0, size, size }

                        -- set up the icon, a sensitive component

                        local icon = UIRegion:New()
                        icon.bitmap = bitmap
                        icon.rectangle = rectangle
                        icon.text = itemTable.text
                        icon.title = itemTable.title
                        icon.category = itemTable.category or key
                        icon.unfocusedBitmap = "base:texture/ui/pictograms/" .. size .. "x/" .. key .. ".tga"
                        icon.focusedBitmap = "base:texture/ui/pictograms/" .. size .. "x/" .. key .. "_focused.tga"   
                        icon.priority = itemTable.priority or 99
                        icon:MoveTo(position[1] - size/2, position[2] - size/2)

                        -- because a region do not draw anything, replace its draw method with UIBitmap's

                        icon.Draw = UIBitmap.Draw

                        table.insert(listIcons, icon)

                    end )

                end

            end )

            table.sort(listIcons, function (e1, e2) return e1.priority > e2.priority end)

            -- create the icons in the correct order

            table.foreachi(listIcons, function (index, icon)

                self.uiPlaygroundPanel:AddComponent(icon, "item" .. index)
                table.insert(self.icons, icon)
                icon.OnFocus = function (self) __self.iconIndex = index end

                -- create a category in the icons table which will hold a reference of the icons of the same category

                self.icons[icon.category] = self.icons[icon.category] or {}
                table.insert(self.icons[icon.category], icon)                

            end )

        end


        -- this is the index of the item that will be described
        
        self.iconIndex = #self.icons
		
		if (#listIcons > 1) then
		
			-- arrow buttons

			self.uiArrowLeft = self:AddComponent(UIArrowLeft:New(), "uiArrowLeft")
			self.uiArrowLeft:MoveTo(self.MaterialPanel.arrowLeft[1], self.MaterialPanel.arrowLeft[2])
			self.uiArrowLeft.OnAction = function (self)
				quartz.framework.audio.loadsound("base:audio/ui/validation.wav")
				quartz.framework.audio.loadvolume(game.settings.audio["volume:sfx"])
				quartz.framework.audio.playsound()
				__self.iconIndex = (__self.icons[__self.iconIndex + 1] and __self.iconIndex + 1 or 1)
			end        

			self.uiArrowRight = self:AddComponent(UIArrowRight:New(), "uiArrowRight")
			self.uiArrowRight:MoveTo(self.MaterialPanel.arrowRight[1], self.MaterialPanel.arrowRight[2])
			self.uiArrowRight.OnAction = function (self)
				quartz.framework.audio.loadsound("base:audio/ui/validation.wav")
				quartz.framework.audio.loadvolume(game.settings.audio["volume:sfx"])
				quartz.framework.audio.playsound()
				__self.iconIndex = (__self.icons[__self.iconIndex - 1] and __self.iconIndex - 1 or #__self.icons) 
			end
		end


    end
    -- buttons,

    -- uiButton1: back

    self.uiButton1 = self:AddComponent(UIButton:New(), "uiButton1")
    self.uiButton1.rectangle = UIMenuWindow.buttonRectangles[1]
	self.uiButton1.text = l "but003"
    self.uiButton1.tip = l"tip006"

	self.uiButton1.OnAction = function (self)
 
		quartz.framework.audio.loadsound("base:audio/ui/back.wav")
		quartz.framework.audio.loadvolume(game.settings.audio["volume:sfx"])
		quartz.framework.audio.playsound()
		UTActivity.Ui.Settings.slideBegin = true

		activity:PostStateChange("settings") 

	end

	 -- uiButton5: next

    self.uiButton5 = self:AddComponent(UIButton:New(), "uiButton5")
    self.uiButton5.rectangle = UIMenuWindow.buttonRectangles[5]
	self.uiButton5.text = l"but006"
    self.uiButton5.tip = l"tip018"

	self.uiButton5.OnAction = function (self)

		quartz.framework.audio.loadsound("base:audio/ui/validation.wav")
		quartz.framework.audio.loadvolume(game.settings.audio["volume:sfx"])
		quartz.framework.audio.playsound()

		activity:PostStateChange("playersmanagement")

	end 

end

-- Draw ----------------------------------------------------------------------

function UTActivity.Ui.Playground:Draw()

    UIMenuWindow.Draw(self)

    if (self.rectangle) then
    
        quartz.system.drawing.pushcontext()
		quartz.system.drawing.loadtranslation(self.rectangle[1], self.rectangle[2])
		if (self.currentPlayground) then

			local icon = self.icons[self.iconIndex]

			if (icon) then

				if (self.previousCategory and self.previousCategory ~= icon.category) then
					table.foreachi(self.icons[self.previousCategory], function (index, icon) icon.bitmap = icon.unfocusedBitmap end )
				end

				table.foreachi(self.icons[icon.category], function (index, icon) icon.bitmap = icon.focusedBitmap end )

				if (icon.bitmap) then

					local rectangle = { 230, 515, 230 + 64, 515 + 64 }

					quartz.system.drawing.loadcolor3f(unpack(UIComponent.colors.white))
					quartz.system.drawing.loadtexture(icon.bitmap)
					quartz.system.drawing.drawtexture(unpack(rectangle))

				end

				if (icon.title) then

					local fontJustification = quartz.system.drawing.justification.topleft + quartz.system.drawing.justification.wordbreak + quartz.system.drawing.justification.singlelineverticalcenter
					local rectangle = { 300, 510, 750, 525 }

					quartz.system.drawing.loadcolor3f(unpack(UIComponent.colors.orange))
					quartz.system.drawing.loadfont(UIComponent.fonts.default)
					quartz.system.drawing.drawtextjustified(icon.title, fontJustification, unpack(rectangle))

				end

				if (icon.text) then

					local fontJustification = quartz.system.drawing.justification.topleft + quartz.system.drawing.justification.wordbreak
					local rectangle = { 300, 530, 750, 700 }

					quartz.system.drawing.loadcolor3f(unpack(UIComponent.colors.darkgray))
					quartz.system.drawing.loadfont(UIComponent.fonts.default)
					quartz.system.drawing.drawtextjustified(icon.text, fontJustification, unpack(rectangle))

				end 

				self.previousCategory = icon.category

			end

			if (self.titleCommon) then

				local fontJustification = quartz.system.drawing.justification.topleft + quartz.system.drawing.justification.wordbreak
				local rectangle = { 220, 165, 1000, 1000 }

				quartz.system.drawing.loadcolor3f(unpack(UIComponent.colors.darkgray))
				quartz.system.drawing.loadfont(UIComponent.fonts.default)
				quartz.system.drawing.drawtextjustified(self.titleCommon, fontJustification, unpack(rectangle))

			end 

		end
        quartz.system.drawing.pop()

    end

end
