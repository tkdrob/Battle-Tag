
--[[--------------------------------------------------------------------------
--
-- File:			UALastManStanding.lua
--                  Copyright (c) Ubisoft Entertainment. All rights reserved.
--
-- Project:         Ubitoys.Tag
-- Date:            September 22, 2010
--
------------------------------------------------------------------------------
--
-- Description:     test activity
--
----------------------------------------------------------------------------]]

--[[ Dependencies ----------------------------------------------------------]]

require "UTActivity"

--[[ Class -----------------------------------------------------------------]]

UTClass.UALastManStanding(UTActivity)

-- state dependencies

UALastManStanding.State = {}

    require "UALastManStanding.State.RoundLoop"

-- default

UALastManStanding.bitmap = "base:texture/ui/loading_lastmanstanding.tga"

-- __ctor --------------------------------------------------------------------

function UALastManStanding:__ctor(...)

	-- properties

    self.name = l"title011"
    self.category = UTActivity.categories.closed
    self.handicap = true

    self.textScoring = l"score005"
    self.textRules = l"rules003"
    
    self.dontDisplayScore = true
    self.iconBanner = "base:texture/ui/Ranking_Bg_LastManStanding.tga"
    
	-- scoringField
	
    self.scoringField = {
		{"hit", "base:texture/ui/icons/32x/hit.tga", l"iconrules004"},
		{"death", "base:texture/ui/icons/32x/death.tga", l"iconrules003"},
		{"lifePoints", "base:texture/ui/icons/32x/heart.tga", l"iconrules002"},
	}

    -- settings

    self.settings = {

        [1] = { title = l"titlemen006", options = {

            [1] = { displayMode = nil, label = l"goption007", tip = l"tip040", choices = { { value = 0, displayMode = "medium", text = l"oth076" }, { value = 1, displayMode = "medium", text = l"oth082" }, { value = 2, displayMode = "medium", text = l"oth111" } }, index = "swap", },
            [2] = { displayMode = nil, label = l"goption009", tip = l"tip035", choices = { { value = 0, displayMode = "medium", text = l"oth076" }, { value = 1, displayMode = "medium", text = l"oth075", conditional = true } }, index = "medkit", condition = function (self) return (1 == game.settings.addons.medkitPack) end },
            
            },
        },
        
        [2] = { title = l"titlemen007", options = {

            [1] = { label = l"goption004", tip = l"tip028", choices = { { value = 6 }, { value = 9 }, { value = 12 }, { value = 15 }, { value = 18 }, { value = 255, text = "", icon = "base:texture/ui/components/uiradiobutton_infinity.tga" } }, index = "ammunitions", },
            [2] = { label = l"goption005", tip = l"tip032", choices = { { value = 1 }, { value = 2 }, { value = 3 }, { value = 4 }, { value = 5 }, { value = 6 } }, index = "clips", },
           -- [3] = { label = l"goption011", choices = { { value = 0, displayMode = "medium", text = "Auto" } }, index = "respawnMode", },
            [3] = { label = l"goption006", tip = l"tip033", choices = { { value = 1 }, { value = 2 }, { value = 3 }, { value = 4 }, { value = 5 }, { value = 6 }, { value = 7 }, { value = 8 }, { value = 9 }, { value = 10 } }, index = "lifePoints", },

            },
        },

        -- keyed settings

        ammunitions = 9,
        clips = 3,
        lifePoints = 5,
        respawnMode = 0,
        respawnTime = 10,
        swap = 0,
        medkit = 0,

		-- no team

        numberOfTeams = 0,
    }
    
    self.advancedsettings = {

        [1] = { title = l"titlemen026", options = {

            [1] = { displayMode = nil, label = l"goption006", tip = l"tip186", choices = { { value = 0, displayMode = "medium", text = l"oth076" }, { value = 1, conditional = true }, { value = 2, conditional2 = true }, { value = 3, conditional3 = true } }, index = "healthhandicap", condition = function (self) return (activity.settings.lifePoints > 1) end, condition2 = function (self) return (activity.settings.lifePoints > 2) end, condition3 = function (self) return (activity.settings.lifePoints > 3) end },
            [2] = { displayMode = nil, label = l"goption004", tip = l"tip187", choices = { { value = 0, displayMode = "medium", text = l"oth076" }, { value = 3, conditional = true }, { value = 6, conditional = true }, { value = 9, conditional2 = true } }, index = "ammohandicap", condition = function (self) return (activity.settings.ammunitions > 6) end, condition2 = function (self) return (activity.settings.ammunitions > 9) end },
            [3] = { displayMode = nil, label = l"goption005", tip = l"tip188", choices = { { value = 0, displayMode = "medium", text = l"oth076" }, { value = 1, conditional = true }, { value = 2, conditional2 = true }, { value = 3, conditional3 = true } }, index = "clipshandicap", condition = function (self) return (activity.settings.clips > 1) end, condition2 = function (self) return (activity.settings.clips > 2) end, condition3 = function (self) return (activity.settings.clips > 3) end },

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
			[11] = { displayMode = nil, label = l"goption055", tip = l"tip222", choices = { { value = 10 }, { value = 12 }, { value = 15 }, { value = 18 }, { value = 20, text = "", icon = "base:texture/ui/components/uiradiobutton_infinity.tga" } }, index = "munitionsammo", },

            },
        },

        -- keyed settings

        healthhandicap = 0,
        ammohandicap = 0,
        clipshandicap = 0,
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

            Arrows = { category = "Position", size = 256, positions = { { 265, 150 }, }, title = l"goption002", text = string.format(l"psexp016"), },
            RF01 = { category = "Ammo", positions = { { 92, 150 }, }, title = l"goption010", text = string.format(l"psexp014"), condition = function (self) return (255 ~= activity.settings.ammunitions) end  },
            RF02 = { category = "Ammo2", positions = { { 437, 150 }, }, title = l"goption010", text = string.format(l"psexp014"), condition = function (self) return (255 ~= activity.settings.ammunitions) end  },

        },
    }



    -- ?? CONFIG DATA SEND WITH RF 

    self.configData = {

		"lifePoints",
		"ammunitions",
		"clips",
		"swap",
		"medkit",

    }

    -- details columms descriptor

	self.detailsDescriptor = {
		information = {
			--{key = "score", icon = "base:texture/ui/Icons/32x/Score.tga"},
			{key = "detailAccuracy", icon = "base:texture/ui/Icons/32x/precision.tga", tip = l"tip073" }
		},
		details = {
			{key = "name", width = 175, style = UIGridLine.RowTitleCellStyle},
			{key = "hitByName", width = 75, style = UIGridLine.RowTitleCellStyle, icon = "base:texture/ui/Icons/32x/Hit.tga", tip = l"tip068"},
			{key = "killByName", width = 50, style = UIGridLine.RowTitleCellStyle, icon = "base:texture/ui/Icons/32x/Death.tga", tip = l"tip070"},
		}
	}

    -- overriden states

    self.states["roundloop"] = UALastManStanding.State.RoundLoop:New(self)
    
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

function UALastManStanding:__dtor()
end

-- InitEntityBakedData  ------------------------------------------------------

function UALastManStanding:InitEntityBakedData(entity, ranking)

	UTActivity:InitEntityBakedData(entity, ranking)		

	entity.data.baked.score = 0
	entity.data.baked.ranking = ranking

	entity.data.baked.accuracy = 0
	entity.data.baked.nbShot = 0
	entity.data.baked.nbAmmoPack = 0
	entity.data.baked.nbMediKit = 0
	entity.data.baked.hitByName = {}
	entity.data.baked.killByName = {}

end

-- InitEntityHeapData --------------------------------------------------------------------

function UALastManStanding:InitEntityHeapData(entity, ranking)

	UTActivity:InitEntityHeapData(entity, ranking)	

	-- data config

	if (entity.primary) then
		entity.gameplayData = { 0x00, 0x06 }
	else
		entity.gameplayData = { 0x00, 0x00 }
		entity.data.heap.gunseconds = 0
		entity.data.heap.guntime = 0
	end

	if (entity.handicapped) then
		entity.data.heap.lifePoints = activity.settings.lifePoints - activity.advancedsettings.healthhandicap
		entity.data.heap.ammunitions = activity.settings.ammunitions - activity.advancedsettings.ammohandicap
		entity.data.heap.clips = activity.settings.clips - activity.advancedsettings.clipshandicap
	else
		entity.data.heap.lifePoints = activity.settings.lifePoints
		entity.data.heap.ammunitions = activity.settings.ammunitions
		entity.data.heap.clips = activity.settings.clips
	end
	entity.data.heap.audio = game.settings.audio["volume:blaster"]
	entity.data.heap.beamPower = game.settings.ActivitySettings.beamPower
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
	if (activity.settings.ammunitions == 255) then
		entity.data.heap.ammunitions = activity.settings.ammunitions
		entity.data.heap.ammunitionsAndClips = "-/-"
	else
		entity.data.heap.ammunitionsAndClips = activity.settings.ammunitions .. "/" .. entity.data.heap.clips
	end
	entity.data.heap.swap = activity.settings.swap
	entity.data.heap.medkit = activity.settings.medkit

    if (entity.data.heap.isDead == 1) then
        entity.data.heap.lifePoints = 0
	end
	if (not game.gameMaster.ingame) then

		entity.data.heap.score = activity.settings.lifePoints + #activity.match.players
		entity.data.heap.ranking = ranking
	
		-- statistics

		entity.data.heap.nbShot = 0
		entity.data.heap.hit = 0
		entity.data.heap.death = 0
		entity.data.heap.accuracy = 0
		entity.data.heap.isDead = 0
		entity.data.heap.nbAmmoPack = 0
		entity.data.heap.nbMediKit = 0
		entity.data.heap.hitByName = {}
		entity.data.heap.killByName = {}
	
		-- gameMaster
	
		entity.data.heap.hitLost = 0
		entity.data.heap.lastPlayerShooted = {}
		entity.data.heap.nbHitLastPlayerShooted = 0
	end

end

-- UpdateEntityBakedData  ---------------------------------------------

function UALastManStanding:UpdateEntityBakedData(entity, ranking)

	entity.data.baked.score = (entity.data.baked.score or 0) + entity.data.heap.score

	-- statistics

	entity.data.baked.nbShot = (entity.data.baked.nbShot or 0) + entity.data.heap.nbShot
	entity.data.baked.hit = (entity.data.baked.hit or 0) + entity.data.heap.hit
	entity.data.baked.death = (entity.data.baked.death or 0) + entity.data.heap.death
	if (entity.data.baked.nbShot > 0) then
		entity.data.baked.accuracy = (100 * (entity.data.baked.hit + entity.data.baked.death) / entity.data.baked.nbShot)
	else
		entity.data.baked.accuracy = 0
	end
	entity.data.baked.detailsScore = entity.data.baked.score .. " " .. l"oth068"
	entity.data.baked.detailAccuracy = string.format("%0.1f", entity.data.baked.accuracy) .. "%"
	entity.data.baked.nbAmmoPack = (entity.data.baked.nbAmmoPack or 0) + entity.data.heap.nbAmmoPack
	entity.data.baked.nbMediKit = (entity.data.baked.nbMediKit or 0) + entity.data.heap.nbMediKit
	
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
		details.hitByName = (entity.data.baked.hitByName[player.nameId] or 0)
		details.killByName = (entity.data.baked.killByName[player.nameId] or 0)
		entity.data.details[player.nameId] = details

	end

end
