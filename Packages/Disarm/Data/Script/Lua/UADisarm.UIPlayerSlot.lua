
--[[--------------------------------------------------------------------------
--
-- File:            UADisarm.UIPlayerSlot.lua
--                  Copyright (c) Ubisoft Entertainment. All rights reserved.
--
-- Project:         Ubitoys.Tag
-- Date:            Novmber 18, 2010
--
------------------------------------------------------------------------------
--
-- Description:     ...
--
----------------------------------------------------------------------------]]

--[[Dependencies -----------------------------------------------------------]]

    require "Ui/UIPlayerSlot"

--[[ Class -----------------------------------------------------------------]]

UADisarm.UIPlayerSlot = UTClass(UIPlayerSlot)

-- default

-- __ctor --------------------------------------------------------------------

function UADisarm.UIPlayerSlot:__ctor(...)

end

-- DisplayButton -------------------------------------------------------------

function UADisarm.UIPlayerSlot:DisplayButton()

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

		-- terrorist/commandos

		if (self.player.terrorist) then

			item = {
				text = l"oth088",
				tip = l"tip126",
				action = function (_self) 
					self.player.terrorist = false 
				end
			}
			menu:AddItem(item)

		else

			local numberOfTerrorist = activity:GetTerroristNumber()
			if (#activity.players < 6 and numberOfTerrorist <= 5 or #activity.players >= 6 and numberOfTerrorist <= 5) then

				item = {
					text = l"oth090",
					tip = l"tip126",
					action = function (_self) 
						self.player.terrorist = true 
					end
				}
				menu:AddItem(item)

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

		-- profils

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


-- Draw ----------------------------------------------------------------------

function UADisarm.UIPlayerSlot:Draw()

	UIPlayerSlot.Draw(self)

	-- draw terrorist icon

	if (self.player and self.player.terrorist) then

		quartz.system.drawing.pushcontext()
		quartz.system.drawing.loadtranslation(unpack(self.rectangle))

		local rectangle = { 195, -15, 195 + 64, -15 + 64 }
		quartz.system.drawing.loadcolor3f(unpack(UIComponent.colors.white))
		quartz.system.drawing.loadtexture("base:texture/ui/Disarm_Icon.tga")
		quartz.system.drawing.drawtexture(unpack(rectangle))

		quartz.system.drawing.pop()

	end

end

-- SetPlayer -----------------------------------------------------------------

function UADisarm.UIPlayerSlot:SetPlayer(player, button)

	UIPlayerSlot.SetPlayer(self, player, button)

	-- the 1st/6rd player ... then it's a terrorist !

	local numberOfTerrorist = activity:GetTerroristNumber()
	if (#activity.players == 1 and numberOfTerrorist < 1 or #activity.players == 6 and numberOfTerrorist < 3) then
		player.terrorist = true
	end	

end