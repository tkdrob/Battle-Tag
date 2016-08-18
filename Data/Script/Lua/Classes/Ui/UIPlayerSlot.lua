
--[[--------------------------------------------------------------------------
--
-- File:            UIPlayerSlot.lua
--                  Copyright (c) Ubisoft Entertainment. All rights reserved.
--
-- Project:         Ubitoys.Tag
-- Date:            September 02, 2010
--
------------------------------------------------------------------------------
--
-- Description:     ...
--
----------------------------------------------------------------------------]]

--[[Dependencies -----------------------------------------------------------]]

	require "UTTeam"
	require "Ui/UIMoreButton"
    require "Ui/UIContextualMenu"

--[[ Class -----------------------------------------------------------------]]

UTClass.UIPlayerSlot(UIMultiComponent)

-- default

-- __ctor --------------------------------------------------------------------

function UIPlayerSlot:__ctor(...)

	-- main panel
		self.uiMainPanel = self:AddComponent(UIPanel:New(), "uiMainPanel")
		self.uiMainPanel.color = UIComponent.colors.white
		self.uiMainPanel.rectangle = { 0, 0, 300, UIPlayerSlotGrid.horizontalPadding - 1 }
		self.uiMainPanel.background = "base:texture/ui/components/UIPanel02.tga"

	-- right panel
		self.uiRightPanel = self:AddComponent(UIPanel:New(), "uiRightPanel")
		self.uiRightPanel.color = UIComponent.colors.lightgray
		self.uiRightPanel.rectangle = { 255, 0, 300, UIPlayerSlotGrid.horizontalPadding - 1 }
		self.uiRightPanel.background = "base:texture/ui/components/UIPanel12.tga"

	-- left panel
		self.uiLeftPanel = self:AddComponent(UIPanel:New(), "uiLeftPanel")
		self.uiLeftPanel.color = UIComponent.colors.lightgray
		self.uiLeftPanel.rectangle = { 0, 0, 80, UIPlayerSlotGrid.horizontalPadding - 1 }
		self.uiLeftPanel.background = "base:texture/ui/components/UIPanel13.tga"

	-- more button
		self.uiButton = self:AddComponent(UIMoreButton:New(), "uiButton")
		self.uiButton:MoveTo( 245 + UIPlayerSlotGrid.slots , -4 )
		self.uiButton.rectangle = { 245 + UIPlayerSlotGrid.slots, 0, 246 + UIPlayerSlotGrid.slots + UIPlayerSlotGrid.horizontalPadding, UIPlayerSlotGrid.horizontalPadding - 1 }

		self.uiButton.visible = false
		self.uiButton.tip = l"tip045"

	-- no player
		self.player = nil

	-- icon or button ?
		self.icon = nil

	-- updating

	self.updating = false
	self._ProfileUpdated = UTEvent:New()

end

-- __dtor --------------------------------------------------------------------

function UIPlayerSlot:__dtor()

	if (self.player) then self.player._ProfileUpdated:Remove(self, self.OnProfileUpdated)
	end

end

-- Draw ----------------------------------------------------------------------

function UIPlayerSlot:Draw()

	-- father

	UIComponent.Draw(self)

	if (self.player) then

		quartz.system.drawing.pushcontext()
        quartz.system.drawing.loadtranslation(unpack(self.rectangle))

		-- player information

			-- icon
			if (self.player.profile.icon) then

				local rectangle = { 1, -5, 44, 40 }
				quartz.system.drawing.loadcolor3f(unpack(UIComponent.colors.white))
				
				--get avatar
				if (self.player.profile.team and self.player.profile.team > 0) then
					-- team default
					if (0 < #activity.teams) then
						--get indicator
						if (game.settings.UiSettings.teamribbon > 0) then
							rectangle = { 81, UIPlayerSlotGrid.horizontalPadding - 5, 161, UIPlayerSlotGrid.horizontalPadding - 2 }
							quartz.system.drawing.loadtexture("base:texture/ui/Team_" .. self.player.profile.team .. "_icon.tga")
							quartz.system.drawing.drawtexture(unpack(rectangle))
						end
					end
					-- Sets the Circle Size for Team Ribbons
					rectangle = { -11 + UIPlayerSlotGrid.playeroffset + math.min(3 * (UIPlayerSlotGrid.slots - 9), 24) - math.max(math.min(UIPlayerSlotGrid.slots - 9, 12), 0) , -1, -11 + UIPlayerSlotGrid.playeroffset + math.min(3 * (UIPlayerSlotGrid.slots - 9), 24) + math.max (math.min(UIPlayerSlotGrid.slots - 9, 12), 0) + UIPlayerSlotGrid.horizontalPadding - 1, UIPlayerSlotGrid.horizontalPadding - 1 }
					if (game.settings.UiSettings.teamribbon == 2 and self.player.profile.team > 0) then
						quartz.system.drawing.loadtexture("base:texture/ui/pictograms/48x/Team_" .. self.player.profile.team .. "_Circle.tga")
						quartz.system.drawing.drawtexture(unpack(rectangle))
					end
				end
				-- Sets the icon position and size --
				rectangle = { -17 + UIPlayerSlotGrid.playeroffset + math.min(3 * (UIPlayerSlotGrid.slots - 9), 24), -6, -17 + UIPlayerSlotGrid.playeroffset + math.min(3 * (UIPlayerSlotGrid.slots - 9), 24) + UIPlayerSlotGrid.horizontalPadding + 12, UIPlayerSlotGrid.horizontalPadding + 6 }								
				quartz.system.drawing.loadtexture("base:texture/avatars/80x/" .. self.player.profile.icon)
				quartz.system.drawing.drawtexture(unpack(rectangle))

			end

			-- hud

			local rectangle = { 34, -5, 79, 40 }
			quartz.system.drawing.loadcolor3f(unpack(UIComponent.colors.white))
			if (self.player.rfGunDevice and not self.player.rfGunDevice.timedout) then
				quartz.system.drawing.loadtexture("base:texture/ui/pictograms/64x/Hud_" .. self.player.rfGunDevice.classId .. ".tga")
			else
				quartz.system.drawing.loadtexture("base:texture/ui/pictograms/64x/Hud_guest.tga")			
			end
  			rectangle = { 90 - UIPlayerSlotGrid.slots - UIPlayerSlotGrid.horizontalPadding, -3, 94 - UIPlayerSlotGrid.slots, 3 + UIPlayerSlotGrid.horizontalPadding }

			quartz.system.drawing.drawtexture(unpack(rectangle))

			-- name

			local numb = {5, 5, 5, 5, 5, 5, 5, 5, 5, 7, 7, 5, 4, 3, 3, 3, 2, 2, 1, 1, 0, 0, -1, -2, -4, -4, -4, -4, -4, -4, -4, -4}
			local rectangle = { 85, numb[UIPlayerSlotGrid.slots] }
			quartz.system.drawing.loadfont(UIComponent.fonts.header)
			quartz.system.drawing.loadcolor3f(unpack(UIComponent.colors.darkgray))
			quartz.system.drawing.drawtext(self.player.profile.name, rectangle[1], rectangle[2] )

			-- icon
			if (self.icon) then

				local rectangle = { 262, 2, 294, 34 }
				quartz.system.drawing.loadcolor3f(unpack(UIComponent.colors.white))
				quartz.system.drawing.loadtexture(self.icon)
				rectangle = { 262, 0, 262 + UIPlayerSlotGrid.horizontalPadding - 1, UIPlayerSlotGrid.horizontalPadding - 1 }
				quartz.system.drawing.drawtexture(unpack(rectangle))

			end
			if (self.player.secondary) then
				local rectangle = { 39, 0, 49, 10 }
				quartz.system.drawing.loadcolor3f(unpack(UIComponent.colors.white))
				quartz.system.drawing.loadtexture("base:texture/ui/icons/32x/dual_guns.tga")	
				quartz.system.drawing.drawtexture(unpack(rectangle))
			end
		quartz.system.drawing.pop()
		
		local numb = {32, 32, 32, 32, 32, 32, 32, 32, 32, 40, 28, 32, 32, 28, 25, 24, 22, 22, 22, 21, 20, 20, 20, 17, 17, 17, 17, 14, 14, 14, 14, 14}
		
		-- draw class icon
	
		if (self.player.class) then
	
			quartz.system.drawing.pushcontext()
			quartz.system.drawing.loadtranslation(unpack(self.rectangle))
	
			local rectangle = { 215, 1, 215 + numb[UIPlayerSlotGrid.slots], 1 + numb[UIPlayerSlotGrid.slots] }
			quartz.system.drawing.loadcolor3f(unpack(UIComponent.colors.white))
			local curClass = {"Soldier", "Sniper", "Heavy", "Stealth", "Medic", "Munitions", "Birthday"}
			quartz.system.drawing.loadtexture("base:texture/ui/Icons/32x/" .. curClass[self.player.class] .. ".tga")
			quartz.system.drawing.drawtexture(unpack(rectangle))
			quartz.system.drawing.pop()
	
		end
		
		-- draw handicap icon
	
		if (self.player.handicapped) then
	
			quartz.system.drawing.pushcontext()
			quartz.system.drawing.loadtranslation(unpack(self.rectangle))
	
			local rectangle = { 215, 1, 215 + numb[UIPlayerSlotGrid.slots], 1 + numb[UIPlayerSlotGrid.slots] }
			quartz.system.drawing.loadcolor3f(unpack(UIComponent.colors.white))
			quartz.system.drawing.loadtexture("base:texture/ui/Icons/32x/Handicap.tga")
			quartz.system.drawing.drawtexture(unpack(rectangle))
			quartz.system.drawing.pop()
	
		end

	end

end

-- DisplayButton -------------------------------------------------------------

function UIPlayerSlot:DisplayButton()

	self.uiButton.visible = true
	self.uiButton.OnAction = function ()

		-- contextual menu 
		local mouse = UIManager.stack.mouse.cursor
		local menu =  UIMenuManager.stack.top:AddComponent(UIContextualMenu:New(mouse.x - 40, mouse.y), "uiContextualMenu")
		
		if (not self.player.rfGunDevice.timedout) then
			local item = {
				text = l"pop001",
				tip = l"tip053",
				action = function (_self)
	
					local ui = UTGame.Ui.Associate:New(self.player)
					UIManager.stack:Push(ui)
	
				end
			}
			menu:AddItem(item)
		end

		-- change team

		if (0 < #activity.teams) then

			for i = 1, #activity.teams do

				if (self.player.team.index ~= i) then

					item = {
						text = activity.teams[i].profile.name,
						tip = l"tip126",
						action = function (_self) activity.states["playersmanagement"]:ChangeTeam(self.player, i) end
					}
					menu:AddItem(item)

				end

			end

		end
		
		-- classes

		if (activity.advancedsettings.classes) then
		
			for i = 1, 7 do
				if (self.player.class ~= i) then
					local textnumb = {l"oth104", l"oth105", l"oth106", l"oth107", l"oth108", l"oth109", l"oth110"}
					local tipnumb = {l"tip210", l"tip211", l"tip212", l"tip213", l"tip216", l"tip217", l"tip218"}
					item = {
						text = textnumb[i],
						tip = tipnumb[i],
						action = function (_self) 
							self.player.class = i
						end
					}
					menu:AddItem(item)
				end
			end
		else
			-- handicapped/not handicapped
	
			if (activity.handicap) then
				if (self.player.handicapped) then
		
					item = {
						text = l"oth101",
						tip = l"tip191",
						action = function (_self) 
							self.player.handicapped = false 
						end
					}
					menu:AddItem(item)
		
				else
		
					item = {
						text = l"goption044",
						tip = l"tip192",
						action = function (_self) 
							self.player.handicapped = true 
						end
					}
					menu:AddItem(item)
		
				end
			end
		end
		
		-- unregister
		
		item = {
			text = l"pop005",
			tip = l"",
			action = function (_self) 
				engine.libraries.usb.proxy:Unregister(self.player.rfGunDevice, "user deleted")
			end
		}
		menu:AddItem(item)

		-- profiles

		if (not self.player.rfGunDevice) then
			item = {
				text = l"pop003",
				tip = l"tip055",
				action = function (_self) activity.states["playersmanagement"]:DeletePlayer(self.player) end
			}
			menu:AddItem(item)
		end	
	
	end

end

-- OnProfileUpdated ----------------------------------------------------------

function UIPlayerSlot:OnProfileUpdated(player)

	if (self.player) then 
		self:DisplayButton()
		self.button = true
	end

	-- event

	self.updating = false
	self._ProfileUpdated:Invoke(self)

end

-- SetPlayer -----------------------------------------------------------------

function UIPlayerSlot:SetPlayer(player, button)

	-- profile

	if (self.player) then self.player._ProfileUpdated:Remove(self, self.OnProfileUpdated)
	end
	if (player) then 
		self.updating = true
		player._ProfileUpdated:Add(self, self.OnProfileUpdated) 
	end

	-- store player

	self.player = player 
	self.button = button
	if (player and button) then 
		self:DisplayButton()
	else
		self.uiButton.visible = false
	end

end