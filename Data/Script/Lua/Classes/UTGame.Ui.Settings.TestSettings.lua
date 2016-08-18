
--[[--------------------------------------------------------------------------
--
-- File:            UTGame.Ui.Settings.TestSettings.lua
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
UTGame.Ui.Settings.TestSettings = UTClass(UITitledPanel)

-- default
    
UTGame.Ui.Settings.TestSettings.options = nil

-- __ctor --------------------------------------------------------------------

function UTGame.Ui.Settings.TestSettings:__ctor()

	UTGame.Ui.Settings.TestSettings.options = {
		
	    [1] = { displayMode = "multiline", displayMode2 = "extend", tip = l"tip252", label = l"sett038", choices = { { value = 100000, displayMode = "large" }, { value = 90000, displayMode = "large" }, { value = 80000, displayMode = "large" }, { value = 70000, displayMode = "large" }, { value = 60000, displayMode = "large" }, { value = 50000, displayMode = "large" }, { value = 40000, displayMode = "large" }, { value = 30000, displayMode = "large" } }, index = "roundloopcycle", },
	    [2] = { displayMode = "multiline", label = l"sett018", choices = { { value = 0, displayMode = "large", text = l"but002", tip = l"tip156" }, { value = 1, displayMode = "large", text = l"but001", tip = l"tip157" } }, index = "bytecodeoverride", },
        [3] = { displayMode = "multiline", label = l"sett039", choices = { { value = false, displayMode = "large", text = l"but002", tip = l"tip254" }, { value = true, displayMode = "large", text = l"but001", tip = l"tip255" } }, index = "vestoverride", },
	
	}
	
    local offset = 0
    
    for i, option in ipairs(UTGame.Ui.Settings.TestSettings.options) do

		self.uiOption = self:AddComponent(UIOption:New(option, game.settings.TestSettings[option.index]))

        self.uiOption:MoveTo(50, -30 + i * 50 + offset)

		if (self.options[i].displayMode2 == "extend") then
            offset = offset + 30
        end
        self.uiOption.width = self.uiOption.width - 100
		self.uiOption.ChangeValue = function(self, value)
			
            if (game.settings.TestSettings[self.option.index] ~= value) then
                game.settings.TestSettings[self.option.index] = value
    			if (self.option.index == "bytecodeoverride") then
    				uploadbytecode = true
    			end
			end
			
		end

    end

end
