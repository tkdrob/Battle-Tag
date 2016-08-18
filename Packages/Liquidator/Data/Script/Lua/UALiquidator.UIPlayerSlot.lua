
--[[--------------------------------------------------------------------------
--
-- File:            UALiquidator.UIPlayerSlot.lua
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

UALiquidator.UIPlayerSlot = UTClass(UIPlayerSlot)

-- default

-- __ctor --------------------------------------------------------------------

function UALiquidator.UIPlayerSlot:__ctor(...)

end

-- DisplayButton -------------------------------------------------------------

function UALiquidator.UIPlayerSlot:DisplayButton()

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

		-- liquidator/survivors

		if (self.player.liquidator) then

			item = {
				text = l"oth072",
				tip = l"tip126",
				action = function (_self) 
					self.player.liquidator = false 
				end
			}
			menu:AddItem(item)

		else

			local numberOfLiquidator = activity:GetLiquidatorNumber()
			if (numberOfLiquidator < math.floor(#activity.players / 6 + 1)) then

				item = {
					text = l"oth073",
					tip = l"tip126",
					action = function (_self) 
						self.player.liquidator = true 
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

function UALiquidator.UIPlayerSlot:Draw()

	UIPlayerSlot.Draw(self)

	-- draw liquidator icon

	if (self.player and self.player.liquidator) then

		quartz.system.drawing.pushcontext()
		quartz.system.drawing.loadtranslation(unpack(self.rectangle))

		local rectangle = { 195, -15, 195 + 64, -15 + 64 }
		quartz.system.drawing.loadcolor3f(unpack(UIComponent.colors.white))
		quartz.system.drawing.loadtexture("base:texture/ui/Liquidator_Icon.tga")
		quartz.system.drawing.drawtexture(unpack(rectangle))

		quartz.system.drawing.pop()

	end

end

-- SetPlayer -----------------------------------------------------------------

function UALiquidator.UIPlayerSlot:SetPlayer(player, button)

	UIPlayerSlot.SetPlayer(self, player, button)

	local numberOfLiquidator = activity:GetLiquidatorNumber()
	if (numberOfLiquidator < math.floor(#activity.players / 5 + 1)) then
		player.liquidator = true
	end	

end