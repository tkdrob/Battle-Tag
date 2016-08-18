
--[[--------------------------------------------------------------------------
--
-- File:            UTGame.Ui.Loading.lua
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

require "UI/UIMenuWindow"
require "UI/UITitledPanel"
require "UI/UIProgress"

--[[ Class -----------------------------------------------------------------]]

UTActivity.Ui = UTActivity.Ui or {}
UTActivity.Ui.Loading = UTClass(UTGame.Ui.Loading)

-- __ctor --------------------------------------------------------------------

function UTActivity.Ui.Loading:__ctor(...)

	-- animate	
	
	self.slideBegin = game.settings.UiSettings.slideBegin
	self.slideEnd = game.settings.UiSettings.slideEnd
	

end

-- __dtor --------------------------------------------------------------------

function UTActivity.Ui.Loading:__dtor()
end