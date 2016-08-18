
--[[--------------------------------------------------------------------------
--
-- File:			UATagThenShoot.lua
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

UTClass.UATagThenShoot(UTActivity)

-- state dependencies

UATagThenShoot.Ui = {}
UATagThenShoot.State = {}

    require "UATagThenShoot.State.RoundLoop"
    require "UATagThenShoot.State.PlayersSetup"

-- default

UATagThenShoot.minNumberOfPlayer = 1

UATagThenShoot.bitmap = "base:texture/ui/loading_tagnshoot.tga"

UATagThenShoot.countdownDuration = 3

UATagThenShoot.horizontalPadding = 36

UATagThenShoot.slots = 9

UATagThenShoot.playeroffset = 17

-- SD07 snd
UATagThenShoot.gameoverSnd = { 0x53, 0x44, 0x30, 0x37 }

-- __ctor --------------------------------------------------------------------

function UATagThenShoot:__ctor(...)

	-- properties

    self.name = l"title001"
    self.category = UTActivity.categories.single
	self.nodual = true

    self.textScoring = l"score001"
    self.textRules = l"rules006"
    self.iconBanner = "base:texture/ui/Ranking_Bg_TagNShoot.tga"
    
    -- settings

    self.settings = {

        [1] = { title = l"titlemen006", options = {

            [1] = { displayMode = nil, label = l"goption001", tip = l"tip027", choices = { { value = 1 }, { value = 2 }, { value = 3 }, { value = 4 }, { value = 5 }, { value = 6 } }, index = "playtime", },
            [2] = { label = l"goption015", tip = l "tip029", choices = { { value = 2 }, { value = 4, conditional = true } }, index = "numberOfBase", condition = function (self) return (1 == game.settings.addons.medkitPack) end },

            },
     --   },
        
      --  [2] = { title = "Players settings", options = {
		--	},
        },

        -- keyed settings

        playtime = 3,
        numberOfBase = 2 + 2 * game.settings.addons.medkitPack,

		-- no team

        numberOfTeams = 0,
    }

    -- playground
    -- !! TABLE FORMAT : { [numberofplayer] = { ["ITEM_BITMAP"] = { category = "string", priority = number, size = number, positions = { { number, number }, ... }, title = "string", text = "string", condition = function() }, ... }

    self.playground = {

        selection = function (self) return activity.settings.numberOfBase end,

        [2] = {

            RF03 = { priority = 1, positions = { { 75, 100 }, }, title = l"oth056" ..  " (" .. l"oth027" .. ")", text = string.format(l"psexp001"), },
            RF04 = { priority = 2, positions = { { 455, 100 }, }, title = l"oth057" ..  "  (" .. l"oth028" .. ")", text = string.format(l"psexp002"), },
            --Start = { positions = { { 265, 100 }, }, title = "Med-kit", text = string.format("Blah blah Med-kit"), },
            RF09 = { positions = { { 265, 250 }, }, title = "UbiConnect", text = string.format(l"psexp013"), },

        },

        [4] = {

            RF03 = { priority = 1, positions = { { 120, 150 }, }, title = l"oth056" ..  " (" .. l"oth027" .. ")", text = string.format(l"psexp001"), },
            RF04 = { priority = 2, positions = { { 200, 60 }, }, title = l"oth057" ..  " (" .. l"oth028" .. ")", text = string.format(l"psexp002"), },
            RF05 = { priority = 3, positions = { { 330, 60 }, }, title = l"oth058" ..  " (" .. l"oth029" .. ")", text = string.format(l"psexp003"), },
            RF06 = { priority = 4, positions = { { 410, 150 }, }, title = l"oth059" ..  " (" .. l"oth030" .. ")", text = string.format(l"psexp004"), },
            --Start = { positions = { { 265, 100 }, }, title = "Med-kit", text = string.format("Blah blah Med-kit"), },
            RF09 = { positions = { { 265, 250 }, }, title = l"oth055", text = string.format(l"psexp013"), },

        },
    }

    -- ?? CONFIG DATA SEND WITH RF 

    self.configData = {
		"numberOfBase",
    }

    -- details columms descriptor

	self.detailsDescriptor = nil

    -- overriden states

    self.states["roundloop"] = UATagThenShoot.State.RoundLoop:New(self)
    self.states["playerssetup"] = UATagThenShoot.State.PlayersSetup:New(self)

    -- ?? LES SETTINGS SONT RENSEIGN�S DANS LE CONSTRUCTEUR DE L'ACTIVIT�
    -- ?? LES PARAM�TRES (DISPLAYMODE, TEXTE, ICONE...) DES COLONES DE GRID SONT RENSEIGN�S DANS LE COMPOSANT D�DI� DU LEADERBOARD
    -- ?? LES ATTRIBUTS - HEAP, BAKED - DES ENTIT�S SONT RENSEIGN�S PAR 2 APPELS DE FONCTION D�DI�S DANS L'ACTIVIT� (� SURCHARGER)
    -- ?? POUR LES DONN�ES DE CONFIGURATION DE BYTECODE, CE SERA SUREMENT PAREIL QUE POUR LES ATTRIBUTS = FONCTION D�DI� (� SURCHARGER)
    -- ?? POUR LE LEADERBOARD:
    -- ??       - SURCHARGER LA PAGE QUI UTILISE LE LEADERBOARD STANDARD,
    -- ??       - RAJOUTER DES PARAM�TRES (DISPLAYMODE, TEXTE, ICONE...) DES COLONES DE GRID SI N�CESSAIRE EN + DE CEUX PAR D�FAUT (LIFE, HIT, AMMO...)
    -- ??       - RENSEIGNER QUELS ATTRIBUTS ON SOUHAITE REPR�SENTER PARMIS CEUX EXISTANT EN HEAP


    -- gameplay data send

    self.gameplayData = { 0x00, 0x00 }

end

-- __dtor --------------------------------------------------------------------

function UATagThenShoot:__dtor()
end

-- InitEntityBakedData  ------------------------------------------------------

function UATagThenShoot:InitEntityBakedData(entity, ranking)

	UTActivity:InitEntityBakedData(entity, ranking)

	entity.data.baked.score = 0
	entity.data.baked.ranking = ranking
	
	-- init entity specific data

	entity.data.baked.nbHit = 0

end

-- InitEntityHeapData  -------------------------------------------------------

function UATagThenShoot:InitEntityHeapData(entity, ranking)

    UTActivity:InitEntityHeapData(entity, ranking)

	entity.gameplayData = { 0x00, 0x00 }
	
	if (not game.gameMaster.ingame) then
		entity.data.heap.score = 0
		entity.data.heap.ranking = ranking
	
		-- init entity specific data

		entity.data.heap.nbHit = 0
		entity.data.heap.state = 0
		entity.data.heap.tagging = 1
		entity.data.heap.numberOfBase = activity.settings.numberOfBase
	end

end

-- OnDeviceRemoved -----------------------------------------------------------

function UATagThenShoot:OnDeviceRemoved(device)

    if (device.owner) then

        local playerEntity = device.owner
        playerEntity:BindDevice()
		playerEntity.data.heap.classId = nil
		playerEntity.data.heap.disconnected = true

	end

end

-- UpdateEntityBakedData  -------------------------------------------------

function UATagThenShoot:UpdateEntityBakedData(entity, ranking)

	entity.data.baked.score = (entity.data.baked.score or 0) + entity.data.heap.score

end
