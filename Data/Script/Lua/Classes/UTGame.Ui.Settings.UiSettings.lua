
--[[--------------------------------------------------------------------------
--
-- File:            UTGame.Ui.Settings.UiSettings.lua
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
UTGame.Ui.Settings.UiSettings = UTClass(UITitledPanel)

-- default
    
UTGame.Ui.Settings.UiSettings.options = nil

-- __ctor --------------------------------------------------------------------

function UTGame.Ui.Settings.UiSettings:__ctor()

	UTGame.Ui.Settings.UiSettings.options = {
		
	    [1] = { displayMode = "multiline", tip = l"tip198", label = l"sett027", choices = { { value = false, displayMode = "large", text = l"but002" }, { value = true, displayMode = "large", text = l"but001" } }, index = "slideBegin", },
	    [2] = { displayMode = "multiline", tip = l"tip199", label = l"sett028", choices = { { value = false, displayMode = "large", text = l"but002" }, { value = true, displayMode = "large", text = l"but001" } }, index = "slideEnd", },
	    [3] = { displayMode = "multiline", tip = l"tip197", label = l"sett026", choices = { { value = 0, displayMode = "large", text = l"but029" }, { value = 1, displayMode = "large", text = l"but030" } }, index = "playerslotgrid", },
	    [4] = { displayMode = "multiline", tip = l"tip201", label = l"sett029", choices = { { value = 9 }, { value = 10 }, { value = 11, conditional2 = true }, { value = 12 }, { value = 13, conditional2 = true }, { value = 14 }, { value = 15, conditional2 = true }, { value = 16 }, { value = 18 }, { value = 20 }, { value = 22 }, { value = 24 }, { value = 28, conditional = true }, { value = 32, conditional = true } }, index = "nbplayerslot", condition = function (self) return (game.settings.UiSettings.playerslotgrid == 0) end, condition2 = function (self) return (game.settings.UiSettings.playerslotgrid ~= 0) end },
	    [5] = { displayMode = "multiline", tip = l"tip215", label = l"sett030", choices = { { value = 0, displayMode = "large", text = l"but002" }, { value = 1, conditional = true, displayMode = "large", text = l"but037" }, { value = 2, conditional = true, displayMode = "large", text = l"but038" } }, index = "teamribbon", condition = function (self) return (game.settings.ActivitySettings.teamdefaults == 1) end },
		[6] = { displayMode = "multiline", tip = l"tip232", label = l"sett033", choices = { { value = 0, displayMode = "large", text = l"but033" }, { value = 1, displayMode = "large", text = l"but034" }, { value = 2, displayMode = "large", text = l"but035" } }, index = "aspectratio", },
        [7] = { displayMode = "multiline", tip = l"tip240", label = l"sett035", choices = { { value = 0, displayMode = "large", text = l"oth083" }, { value = 1, displayMode = "large", text = l"but039" } }, index = "teamcolors", },
	
	}
	
    for i, option in ipairs(UTGame.Ui.Settings.UiSettings.options) do

		self.uiOption = self:AddComponent(UIOption:New(option, game.settings.UiSettings[option.index]))

		self.uiOption:MoveTo(50, -30 + i * 50)
		self.uiOption.width = self.uiOption.width - 100

		self.uiOption.ChangeValue = function(self, value)
			
            if (game.settings.UiSettings[self.option.index] ~= value) then
            	game.settings.UiSettings[self.option.index] = value
    			if (self.option.index == "playerslotgrid") then
    				if (value == 1 and game.settings.UiSettings.nbplayerslot > 16) then
    					game.settings.UiSettings.nbplayerslot = 16
    				end
    				uiSettingprev = 6
    				if (activity) then
    					UIPlayerSlotGrid.maxSlot = 9 + 9 * value
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
