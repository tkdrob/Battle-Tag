
--[[--------------------------------------------------------------------------
--
-- File:			UADisarm.lua
--                  Copyright (c) Ubisoft Entertainment. All rights reserved.
--
-- Project:         Ubitoys.Tag
-- Date:            November 18, 2010
--
------------------------------------------------------------------------------
--
-- Description:     test activity
--
----------------------------------------------------------------------------]]

--[[ Dependencies ----------------------------------------------------------]]

require "UTActivity"

--[[ Class -----------------------------------------------------------------]]

UTClass.UADisarm(UTActivity)

-- state dependencies

UADisarm.State = {}

	require "UADisarm.State.RoundLoop"
	require "UADisarm.UIPlayerSlot"

-- default

UADisarm.bitmap = "base:texture/ui/Loading_Disarm.tga"

UADisarm.minNumberOfPlayer = 3

UADisarm.playerSlot = UADisarm.UIPlayerSlot

UADisarm.numberOfTerrorist = 0

-- __ctor --------------------------------------------------------------------

function UADisarm:__ctor(...)

	-- activity name

    self.name = l"title019"
    self.category = UTActivity.categories.closed

	self.dontDisplayScore = true
    self.textScoring = l"score013"
    self.Ui.Title.textScoring.rectangle = { 20, 50, 640, 210 }
    self.Ui.Title.scoringOffset = 40
    self.textRules = l"rules015"
    self.iconBanner = "base:texture/ui/Ranking_Bg_Disarm.tga"

	-- scoringField

    self.scoringField = {
		{"hit", "base:texture/ui/icons/32x/hit.tga", l"iconrules004"},
		{"death", "base:texture/ui/icons/32x/death.tga", l"iconrules003"},
		{"lifePoints", "base:texture/ui/icons/32x/heart.tga", l"iconrules002"},
		--{"score", nil, nil, 280, quartz.system.drawing.justification.right, UIComponent.fonts.header, UIComponent.colors.orange},
	}
	
    -- settings

    self.settings = {

        [1] = { title = l"titlemen006", options = {

            [1] = { displayMode = nil, label = l"goption001", tip = l"tip114", choices = { { value = 5 }, { value = 10 }, { value = 15 }, { value = 20 }, { value = 25 }, { value = 30 } }, index = "playtime", },
			[2] = { label = l"goption043", tip = l"tip234", choices = { { value = 0, displayMode = "medium", text = l"oth111" }, { value = 1, displayMode = "medium", text = l"oth112" } }, index = "wincondition", },

            },
        },

        [2] = { title = l"titlemen024", options = {

            [1] = { label = l"goption006", tip = l"tip115", choices = { { value = 6 }, { value = 9 }, { value = 12 }, { value = 12 }, { value = 15 }, { value = 18 } }, index = "lifePointsTerrorist", },
            [2] = { label = l"goption004", tip = l"tip028", choices = { { value = 255, text = "", icon = "base:texture/ui/components/uiradiobutton_infinity.tga" } }, index = "ammunitionsTerrorist", },
            [3] = { displayMode = nil, label = l"goption013", tip = l"tip041", choices = { { value = 0, displayMode = "medium", text = l"oth076" }, { value = 1, displayMode = "medium", text = l"oth075" } }, index = "teamFragTerrorist", },
	    	[4] = { label = l"goption023", tip = l"tip134", choices = { { value = 1 }, { value = 2 }, { value = 3 }, { value = 4 } }, index = "firstdigit", },
	  	 	[5] = { label = l"goption024", tip = l"tip135", choices = { { value = 1 }, { value = 2 }, { value = 3 }, { value = 4 } }, index = "seconddigit", },
 	   	 	[6] = { label = l"goption025", tip = l"tip136", choices = { { value = 1 }, { value = 2 }, { value = 3 }, { value = 4 } }, index = "thirddigit", },
			[7] = { label = l"goption060", tip = l"tip233", choices = { { value = 1 }, { value = 2 }, { value = 3 }, { value = 4 } }, index = "fourthdigit", },
 	   	 	[8] = { label = l"goption016", tip = l"tip141", choices = { { value = 3 }, { value = 5 }, { value = 8 }, { value = 10 }, { value = 12 }, { value = 15 } }, index = "invulnerabilityTimeTerrorist", },
	     
            },
        },
        
        [3] = { title = l"titlemen025", options = {        

            [1] = { label = l"goption004", tip = l"tip028", choices = { { value = 6 }, { value = 9 }, { value = 12 }, { value = 15 }, { value = 18 } }, index = "ammunitionsCommando", },
            [2] = { label = l"goption005", tip = l"tip118", choices = { { value = 1 }, { value = 2 }, { value = 3 }, { value = 4 }, { value = 5 }, { value = 6 } }, index = "clipsCommando", },
            [3] = { label = l"goption006", tip = l"tip119", choices = { { value = 3 }, { value = 5 }, { value = 6 }, { value = 7 }, { value = 8 }, { value = 9 } }, index = "lifePointsCommando", },
            [4] = { label = l"oth071", tip = l"tip123", choices = { { value = 5 }, { value = 10 }, { value = 15 }, { value = 20 }, { value = 25 }, { value = 30 } }, index = "timePenality", },
            [5] = { displayMode = nil, label = l"goption013", tip = l"tip041", choices = { { value = 0, displayMode = "medium", text = l"oth076" }, { value = 1, displayMode = "medium", text = l"oth075" } }, index = "teamFragCommando", },
            [6] = { displayMode = nil, label = l"goption007", tip = l"tip040", choices = { { value = 0, displayMode = "medium", text = l"oth076" }, { value = 1, displayMode = "medium", text = l"oth082" }, { value = 2, displayMode = "medium", text = l"oth111" } }, index = "swap", },
            [7] = { displayMode = nil, label = l"goption028", tip = l"tip140", choices = { { value = 0, displayMode = "medium", text = l"oth076" }, { value = 10 }, { value = 15 }, { value = 20 }, { value = 25 }, { value = 30 } }, index = "respawntimer", },
            [8] = { displayMode = nil, label = l"goption061", tip = l"tip235", choices = { { value = false, displayMode = "medium", text = l"oth076" }, { value = true, displayMode = "medium", text = l"oth075" } }, index = "retry", },
            
            },
        },        

        -- keyed settings

	    playtime = 5,       
        ammunitionsTerrorist = 255,
		wincondition = 1,
        ammunitionsCommando = 9,
        clipsCommando = 5,
        lifePointsTerrorist = 15,
        lifePointsCommando = 3,
        swap = 0,
        numberOfTeams = 0,
        teamFragTerrorist = 0,
        teamFragCommando = 0,
        timePenality = 10,
		firstdigit = 1,
		seconddigit = 2,
		thirddigit = 3,
		fourthdigit = 4,
		respawntimer = 15,
		invulnerabilityTimeTerrorist = 5,
		retry = true,

    }

    -- playground
    -- !! TABLE FORMAT : { [numberofplayer] = { ["ITEM_BITMAP"] = { category = "string", priority = number, size = number, positions = { { number, number }, ... }, title = "string", text = "string", condition = function() }, ... }

    self.playground = {

        [1] = { 

            RedArea = { priority = 20, size = 128, text = string.format(l"psexp046"), positions = { { 480, 150 }, }, },
            BlueArea = { priority = 20, size = 128, text = string.format(l"psexp045"), positions = { { 50, 150 }, }, },

            RF01 = { category = "Ammo", title = l"goption010", text = string.format(l"psexp014"), positions = { { 200, 50 }, }, condition = function (self) return (255 ~= activity.settings.ammunitions) end },
            RF02 = { category = "Ammo2", title = l"goption010", text = string.format(l"psexp014"), positions = { { 200, 250 }, }, condition = function (self) return (255 ~= activity.settings.ammunitions) end },
            RF03 = { priority = 1, title = l"oth056" ..  " (" .. l"oth027" .. ")", text = string.format(l"psexp054"), positions = { { 50, 150 }, }, },
            RF04 = { priority = 2, title = l"oth057" ..  " (" .. l"oth028" .. ")", text = string.format(l"psexp047"), positions = { { 480, 130 }, }, },
            RF05 = { priority = 3, title = l"oth058" ..  " (" .. l"oth029" .. ")", text = string.format(l"psexp047"), positions = { { 480, 160 }, }, },
            RF06 = { priority = 4, title = l"oth059" ..  " (" .. l"oth030" .. ")", text = string.format(l"psexp047"), positions = { { 480, 190 }, }, },
            RF07 = { category = "Med-Kit", title = l"goption009", text = string.format(l"psexp015"), positions = { { 330, 50 }, }, condition = function (self) return (1 == game.settings.addons.medkitPack) end },
            RF08 = { category = "Med-Kit2", title = l"goption009", text = string.format(l"psexp015"), positions = { { 330, 250 }, }, condition = function (self) return (1 == game.settings.addons.medkitPack) end },
			RF14 = { priority = 1, title = l"oth056" ..  " (" .. l"oth027" .. ")", text = string.format(l"psexp047"), positions = { { 480, 100 }, }, },
        },
    }

    -- ?? CONFIG DATA SEND WITH RF 

    self.configData = {

		"lifePoints",
		"ammunitions",
		"clips",
		"swap",
		"terrorist",
		"teamFrag",
		"medkit",
		"respawntimer",
		"invulnerabilityTimeTerrorist",

    }    
    
	-- details columms descriptor

	self.detailsDescriptor = {
		information = {
			{key = "detailsScore", icon = "base:texture/ui/Icons/32x/score.tga", tip = l"tip072" },
			{key = "detailAccuracy", icon = "base:texture/ui/Icons/32x/precision.tga", tip = l"tip073" }
		},
		details = {
			{key = "detailsTeam", width = 55, style = UIGridLine.ImageCellStyle:New(35, 10), preferredHeight = 10, preferredWidth = 35},
			{key = "name", width = 130, style = UIGridLine.RowTitleCellStyle},
			{key = "hitByName", width = 75, style = UIGridLine.RowTitleCellStyle, icon = "base:texture/ui/Icons/32x/Hit.tga", tip = l"tip068"},
			{key = "killByName", width = 50, style = UIGridLine.RowTitleCellStyle, icon = "base:texture/ui/Icons/32x/Death.tga", tip = l"tip070"},
		}
	}

    -- overriden states

    self.states["roundloop"] = UADisarm.State.RoundLoop:New(self)
    
    -- ?? LES SETTINGS SONT RENSEIGN�S DANS LE CONSTRUCTEUR DE L'ACTIVIT�
    -- ?? LES PARAM�TRES (DISPLAYMODE, TEXTE, ICONE...) DES COLONES DE GRID SONT RENSEIGN�S DANS LE COMPOSANT D�DI� DU LEADERBOARD
    -- ?? LES ATTRIBUTS - HEAP, BAKED - DES ENTIT�S SONT RENSEIGN�S PAR 2 APPELS DE FONCTION D�DI�S DANS L'ACTIVIT� (� SURCHARGER)
    -- ?? POUR LES DONN�ES DE CONFIGURATION DE BYTECODE, CE SERA SUREMENT PAREIL QUE POUR LES ATTRIBUTS = FONCTION D�DI� (� SURCHARGER)
    -- ?? POUR LE LEADERBOARD:
    -- ??       - SURCHARGER LA PAGE QUI UTILISE LE LEADERBOARD STANDARD,
    -- ??       - RAJOUTER DES PARAM�TRES (DISPLAYMODE, TEXTE, ICONE...) DES COLONES DE GRID SI N�CESSAIRE EN + DE CEUX PAR D�FAUT (LIFE, HIT, AMMO...)
    -- ??       - RENSEIGNER QUELS ATTRIBUTS ON SOUHAITE REPR�SENTER PARMIS CEUX EXISTANT EN HEAP

end

-- __dtor --------------------------------------------------------------------

function UADisarm:__dtor()
end

-- Check ---------------------------------------------------------------------

function UADisarm:Check()

	-- check number of terrorist

	local numberOfTerrorist = self:GetTerroristNumber()
	local numplayers = 0
	for i, player in ipairs(activity.players) do
		if (not player.primary) then
			numplayers = numplayers + 1
		elseif (player.primary.terrorist) then
			player.terrorist = true
		end
	end
	if (numplayers > numberOfTerrorist + 1) then
		return true
	else

		local uiPopup = UIPopupWindow:New()

		uiPopup.title = l"con035"
		uiPopup.text = l"tip155"
		

		-- buttons

        uiPopup.uiButton2 = uiPopup:AddComponent(UIButton:New(), "uiButton2")
        uiPopup.uiButton2.rectangle = UIPopupWindow.buttonRectangles[2]
	    uiPopup.uiButton2.text = l"but019"

		uiPopup.uiButton2.OnAction = function ()

			UIManager.stack:Pop()
			--activity:PostStateChange("revision", "bytecode")

		end

		UIManager.stack:Push(uiPopup)
		return false

	end

end

-- InitEntityBakedData  ------------------------------------------------------

function UADisarm:InitEntityBakedData(entity, ranking)

	entity.data.baked.score = 0
	entity.data.baked.ranking = ranking

	-- init entity specific data

	if (entity:IsKindOf(UTTeam)) then

		-- team

		for i, player in ipairs(entity.players) do
			self:InitEntityBakedData(player, i)
		end

	else

        UTActivity:InitEntityBakedData(entity, ranking)

		-- player 

		entity.data.baked.accuracy = 0
		entity.data.baked.nbShot = 0
		entity.data.baked.nbRespawn = 0
		entity.data.baked.nbAmmoPack = 0
		entity.data.baked.nbMediKit = 0
		entity.data.baked.timeshit = 0
		entity.data.baked.hitByName = {}
		entity.data.baked.killByName = {}

	end

end

-- InitEntityHeapData  -----------------------------------------------------

function UADisarm:InitEntityHeapData(entity, ranking)

    -- !! INITIALIZE ALL HEAP DATA (RELEVANT DURING ONE MATCH ONLY)
	
	if (not game.gameMaster.ingame) then
		entity.data.heap.score = 0
		entity.data.heap.ranking = ranking
	end
	
	-- init entity specific data

	if (entity:IsKindOf(UTTeam)) then

		-- team

		for i, player in ipairs(entity.players) do
			self:InitEntityHeapData(player, i)
		end

	else

        UTActivity:InitEntityHeapData(entity, ranking)

		-- !! PLAYER : CAN BE TAKEN FROM SETTINGS OR NOT ... TODO

		if (entity.primary) then
			entity.gameplayData = { 0x00, 0x06 }
		else
			entity.gameplayData = { 0x00, 0x00 }
			entity.data.heap.gunseconds = 0
			entity.data.heap.guntime = 0
		end

		if (entity.terrorist) then

			entity.data.heap.lifePoints =  activity.settings.lifePointsTerrorist
			entity.data.heap.ammunitions = activity.settings.ammunitionsTerrorist
			entity.data.heap.clips = 0
			entity.data.heap.teamFrag = activity.settings.teamFragTerrorist
			entity.data.heap.terrorist = 2

		else

			entity.data.heap.lifePoints = activity.settings.lifePointsCommando
			entity.data.heap.ammunitions = activity.settings.ammunitionsCommando
			entity.data.heap.clips = activity.settings.clipsCommando
			entity.data.heap.teamFrag = activity.settings.teamFragCommando
			entity.data.heap.terrorist = 1

		end
		entity.data.heap.swap = activity.settings.swap
		entity.data.heap.medkit = game.settings.addons.medkitPack
		entity.data.heap.respawntimer = activity.settings.respawntimer
		entity.data.heap.invulnerabilityTimeTerrorist = activity.settings.invulnerabilityTimeTerrorist

		if (not game.gameMaster.ingame) then
			entity.data.heap.bombdigitscancount = 0
			entity.data.heap.hit = 0
			entity.data.heap.death = 0
			entity.data.heap.isDead = 0
			-- statistics

			entity.data.heap.accuracy = 0
			entity.data.heap.nbShot = 0
			entity.data.heap.nbRespawn = 0
			entity.data.heap.nbAmmoPack = 0
			entity.data.heap.nbMediKit = 0
			entity.data.heap.timeshit = 0
			entity.data.heap.hitByName = {}
			entity.data.heap.killByName = {}

			--print("my team index is : " .. entity.data.heap.team)

			-- gameMaster
		
			entity.data.heap.hitLost = 0
			entity.data.heap.lastPlayerShooted = {}
			entity.data.heap.nbHitLastPlayerShooted = 0
		end
		
	end
	
end

-- GetTerroristNumber  ------------------------------------------------------

function UADisarm:GetTerroristNumber()

	local numberOfTerrorist = 0
	for _, player in ipairs(activity.players) do
		if (player.terrorist and not player.primary) then
			numberOfTerrorist = numberOfTerrorist + 1
		end
	end
	return numberOfTerrorist

end

-- UpdateEntityBakedData  ---------------------------------------------

function UADisarm:UpdateEntityBakedData(entity, ranking)

	entity.data.baked.score = (entity.data.baked.score or 0) + (entity.data.heap.score or 0)

	if (entity:IsKindOf(UTTeam)) then

		-- team

		for i, player in pairs(entity.players) do
			self:UpdateEntityBakedData(player, i)
		end

	else

		-- statistics

		entity.data.baked.nbShot = (entity.data.baked.nbShot or 0) + entity.data.heap.nbShot
		entity.data.baked.hit = (entity.data.baked.hit or 0) + entity.data.heap.hit
		entity.data.baked.death = (entity.data.baked.death or 0) + entity.data.heap.death
		if (entity.data.baked.nbShot > 0) then
			entity.data.baked.accuracy = (100 * (entity.data.baked.hit + entity.data.baked.death) / entity.data.baked.nbShot)
		else
			entity.data.baked.accuracy = 0
		end
		entity.data.baked.detailAccuracy = string.format("%0.1f", entity.data.baked.accuracy) .. "%"
		--entity.data.baked.detailsScore = entity.data.baked.score .. " " .. l"oth068"
		entity.data.baked.nbRespawn = (entity.data.baked.nbRespawn or 0) + entity.data.heap.nbRespawn
		entity.data.baked.nbAmmoPack = (entity.data.baked.nbAmmoPack or 0) + entity.data.heap.nbAmmoPack
		entity.data.baked.nbMediKit = (entity.data.baked.nbMediKit or 0) + entity.data.heap.nbMediKit
		entity.data.baked.timeshit = (entity.data.baked.timeshit or 0) + entity.data.heap.timeshit
		
		for player, value in pairs(entity.data.heap.hitByName) do
			entity.data.baked.hitByName[player] = (entity.data.baked.hitByName[player] or 0) + value
		end
		for player, value in pairs(entity.data.heap.killByName) do
			entity.data.baked.killByName[player] = (entity.data.baked.killByName[player] or 0) + value
		end

		-- details data

		entity.data.details = {}
		for i, player in ipairs(activity.players) do

			local details = {}
			details.name = player.profile.name
			details.detailsTeam = player.team.profile.details
			details.hitByName = (entity.data.baked.hitByName[player.nameId] or 0)
			details.killByName = (entity.data.baked.killByName[player.nameId] or 0)
			entity.data.details[player.nameId] = details

		end

	end

end