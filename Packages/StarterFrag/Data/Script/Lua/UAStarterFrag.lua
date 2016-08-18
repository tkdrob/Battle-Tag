
--[[--------------------------------------------------------------------------
--
-- File:			UTActivity_UAStarterFrag.lua
--                  Copyright (c) Ubisoft Entertainment. All rights reserved.
--
-- Project:         Ubitoys.Tag
-- Date:            September 21, 2010
--
------------------------------------------------------------------------------
--
-- Description:     test activity
--
----------------------------------------------------------------------------]]

--[[ Dependencies ----------------------------------------------------------]]

require "UTActivity"

--[[ Class -----------------------------------------------------------------]]

UTClass.UAStarterFrag(UTActivity)

-- state dependencies

UAStarterFrag.State = {}

    require "UAStarterFrag.State.RoundLoop"

-- default

UAStarterFrag.bitmap = "base:texture/ui/loading_starterfrag.tga"

-- __ctor --------------------------------------------------------------------

function UAStarterFrag:__ctor(...)

	-- properties

    self.name = l "title004"
    self.category = UTActivity.categories.closed
	self.nodual = true

    self.textScoring = l "score003"
    self.textRules = l "rules005"
    self.iconBanner = "base:texture/ui/Ranking_Bg_StarterFrag.tga"
    
	-- scoringField
	
    self.scoringField = {
		{"score", nil, nil, 280, quartz.system.drawing.justification.right, UIComponent.fonts.header, UIComponent.colors.orange},
	}

    -- settings

    self.settings = {

        [1] = { title = l "titlemen006", options = {

            [1] = { displayMode = nil, label = l"goption001", tip = l"tip027", choices = { { value = 2 }, { value = 5 }, { value = 6 }, { value = 7 }, { value = 8 }, { value = 10 }, { value = 15 }, { value = 20 }, { value = 30 } }, index = "playtime", },

            },
        },
        
        [2] = { title = l"titlemen007", options = {

            [1] = { label = l"goption004", tip = l"tip028", choices = { { value = 6 }, { value = 9 }, { value = 12 }, { value = 15 }, { value = 18 } }, index = "ammunitions", },
            [2] = { label = l"goption005", tip = l"tip032", choices = { { value = 1 }, { value = 2 }, { value = 3 }, { value = 4 }, { value = 5 }, { value = 6 } }, index = "clips", },

            },
        },

        -- keyed settings

        playtime = 5,
        ammunitions = 12,
        clips = 3,

		-- no team

        numberOfTeams = 0,
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
    
		"ammunitions",
		"clips",
    }

    -- details columms descriptor

	self.detailsDescriptor = {
		information = {
			{ key = "detailsScore", icon = "base:texture/ui/Icons/32x/score.tga", tip = l"tip072" },
			{key = "detailAccuracy", icon = "base:texture/ui/Icons/32x/precision.tga", tip = l"tip073" }
		},
		details = {
			{key = "name", width = 175, style = UIGridLine.RowTitleCellStyle},
			{key = "hitByName", width = 75, style = UIGridLine.RowTitleCellStyle, icon = "base:texture/ui/Icons/32x/Hit.tga", tip = l"tip068"},
		}
	}

    -- overriden states

    self.states["roundloop"] = UAStarterFrag.State.RoundLoop:New(self)
    
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

function UAStarterFrag:__dtor()
end

-- InitEntityBakedData  ------------------------------------------------------

function UAStarterFrag:InitEntityBakedData(entity, ranking)

	UTActivity:InitEntityBakedData(entity, ranking)

	entity.data.baked.score = 0
	entity.data.baked.ranking = ranking

	entity.data.baked.accuracy = 0
	entity.data.baked.nbShot = 0
	entity.data.baked.nbAmmoPack = 0
	entity.data.baked.nbHit = 0
	entity.data.baked.hitByName = {}

end

-- InitEntityHeapData  --------------------------------------------------------------------

function UAStarterFrag:InitEntityHeapData(entity, ranking)

    UTActivity:InitEntityHeapData(entity, ranking)

	if (not game.gameMaster.ingame) then
		entity.data.heap.score = 0
		entity.data.heap.ranking = ranking
	end

	entity.gameplayData = { 0x00, 0x00 }
	
	-- data config

	entity.data.heap.ammunitions = activity.settings.ammunitions
	entity.data.heap.clips = activity.settings.clips
	if (activity.settings.ammunitions == 255) then
		entity.data.heap.ammunitionsAndClips = "-/-"
	else
		entity.data.heap.ammunitionsAndClips = activity.settings.ammunitions .. "/" .. entity.data.heap.clips
	end
		
	if (not game.gameMaster.ingame) then
		-- statistics

		entity.data.heap.nbHit = 0
		entity.data.heap.nbShot = 0
		entity.data.heap.hit = 0
		entity.data.heap.accuracy = 0
		entity.data.heap.nbAmmoPack = 0
		entity.data.heap.hitByName = {}
	
		-- gameMaster
	
		entity.data.heap.hitLost = 0
		entity.data.heap.lastPlayerShooted = {}
		entity.data.heap.nbHitLastPlayerShooted = 0
	end

end

-- UpdateEntityBakedData  ---------------------------------------------

function UAStarterFrag:UpdateEntityBakedData(entity, ranking)

	entity.data.baked.score = (entity.data.baked.score or 0) + entity.data.heap.score

	-- statistics

	entity.data.baked.nbShot = (entity.data.baked.nbShot or 0) + entity.data.heap.nbShot
	entity.data.baked.hit = (entity.data.baked.hit or 0) + entity.data.heap.hit
	if (entity.data.baked.nbShot > 0) then
		entity.data.baked.accuracy = (100 * entity.data.baked.hit / entity.data.baked.nbShot)
	else
		entity.data.baked.accuracy = 0
	end
	entity.data.baked.detailsScore = entity.data.baked.score .. " " .. l"oth068"
	entity.data.baked.detailAccuracy = string.format("%0.1f", entity.data.baked.accuracy) .. "%"
	entity.data.baked.nbAmmoPack = (entity.data.baked.nbAmmoPack or 0) + entity.data.heap.nbAmmoPack
	entity.data.baked.nbHit = (entity.data.baked.nbHit or 0) + entity.data.heap.nbHit
	
	for player, value in pairs(entity.data.heap.hitByName) do
		entity.data.baked.hitByName[player] = (entity.data.baked.hitByName[player] or 0) + value
	end

	-- details data

	entity.data.details = {}
	for i, player in ipairs(activity.players) do

		local details = {}
		details.name = player.profile.name
		details.hitByName = (entity.data.baked.hitByName[player.nameId] or 0)
		entity.data.details[player.nameId] = details

	end

end
