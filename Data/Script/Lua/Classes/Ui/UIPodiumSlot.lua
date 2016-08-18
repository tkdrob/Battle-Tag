
--[[--------------------------------------------------------------------------
--
-- File:            UIPodiumSlot.lua
--                  Copyright (c) Ubisoft Entertainment. All rights reserved.
--
-- Project:         Ubitoys.Tag
-- Date:            August 13, 2010
--
------------------------------------------------------------------------------
--
-- Description:     ...
--
----------------------------------------------------------------------------]]

--[[ Dependencies ----------------------------------------------------------]]

require "Ui/UIComponent"

--[[ Class -----------------------------------------------------------------]]

UTClass.UIPodiumSlot(UIComponent)

require "Ui/UILeaderboard"

-- default

UIPodiumSlot.medalIcons = {

    [1] = "base:texture/ui/ranking_medal_gold.tga",
    [2] = "base:texture/ui/ranking_medal_silver.tga",
    [3] = "base:texture/ui/ranking_medal_bronze.tga",

}

UIPodiumSlot.rankingPictures = {

    [1] = "base:texture/ui/Rankings_Arrow1.tga",
    [2] = "base:texture/ui/Rankings_Arrow2.tga",
    [3] = "base:texture/ui/Rankings_Arrow3.tga",

}

UIPodiumSlot.rankingPicturesSmall = {

    [1] = "base:texture/ui/Rankings_SmallArrow1.tga",
    [2] = "base:texture/ui/Rankings_SmallArrow2.tga",
    [3] = "base:texture/ui/Rankings_SmallArrow3.tga",

}

-- __ctor --------------------------------------------------------------------


function UIPodiumSlot:__ctor()
	self.rankVector = {0, 0}
end

-- __dtor --------------------------------------------------------------------

function UIPodiumSlot:__dtor()
end

-- Build ---------------------------------------------------------------------

function UIPodiumSlot:Build(challenger, nbChallenger, rank, realRank, teamPosition, teamScore)
		
	local timeStart = -0.8 + rank * 0.9
	
	self.positionY = 400
	self.nbChallenger = nbChallenger
	self.height = 140
    self.HUDoffset = 0
	self.nameOffset = { 105, -40} 
	self.scoreOffset = { 340, -40} 
	
	SlotHeight = 20
	if (MultiColumn) then
        if (#activity.teams > 2) then
            SlotHeight = 30
        end
		if (#activity.teams == 2) then 	SlotWidth = 400	end
		if (#activity.teams == 3) then	SlotWidth = 320 end
		if (#activity.teams == 4) then  SlotWidth = 250 end
	else
		-- defaults for more than 4 teams
		SlotWidth = 400
	end	
    
    if (#activity.teams == 0) then
		
		self.challenger = challenger
		if (self.nbChallenger == 1) then
			self.positionY = 200
		elseif (self.nbChallenger == 2) then
			self.positionY = 280
		else
			self.positionY = 400
		end
		
	else	
		self.team = challenger
		self.teamPosition = teamPosition
		self.teamScore = teamScore
		
		if (MultiColumn and #activity.teams > 2) then
            self.height = 15 + SlotHeight * math.max (#self.team.players, 3)
        elseif (#self.team.players > 5) then
			self.height = 15 + 20 * #self.team.players
		else
			self.height = 110
		end
		
		if (#self.team.players > 5) then
			self.positionY = 570 - #self.team.players * 30
		else
			self.positionY = 470
		end
		self.scoreOffset = { 360, -68} 
		self.nameOffset = { 110, -32} 
	end
	
	self.positionX = 1000
	self.rank = rank
	self.realRank = realRank
	self.visible = false

	self.rankVectorX = -100	
		
	self.alphaMedal = 0 
	self.scaleIcon = 1 	
		
	self.fxs = {}
	self.fxs[1] = UIManager:AddFx("callback", { timeOffset = timeStart, 
	__function = function() 
	
		quartz.framework.audio.loadsound("base:audio/ui/ranking.wav")
		quartz.framework.audio.loadvolume(game.settings.audio["volume:sfx"])
		quartz.framework.audio.playsound()
		
		self.visible = true 
	
	end})
    if (MultiColumn) then
        self.fxs[2] = UIManager:AddFx("value", { timeOffset = timeStart, duration = 0.2, __self = self, value = "rankVectorX", from = -100, to = 50 + self.rank * (SlotWidth + 20)})
	   	self.fxs[3] = UIManager:AddFx("value", { timeOffset = timeStart, duration = 0.2, __self = self, value = "positionX", from = 1000, to = -420 + self.rank * (SlotWidth + 60)})
    else
        self.fxs[2] = UIManager:AddFx("value", { timeOffset = timeStart, duration = 0.2, __self = self, value = "rankVectorX", from = -100, to = 50 + self.realRank * 40})
	    self.fxs[3] = UIManager:AddFx("value", { timeOffset = timeStart, duration = 0.2, __self = self, value = "positionX", from = 1000, to = 350 + self.realRank * 40})
    end
	self.fxs[4] = UIManager:AddFx("value", { timeOffset = timeStart + 0.2, duration = 0.1, __self = self, value = "scaleIcon", from = 0, to = 5, type = "descelerate" })
	self.fxs[5] = UIManager:AddFx("value", { timeOffset = timeStart + 0.3, duration = 0.15, __self = self, value = "scaleIcon", from = 5, to = 0, type = "accelerate" })
	self.fxs[6] = UIManager:AddFx("value", { timeOffset = timeStart + 0.45, duration = 0.2, __self = self, value = "alphaMedal", from = 0, to = 1 })
	
	if (#activity.teams == 0) then
		if (self.nbChallenger == 2) then
			self.fxs[7] = UIManager:AddFx("value", { timeOffset = timeStart + 0.7, duration = 0.3, __self = self, value = "positionY", from = self.positionY, to = self.rank * self.height , type = "accelerate"})
		elseif (self.nbChallenger > 2) then
			self.fxs[7] = UIManager:AddFx("value", { timeOffset = timeStart + 0.7, duration = 0.3, __self = self, value = "positionY", from = self.positionY, to = - 100 + self.rank * self.height , type = "accelerate"})
		end
	else
		self.fxs[7] = UIManager:AddFx("value", { timeOffset = timeStart + 0.7, duration = 0.3, __self = self, value = "positionY", from = self.positionY, to = self.teamPosition, type = "accelerate"})
	end
	if (MultiColumn) then
        UIPodiumSlot.rankingPictures = UIPodiumSlot.rankingPicturesSmall
    end
end

-- Destroy ---------------------------------------------------------------------

function UIPodiumSlot:Destroy()
	
	print("UIPodiumSlot:Destroy")

	for i, fx in ipairs(self.fxs) do
		UIManager:RemoveFx(fx)
	end

end


-- Draw --------------------------------------------------------------------

function UIPodiumSlot:Draw()

	color = UIComponent.colors.white
                    
    if (self.challenger) then
	
		if (self.realRank < 4) then
			quartz.system.drawing.loadcolor3f(unpack(color))
            quartz.system.drawing.loadtexture(self.rankingPictures[self.realRank])
			quartz.system.drawing.drawtexture(self.rankVectorX, self.positionY + 10)
		    
			quartz.system.drawing.loadalpha(self.alphaMedal)
			
			local rectIcon = {-278 + self.positionX + 10 * self.alphaMedal, -5 + self.positionY + 10 * self.alphaMedal, -150 + self.positionX - 10 * self.alphaMedal, self.positionY - 10 * self.alphaMedal + 123}

			quartz.system.drawing.loadtexture(UIPodiumSlot.medalIcons[self.realRank])
			quartz.system.drawing.drawtexture(unpack(rectIcon))
		    
			quartz.system.drawing.loadalpha(1)
		end
	    
		local rectangleLine = {self.positionX, self.positionY + 40, self.positionX + 400, self.positionY + 80}

		quartz.system.drawing.loadcolor3f(unpack(UIComponent.colors.white))
		quartz.system.drawing.loadtexture("base:texture/ui/components/uigridline_background01.tga")
		quartz.system.drawing.drawtextureh(unpack(rectangleLine))
	
		local rectangle = {self.positionX - 20, self.positionY + 10, self.positionX + 420, self.positionY + 110}
		
		quartz.system.drawing.loadcolor3f(unpack(UIComponent.colors.white))
		quartz.system.drawing.loadtexture("base:texture/ui/components/uipanel05.tga")
		quartz.system.drawing.drawwindow(unpack(rectangle))
    
		if (self.challenger.rfGunDevice and self.challenger.rfGunDevice.classId) then
			local rectangleHud = {self.positionX + 35, self.positionY + 30, self.positionX + 99, self.positionY + 94}
			quartz.system.drawing.loadtexture("base:texture/ui/pictograms/64x/Hud_" .. self.challenger.rfGunDevice.classId .. ".tga")
			quartz.system.drawing.drawtexture(unpack(rectangleHud))
		end
		
		local fontJustification = quartz.system.drawing.justification.left + quartz.system.drawing.justification.singlelineverticalcenter

		quartz.system.drawing.loadcolor3f(unpack(UIComponent.colors.darkgray))
		quartz.system.drawing.loadfont(UIComponent.fonts.title)
		quartz.system.drawing.drawtextjustified(self.challenger.profile.name, fontJustification, self.positionX + self.nameOffset[1], self.positionY + self.nameOffset[2], self.positionX + 400 + self.nameOffset[1], self.positionY + 200 + self.nameOffset[2])
	    
		if (self.challenger.data and self.challenger.data.baked and self.challenger.data.baked.score and not activity.dontDisplayScore) then
			fontJustification = quartz.system.drawing.justification.right + quartz.system.drawing.justification.singlelineverticalcenter
			quartz.system.drawing.loadcolor3f(unpack(UIComponent.colors.orange))
			quartz.system.drawing.loadfont(UIComponent.fonts.title) 
			quartz.system.drawing.drawtextjustified(self.challenger.data.baked.score, fontJustification, self.positionX + self.scoreOffset[1] - 200, self.positionY + self.scoreOffset[2], self.positionX + 40 + self.scoreOffset[1], self.positionY + 200 + self.scoreOffset[2])
		end
		
		if (game.settings.UiSettings.teamribbon == 2 and self.challenger.profile.team > 0) then
			local rectIconbackground = {-125 + self.positionX - 10 * self.scaleIcon, self.positionY - 15 - 10 * self.scaleIcon, self.positionX + 25 + 10 * self.scaleIcon, self.positionY + 135 + 10 * self.scaleIcon}
			quartz.system.drawing.loadcolor3f(unpack(UIComponent.colors.white))
			quartz.system.drawing.loadtexture("base:texture/ui/pictograms/48x/Team_" .. self.challenger.profile.team .. "_Circle.tga")
			quartz.system.drawing.drawtexture(unpack(rectIconbackground))	
		end
		
		local rectIcon = {-140 + self.positionX - 10 * self.scaleIcon, self.positionY - 40 - 10 * self.scaleIcon, self.positionX + 40 + 10 * self.scaleIcon, self.positionY + 160 + 10 * self.scaleIcon}

		quartz.system.drawing.loadcolor3f(unpack(UIComponent.colors.white))
		quartz.system.drawing.loadtexture("base:texture/avatars/256x/" .. self.challenger.profile.icon)
		
		quartz.system.drawing.drawtexture(unpack(rectIcon))
		
	elseif (self.team) then
		local numplayers = 0
		for i, player in pairs(self.team.players) do
			if (not player.primary) then
				numplayers = numplayers + 1
			end
		end
		local rectangle = {self.positionX - 20, self.positionY + 15, self.positionX + 420, self.positionY + 20 + 20 * numplayers}
        if (MultiColumn and #activity.teams > 2) then
            rectangle = {self.positionX - 20, self.positionY + 15, self.positionX + SlotWidth + 20, self.positionY + 20 + SlotHeight * numplayers}
        end
		
		quartz.system.drawing.loadcolor3f(unpack(UIComponent.colors.white))
		quartz.system.drawing.loadtexture("base:texture/ui/components/uipanel05.tga")
		quartz.system.drawing.drawwindow(unpack(rectangle))		

		local fontJustification = quartz.system.drawing.justification.left + quartz.system.drawing.justification.singlelineverticalcenter
			
		for i, player in pairs(self.team.players) do
			if (not player.primary) then
				local rectangleLine = {self.positionX, self.positionY + 20 * i, self.positionX + 400, self.positionY + 16 + 20 * i}
                if (MultiColumn and #activity.teams > 2) then
                    rectangleLine = {self.positionX, self.positionY + SlotHeight * i - SlotHeight / 2 + 5, self.positionX + SlotWidth + 10, self.positionY + SlotHeight * i + SlotHeight / 2 - 5}
                end

				quartz.system.drawing.loadcolor3f(unpack(UIComponent.colors.white))
				quartz.system.drawing.loadtexture("base:texture/ui/components/uigridline_background01.tga")
				quartz.system.drawing.drawwindow(unpack(rectangleLine))

				if (game.settings.UiSettings.teamribbon == 2 and player.profile.team > 0) then
					local rectIconbackground = {rectangleLine[1] + 28, rectangleLine[2] - 5, rectangleLine[1] + 52, rectangleLine[2] + 19}
                    if (MultiColumn and #activity.teams > 2) then
                        rectIconbackground = {rectangleLine[1] + 20, rectangleLine[2] - 5, rectangleLine[1] + 20 + SlotHeight, rectangleLine[4] + 5}
                    end
					quartz.system.drawing.loadcolor3f(unpack(UIComponent.colors.white))
					quartz.system.drawing.loadtexture("base:texture/ui/pictograms/48x/Team_" .. player.profile.team .. "_Circle.tga")
					quartz.system.drawing.drawtexture(unpack(rectIconbackground))	
				end

				local rectIcon = {rectangleLine[1] + 25, rectangleLine[2] - 8, rectangleLine[1] + 55, rectangleLine[2] + 22}
                if (MultiColumn and #activity.teams > 2) then
                    rectIcon = {rectangleLine[1] + 15, rectangleLine[2] - 8, rectangleLine[1] + 15 + SlotHeight + 10, rectangleLine[4] + 8}
                end
			
				quartz.system.drawing.loadcolor3f(unpack(UIComponent.colors.white))
				quartz.system.drawing.loadtexture("base:texture/avatars/42x/" .. player.profile.icon)
				quartz.system.drawing.drawtexture(unpack(rectIcon))
			
				if (player.rfGunDevice and player.rfGunDevice.classId) then 
				   	if (not MultiColumn or #activity.teams <= 3) then
					    local rectangleHud = {rectangleLine[1] + 74, rectangleLine[2] - 6, rectangleLine[1] + 100, rectangleLine[2] + 20}
					    quartz.system.drawing.loadcolor3f(unpack(UIComponent.colors.white))
					    quartz.system.drawing.loadtexture("base:texture/ui/pictograms/64x/hud_" .. player.rfGunDevice.classId .. ".tga")
					    quartz.system.drawing.drawtexture(unpack(rectangleHud))
                        self.HUDoffset = SlotHeight * 2
                    end
				end

				quartz.system.drawing.loadcolor3f(unpack(UIComponent.colors.darkgray))
				if (SlotWidth < 250) then 
					quartz.system.drawing.loadfont(UIComponent.fonts.default)
				else
					quartz.system.drawing.loadfont(UIComponent.fonts.header)
				end
                if (MultiColumn and #activity.teams > 2) then
                    fontJustification = quartz.system.drawing.justification.left + quartz.system.drawing.justification.singlelineverticalcenter
				    quartz.system.drawing.drawtextjustified(player.profile.name, fontJustification, rectangleLine[1] + SlotHeight + 27 + self.HUDoffset, rectangleLine[2], rectangleLine[3], rectangleLine[4])
                else
                    quartz.system.drawing.drawtextjustified(player.profile.name, fontJustification, self.positionX + self.nameOffset[1], self.positionY + self.nameOffset[2] - 75 + 20 * i, self.positionX + 400 + self.nameOffset[1], self.positionY + 155 + self.nameOffset[2] + 20 * i)
                end
			
				if (player.data and player.data.baked and player.data.baked.score and not activity.dontDisplayScore) then
					quartz.system.drawing.loadcolor3f(unpack(UIComponent.colors.orange))
					quartz.system.drawing.loadfont(UIComponent.fonts.header)
                    if (MultiColumn and #activity.teams > 2) then
                        quartz.system.drawing.drawtextjustified(player.data.baked.score, fontJustification, rectangleLine[3] - 40, rectangleLine[2], self.positionX + 610 + self.nameOffset[1], rectangleLine[4])
                    else
					    quartz.system.drawing.drawtextjustified(player.data.baked.score, fontJustification, rectangleLine[1] + self.nameOffset[1] + 220, rectangleLine[2] + self.nameOffset[2] - 60, self.positionX + 620 + self.nameOffset[1], rectangleLine[2] + 140 + self.nameOffset[2])
                    end
				end
			end
		end	
		
		local leftIconPosition = 0
		
		--if (#self.team.players >= 3) then
		
			--leftIconPosition = 15 * #self.team.players
			
		--else
		
			leftIconPosition = 30
			
		--end
	
		if (self.realRank < 4 and (game.settings.UiSettings.finalranking == 0 or MultiColumn)) then
			quartz.system.drawing.loadcolor3f(unpack(color))		
			quartz.system.drawing.loadtexture(self.rankingPictures[self.realRank])
			quartz.system.drawing.drawtexture(self.positionX - 25, self.positionY - 25, self.positionX + 45, self.positionY + 5)
		    
			quartz.system.drawing.loadalpha(self.alphaMedal)
			
			local rectIcon
			if (not MultiColumn) then 
				rectIcon = {-278 + self.positionX + 10 * self.alphaMedal, -40 + self.positionY + 10 * self.alphaMedal + leftIconPosition, -150 + self.positionX - 10 * self.alphaMedal, self.positionY + leftIconPosition - 10 * self.alphaMedal + 88}
				quartz.system.drawing.loadtexture(UIPodiumSlot.medalIcons[self.realRank])
				quartz.system.drawing.drawtexture(unpack(rectIcon))
				quartz.system.drawing.loadalpha(1)
			end
		
		end
		
		local rectScore -- Prints the Team Score at top or side of the Team Panel
		
		if (MultiColumn) then 
		 	rectScore = {self.positionX, self.positionY - 20, self.positionX + SlotWidth + 20, self.positionY}
		else
		 	rectScore = {-115 + self.positionX, self.positionY + SlotHeight + leftIconPosition, -40 + self.positionX, self.positionY + leftIconPosition + 78}
		end		
		local fontJustificationScore = quartz.system.drawing.justification.right + quartz.system.drawing.justification.singlelineverticalcenter
			
		if (self.teamScore and activity.dontDisplayScore == nil) then
		
			if (MultiColumn) then
				quartz.system.drawing.loadcolor3f(unpack(UIComponent.colors[self.team.profile.teamColor]))
				quartz.system.drawing.loadfont(UIComponent.fonts.title) 
				quartz.system.drawing.drawtextjustified(self.teamScore, fontJustificationScore, rectScore[1], rectScore[2], rectScore[3], rectScore[4])
			else
				quartz.system.drawing.loadcolor3f(unpack(UIComponent.colors.white))
				quartz.system.drawing.loadtexture("base:texture/ui/Leaderboard_score_bg.tga")
				quartz.system.drawing.drawtexture(unpack(rectScore))
		
				quartz.system.drawing.loadcolor3f(unpack(UIComponent.colors[self.team.profile.teamColor]))
				quartz.system.drawing.loadfont(UIComponent.fonts.title) 
				quartz.system.drawing.drawtextjustified(self.teamScore, fontJustificationScore, rectScore[1] - 20, rectScore[2] + 20, rectScore[1] + 65, rectScore[2] + 65)
			end		
		end
		
		local rectIcon
		-- left team border
		quartz.system.drawing.loadcolor3f(unpack(UIComponent.colors.white))
		quartz.system.drawing.loadtexture("base:texture/ui/components/UI" .. self.team.profile.teamColor .. "slot_01.tga")--self.team.profile.icon)
		quartz.system.drawing.drawtexturev(self.positionX - 25, self.positionY + 15, self.positionX - 5, self.positionY + 15 + SlotHeight * #self.team.players + 5)
		-- right team border
		quartz.system.drawing.loadcolor3f(unpack(UIComponent.colors.white))
		quartz.system.drawing.loadtexture("base:texture/ui/components/UI" .. self.team.profile.teamColor .. "slot_02.tga")--self.team.profile.icon)
		quartz.system.drawing.drawtexturev(self.positionX + SlotWidth + 16, self.positionY + 15, self.positionX + SlotWidth + 26, self.positionY + 15 + SlotHeight * #self.team.players + 5)
	
		-- Positioning the Team Icon - on side for 2 teams, above for 3 and 4 teams
		if (MultiColumn) then 
			--rectIcon = {self.positionX + SlotWidth/2 - 75, self.positionY - 50,  self.positionX + SlotWidth/2 + 75, self.positionY+20}
			rectIcon = {self.positionX + SlotWidth / 2 - 60, self.positionY - 50,  self.positionX + SlotWidth / 2 + 60, self.positionY + 20}
		else	
			rectIcon = {-150 + self.positionX - 10 * self.scaleIcon, self.positionY - 35 + leftIconPosition - 10 * self.scaleIcon, self.positionX + 18 + 10 * self.scaleIcon, self.positionY + leftIconPosition + 65 + 10 * self.scaleIcon}
		end
		quartz.system.drawing.loadcolor3f(unpack(UIComponent.colors.white))
		quartz.system.drawing.loadtexture(self.team.profile.icon)
		quartz.system.drawing.drawtexture(unpack(rectIcon))
		
	end
		
	
end
