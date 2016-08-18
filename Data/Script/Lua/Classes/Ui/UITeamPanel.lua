
--[[--------------------------------------------------------------------------
--
-- File:            UITeamPanel.lua
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

--[[Dependencies ----------------------------------------------------------]]

--[[ Class -----------------------------------------------------------------]]

UTClass.UITeamPanel(UIPanel)

-- defaults

UITeamPanel.headers = {

    red = "base:texture/ui/leaderboard_redline.tga",
    blue = "base:texture/ui/leaderboard_blueline.tga",
    yellow = "base:texture/ui/leaderboard_yellowline.tga",
    green = "base:texture/ui/leaderboard_greenline.tga",
    silver = "base:texture/ui/leaderboard_silverline.tga",
    purple = "base:texture/ui/leaderboard_purpleline.tga",

}

UITeamPanel.headerRectangle = { 1, 20, 330 + 1, 43 }
UITeamPanel.titleRectangle = { 100 + 1, UITeamPanel.headerRectangle[2], UITeamPanel.headerRectangle[3], UITeamPanel.headerRectangle[4] }
UITeamPanel.iconRectangle = { -25, 30 - 40, -25 + 135, 30 + 40 }
UITeamPanel.background = "base:texture/ui/components/uipanel04.tga"
UITeamPanel.fontColor = UIComponent.colors.white

-- __ctor ------------------------------------------------------------------

function UITeamPanel:__ctor(team)

    self.team = team

end

-- __dtor -------------------------------------------------------------------

function UITeamPanel:__dtor()
end

-- Draw ---------------------------------------------------------------------

function UITeamPanel:Draw()

    if (self.rectangle) then

        quartz.system.drawing.pushcontext()

        if (self.background) then
            
            local color = UIComponent.colors.white
            
            quartz.system.drawing.loadcolor3f(unpack(color))
            quartz.system.drawing.loadtexture(self.background)
            quartz.system.drawing.drawwindow(unpack(self.rectangle))

        end

        quartz.system.drawing.loadtranslation(self.rectangle[1], self.rectangle[2])
        
        if (self.team) then

            quartz.system.drawing.loadcolor3f(unpack(UIComponent.colors.white))
            quartz.system.drawing.loadtexture(self.headers[self.team.profile.teamColor])
            quartz.system.drawing.drawwindow(unpack(self.headerRectangle))

            quartz.system.drawing.loadtexture(self.team.profile.icon)
            quartz.system.drawing.drawtexture(unpack(self.iconRectangle))

    	   	local fontJustification = quartz.system.drawing.justification.left + quartz.system.drawing.justification.singlelineverticalcenter

       	   	local rectangleTitle = { unpack(self.headerRectangle) }
    	    rectangleTitle[1] = rectangleTitle[1] + 50

            quartz.system.drawing.loadcolor3f(unpack(UIComponent.colors.white))
            quartz.system.drawing.loadfont(UIComponent.fonts.header)
            quartz.system.drawing.drawtextjustified(self.team.profile.name, fontJustification, unpack(self.titleRectangle))
      
        end

        quartz.system.drawing.pop()

	end

    UIComponent.Draw(self)


end