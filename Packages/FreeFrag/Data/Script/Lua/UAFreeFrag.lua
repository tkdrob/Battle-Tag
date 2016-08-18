
--[[--------------------------------------------------------------------------
--
-- File:			UAFreeFrag.lua
--                  Copyright (c) Ubisoft Entertainment. All rights reserved.
--
-- Project:         Ubitoys.Tag
-- Date:            September 27, 2010
--
------------------------------------------------------------------------------
--
-- Description:     test activity
--
----------------------------------------------------------------------------]]

--[[ Dependencies ----------------------------------------------------------]]

require "UTActivity"

--[[ Class -----------------------------------------------------------------]]

UTClass.UAFreeFrag(UTActivity)

-- state dependencies

UAFreeFrag.State = {}

	require "UAFreeFrag.State.RoundLoop"

-- default

UAFreeFrag.bitmap = "base:texture/ui/loading_freefrag.tga"

-- __ctor --------------------------------------------------------------------

function UAFreeFrag:__ctor(...)

	-- properties

    self.name = l"title005"
    self.category = UTActivity.categories.closed
	self.nodual = true
    
    self.textScoring = l"score003"
    self.textRules = l"rules002"
    self.iconBanner = "base:texture/ui/Ranking_Bg_FreeFrag.tga"

	-- scoringField

    self.scoringField = {
		{"score", nil, nil, 280, quartz.system.drawing.justification.right, UIComponent.fonts.header, UIComponent.colors.orange},
	}

    -- settings

    self.settings = {

        [1] = { title = l "titlemen006", options = {

            [1] = { label = l "goption001", tip = l "tip027", choices = { { value = 2 }, { value = 5 }, { value = 6 }, { value = 7 }, { value = 8 }, { value = 10 }, { value = 15 }, { value = 20 }, { value = 30 } }, index = "playtime", },

            },
        },

        -- fake settings

        [2] = { title = l "titlemen007", options = {

            [1] = { label = l "goption004", tip = l "tip028", choices = { { value = -1, text = "", icon = "base:texture/ui/components/uiradiobutton_infinity.tga" } }, index = "ammunitions", },
            [2] = { label = l "goption006", tip = l "tip033", choices = { { value = -1, text = "", icon = "base:texture/ui/components/uiradiobutton_infinity.tga" } }, index = "lifePoints", },

            },

        },

        -- keyed settings

        playtime = 5,
        ammunitions = -1,
        lifePoints = -1,

		-- no team

        numberOfTeams = 0,
    }

    -- ?? CONFIG DATA SEND WITH RF 

    self.configData = {}

    -- details columms descriptor

	self.detailsDescriptor = {
		information = {
			{ key = "detailsScore", icon = "base:texture/ui/Icons/32x/score.tga", tip = l"tip072" },
			{ key = "detailAccuracy", icon = "base:texture/ui/Icons/32x/precision.tga", tip = l"tip073" }
		},
		details = {
			{ key = "name", width = 175, style = UIGridLine.RowTitleCellStyle },
			{ key = "hitByName", width = 75, style = UIGridLine.RowTitleCellStyle, icon = "base:texture/ui/Icons/32x/Hit.tga", tip = l"tip068" },
		}
	}

	-- playground
    -- !! TABLE FORMAT : { [numberofplayer] = { ["ITEM_BITMAP"] = { category = "string", priority = number, size = number, positions = { { number, number }, ... }, title = "string", text = "string", condition = function() }, ... }

    self.playground = {

        [1] = { 

            Arrows = { category = "Position", size = 256, positions = { { 265, 150 }, }, title = l"goption002", text = string.format(l"psexp016"), },

        },
    }

    -- overriden states

    self.states["roundloop"] = UAFreeFrag.State.RoundLoop:New(self)

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

function UAFreeFrag:__dtor()
end

-- initialize entity baked data  --------------------------------------------------------------------

function UAFreeFrag:InitEntityBakedData(entity, ranking)

    UTActivity:InitEntityBakedData(entity, ranking)

	entity.data.baked.score = 0
	entity.data.baked.ranking = ranking

	entity.data.baked.accuracy = 0
	entity.data.baked.nbShot = 0
	entity.data.baked.hit = 0
	entity.data.baked.nbHit = 0
	entity.data.baked.hitByName = {}

end

-- initialize entity heap data  --------------------------------------------------------------------

function UAFreeFrag:InitEntityHeapData(entity, ranking)

	UTActivity:InitEntityHeapData(entity, ranking)

	if (not game.gameMaster.ingame) then
		entity.data.heap.score = 0
		entity.data.heap.ranking = ranking
	end

	entity.gameplayData = { 0x00, 0x00 }

	if (not game.gameMaster.ingame) then
		-- statistics

		entity.data.heap.nbShot = 0
		entity.data.heap.nbShotbackup = 0
		entity.data.heap.hit = 0
		entity.data.heap.nbHit = 0
		entity.data.heap.nbHitbackup = 0
		entity.data.heap.accuracy = 0
		entity.data.heap.hitByName = {}

		-- gameMaster

		entity.data.heap.lastPlayerShooted = {}
		entity.data.heap.nbHitLastPlayerShooted = 0
	end

end

-- update entity final data  ---------------------------------------------

function UAFreeFrag:UpdateEntityBakedData(entity, ranking)

	entity.data.baked.score = (entity.data.baked.score or 0) + entity.data.heap.score

	-- statistics

	entity.data.baked.nbShot = (entity.data.baked.nbShot or 0) + entity.data.heap.nbShot
	entity.data.baked.hit = (entity.data.baked.hit or 0) + entity.data.heap.hit
	entity.data.baked.nbHit = (entity.data.baked.nbHit or 0) + entity.data.heap.nbHit
	if (entity.data.baked.nbShot > 0) then
		entity.data.baked.accuracy = (100 * entity.data.baked.hit / entity.data.baked.nbShot)
	else
		entity.data.baked.accuracy = 0
	end
	entity.data.baked.detailsScore = entity.data.baked.score .. " " .. l"oth068"
	entity.data.baked.detailAccuracy = string.format("%0.1f", entity.data.baked.accuracy) .. "%"
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