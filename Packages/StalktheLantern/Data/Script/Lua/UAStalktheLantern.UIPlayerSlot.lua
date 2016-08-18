
--[[--------------------------------------------------------------------------
--
-- File:            UAStalktheLantern.UIPlayerSlot.lua
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

UAStalktheLantern.UIPlayerSlot = UTClass(UIPlayerSlot)

-- default

-- __ctor --------------------------------------------------------------------

function UAStalktheLantern.UIPlayerSlot:__ctor(...)

end

-- DisplayButton -------------------------------------------------------------

function UAStalktheLantern.UIPlayerSlot:DisplayButton()

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

		-- defenders/stalkers

		if (self.player.defender) then

			item = {
				text = l"oth114",
				tip = l"tip126",
				action = function (_self) 
					self.player.defender = false 
				end
			}
			menu:AddItem(item)

		else

			local numberOfDefender = activity:GetDefenderNumber()
			if (numberOfDefender < math.floor(#activity.players / 6 + 1)) then

				item = {
					text = l"oth113",
					tip = l"tip126",
					action = function (_self) 
						self.player.defender = true
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

function UAStalktheLantern.UIPlayerSlot:Draw()

	UIPlayerSlot.Draw(self)

	-- draw Defender icon

	if (self.player and self.player.defender) then

		quartz.system.drawing.pushcontext()
		quartz.system.drawing.loadtranslation(unpack(self.rectangle))

		local rectangle = { 195, -15, 195 + 64, -15 + 64 }
		quartz.system.drawing.loadcolor3f(unpack(UIComponent.colors.white))
		quartz.system.drawing.loadtexture("base:texture/ui/Defender_Icon.tga")
		quartz.system.drawing.drawtexture(unpack(rectangle))

		quartz.system.drawing.pop()

	end

end

-- SetPlayer -----------------------------------------------------------------

function UAStalktheLantern.UIPlayerSlot:SetPlayer(player, button)

	UIPlayerSlot.SetPlayer(self, player, button)

	local numberOfDefender = activity:GetDefenderNumber()
	if (numberOfDefender < math.floor(#activity.players / 5) + 1) then
		player.defender = true
	end	

end