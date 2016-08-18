
--[[--------------------------------------------------------------------------
--
-- File:			UAStalktheLantern.lua
--                  Copyright (c) Ubisoft Entertainment. All rights reserved.
--
-- Project:         Ubitoys.Tag
-- Date:            November 25, 2010
--
------------------------------------------------------------------------------
--
-- Description:     
--
----------------------------------------------------------------------------]]

--[[ Dependencies ----------------------------------------------------------]]

require "UTActivity"

--[[ Class -----------------------------------------------------------------]]

UTClass.UAStalktheLantern(UTActivity)

-- state dependencies

UAStalktheLantern.State = {}

	require "UAStalktheLantern.State.RoundLoop"
	require "UAStalktheLantern.UIPlayerSlot"

-- default

UAStalktheLantern.bitmap = "base:texture/ui/loading_StalktheLantern.tga"

UAStalktheLantern.minNumberOfPlayer = 3

UAStalktheLantern.playerSlot = UAStalktheLantern.UIPlayerSlot

UAStalktheLantern.numberOfDefender = 0

-- __ctor --------------------------------------------------------------------

function UAStalktheLantern:__ctor(...)

	-- activity name

    self.name = l"title025"
    self.category = UTActivity.categories.closed
	self.dontDisplayScore = true
    self.handicap = true
    self.textScoring = l"score018"
    self.textRules = l"rules020"
    self.iconBanner = "base:texture/ui/Ranking_Bg_StalktheLantern.tga"
    self.Ui.Title.textScoring.rectangle = { 20, 50, 640, 210 }
    self.Ui.Title.scoringOffset = 40
    
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

            [1] = { displayMode = nil, label = l"goption001", tip = l"tip027", choices = { { value = 5 }, { value = 10 }, { value = 15 }, { value = 20 }, { value = 25 }, { value = 30 } }, index = "playtime", },
            [2] = { displayMode = nil, label = l"goption013", tip = l"tip041", choices = { { value = 0, displayMode = "medium", text = l"oth076" }, { value = 1, displayMode = "medium", text = l"oth075" } }, index = "teamFrag", },
            [3] = { displayMode = nil, label = l"goption007", tip = l"tip040", choices = { { value = 0, displayMode = "medium", text = l"oth076" }, { value = 1, displayMode = "medium", text = l"oth082" }, { value = 2, displayMode = "medium", text = l"oth111" } }, index = "swap", },

            },
        },

        [2] = { title = l"titlemen029", options = {

            [1] = { label = l"goption004", tip = l"tip028", choices = { { value = 3 }, { value = 5 }, { value = 8 }, { value = 10 }, { value = 12 }, { value = 15 } }, index = "ammunitionsDefender", },
            [2] = { label = l"goption005", tip = l"tip032", choices = { { value = 1 }, { value = 2 }, { value = 3 } }, index = "clipsDefender", },
            [3] = { label = l"goption012", tip = l"tip036", choices = { { value = 0 }, { value = 5 }, { value = 10 }, { value = 12 }, { value = 15 }, { value = 20 } }, index = "respawnTimeDefender", },
            [4] = { label = l"goption006", tip = l"tip033", choices = { { value = 3 }, { value = 5 }, { value = 7 }, { value = 8 }, { value = 9 }, { value = 10 }, { value = 12 }, { value = 15 }, { value = 18 } }, index = "lifePointsDefender", },
            [5] = { label = l"goption017", tip = l"tip127", choices = { { value = 3 }, { value = 5 }, { value = 7 }, { value = 9 }, { value = 12 }, { value = 15 }, { value = 0, text = "", icon = "base:texture/ui/components/uiradiobutton_infinity.tga" } }, index = "livesDefender", },
			[6] = { label = l"goption011", choices = { { value = 0, text = "", icon = "base:texture/ui/components/uiradiobutton_tbase.tga" }, { value = 1, displayMode = "medium", text = l"oth080" } }, index = "respawnModeDefender", },

            },
        },

        [3] = { title = l"titlemen030", options = {

            [1] = { label = l"goption004", tip = l"tip028", choices = { { value = 6 }, { value = 9 }, { value = 12 }, { value = 15 }, { value = 18 }, { value = 255, text = "", icon = "base:texture/ui/components/uiradiobutton_infinity.tga" } }, index = "ammunitionsStalker", },
            [2] = { label = l"goption005", tip = l"tip032", choices = { { value = 1 }, { value = 2 }, { value = 3 }, { value = 4 }, { value = 5 }, { value = 6 } }, index = "clipsStalker", },
            [3] = { label = l"goption012", tip = l"tip036", choices = { { value = 0 }, { value = 5 }, { value = 10 }, { value = 12 }, { value = 15 }, { value = 20 } }, index = "respawnTimeStalker", },
            [4] = { label = l"goption006", tip = l"tip033", choices = { { value = 1 }, { value = 2 }, { value = 3 }, { value = 4 }, { value = 5 }, { value = 6 } }, index = "lifePointsStalker", },
            [5] = { label = l"goption017", tip = l"tip127", choices = { { value = 3 }, { value = 5 }, { value = 7 }, { value = 9 }, { value = 12 }, { value = 15 }, { value = 0, text = "", icon = "base:texture/ui/components/uiradiobutton_infinity.tga" } }, index = "livesStalker", },

            },
        },      

        -- keyed settings

	    playtime = 5,       
        ammunitionsDefender = 5,
		ammunitionsStalker = 9,
        clipsDefender = 1,
		clipsStalker = 5,
        lifePointsDefender = 8,
		lifePointsStalker = 1,
        respawnTimeDefender = 0,
		respawnTimeStalker = 0,
		respawnModeDefender = 1,
		respawnModeStalker = 0,
        swap = 0,
        numberOfTeams = 0,
		teamFrag = 0,
        livesDefender = 0,
		livesStalker = 0,

    }

    self.advancedsettings = {

        [1] = { title = l"titlemen026", options = {

            [1] = { displayMode = nil, label = l"goption006", tip = l"tip186", choices = { { value = 0, displayMode = "medium", text = l"oth076" }, { value = 1 }, { value = 2 }, { value = 3 } }, index = "healthhandicap", },
            [2] = { displayMode = nil, label = l"goption004", tip = l"tip187", choices = { { value = 0, displayMode = "medium", text = l"oth076" }, { value = 3 }, { value = 6 }, { value = 9 } }, index = "ammohandicap", },
            [3] = { displayMode = nil, label = l"goption005", tip = l"tip188", choices = { { value = 0, displayMode = "medium", text = l"oth076" }, { value = 1 }, { value = 2 }, { value = 3 } }, index = "clipshandicap", },
            [4] = { displayMode = nil, label = l"goption017", tip = l"tip190", choices = { { value = 0, displayMode = "medium", text = l"oth076" }, { value = 1 }, { value = 2 }, { value = 3 }, { value = 4 } }, index = "liveshandicap", },

            },
        },
        
        [2] = { title = l"titlemen028", options = {

			[1] = { displayMode = nil, label = l"goption045", tip = l"tip203", choices = { { value = false, displayMode = "medium", text = l"but002" }, { value = true, displayMode = "medium", text = l"but001" } }, index = "classes", },
			[2] = { displayMode = nil, label = l"goption046", tip = l"tip204", choices = { { value = 1 }, { value = 2 }, { value = 3 }, { value = 4 }, { value = 5 }, { value = 6 } }, index = "sniperhealth", },
			[3] = { displayMode = nil, label = l"goption047", tip = l"tip205", choices = { { value = 1 }, { value = 2 }, { value = 3 }, { value = 4 }, { value = 5 }, { value = 6 } }, index = "sniperammo", },
			[4] = { displayMode = nil, label = l"goption048", tip = l"tip206", choices = { { value = 5 }, { value = 6 }, { value = 7 }, { value = 8 }, { value = 9 }, { value = 10 } }, index = "heavyhealth", },
			[5] = { displayMode = nil, label = l"goption049", tip = l"tip207", choices = { { value = 12 }, { value = 15 }, { value = 18 } }, index = "heavyammo", },
			[6] = { displayMode = nil, label = l"goption050", tip = l"tip208", choices = { { value = 1 }, { value = 2 }, { value = 3 }, { value = 4 }, { value = 5 } }, index = "stealthhealth", },
			[7] = { displayMode = nil, label = l"goption051", tip = l"tip209", choices = { { value = 5 }, { value = 8 }, { value = 12 }, { value = 15 }, { value = 18 } }, index = "stealthammo", },
			[8] = { displayMode = nil, label = l"goption052", tip = l"tip219", choices = { { value = 1 }, { value = 2 }, { value = 3 }, { value = 4 }, { value = 5 }, { value = 6 } }, index = "medichealth", },
			[9] = { displayMode = nil, label = l"goption053", tip = l"tip220", choices = { { value = 3 }, { value = 5 }, { value = 7 }, { value = 8 }, { value = 10 }, { value = 12 } }, index = "medicammo", },
			[10] = { displayMode = nil, label = l"goption054", tip = l"tip221", choices = { { value = 1 }, { value = 2 }, { value = 3 }, { value = 4 }, { value = 5 }, { value = 6 } }, index = "munitionshealth", },
			[11] = { displayMode = nil, label = l"goption055", tip = l"tip222", choices = { { value = 10 }, { value = 12 }, { value = 15 }, { value = 18 }, { value = 255, text = "", icon = "base:texture/ui/components/uiradiobutton_infinity.tga" } }, index = "munitionsammo", },

            },
        },

        -- keyed settings

        healthhandicap = 0,
        ammohandicap = 0,
        clipshandicap = 0,
        liveshandicap = 0,
        classes = false,
        sniperhealth = 2,
        sniperammo = 5,
        heavyhealth = 8,
        heavyammo = 18,
        stealthhealth = 5,
        stealthammo = 8,
        medichealth = 3,
        medicammo = 5,
        munitionshealth = 5,
        munitionsammo = 15,
        
    }

    -- playground
    -- !! TABLE FORMAT : { [numberofplayer] = { ["ITEM_BITMAP"] = { category = "string", priority = number, size = number, positions = { { number, number }, ... }, title = "string", text = "string", condition = function() }, ... }

    self.playground = {

        [1] = { 

            BlueArea = { priority = 20, size = 128, text = string.format(l"psexp025"), positions = { { 480, 150 }, }, },
            RedArea = { priority = 20, size = 128, text = string.format(l"psexp025"), positions = { { 50, 150 }, }, },

            RF01 = { category = "Ammo", title = l"goption010", text = string.format(l"psexp014"), positions = { { 200, 100 }, }, condition = function (self) return (255 ~= activity.settings.ammunitions) end  },
            RF02 = { category = "Ammo2", title = l"goption010", text = string.format(l"psexp014"), positions = { { 330, 200 }, }, condition = function (self) return (255 ~= activity.settings.ammunitions) end  },
            RF03 = { priority = 1, title = l"oth056" ..  " (" .. l"oth027" .. ")", text = string.format(l"psexp018" .. l"psexp055"), positions = { { 50, 150 }, }, },
            RF04 = { priority = 2, title = l"oth057" ..  " (" .. l"oth028" .. ")", text = string.format(l"psexp019"), positions = { { 480, 150 }, }, },
            RF07 = { category = "Med-Kit", title = l"goption009", text = string.format(l"psexp015"), positions = { { 350, 150 }, }, condition = function (self) return (1 == game.settings.addons.medkitPack) end },
            RF08 = { category = "Med-Kit2", title = l"goption009", text = string.format(l"psexp015"), positions = { { 180, 150 }, }, condition = function (self) return (1 == game.settings.addons.medkitPack) end },
        },

    }

    -- ?? CONFIG DATA SEND WITH RF 

    self.configData = {

		"lifePoints",
		"ammunitions",
		"clips",
		"swap",
		"respawnTime",
		"defender",
		"teamFrag",
		"lives",
		"respawnmode",

    }
    
	-- details columms descriptor

	self.detailsDescriptor = {
		information = {
			--{key = "detailsScore", icon = "base:texture/ui/Icons/32x/score.tga", tip = l"tip072" },
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

    self.states["roundloop"] = UAStalktheLantern.State.RoundLoop:New(self)
    
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

function UAStalktheLantern:__dtor()
end

-- Check ---------------------------------------------------------------------

function UAStalktheLantern:Check()

	-- check number of defenders

	local numberOfDefender = self:GetDefenderNumber()
	local numplayers = 0
	for i, player in ipairs(activity.players) do
		if (not player.primary) then
			numplayers = numplayers + 1
		elseif (player.primary.defender) then
			player.defender = true
		end
	end
	--if (numberOfDefender == math.floor(numplayers / 6 + 1)) then
	if (numberOfDefender > 0) then

		return true

	else

		local uiPopup = UIPopupWindow:New()

		uiPopup.title = l"con035"
		--if (numberOfDefender < math.floor(numplayers / 6)) then
		--	uiPopup.text = l"tip243"
		--else
			uiPopup.text = l"tip242"
		--end
		

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

function UAStalktheLantern:InitEntityBakedData(entity, ranking)

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

function UAStalktheLantern:InitEntityHeapData(entity, ranking)

    -- !! INITIALIZE ALL HEAP DATA (RELEVANT DURING ONE MATCH ONLY)

	if (not game.gameMaster.ingame) then
		entity.data.heap.score = 0
		entity.data.heap.ranking = ranking
	end
	
	-- init entity specific data

	if (entity:IsKindOf(UTTeam)) then

		-- team
		
		--entity.data.heap.nbPlayerAlive = #entity.players

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
		if (entity.defender) then
			entity.data.heap.lifePoints = activity.settings.lifePointsDefender
			entity.data.heap.ammunitions = activity.settings.ammunitionsDefender
			entity.data.heap.clips = activity.settings.clipsDefender
			entity.data.heap.lives = activity.settings.livesDefender
			entity.data.heap.respawnTime = activity.settings.respawnTimeDefender
			entity.data.heap.respawnmode = activity.settings.respawnModeDefender
			entity.data.heap.defender = 1
		else
			entity.data.heap.lifePoints = activity.settings.lifePointsStalker
			entity.data.heap.ammunitions = activity.settings.ammunitionsStalker
			entity.data.heap.clips = activity.settings.clipsStalker
			entity.data.heap.lives = activity.settings.livesStalker
			entity.data.heap.respawnTime = activity.settings.respawnTimeStalker
			entity.data.heap.respawnmode = activity.settings.respawnModeStalker
			entity.data.heap.defender = 2
		end
		if (activity.advancedsettings.classes) then
			local curindex = {"sniperhealth", "sniperammo", "heavyhealth", "heavyammo", "stealthhealth", "stealthammo", "medichealth", "medicammo", "munitionshealth", "munitionsammo"}
			for i = 1, 6 do
				if (entity.class == i and i > 1) then
					entity.data.heap.lifePoints = self.advancedsettings[curindex[(2 * i - 3)]]
					entity.data.heap.ammunitions = self.advancedsettings[curindex[(2 * i - 2)]]
					break
				end
			end
			if (entity.class == 2) then
				entity.data.heap.audio = 0
				entity.data.heap.beamPower = 5
			elseif (entity.class == 3) then
				entity.data.heap.audio = 0
				entity.data.heap.beamPower = 1
			elseif (entity.class == 4) then
				entity.data.heap.audio = 16
			elseif (entity.class == 7) then
				entity.data.heap.lifePoints = 100
				entity.data.heap.ammunitions = 255
			end
		end
		if (entity.handicapped) then
			if (entity.class ~= 7) then
				entity.data.heap.lifePoints = math.max(entity.data.heap.lifePoints - activity.advancedsettings.healthhandicap, 1)
				entity.data.heap.ammunitions = math.max(entity.data.heap.ammunitions - activity.advancedsettings.ammohandicap, 1)
			end
			entity.data.heap.clips = math.max(entity.data.heap.clips - activity.advancedsettings.clipshandicap, 1)
			entity.data.heap.lives = math.max(entity.data.heap.lives - activity.advancedsettings.liveshandicap, 1)
		end
		entity.data.heap.swap = activity.settings.swap
		entity.data.heap.teamFrag = activity.settings.teamFrag

		if (not game.gameMaster.ingame) then
			-- statistics

			entity.data.heap.hit = 0
			entity.data.heap.death = 0
			entity.data.heap.accuracy = 0
			entity.data.heap.isDead = 0
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

-- GetDefenderNumber  ------------------------------------------------------

function UAStalktheLantern:GetDefenderNumber()

	local numberOfDefender = 0
	for _, player in ipairs(activity.players) do
		if (player.defender and not player.primary) then
			numberOfDefender = numberOfDefender + 1
		end
	end
	return numberOfDefender

end

-- UpdateEntityBakedData  ---------------------------------------------

function UAStalktheLantern:UpdateEntityBakedData(entity, ranking)

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