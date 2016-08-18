
--[[--------------------------------------------------------------------------
--
-- File:			UAOldFashionDuel.lua
--                  Copyright (c) Ubisoft Entertainment. All rights reserved.
--
-- Project:         Ubitoys.Tag
-- Date:            September 23, 2010
--
------------------------------------------------------------------------------
--
-- Description:     test activity
--
----------------------------------------------------------------------------]]

--[[ Dependencies ----------------------------------------------------------]]

require "UTActivity"

--[[ Class -----------------------------------------------------------------]]

UTClass.UAOldFashionDuel(UTActivity)

-- ui creation

UAOldFashionDuel.Ui = {}

-- state dependencies

UAOldFashionDuel.State = {}

	require "UAOldFashionDuel.State.RoundLoop"
    require "UAOldFashionDuel.State.PlayersSetup"
    
-- default

UAOldFashionDuel.bitmap = "base:texture/ui/Loading_OldFashionDuel.tga"

UAOldFashionDuel.countdownDuration = 5

UAOldFashionDuel.gameoverTexture = "base:texture/ui/text_roundover.tga"

UAOldFashionDuel.gameoverSound = {"base:audio/gamemaster/DLG_GM_GLOBAL_120.wav"}

UAOldFashionDuel.horizontalPadding = 36

UAOldFashionDuel.slots = 9

UAOldFashionDuel.playeroffset = 17

-- SD07 snd
UAOldFashionDuel.gameoverSnd = { 0x53, 0x44, 0x30, 0x37 }

-- __ctor --------------------------------------------------------------------

function UAOldFashionDuel:__ctor(...)

	-- properties

    self.name = l"title006"
    self.category = UTActivity.categories.open
	self.nodual = true

    self.textScoring = l"score003"
    self.textRules = l"rules004"
    self.iconBanner = "base:texture/ui/Ranking_Bg_OldFashionDuel.tga"
    
    -- settings

    self.settings = {

        [1] = { title = l"titlemen006", options = {

            [1] = { label = l"goption003", tip = l"tip026", choices = { { value = 1 }, { value = 3 }, { value = 5 } }, index = "numberOfRound" },

            },
        },
        
        -- keyed settings

        numberOfRound = 5,
        playtime = nil,

		-- no team

        numberOfTeams = 0,
    }

    -- playground
    -- !! TABLE FORMAT : { [numberofplayer] = { ["ITEM_BITMAP"] = { category = "string", priority = number, size = number, positions = { { number, number }, ... }, title = "string", text = "string", condition = function() }, ... }

    self.playground = {

        [1] = {

            Player1 = { size = 128, positions = { { 100, 150 }, }, title = l"oth020" .. " 1", text = l"psexp026", },
            Player2 = { size = 128, positions = { { 500, 150 }, }, title = l"oth020" .. " 2", text = l"psexp026", },

        },
    }

    -- ?? CONFIG DATA SEND WITH RF

    self.configData = {}

    -- details columms descriptor

	self.detailsDescriptor = nil

    -- overriden states

    self.states["roundloop"] = UAOldFashionDuel.State.RoundLoop:New(self)
    self.states["playerssetup"] = UAOldFashionDuel.State.PlayersSetup:New(self)

    -- ?? LES SETTINGS SONT RENSEIGN�S DANS LE CONSTRUCTEUR DE L'ACTIVIT�
    -- ?? LES PARAM�TRES (DISPLAYMODE, TEXTE, ICONE...) DES COLONES DE GRID SONT RENSEIGN�S DANS LE COMPOSANT D�DI� DU LEADERBOARD
    -- ?? LES ATTRIBUTS - HEAP, BAKED - DES ENTIT�S SONT RENSEIGN�S PAR 2 APPELS DE FONCTION D�DI�S DANS L'ACTIVIT� (� SURCHARGER)
    -- ?? POUR LES DONN�ES DE CONFIGURATION DE BYTECODE, CE SERA SUREMENT PAREIL QUE POUR LES ATTRIBUTS = FONCTION D�DI� (� SURCHARGER)
    -- ?? POUR LE LEADERBOARD:
    -- ??       - SURCHARGER LA PAGE QUI UTILISE LE LEADERBOARD STANDARD,
    -- ??       - RAJOUTER DES PARAM�TRES (DISPLAYMODE, TEXTE, ICONE...) DES COLONES DE GRID SI N�CESSAIRE EN + DE CEUX PAR D�FAUT (LIFE, HIT, AMMO...)
    -- ??       - RENSEIGNER QUELS ATTRIBUTS ON SOUHAITE REPR�SENTER PARMIS CEUX EXISTANT EN HEAP

	-- gameplay data

end

-- __dtor --------------------------------------------------------------------

function UAOldFashionDuel:__dtor()
end

-- InitEntityBakedData  ------------------------------------------------------

function UAOldFashionDuel:InitEntityBakedData(entity, ranking)

    UTActivity:InitEntityBakedData(entity, ranking)

	entity.data.baked.score = 0
	entity.data.baked.ranking = ranking

end

-- InitEntityHeapData  --------------------------------------------------------------------

function UAOldFashionDuel:InitEntityHeapData(entity, ranking)

	UTActivity:InitEntityHeapData(entity, ranking)

	if (not game.gameMaster.ingame) then
		entity.data.heap.score = 0
		entity.data.heap.ranking = ranking
		entity.data.heap.nbHits = 0
	end
	entity.data.heap.ammunitions = 6

	entity.gameplayData = { 0x00, 0x00 }

end

-- UpdateEntityBakedData  ---------------------------------------------

function UAOldFashionDuel:UpdateEntityBakedData(entity, ranking)

	entity.data.baked.score = (entity.data.baked.score or 0) + entity.data.heap.score

end
