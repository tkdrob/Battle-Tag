
--[[--------------------------------------------------------------------------
--
-- File:            UTGame.Ui.Settings.ActivitySettings.lua
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
UTGame.Ui.Settings.ActivitySettings = UTClass(UITitledPanel)

-- default
    
UTGame.Ui.Settings.ActivitySettings.options = nil

-- __ctor --------------------------------------------------------------------

function UTGame.Ui.Settings.ActivitySettings:__ctor()

	UTGame.Ui.Settings.ActivitySettings.options = {
		
	    [1] = { displayMode = "multiline", label = l"goption003", tip = l"tip026", choices = { { value = 1, icon = "base:texture/ui/components/uiradiobutton_house.tga" }, { value = 2 }, { value = 3 }, { value = 4 }, { value = 5, icon = "base:texture/ui/components/uiradiobutton_sun.tga" } }, index = "beamPower" },
		[2] = { displayMode = "multiline", label = l"sett015", tip = l"tip130", choices = { { value = 0 }, { value = 1 }, { value = 2 }, { value = 3 }, { value = 4 }}, index = "teampoints", },
	    [3] = { displayMode = "multiline", label = l"sett016", tip = l"tip131", choices = { { value = 1 }, { value = 2 }, { value = 3 }, { value = 4 }, { value = 5 }}, index = "playerpoints", },
	    [4] = { displayMode = "multiline", label = l"goption014", tip = l"tip004", choices = { { value = 0, displayMode = "large", text = l"but002" }, { value = 1, displayMode = "large", text = l"but001" } }, index = "assist", },
	    [5] = { displayMode = "multiline", label = l"sett023", choices = { { value = 0, conditional = true, displayMode = "large", text = l"but002", tip = l"tip177" }, { value = 1, displayMode = "large", text = l"but001", tip = l"tip178" } }, index = "preventlaunch", condition = function (self) return (game.settings.GameSettings.unregister == 0) end },
	    [6] = { displayMode = "multiline", label = l"but026", choices = { { value = 0, displayMode = "large", text = l"but002", tip = l"tip180" }, { value = 1, displayMode = "large", text = l"but001", tip = l"tip179" } }, index = "teamdefaults", },
	    [7] = { displayMode = "multiline", label = l"goption002", tip = l"tip025", choices = { { value = 0, displayMode = "large", text = l"oth080" }, { value = 1, displayMode = "large", text = l"oth032" } }, index = "gameLaunch", },
		[8] = { displayMode = "multiline", label = l"goption056", tip = l"tip227", choices = { { value = 3 }, { value = 5 }, { value = 10 } }, index = "countdown", },
	
	}
	
    for i, option in ipairs(UTGame.Ui.Settings.ActivitySettings.options) do

		self.uiOption = self:AddComponent(UIOption:New(option, game.settings.ActivitySettings[option.index]))

		self.uiOption:MoveTo(50, -30 + i * 50)
		self.uiOption.width = self.uiOption.width - 100

		self.uiOption.ChangeValue = function(self, value)
			
            if (game.settings.ActivitySettings[self.option.index] ~= value) then
            	game.settings.ActivitySettings[self.option.index] = value
            	if (self.option.index == "assist" or self.option.index == "teamdefaults") then
            		if (self.option.index == "assist") then
	    				uploadbytecode = true
	            		if (game.settings.TestSettings.bytecodeoverride == 1) then
	    					game.settings.TestSettings.bytecodeoverride = 0
	    				end
	    			elseif (value == 0) then
	    				game.settings.UiSettings.teamribbon = 0
	    			end
    				game:SaveSettings()
	    			uiSettingprev = 5
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
