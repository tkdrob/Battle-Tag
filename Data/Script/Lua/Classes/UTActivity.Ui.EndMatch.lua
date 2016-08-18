
--[[--------------------------------------------------------------------------
--
-- File:            UTActivity.Ui.EndMatch.lua
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
require "Ui/UIClosingWindow"

--[[ Class -----------------------------------------------------------------]]

UTActivity.Ui = UTActivity.Ui or {}
UTActivity.Ui.EndMatch = UTClass(UIMenuPage)

-- __ctor -------------------------------------------------------------------

function UTActivity.Ui.EndMatch:__ctor(...)

	-- sort challengers by HEAP score !

	function sortHeapChallengers(c1,c2)
		if c1.data.heap.score > c2.data.heap.score then
			return true
		end
	end
	
	-- sort challengers by BAKED score !

	function sortBakedChallengers(c1,c2)
		if c1.data.baked.score > c2.data.baked.score then
			return true
		end
	end
	
	-- update baked data from heap data !

	if (activity.finalRanking) then

		for i, challenger in ipairs(activity.match.challengers) do

			activity:UpdateEntityBakedData(challenger, i)

		end

		if (0 < #activity.teams) then

			table.sort( activity.teams,	sortBakedChallengers )
			for i, team in ipairs(activity.teams) do
				table.sort( team.players, sortBakedChallengers )
			end

		end
		table.sort( activity.players, sortBakedChallengers )

	end

	-- update heap data from match !

	if (0 < #activity.teams) then

		table.sort( activity.match.challengers, sortHeapChallengers )
		for i, team in ipairs(activity.match.challengers) do
			table.sort( team.players, sortHeapChallengers )
		end

	else
		table.sort( activity.match.challengers, sortHeapChallengers )
	end
	
	-- !! compute special rankings : TODO


	-- transparency

	UIPage.transparent = true

	-- closing windows

	self.gameoverWindows = self:AddComponent(UIClosingWindow:New(), "uiClosingWindow")
	self.gameoverWindows:Build("base:texture/ui/GameOver_Top.tga", "base:texture/ui/GameOver_Bottom.tga")
	self.gameoverWindows:CloseWindow()

	-- button

	self.uiButton1 = self:AddComponent(UIButton:New(), "uiButton1")
	self.uiButton1.rectangle = { 410, 680, 547, 714 }
	self.uiButton1.text = l"but019"
	self.uiButton1.visible = false

    self.uiButton1.OnAction = function (_self) 

			-- wait for all gun to be ready before doing ANYTHING !!!

			self.uiButton1.visible = false
			
			-- start opening

			self.gameoverWindows:OpenWindow()
			self.displayGameover = false

			if (activity.finalRanking) then
				UIMenuManager.stack:Replace(UTActivity.Ui.FinalRankings)
			else
				UIMenuManager.stack:Replace(UTActivity.Ui.IntermediateRankings)
			end			
			
	end

	-- game over

	self.displayGameover = false
	self.gameoverRectangle = { 480 - 100, 360 - 20, 720 + 60, 360 + 20}

end

-- Draw -------------------------------------------------------------------

function UTActivity.Ui.EndMatch:Draw()

	UIPage.Draw(self)

	-- draw game over

	if (self.displayGameover) then

	    quartz.system.drawing.loadcolor3f(unpack(UIComponent.colors.white))
        quartz.system.drawing.loadtexture(activity.gameoverTexture)
        quartz.system.drawing.drawtexture(180, 333)
        
	end

end

-- OnClose -------------------------------------------------------------------

function UTActivity.Ui.EndMatch:OnClose()

	self.gameoverWindows._WindowClosed:Remove(self, UTActivity.Ui.EndMatch.OnWindowClosed)
	self.gameoverWindows._WindowOpened:Remove(self, UTActivity.Ui.EndMatch.OnWindowOpened)

end

-- OnOpen --------------------------------------------------------------------

function UTActivity.Ui.EndMatch:OnOpen()

	self.gameoverWindows._WindowClosed:Add(self, UTActivity.Ui.EndMatch.OnWindowClosed)
	self.gameoverWindows._WindowOpened:Add(self, UTActivity.Ui.EndMatch.OnWindowOpened)

end

-- OnWindowClosed ------------------------------------------------------------

function UTActivity.Ui.EndMatch:OnWindowClosed()

    -- animation finished
	self.displayGameover = true

end

-- OnWindowOpened ------------------------------------------------------------

function UTActivity.Ui.EndMatch:OnWindowOpened()

    -- animation finished : open final ranking or intermediate ranking ...$

	if (activity.finalRanking) then
		activity:PostStateChange("finalrankings")
	else
		activity:PostStateChange("intermediaterankings")
	end		

end

-- Update --------------------------------------------------------------------

function UTActivity.Ui.EndMatch:Update()

    local time = quartz.system.time.gettimemicroseconds()
    local elapsedTime = time - (self.time or quartz.system.time.gettimemicroseconds())
    self.time = time    

	-- update closing windows

	self.gameoverWindows:Update(elapsedTime)

	-- button

	if (self.displayGameover and activity.states["endmatch"].isReady) then
        self.uiButton1.visible = true
    end
end
