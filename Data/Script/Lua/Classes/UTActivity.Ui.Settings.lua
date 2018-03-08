
--[[--------------------------------------------------------------------------
--
-- File:            UTActivity.Ui.Settings.lua
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
require "Ui/UITitledPanel"
require "Ui/UIOption"

--[[ Class -----------------------------------------------------------------]]

UTActivity.Ui = UTActivity.Ui or {}
UTActivity.Ui.Settings = UTClass(UIMenuWindow)

-- default

UTActivity.Ui.Settings.categoryOffset = 15
UTActivity.Ui.Settings.optionOffset = { 10, 30 }
UTActivity.Ui.Settings.optionMargin = { 10, 10 }


-- __ctor -------------------------------------------------------------------

function UTActivity.Ui.Settings:__ctor(...)
    
	-- animate	
    
	self.slideBegin = game.settings.UiSettings.slideBegin and slideanimation
	self.slideEnd = game.settings.UiSettings.slideEnd and slideanimation
	slideanimation = true
	
    -- holds the UIOptions to retrieve them easily

	self.uiOptions = {}

	-- window settings

	self.uiWindow.title = l "titlemen004"
	self.uiWindow.text = ""
	
    self.uiMultiComponent = self.uiWindow:AddComponent(UIMultiComponent:New(), "uiPanel")
    self.uiMultiComponent.rectangle = self.clientRectangle
    
	self.uiWindow.uiPanel = self.uiMultiComponent:AddComponent(UIPanel:New(), "uiPanel")
	self.uiWindow.uiPanel.rectangle = { -10, 0, 725, 455 }

    -- two pass algorithm

	local categories = {}

	-- first pass: parse all activity settings,
	-- foreach category, create category and parse all options

    table.foreachi(activity.settings, function (index, category) 

	    local uiPanelCategory = self.uiWindow.uiPanel:AddComponent(UITitledPanel:New(), "uiPanelCategory" .. index)
	    uiPanelCategory.title = category.title

		local entry = { uiOptions = {}, uiPanel = uiPanelCategory, }
		table.insert(categories, entry)

	    table.foreachi(category.options, function (index, option)

	        local uiOption = uiPanelCategory:AddComponent(UIOption:New(option, activity.settings[option.index]), "uiOption" .. index)

	        table.insert(self.uiOptions, uiOption)	        
	        table.insert(entry.uiOptions, uiOption)
			uiOption.ChangeValue = function(self, value)

				if (activity.settings[self.option.index] ~= value) then
					activity.settings[self.option.index] = value
					if (self.option.index == "energymode" or self.option.index == "respawnhit") then
						uploadbytecode = true
						game.settings.TestSettings.bytecodeoverride = 0
					end
            		if (self.option.index == "numberOfTeams") then
            			if (0 == game.settings.addons.medkitPack) then	
           					if (value > 2 or activity.name == "King of the Hill") then
            					activity.settings.respawnmode = 1
            				end
            			else
            				if (value > 3 and activity.name == "King of the Hill" and 0 == game.settings.addons.customPack) then
            					activity.settings.respawnmode = 1
            				end
            			end
            			if (value > 4) then
            				activity.settings.teamFrag = 1
            				if (0 == game.settings.addons.customPack) then
           						activity.settings.respawnmode = 1
            				end
            			end
					end
					if (self.option.index == "teamFrag") then
						if (value == 0 and activity.settings.numberOfTeams > 4) then
							activity.settings.numberOfTeams = 4
						end
					end
					if (self.option.index == "bonusmin" and value == 0) then
						activity.settings.bonusmax = 0
					end
					if (self.option.index == "bonusmax" and value > 0) then
						activity.settings.bonusmin = 25
					end
					if (self.option.index == "lifePoints" and activity.advancedsettings.healthhandicap > value) then
						activity.advancedsettings.healthhandicap = 0
					end
					if (self.option.index == "ammunitions" and activity.advancedsettings.ammohandicap > value) then
						activity.advancedsettings.ammohandicap = 0
					end
					if (self.option.index == "clips" and activity.advancedsettings.clipshandicap > value) then
						activity.advancedsettings.clipshandicap = 0
					end
					slideanimation = false
            		game:SaveSettings()
					activity:PostStateChange("settings")
				end
			end

	    end )

	end )

	-- second pass: organize components layout

	local position = { 10, 15 }

    table.foreachi(categories, function (index, entry)

        -- the height of the panel depends on the number of uiOptions

	    entry.uiPanel.rectangle =  { 0, 0, 715, 30 + 30 * math.ceil(#entry.uiOptions / 2) + self.optionMargin[2] }
	    entry.uiPanel:MoveTo(position[1], position[2])

	    position[2] = entry.uiPanel.rectangle[4] + self.categoryOffset

	    local offset = { 10, 0 }

	    table.foreachi(entry.uiOptions, function (index, option)

	        --offset[1] = (index > math.ceil(#entry.uiOptions / 2) and 350) or 10	        
	        --offset[2] = (index - 1 == math.ceil(#entry.uiOptions / 2) and 30) or offset[2] + 30

            offset[1] = (math.mod(index, 2) == 0 and 285) or -35
            offset[2] = math.floor((index - 1) / 2) * self.optionOffset[2]

	        option:MoveTo(offset[1], entry.uiPanel.headerSize + self.optionMargin[2] + offset[2])

	    end )

	end )

	-- materials' panel
--[[
	self.uiWindow.uiPanel.uiPanelMaterials = self.uiWindow.uiPanel:AddComponent(UITitledPanel:New(), "uiPanelMaterials")
	self.uiWindow.uiPanel.uiPanelMaterials.title = l "titlemen008"
	self.uiWindow.uiPanel.uiPanelMaterials.rectangle = { 15, 350, 710, 440 }
]]--
	-- buttons,

	-- uiButton1: cancel changes, get back to title screen

    self.uiButton1 = self:AddComponent(UIButton:New(), "uiButton1")
    self.uiButton1.rectangle = UIMenuWindow.buttonRectangles[1]
	self.uiButton1.text = l"but003"
    self.uiButton1.tip = l"tip006"

	self.uiButton1.OnAction = function (self) 
	
		quartz.framework.audio.loadsound("base:audio/ui/back.wav")
		quartz.framework.audio.loadvolume(game.settings.audio["volume:sfx"])
		quartz.framework.audio.playsound()
    		
	    if (activity.forward2) then
            game:PostStateChange("selector") 
		else
            activity:PostStateChange("title") 
		end
	
	end
	
	if (activity.advancedsettings[1]) then
		self.uiButton2 = self:AddComponent(UIButton:New(), "uiButton2")
		self.uiButton2.rectangle = UIMenuWindow.buttonRectangles[2]
		self.uiButton2.text = l"but027"
		self.uiButton2.tip = l"tip189"
		
		local __self = self
		
		self.uiButton2.OnAction = function ()
		
		    self:Save(self)
			activity:PostStateChange("advancedsettings")

		end
	end
	
	-- uiButton5: accept changes, get back to title screen

    self.uiButton5 = self:AddComponent(UIButton:New(), "uiButton5")
    self.uiButton5.rectangle = UIMenuWindow.buttonRectangles[5]
	self.uiButton5.text = l "but006"
    self.uiButton5.tip = l"tip017"

    local __self = self

	self.uiButton5.OnAction = function () 

		self:Save(self)

	    if (activity.forward2) then
            activity:PostStateChange("playersmanagement")
        else
            activity:PostStateChange("playground")
        end

	end

end

function UTActivity.Ui.Settings:OnOpen()

	self:Activate()
end

function UTActivity.Ui.Settings:OnClose()

	self:Deactivate()
end

function UTActivity.Ui.Settings:Save(__self)

	table.foreach(__self.uiOptions, function (_, uiOption)
		
		activity.settings[uiOption.option.index] = uiOption.value
		--print(uiOption.option.index.." "..activity.settings[uiOption.option.index].." "..uiOption.value)
		
	end )
		
	quartz.framework.audio.loadsound("base:audio/ui/validation.wav")
	quartz.framework.audio.loadvolume(game.settings.audio["volume:sfx"])
	quartz.framework.audio.playsound()
		    
	if (game and game.settings) then
		
		if (not game.settings.activities) then
					
			game.settings.activities = {}
					
		end
				
		if (not game.settings.activities[activity.name]) then
					
			game.settings.activities[activity.name] = {}
						
		end
					
		local settings = game.settings.activities[activity.name]
		
		for key, value in pairs(activity.settings) do
						
			if (type(activity.settings[key]) ~= "table") then
						
				settings[key] = activity.settings[key]
							
			end
		end
			        
		game:SaveSettings()
					
	end
end

function UTActivity.Ui.Settings:Activate()

    if (not self.keyboardActive) then

        --game._Char:Add(self, self.Char)
        game._KeyDown:Add(self, self.KeyDown)
        self.keyboardActive = true

    end

end

function UTActivity.Ui.Settings:Deactivate()

    if (self.keyboardActive) then 
    
        --game._Char:Remove(self, self.Char)
        game._KeyDown:Remove(self, self.KeyDown)
        self.keyboardActive = false

    end

end

function UTActivity.Ui.Settings:KeyDown(virtualKeyCode, scanCode)
		
	if (27 == virtualKeyCode or 49 == virtualKeyCode) then
		
		quartz.framework.audio.loadsound("base:audio/ui/back.wav")
		quartz.framework.audio.loadvolume(game.settings.audio["volume:sfx"])
		quartz.framework.audio.playsound()
    		
	    if (activity.forward2) then
            game:PostStateChange("selector") 
		else
            activity:PostStateChange("title") 
		end
	end
	if (50 == virtualKeyCode) then

		self:Save(self)
		activity:PostStateChange("advancedsettings")
	end
	if (13 == virtualKeyCode or 53 == virtualKeyCode) then
		
	    self:Save(self)
		if (activity.forward2) then
            activity:PostStateChange("playersmanagement")
        else
            activity:PostStateChange("playground")
        end
	end

end