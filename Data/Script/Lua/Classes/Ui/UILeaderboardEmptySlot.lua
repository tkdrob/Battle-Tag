
--[[--------------------------------------------------------------------------
--
-- File:            UILeaderboardEmptySlot.lua
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

require "Ui/UIPanel"
require "Ui/UILabel"

--[[ Class -----------------------------------------------------------------]]

UTClass.UILeaderboardEmptySlot(UIMultiComponent)

UILeaderboardEmptySlot.color = {1, 1, 1, 0.8}

-- __ctor ------------------------------------------------------------------

function UILeaderboardEmptySlot:__ctor(leaderboard)

	local itemOffset = 0
		
    for index, item in ipairs(leaderboard.rankedList) do
    		
        if (item.challenger:IsKindOf(UTTeam)) then
			itemOffset = itemOffset + 30 + (64 * item.numplayers)
		elseif (not item.challenger.primary) then
			if (self.largePanel) then
				itemOffset = itemOffset + 80
			else
				itemOffset = itemOffset + 65
			end
		end
	end
	
	self.itemOffset = #activity.teams == 0 and itemOffset or itemOffset - 50
		
	-- calcul du nombre de slot décoratif pouvant tenir 
	
	self.nbSlotEmpty = math.floor((520 - self.itemOffset) / (50 + 15))
	
	local buttom = #activity.teams > 0 and 620 or 660
	
	self.uiSlotEmpty = {}
	self.uiSlotEmptyLabel1 = {}
	self.uiSlotEmptyLabel2 = {}
	self.uiSlotEmptyNbSquareLine = {}
	self.uiSlotEmptyNbSquareLine[1] = {}
	self.uiSlotEmptyNbSquareLine[2] = {}
	self.uiSlotEmptyNbSquareLine[3] = {}
	self.uiSlotEmptyNbSquareLine[4] = {}
	
	self.uiSlotEmptyWidthLine = {}
	self.uiSlotEmptyWidthLine[1] = {}
	self.uiSlotEmptyWidthLine[2] = {}
	self.uiSlotEmptyWidthLine[3] = {}
	self.uiSlotEmptyWidthLine[4] = {}
	
	for i = 1, self.nbSlotEmpty do
	
		self.uiSlotEmpty[i] = self:AddComponent(UIPicture:New(), "uiSlotEmpty" .. i)
		self.uiSlotEmpty[i].color = UILeaderboardEmptySlot.color
		self.uiSlotEmpty[i].texture = "base:texture/ui/Leaderboard_Boarder_Empty.tga"
		self.uiSlotEmpty[i].rectangle = {0, buttom - 80 * i, 378, buttom - 80 * i + 50}
	
		self.uiSlotEmptyLabel1[i] = self:AddComponent(UILabel:New(), "uiSlotEmpty" .. i)
		self.uiSlotEmptyLabel1[i].color = UILeaderboardEmptySlot.color
		self.uiSlotEmptyLabel1[i].text = "XW " .. math.random(9999)
		self.uiSlotEmptyLabel1[i].rectangle = {14, buttom - 80 * i, 378, buttom - 80 * i + 50}
	
		self.uiSlotEmptyLabel2[i] = self:AddComponent(UILabel:New(), "uiSlotEmpty" .. i)
		self.uiSlotEmptyLabel2[i].color = UILeaderboardEmptySlot.color
		self.uiSlotEmptyLabel2[i].text = "XW " .. math.random(9999)
		self.uiSlotEmptyLabel2[i].rectangle = {292, buttom - 80 * i + 34, 378, buttom - 80 * i + 50 + 34}
		
		self.uiSlotEmptyNbSquareLine[1][i] = {width = math.random(4), frame = math.random(8) + 4, current = 0, nbSquare = 0, position = {0, buttom - 80 * i + 20}}
		self.uiSlotEmptyNbSquareLine[2][i] = {width = math.random(4), frame = math.random(8) + 4, current = 0, nbSquare = 0, position = {0, buttom - 80 * i + 27}}
		self.uiSlotEmptyNbSquareLine[3][i] = {width = math.random(4), frame = math.random(8) + 4, current = 0, nbSquare = 0, position = {171, buttom - 80 * i + 20}}
		self.uiSlotEmptyNbSquareLine[4][i] = {width = math.random(4), frame = math.random(8) + 4, current = 0, nbSquare = 0, position = {171,buttom - 80 * i + 27}}
		
		self.uiSlotEmptyWidthLine[1][i] = {width = math.random(5), frame = math.random(100) + 100, current = 0, nbSquare = 0, position = {66, buttom - 80 * i + 20}}
		self.uiSlotEmptyWidthLine[2][i] = {width = math.random(5), frame = math.random(100) + 100, current = 0, nbSquare = 0, position = {66, buttom - 80 * i + 27}}
		self.uiSlotEmptyWidthLine[3][i] = {width = math.random(5), frame = math.random(100) + 100, current = 0, nbSquare = 0, position = {237, buttom - 80 * i + 20}}
		self.uiSlotEmptyWidthLine[4][i] = {width = math.random(5), frame = math.random(100) + 100, current = 0, nbSquare = 0, position = {237,buttom - 80 * i + 27}}
	end
	
	self.nbFrame = 0
end

-- __dtor ------------------------------------------------------------------

function UILeaderboardEmptySlot:__dtor()
end

-- Draw --------------------------------------------------------------

function UILeaderboardEmptySlot:Draw()

    -- update
    
	self.nbFrame = self.nbFrame + 1 
	
	if (self.nbFrame > 8) then
	
		for i = 1, self.nbSlotEmpty do
		
			self.uiSlotEmptyLabel1[i].text = "XW " .. math.random(9999)
			self.uiSlotEmptyLabel2[i].text = "XW " .. math.random(9999)
					
			for j = 1, 4 do
			
				local lineSquare = self.uiSlotEmptyNbSquareLine[j][i]
				
				lineSquare.current = lineSquare.current + 1
							
				if (lineSquare.current > lineSquare.frame) then
				
					self.uiSlotEmptyNbSquareLine[j][i] = {width = math.random(4), frame = math.random(8) + 4, current = 0, nbSquare = 0, position = self.uiSlotEmptyNbSquareLine[j][i].position}
					
				else
				
					lineSquare.nbSquare = lineSquare.width * lineSquare.current * (lineSquare.frame - lineSquare.current) / lineSquare.frame
					
					if (lineSquare.nbSquare > 8) then
					
						lineSquare.nbSquare = 8
						
					end			
				end	
					
			end
			
		end
		
		self.nbFrame = 0
		
	end
	
	for i = 1, self.nbSlotEmpty do
	
		for j = 1, 4 do
		
			local line = self.uiSlotEmptyWidthLine[j][i]
			
			line.current = line.current + 1
						
			if (line.current > line.frame) then
			
				self.uiSlotEmptyWidthLine[j][i] = {width = math.random(5), frame = math.random(100) + 100, current = 0, nbSquare = 0, position = self.uiSlotEmptyWidthLine[j][i].position}
				
			else
			
				line.nbSquare = 0.7 * line.width * line.current * (line.frame - line.current) / line.frame
				
				if (line.nbSquare > 50) then
				
					line.nbSquare = 50
					
				end			
			end			
		end	
						
	end
	
	-- draw
	
	for i = 1, self.nbSlotEmpty do
	
		for j = 1, 4 do
			quartz.system.drawing.loadcolor4f(unpack(UILeaderboardEmptySlot.color))
			quartz.system.drawing.loadtexture("base:texture/ui/Leaderboard_Boarder_Empty_Square.tga")
		
			for k = 1, self.uiSlotEmptyNbSquareLine[j][i].nbSquare do
						
				quartz.system.drawing.drawtexture(self.uiSlotEmptyNbSquareLine[j][i].position[1] + k * 7 + 50, self.uiSlotEmptyNbSquareLine[j][i].position[2])
			
			end
						
			quartz.system.drawing.drawtexture(self.uiSlotEmptyWidthLine[j][i].position[1] + 50, self.uiSlotEmptyNbSquareLine[j][i].position[2], self.uiSlotEmptyWidthLine[j][i].position[1] + 50 + self.uiSlotEmptyWidthLine[j][i].nbSquare, self.uiSlotEmptyNbSquareLine[j][i].position[2] + 4)
						
		end
	end
	
	UIMultiComponent.Draw(self)
end
