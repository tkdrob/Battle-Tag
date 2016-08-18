
--[[--------------------------------------------------------------------------
--
-- File:            UTActivity.Ui.IntermediateRankings.lua
--                  Copyright (c) Ubisoft Entertainment. All rights reserved.
--
-- Project:         Ubitoys.Tag
-- Date:            July 28, 2010
--
------------------------------------------------------------------------------
--
-- Description:     ...
--
----------------------------------------------------------------------------]]

--[[ Dependencies ----------------------------------------------------------]]

require "Ui/UIMenuPage"
require "Ui/UILeaderboard"

--[[ Class -----------------------------------------------------------------]]

UTActivity.Ui = UTActivity.Ui or {}
UTActivity.Ui.IntermediateRankings = UTClass(UIMenuPage)

-- __ctor -------------------------------------------------------------------

function UTActivity.Ui.IntermediateRankings:__ctor(...)

    assert(activity)

	-- panel settings

    self.uiPanel = self:AddComponent(UIPanel:New(), "uiPanel")
    self.uiPanel.background = "base:texture/ui/components/uipanel05.tga"
    self.uiPanel.rectangle = UIMenuPage.panelMargin

    self.uiPanel = self:AddComponent(UIPanel:New(), "uiPanel")
    self.uiPanel.background = "base:texture/ui/components/uipanel05.tga"
    
    -- buttons,

	-- uiButton1: quit
	
    self.uiButton1 = self:AddComponent(UIButton:New(), "uiButton1")
	self.uiButton1.rectangle = UIMenuWindow.buttonRectangles[1]
	self.uiButton1.text = l"but018"
	self.uiButton1.tip = l"tip007"

	self.uiButton1.OnAction = function (self) 
		activity:PostStateChange("end") 
		game:PostStateChange("title")
	end


	-- uiButton5: next match button 
	
    self.uiButton5 = self:AddComponent(UIButton:New(), "uiButton5")
	self.uiButton5.rectangle = UIMenuWindow.buttonRectangles[5]
	self.uiButton5.text = l"oth016"
	self.uiButton5.tip = l"tip020"
	self.uiButton5.enabled = false

	self.uiButton5.OnAction = function (self) activity:PostStateChange("matchmaking") end

    -- standard leaderboard
    -- !! with teams a visual pb may appears ....

    self.uiLeaderboard = self:AddComponent(UILeaderboard:New())
    self.uiLeaderboard:MoveTo(300, 50)
    self.uiLeaderboard.largePanel = false
	self.uiLeaderboard:RegisterField("score", nil, nil, 280, quartz.system.drawing.justification.right, UIComponent.fonts.header, UIComponent.colors.orange)
	if (0 < #activity.teams) then
		self.uiLeaderboard:Build(activity.teams, "baked")
	else
		self.uiLeaderboard:Build(activity.players, "baked")
	end

end

-- OnClose -------------------------------------------------------------------

function UTActivity.Ui.IntermediateRankings:OnClose()

    self.uiLeaderboard:RemoveDataChangedEvents()

end

-- Update -------------------------------------------------------------------

function UTActivity.Ui.IntermediateRankings:Update()

	local elapsedTime = quartz.system.time.gettimemicroseconds() - (self.time or quartz.system.time.gettimemicroseconds())
	self.time = quartz.system.time.gettimemicroseconds()
	self.updateTimer = (self.updateTimer or 0)

	if (self.updateTimer < 1000000) then

		self.updateTimer = self.updateTimer + elapsedTime
		if (self.updateTimer > 1000000) then
			for i, challenger in ipairs(activity.match.challengers) do
				activity:UpdateEntityBakedData(challenger, i)
			end
		end

		function sortBakedChallengers(c1,c2)
			if c1.data.baked.score > c2.data.baked.score then
				return true
			end
		end
		
		table.sort( activity.players, sortBakedChallengers )

	else

		if (activity.states["intermediaterankings"].isReady) then 

			self.uiButton5.enabled = true

		end

	end

end
