
--[[--------------------------------------------------------------------------
--
-- File:            UTGame.Ui.Settings.Sound.lua
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
UTGame.Ui.Settings.Sound = UTClass(UITitledPanel)

-- default
    
UTGame.Ui.Settings.Sound.options = nil

-- __ctor --------------------------------------------------------------------

function UTGame.Ui.Settings.Sound:__ctor()

	UTGame.Ui.Settings.Sound.options = UTGame.Ui.Settings.Sound.options or {
	
        [1] = { displayMode = "multiline", tip = l"tip102", label = l "sett011", choices = { { value = 0, displayMode = "large", text = "Off" }, { value = 1 }, { value = 2 }, { value = 3 }, { value = 4 }, { value = 5 }, { value = 6 }, { value = 7 }, { value = 8 }}, index = "l-volume:music", },
        [2] = { displayMode = "multiline", tip = l"tip103", label = l "sett012", choices = { { value = 0, displayMode = "large", text = "Off"  }, { value = 1 }, { value = 2 }, { value = 3 }, { value = 4 }, { value = 5 }, { value = 6 }, { value = 7 }, { value = 8 } }, index = "l-volume:sfx", },
        [3] = { displayMode = "multiline", tip = l"tip104", label = l "oth012", choices = { { value = 0, displayMode = "large", text = "Off"  }, { value = 1 }, { value = 2 }, { value = 3 }, { value = 4 }, { value = 5 }, { value = 6 }, { value = 7 }, { value = 8 } }, index = "l-volume:gm", },
		[4] = { displayMode = "multiline", tip = l"tip149", label = l "oth085", choices = { { value = 0, displayMode = "large", text = "Off"  }, { value = 1 }, { value = 2 }, { value = 3 }, { value = 4 }, { value = 5 }, { value = 6 }, { value = 7 }, { value = 8 } }, index = "l-volume:gd", },
        [5] = { displayMode = "multiline", tip = l"tip183", label = l "sett024", choices = { { value = 0, displayMode = "large", text = l"No" }, { value = 1, displayMode = "large", text = l"Yes" } }, index = "gmtalkative", },
        [6] = { displayMode = "multiline", tip = l"tip105", label = l "sett013", choices = { { value = 16, displayMode = "large", text = "Off"  }, { value = 4, displayMode = "large", text = l"oth052" }, { value = 1, displayMode = "large", text = l"oth053" }, { value = 0, displayMode = "large", text = l"oth054" }}, index = "l-volume:blaster", },

	}
	
    for i, option in ipairs(UTGame.Ui.Settings.Sound.options) do

		self.uiOption = self:AddComponent(UIOption:New(option, game.settings.audio[option.index]))

		self.uiOption:MoveTo(50, -30 + i * 60)
		self.uiOption.width = self.uiOption.width - 100

		self.uiOption.ChangeValue = function(self, value)

            local __index, __volume = string.sub(self.option.index, 3), value / 8
            
			if (self.option.label == l"sett013") then
				__volume = value
			end
			
			if (self.option.label == l"oth085") then
				__volume = value / 2
			end
			
			if (self.option.label == l"sett011") then
				__volume = value / 14
			end
			
			game.settings.audio[__index] = __volume
			game.settings.audio[self.option.index] = value

			if (__index == "volume:music") then
				quartz.framework.audio.setmusicvolume(__volume)
			end
		end

    end

end
