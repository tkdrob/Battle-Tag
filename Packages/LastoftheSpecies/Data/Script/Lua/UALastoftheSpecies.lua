
--[[--------------------------------------------------------------------------
--
-- File:			UALastoftheSpecies.lua
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

UTClass.UALastoftheSpecies(UTActivity)

-- state dependencies

UALastoftheSpecies.State = {}

	require "UALastoftheSpecies.State.RoundLoop"

-- default

UALastoftheSpecies.bitmap = "base:texture/ui/loading_LastoftheSpecies.tga"

-- __ctor --------------------------------------------------------------------

function UALastoftheSpecies:__ctor(...)

	-- activity name

    self.name = l"title024"
    self.category = UTActivity.categories.closed
	self.nodual = true

    self.dontDisplayScore = true
    self.textScoring = l"score017"
    self.Ui.Title.textScoring.rectangle = { 20, 50, 640, 210 }
    self.textRules = l"rules019"
    self.iconBanner = "base:texture/ui/Ranking_Bg_TheWolf.tga"
    
	-- scoringField
	
    self.scoringField = {
		{"score", nil, nil, 280, quartz.system.drawing.justification.right, UIComponent.fonts.header, UIComponent.colors.orange},
	}
	
    -- settings

    self.settings = {

        [1] = { title = l"titlemen006", options = {

            [1] = { displayMode = nil, label = l"goption001", tip = l"tip027", choices = { { value = 5 }, { value = 10 }, { value = 15 }, { value = 20 }, { value = 25 }, { value = 30 }, }, index = "playtime", },

            },
        },

        -- keyed settings

        playtime = 5,     

		-- no team

        numberOfTeams = 0,

    }
    
	-- playground
    -- !! TABLE FORMAT : { [numberofplayer] = { ["ITEM_BITMAP"] = { category = "string", priority = number, size = number, positions = { { number, number }, ... }, title = "string", text = "string", condition = function() }, ... }

    self.playground = {

        [1] = { 
        
            RF09 = { priority = 4, title = l"oth055", text = string.format(l"psexp033"), positions = { { 265, 150 }, }, },           
       
        },
    }

    -- ?? CONFIG DATA SEND WITH RF 

    self.configData = {
		"id",
    }  
    
	-- details columms descriptor

	self.detailsDescriptor = nil

    -- overriden states

    self.states["roundloop"] = UALastoftheSpecies.State.RoundLoop:New(self)
    
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

function UALastoftheSpecies:__dtor()
end

-- InitEntityBakedData  ------------------------------------------------------

function UALastoftheSpecies:InitEntityBakedData(entity, ranking)

	entity.data.baked.score = 0
	entity.data.baked.ranking = ranking

	UTActivity:InitEntityBakedData(entity, ranking)

end

-- InitEntityHeapData  -----------------------------------------------------

function UALastoftheSpecies:InitEntityHeapData(entity, ranking)

    -- !! INITIALIZE ALL HEAP DATA (RELEVANT DURING ONE MATCH ONLY)

	if (not game.gameMaster.ingame) then
		entity.gameplayData = { 0x00, 0x00 }
		entity.data.heap.score = 0
		entity.data.heap.ranking = ranking
		entity.data.heap.nbHit = 0
		entity.data.heap.nbHitbackup = 0
		if (entity.rfGunDevice) then
			entity.data.heap.id = entity.rfGunDevice.classId
		else
			entity.data.heap.id = ranking
		end
	end

    UTActivity:InitEntityHeapData(entity, ranking)

end

-- UpdateEntityBakedData  ---------------------------------------------

function UALastoftheSpecies:UpdateEntityBakedData(entity, ranking)

	entity.data.baked.score = entity.data.baked.score + entity.data.heap.score

end
