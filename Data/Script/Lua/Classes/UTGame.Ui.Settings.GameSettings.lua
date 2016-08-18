
--[[--------------------------------------------------------------------------
--
-- File:            UTGame.Ui.Settings.GameSettings.lua
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

require "Ui/UIOption"
require "Ui/UIPanel"
require "Ui/UITitledPanel"

--[[ Class -----------------------------------------------------------------]]

UTGame.Ui.Settings = UTGame.Ui.Settings or {}
UTGame.Ui.Settings.GameSettings = UTClass(UITitledPanel)

-- default
    
UTGame.Ui.Settings.GameSettings.options = nil

-- __ctor --------------------------------------------------------------------

function UTGame.Ui.Settings.GameSettings:__ctor()

	UTGame.Ui.Settings.GameSettings.options = {
		
	    --[1] = { displayMode = "multiline", label = l"sett019", choices = { { value = 0, displayMode = "large", text = l"but002", tip = l"tip167" }, { value = 1, conditional = true, displayMode = "large", text = l"but001", tip = l"tip168" } }, index = "protectedmode", condition = function (self) return (game.settings.GameSettings.unregister == 0 or game.settings.GameSettings.reconnect > 0) end },
	    [1] = { displayMode = "multiline", label = l"sett020", choices = { { value = 0, displayMode = "large", text = l"but002", tip = l"tip169" }, { value = 1, displayMode = "large", text = l"but001", tip = l"tip170" } }, index = "playernumbermod", },
	    [2] = { displayMode = "multiline", label = l"sett021", choices = { { value = 0, displayMode = "large", text = l"oth032", tip = l"tip171" }, { value = 1, displayMode = "large", text = l"oth080", tip = l"tip172" } }, index = "unregister", },
	    [3] = { displayMode = "multiline", label = l"sett022", choices = { { value = 0, displayMode = "large", text = l"but002", tip = l"tip173" }, { value = 1, displayMode = "large", text = l"oth080", tip = l"tip174" }, { value = 2, displayMode = "large", text = l"oth032", tip = l"tip193" } }, index = "reconnect", },
		[4] = { displayMode = "multiline", label = l"sett034", choices = { { value = 0, displayMode = "large", text = l"oth080", tip = l"tip237" }, { value = 1, displayMode = "large", text = l"oth032", tip = l"tip238" }, { value = 2, displayMode = "large", text = l"oth076", tip = l"tip237" } }, index = "vestdisconnect", },
	
	}
	
    for i, option in ipairs(UTGame.Ui.Settings.GameSettings.options) do

		self.uiOption = self:AddComponent(UIOption:New(option, game.settings.GameSettings[option.index]))

		self.uiOption:MoveTo(50, -30 + i * 60)
        self.uiOption.uiLabel.rectangle = { 0, 0, 250, 24 }
		self.uiOption.width = self.uiOption.width - 100

		self.uiOption.ChangeValue = function(self, value)
			
            if (game.settings.GameSettings[self.option.index] ~= value) then
            	game.settings.GameSettings[self.option.index] = value
    			if (self.option.index == "playernumbermod" and devicenumberflag) then
    				devicenumberflag = false
    				game:PostStateChange("connected")
				end
				if (self.option.index == "unregister") then
					game.settings.ActivitySettings.preventlaunch = 1
					if (value == 1 and game.settings.GameSettings.reconnect == 0) then
						game.settings.GameSettings.protectedmode = 0
		    		end
				end
				if (self.option.index == "reconnect" and game.settings.GameSettings.unregister == 1) then
					if (value == 0) then
						game.settings.GameSettings.protectedmode = 0
					end
				end
				if (self.option.index == "unregister" or self.option.index == "reconnect" and game.settings.GameSettings.unregister == 1) then
    				game:SaveSettings()
    				uiSettingprev = 4
	            	if (activity) then
	            		UIManager.stack:Pop()
	            		UIManager.stack:Push(UTGame.Ui.Settings)
	            	else
						game:PostStateChange("settings")
					end
				end
			end
			
		end

    end

end
