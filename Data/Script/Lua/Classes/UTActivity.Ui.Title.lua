
--[[--------------------------------------------------------------------------
--
-- File:            UTActivity.Ui.Title.lua
--                  Copyright (c) Ubisoft Entertainment. All rights reserved.
--
-- Project:         Ubitoys.Tag
-- Date:            July 26, 2010
--
------------------------------------------------------------------------------
--
-- Description:     ...
--
----------------------------------------------------------------------------]]

--[[ Dependencies ----------------------------------------------------------]]

require "Ui/UIMenuWindow"

--[[ Class -----------------------------------------------------------------]]

UTActivity.Ui = UTActivity.Ui or {}
UTActivity.Ui.Title = UTClass(UIMenuWindow)

UTActivity.Ui.Title.textRules = {

    font = UIComponent.fonts.default,
    fontColor = UIComponent.colors.gray,
    fontJustificationleft = quartz.system.drawing.justification.topleft + quartz.system.drawing.justification.wordbreak,
    fontJustificationcenter = quartz.system.drawing.justification.center + quartz.system.drawing.justification.wordbreak,

    -- 96, 33, 396, 58
    rectangle = { 20, 70, 640, 260 },
}

UTActivity.Ui.Title.textScoring = {

    font = UIComponent.fonts.header,
    fontColor = UIComponent.colors.red,
    fontJustification = quartz.system.drawing.justification.center + quartz.system.drawing.justification.wordbreak,

    -- 96, 33, 396, 58
    rectangle = { 20, 70, 640, 210 },
}

UTActivity.Ui.Title.scoringOffset = 0

-- __ctor --------------------------------------------------------------------

function UTActivity.Ui.Title:__ctor(...)

    assert(activity)
    
	-- animate	
	
	self.slideBegin = game.settings.UiSettings.slideBegin
	self.slideEnd = game.settings.UiSettings.slideEnd

	-- window settings

	self.uiWindow.title = l "titlemen002"

	-- client area

	self.uiPanel = self.uiWindow:AddComponent(UIPanel:New(), "uiMultiComponent")
	self.uiPanel.rectangle = self.uiWindow.clientRectangle

	self.uiPanel.rectangle[1] = self.uiPanel.rectangle[1] + UIComponent.metrics.windowMargin.left
	self.uiPanel.rectangle[2] = self.uiPanel.rectangle[2] + UIComponent.metrics.windowMargin.top
	self.uiPanel.rectangle[3] = self.uiPanel.rectangle[3] - UIComponent.metrics.windowMargin.right
	self.uiPanel.rectangle[4] = self.uiPanel.rectangle[4] - UIComponent.metrics.windowMargin.bottom

	-- first panel : rules description

    self.uiRulesPanel = self.uiPanel:AddComponent(UITitledPanel:New(), "uiRulesPanel")
    self.uiRulesPanel.title = activity.name
    self.uiRulesPanel.rectangle = { 30, 30, 685, 280 }

    if (activity.bitmap) then

        local background = self.uiRulesPanel:AddComponent(UIBitmap:New(activity.bitmap))
        local scale = (self.uiRulesPanel.rectangle[4] - self.uiRulesPanel.rectangle[2]) / background.rectangle[4]

        background.rectangle = {

            0.5 * (self.uiRulesPanel.rectangle[3] - self.uiRulesPanel.rectangle[1] - background.rectangle[3] * scale),
            self.uiRulesPanel.rectangle[2],
            self.uiRulesPanel.rectangle[3] - 0.5 * (self.uiRulesPanel.rectangle[3] - self.uiRulesPanel.rectangle[1] - background.rectangle[3] * scale),
            self.uiRulesPanel.rectangle[4],

        }

        background.Draw = function (self)

	        quartz.system.drawing.loadcolor4f(1.0, 1.0, 1.0, 0.125)
            quartz.system.drawing.loadtexture(self.bitmap)
            quartz.system.drawing.drawtexture(unpack(self.rectangle))

        end

    end

    -- second panel : rules description

    self.uiScoringPanel = self.uiPanel:AddComponent(UITitledPanel:New(), "uiRulesPanel")
    self.uiScoringPanel.title = l "titlemen003"
    self.uiScoringPanel.rectangle = { 30, 310, 685, 430 }
    
    -- buttons,

	-- uiButton1:
	-- exit activity and get back to title screen

    self.uiButton1 = self:AddComponent(UIButton:New(), "uiButton1")
    self.uiButton1.rectangle = UIMenuWindow.buttonRectangles[1]
	self.uiButton1.text = l"but003"
    self.uiButton1.tip = l"tip006"


	self.uiButton1.OnAction = function (_self) 
			quartz.framework.audio.loadsound("base:audio/ui/back.wav")
			quartz.framework.audio.loadvolume(game.settings.audio["volume:sfx"])
			quartz.framework.audio.playsound()
		
			if (activity.advertised) then game:PostStateChange("title") 
			else game:PostStateChange("selector") 
			end			
	end

    -- uiButton5:
    -- settings, but don't get there if there aren't any ...

    self.uiButton5 = self:AddComponent(UIButton:New(), "uiButton5")
    self.uiButton5.text = l"but006"
    self.uiButton5.tip = l"tip016"
    self.uiButton5.rectangle = UIMenuWindow.buttonRectangles[5]

--    if (activity.settings --[[ ?? DON'T GET TO SETTINGS IF THERE AREN'T ANY --]] or true) then

	    self.uiButton5.OnAction = function (self) 
	    
			quartz.framework.audio.loadsound("base:audio/ui/validation.wav")
			quartz.framework.audio.loadvolume(game.settings.audio["volume:sfx"])
			quartz.framework.audio.playsound()
			UTActivity.Ui.Settings.slideBegin = true
			
			activity:PostStateChange("settings") 
	    
	    end

 --   else

 --       self.uiButton5.enabled = false

--	end
	
end

-- Draw ----------------------------------------------------------------------

function UTActivity.Ui.Title:Draw()

    UIMenuWindow.Draw(self)
   
	if (self.visible) then

	    if (self.rectangle) then
	    
	        quartz.system.drawing.pushcontext()
			quartz.system.drawing.loadtranslation(self.rectangle[1], self.rectangle[2])
	        quartz.system.drawing.loadtranslation(self.uiPanel.rectangle[1] + self.uiWindow.rectangle[1], self.uiPanel.rectangle[2] + self.uiWindow.rectangle[2])

            if (activity.textRules) then

                quartz.system.drawing.pushcontext()
                quartz.system.drawing.loadtranslation(self.uiRulesPanel.rectangle[1], self.uiRulesPanel.rectangle[2] - 30)

                quartz.system.drawing.loadcolor3f(unpack(self.textRules.fontColor))
                quartz.system.drawing.loadfont(self.textRules.font)
                quartz.system.drawing.drawtextjustified(activity.textRules, self.textRules.fontJustificationleft, unpack(self.textRules.rectangle) )

                quartz.system.drawing.pop()
                
				if (activity.scoringField) then
				
					local baseY = 132
                    local offsetX = 0
					local offsetY = 0
					local rectangleIcon = {self.textRules.rectangle[1] + 80, baseY + 8 + self.scoringOffset, self.textRules.rectangle[3] + 80 , baseY + 48 + self.scoringOffset}
					
					for i, field in ipairs(activity.scoringField) do
					
						if (i == 4) then
                            offsetX = 250
                            offsetY = 0
						    rectangleIcon[2] = rectangleIcon[2] - 108
						    rectangleIcon[4] = rectangleIcon[4] - 108
                        end
                        
                        if (field[2]) then

							quartz.system.drawing.loadcolor3f(unpack(UIComponent.colors.white))
							quartz.system.drawing.loadtexture(field[2])
							quartz.system.drawing.drawtexture(40 + offsetX, baseY + offsetY + self.scoringOffset)

						end			
						
						if (field[3]) then
						
							quartz.system.drawing.loadcolor3f(unpack(self.textRules.fontColor))
							quartz.system.drawing.loadfont(self.textRules.font)
                            if (i >= 4) then
                                quartz.system.drawing.drawtextjustified(field[3], self.textRules.fontJustificationcenter, unpack(rectangleIcon) )
                            else
                                quartz.system.drawing.drawtextjustified(field[3], self.textRules.fontJustificationleft, unpack(rectangleIcon) )
                            end
						end

						rectangleIcon[2] = rectangleIcon[2] + 36
						rectangleIcon[4] = rectangleIcon[4] + 36
						offsetY = offsetY + 36
						
					end
				end
				


            end

            if (activity.textScoring) then

                quartz.system.drawing.pushcontext()
                quartz.system.drawing.loadtranslation(self.uiScoringPanel.rectangle[1], self.uiScoringPanel.rectangle[2] - 20)

                quartz.system.drawing.loadcolor3f(unpack(self.textScoring.fontColor))
                quartz.system.drawing.loadfont(self.textScoring.font)
                quartz.system.drawing.drawtextjustified(activity.textScoring, self.textScoring.fontJustification, unpack(self.textScoring.rectangle))
                
                quartz.system.drawing.pop()

            end

            quartz.system.drawing.pop()

        end

    end

end
