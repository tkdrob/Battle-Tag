
--[[--------------------------------------------------------------------------
--
-- File:			UAInfection.lua
--                  Copyright (c) Ubisoft Entertainment. All rights reserved.
--
-- Project:         Ubitoys.Tag
-- Date:            August 29, 2010
--
------------------------------------------------------------------------------
--
-- Description:     test activity
--
----------------------------------------------------------------------------]]

--[[ Dependencies ----------------------------------------------------------]]

require "UTActivity"

--[[ Class -----------------------------------------------------------------]]

UTClass.UAInfection(UTActivity)

-- state dependencies

UAInfection.State = {}

	require "UAInfection.State.RoundLoop"

-- default

UAInfection.bitmap = "base:texture/ui/loading_Infection.tga"

UAInfection.minNumberOfPlayer = 3

-- __ctor --------------------------------------------------------------------

function UAInfection:__ctor(...)

	-- activity name

    self.name = l"title020"
    self.category = UTActivity.categories.closed
	self.nodual = true

    self.textScoring = l"score014"
    self.Ui.Title.textScoring.rectangle = { 20, 50, 640, 210 }
    self.textRules = l"rules016"
    self.iconBanner = "base:texture/ui/Ranking_Bg_Infection.tga"
    
	-- scoringField
	
    self.scoringField = {
		{"score", nil, nil, 280, quartz.system.drawing.justification.right, UIComponent.fonts.header, UIComponent.colors.orange},
	}
	
    -- settings

    self.settings = {

        [1] = { title = l"titlemen006", options = {

            [1] = { displayMode = nil, label = l"goption001", tip = l"tip027", choices = { { value = 2 }, { value = 5 }, { value = 6 }, { value = 7 }, { value = 8 }, { value = 10 }, { value = 15 }, { value = 20 }, { value = 30 } }, index = "playtime", },
			[2] = { displayMode = nil, label = l"goption062", tip = l"tip241", choices = { { value = 1 }, { value = 2 }, { value = 3 }, { value = 4 }, { value = 5 } }, index = "nbzombies", },

            },
        },

        [2] = { title = l"titlemen007", options = {        

			[1] = { displayMode = nil, label = l"goption030", tip = l"tip143", choices = { { value = 5 }, { value = 10 }, { value = 15 }, { value = 20 }, { value = 25 }, { value = 30 }, }, index = "infectiontime", },
			[2] = { displayMode = nil, label = l"goption012", tip = l"tip144", choices = { { value = 5 }, { value = 10 }, { value = 15 }, { value = 20 }, { value = 25 }, { value = 30 }, }, index = "respawnTime", },
			[3] = { displayMode = nil, label = l"goption031", tip = l"tip145", choices = { { value = 1 }, { value = 2 }, { value = 3 }, { value = 4 }, { value = 5 }, { value = 6 }, }, index = "zombielife", },
			--[4] = { displayMode = nil, label = l"goption032", tip = l"tip146", choices = { { value = 1 }, { value = 2 }, { value = 3 }, { value = 4 }, { value = 5 }, { value = 6 }, }, index = "lifePointsSurvivor", },
            --[5] = { label = l"goption004", tip = l"tip028", choices = { { value = 6 }, { value = 9 }, { value = 12 }, { value = 15 }, { value = 18 } }, index = "ammunitions", },
            --[6] = { label = l"goption005", tip = l"tip118", choices = { { value = 1 }, { value = 2 }, { value = 3 }, { value = 4 }, { value = 5 }, { value = 6 } }, index = "clips", },
            --[7] = { displayMode = nil, label = l"goption007", tip = l"tip040", choices = { { value = 0, displayMode = "large", text = l"oth076" }, { value = 1, displayMode = "large", text = l"oth075"  } }, index = "swap", },

            },
        },

        -- keyed settings

        playtime = 5,
		nbzombies = 1,
        infectiontime = 15,
        respawnTime = 10,
        zombielife = 3,
        --lifePointsSurvivor = 1,
        --ammunitions = 9,
        --clips = 2,
        --swap = 1,

		-- no team

        numberOfTeams = 0,

    }
    
	-- playground
    -- !! TABLE FORMAT : { [numberofplayer] = { ["ITEM_BITMAP"] = { category = "string", priority = number, size = number, positions = { { number, number }, ... }, title = "string", text = "string", condition = function() }, ... }

    self.playground = {

        [1] = { 

            RF03 = { priority = 1, title = l"oth056" ..  " (" .. l"oth027" .. ")", text = string.format(l"psexp034"), positions = { { 50, 150 }, }, },
            RF04 = { priority = 2, title = l"oth057" ..  " (" .. l"oth028" .. ")", text = string.format(l"psexp034"), positions = { { 480, 150 }, }, },
            RF05 = { priority = 3, title = l"oth058" ..  " (" .. l"oth029" .. ")", text = string.format(l"psexp034"), positions = { { 265, 30 }, }, },
            RF06 = { priority = 4, title = l"oth059" ..  " (" .. l"oth030" .. ")", text = string.format(l"psexp034"), positions = { { 265, 270 }, }, },           
            RF07 = { category = "Med-Kit", title = l"goption009", text = string.format(l"psexp015"), positions = { { 330, 100 }, }, condition = function (self) return (1 == game.settings.addons.medkitPack) end },
            RF08 = { category = "Med-Kit2", title = l"goption009", text = string.format(l"psexp015"), positions = { { 200, 200 }, }, condition = function (self) return (1 == game.settings.addons.medkitPack) end },
			RF09 = { priority = 4, title = l"oth055", text = string.format(l"psexp033"), positions = { { 265, 150 }, }, },           
       
        },
    }

    -- ?? CONFIG DATA SEND WITH RF 

    self.configData = {
		"id",
		"infectiontime",
		"respawnTime",
		"zombielife",
		--"lifePointsSurvivor",
        --"ammunitions",
        --"clips",
        --"swap",
    }  
    
	-- details columms descriptor

	self.detailsDescriptor = nil

    -- overriden states

    self.states["roundloop"] = UAInfection.State.RoundLoop:New(self)
    
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

function UAInfection:__dtor()
end

-- InitEntityBakedData  ------------------------------------------------------

function UAInfection:InitEntityBakedData(entity, ranking)

	entity.data.baked.score = 0
	entity.data.baked.ranking = ranking

	UTActivity:InitEntityBakedData(entity, ranking)

end

-- InitEntityHeapData  -----------------------------------------------------

function UAInfection:InitEntityHeapData(entity, ranking)

    -- !! INITIALIZE ALL HEAP DATA (RELEVANT DURING ONE MATCH ONLY)

	if (not game.gameMaster.ingame) then
		entity.gameplayData = { 0x00, 0x00 }
		entity.data.heap.score = 0
		entity.data.heap.ranking = ranking
	end
	--entity.data.heap.swap = activity.settings.swap
	entity.data.heap.infectiontime = activity.settings.infectiontime
	entity.data.heap.respawnTime = activity.settings.respawnTime
	entity.data.heap.zombielife = activity.settings.zombielife
	--entity.data.heap.lifePointsSurvivor = activity.settings.lifePointsSurvivor
    --entity.data.heap.ammunitions = activity.settings.ammunitions
    --entity.data.heap.clips = activity.settings.clips
    
    if (not game.gameMaster.ingame) then
		-- statistics
    
		entity.data.heap.nbHit = 0
		entity.data.heap.nbHitbackup = 0
		entity.data.heap.nbShot = 0
		if (entity.rfGunDevice) then
			entity.data.heap.id = entity.rfGunDevice.classId
		else
			entity.data.heap.id = ranking
		end
		entity.data.heap.last_rfid = 0
	end

    UTActivity:InitEntityHeapData(entity, ranking)

end

-- UpdateEntityBakedData  ---------------------------------------------

function UAInfection:UpdateEntityBakedData(entity, ranking)

	entity.data.baked.score = (entity.data.baked.score or 0) + entity.data.heap.score
	
	-- statistics

	entity.data.baked.nbHit = (entity.data.baked.nbHit or 0) + entity.data.heap.nbHit
	entity.data.baked.nbShot = (entity.data.baked.nbShot or 0) + entity.data.heap.nbShot
end
