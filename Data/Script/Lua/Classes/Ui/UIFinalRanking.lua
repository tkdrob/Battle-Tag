
--[[--------------------------------------------------------------------------
--
-- File:            UIFinalRanking.lua
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

require "Ui/UIMultiComponent"
require "Ui/UIPicture"
require "Ui/UILabel"

--[[ Class -----------------------------------------------------------------]]

UTClass.UIFinalRanking(UIMultiComponent)

	require "Ui/UIPodiumSlot"


-- __ctor --------------------------------------------------------------------

function UIFinalRanking:__ctor()

	self.uiPodiums = {}
	self.timer = 0

end

-- __dtor --------------------------------------------------------------------

function UIFinalRanking:__dtor()

    -- remove datachanged event

end

-- Build ---------------------------------------------------------------------

function UIFinalRanking:Build(challengers)

	self.challengers = challengers	
	self.width = 400 
	
	local rank = 1 
	local score = -1
	local realRank = 0
	
	self.nbChallenger = 0
	
	for i, challenger in pairs(self.challengers) do
		self.nbChallenger = self.nbChallenger + 1
	end
	
	if (#activity.teams == 0) then
				
		local bannerOffset = 0 
		
		if (self.nbChallenger > 3) then
		
			-- banner container
			
			self.uiBanner = self:AddComponent(UIMultiComponent:New(), "uiBanner")	
			self.uiBanner:MoveTo(1040, 520)
			self.uiBanner.visible = false
				
			-- banner LEFT
			
			local uiBannerLeft = self.uiBanner:AddComponent(UIPicture:New(), "uiBannerLeft")
			uiBannerLeft.rectangle = {0, 0, 64, 32}
			uiBannerLeft.texture = "base:texture/ui/ranking_banner_endbg.tga"
			uiBannerLeft:MoveTo(-64, 15)
			
			-- banner LINE

			local uiBannerLine = self.uiBanner:AddComponent(UIPicture:New(), "uiBannerLine")
			uiBannerLine.rectangle = {0, 0, self.width * (self.nbChallenger - 3) - 64, 32}
			uiBannerLine.texture = "base:texture/ui/ranking_banner_middlebg.tga"
			uiBannerLine:MoveTo(0, 15)
			
			-- banner RIGHT
			
			local uiBannerRight = self.uiBanner:AddComponent(UIPicture:New(), "uiBannerRight")
			uiBannerRight.rectangle = {0, 0, 64, 32}
			uiBannerRight.texture = "base:texture/ui/ranking_banner_startbg.tga"
			uiBannerRight:MoveTo(self.width * (self.nbChallenger - 3) - 64, 15)
			
			-- banner apparait au bout de 3 secondes
			
			UIManager:AddFx("callback", { timeOffset = 3, __function = function() self.uiBanner.visible = true end})
	
		end
		
		for i, challenger in pairs(self.challengers) do
		
			if (not challenger.primary) then
				if (rank <= 3) then
				
					if (score == - 1 or score > challenger.data.baked.score) then
						score = challenger.data.baked.score
						realRank = realRank + 1
					end 
				
					self.uiPodiums[rank] = self:AddComponent(UIPodiumSlot:New(), "uiFinalRanking.Podium" .. rank)				
					self.uiPodiums[rank]:Build(challenger, self.nbChallenger, rank, realRank)
			
				else
			
					-- banner player
			
					local uiBannerPosition = self.uiBanner:AddComponent(UIPicture:New(), "uiBannerPosition")
					uiBannerPosition.rectangle = {0, 0, 64, 22}
					uiBannerPosition.texture = "base:texture/ui/ranking_banner_position.tga"
				
					local uiPosition = self.uiBanner:AddComponent(UILabel:New({0, 0, 100, 64}, challenger.profile.name), "uiPosition")
					uiPosition.fontColor = UIComponent.colors.white
					uiPosition.font = UIComponent.fonts.header				
					uiPosition.text = rank .. "th"
			
					local uiBannerName1 = self.uiBanner:AddComponent(UIPicture:New(), "uiBannerLine1")
					uiBannerName1.rectangle = {0, 0, 70, 22}
					uiBannerName1.texture = "base:texture/ui/ranking_banner_namebg.tga"
				
					local uiBannerName2 = self.uiBanner:AddComponent(UIPicture:New(), "uiBannerLine2")
					uiBannerName2.rectangle = {0, 0, 70, 22}
					uiBannerName2.texture = "base:texture/ui/ranking_banner_namebg.tga"
				
					local uiBannerName3 = self.uiBanner:AddComponent(UIPicture:New(), "uiBannerLine3")
					uiBannerName3.rectangle = {0, 0, 70, 22}
					uiBannerName3.texture = "base:texture/ui/ranking_banner_namebg.tga"
				
					local uiBannerName4 = self.uiBanner:AddComponent(UIPicture:New(), "uiBannerLine4")
					uiBannerName4.rectangle = {0, 0, 70, 22}
					uiBannerName4.texture = "base:texture/ui/ranking_banner_namebg.tga"
				
					local uiBannerName5 = self.uiBanner:AddComponent(UIPicture:New(), "uiBannerLine5")
					uiBannerName5.rectangle = {0, 0, 70, 22}
					uiBannerName5.texture = "base:texture/ui/ranking_banner_namebg.tga"
				
				
					local uiBannerIcon = self.uiBanner:AddComponent(UIPicture:New(), "uiBannerIcon")
					uiBannerIcon.rectangle = {0, 0, 60, 22}
					uiBannerIcon.texture = "base:texture/ui/ranking_banner_arrow.tga"
				
					local uiIconbackground = self.uiBanner:AddComponent(UIPicture:New(), "uiIconbackground")
					uiIconbackground.texture = "base:texture/ui/pictograms/48x/Team_" .. challenger.profile.team .. "_Circle.tga"
					if (game.settings.UiSettings.teamribbon == 2 and challenger.profile.team > 0) then
						uiIconbackground.rectangle = {0, 0, 32, 32}
					else
						uiIconbackground.rectangle = nil
					end
					
					local uiIcon = self.uiBanner:AddComponent(UIPicture:New(), "uiIcon")
					uiIcon.rectangle = {0, 0, 32, 32}
					uiIcon.texture = "base:texture/avatars/32x/" .. challenger.profile.icon			
				
				
					if (challenger.rfGunDevice and challenger.rfGunDevice.classId) then
				
						local uiIconGun = self.uiBanner:AddComponent(UIPicture:New(), "uiIconGun")
						uiIconGun.rectangle = {0, 0, 32, 32}
						uiIconGun.texture = "base:texture/ui/pictograms/64x/Hud_" .. challenger.rfGunDevice.classId .. ".tga"
						uiIconGun:MoveTo(bannerOffset + 105, 15)
					
					end
				
					local uiName = self.uiBanner:AddComponent(UILabel:New({0, 0, 140, 64}, challenger.profile.name), "uiName")
					uiName.fontColor = UIComponent.colors.darkgray
					uiName.font = UIComponent.fonts.header
				
					local uiScore = nil
				
					-- pas de score pour le survivant
				
					if (not activity.dontDisplayScore) then
						uiScore = self.uiBanner:AddComponent(UILabel:New({0, 0, 100, 64}, challenger.data.baked.score), "uiScore")
						uiScore.fontColor = UIComponent.colors.orange
						uiScore.font = UIComponent.fonts.header
					end
				
					uiBannerPosition:MoveTo(bannerOffset - 10, 20)
					uiBannerName1:MoveTo(bannerOffset + 80, 20)
					uiBannerName2:MoveTo(bannerOffset + 130, 20)
					uiBannerName3:MoveTo(bannerOffset + 180, 20)
					uiBannerName4:MoveTo(bannerOffset + 230, 20)
					uiBannerName5:MoveTo(bannerOffset + 280, 20)
					uiBannerIcon:MoveTo(bannerOffset + 55, 20)
					uiPosition:MoveTo(bannerOffset, 20)
					uiIconbackground:MoveTo(bannerOffset + 65, 14)
					uiIcon:MoveTo(bannerOffset + 65, 15)
					uiName:MoveTo(bannerOffset + 140, 20)
				
					if (uiScore) then
						uiScore:MoveTo(bannerOffset + 280, 20)
					end
		    
					bannerOffset = bannerOffset + self.width
				
				end
				
				rank = rank + 1
			end
			
		end

	else
		
		local teamPosition = 10
		for i, challenger in pairs(self.challengers) do
								
			if (#challenger.players > 0) then
				if (score == -1 or score > challenger.data.baked.score) then
					score = challenger.data.baked.score
					realRank = realRank + 1
				end
                if (MultiColumn) then
                    teamPosition = realRank * 50
                end
			
				self.uiPodiums[rank] = self:AddComponent(UIPodiumSlot:New(), "uiFinalRanking.Podium" .. rank)
				self.uiPodiums[rank]:Build(challenger, self.nbChallenger, rank, realRank, teamPosition, challenger.data.baked.score)
                if not(MultiColumn) then
                    teamPosition = teamPosition + self.uiPodiums[rank].height
                end
				
				rank = rank + 1
			end
		end
					
	end

end

-- Destroy --------------------------------------------------------------------

function UIFinalRanking:Destroy()

	for i, uiPodium in ipairs(self.uiPodiums) do
		uiPodium:Destroy()
	end
	
end

-- Draw --------------------------------------------------------------------

function UIFinalRanking:Draw()

	UIComponent.Draw(self)
end

-- Update --------------------------------------------------------------------

function UIFinalRanking:Update()

	if ( self.nbChallenger > 3 and self.uiBanner and self.uiBanner.visible) then	
	
		local elapsedTime = quartz.system.time.gettimemicroseconds() - self.timer
		self.timer = quartz.system.time.gettimemicroseconds()

		-- movement

		self.uiBanner.rectangle[1] = self.uiBanner.rectangle[1] - (0.0002 * elapsedTime)
		self.uiBanner.rectangle[3] = self.uiBanner.rectangle[3] - (0.0002 * elapsedTime)

		-- when out of screen, then must restart

		if (self.uiBanner.rectangle[1] < - (128 + (self.nbChallenger - 3) * self.width )) then
			self.uiBanner.rectangle[1] = 1240
			self.uiBanner.rectangle[3] = 1340
		end
	end

end