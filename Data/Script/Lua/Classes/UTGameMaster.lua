
--[[--------------------------------------------------------------------------
--
-- File:            UTGameMaster.lua
--                  Copyright (c) Ubisoft Entertainment. All rights reserved.
--
-- Project:         Ubitoys.Tag
-- Date:            May 28, 2010
--
------------------------------------------------------------------------------
--
-- Description:     ...
--
----------------------------------------------------------------------------]]

--[[ Dependencies ----------------------------------------------------------]]


--[[ Class -----------------------------------------------------------------]]

UTClass.UTGameMaster()

-- defaults

UTGameMaster.updatePriority = {}
UTGameMaster.specificRegisterFonction = {}

-- __ctor --------------------------------------------------------------------

function UTGameMaster:__ctor(...)

	self.dataBase = {}
	self.dataBaseOrder = {}
	self.areaPriorityZero = {}

	self.ingame = false	
	self.eventRegister = false
	self.nextFreeTime = 0
	self.nextFreeInactiveTime = 0

    self.watch = {}

end

-- __dtor --------------------------------------------------------------------

function UTGameMaster:__dtor()
end

-- Begin ---------------------------------------------------------------------

function UTGameMaster:Begin()
		
	self.ingame = true
	self.eventRegister = true
				
	table.foreachi(activity.match.players, function(index, player) 
	
		player._DataChanged:Add(self, self.OnDataChanged)
	
	end )

	self.lastActionTime = quartz.system.time.gettimemicroseconds()
	
end

-- End -----------------------------------------------------------------------

function UTGameMaster:End()
		
	if (self.eventRegister == true) then
	
		self.eventRegister = false
		table.foreachi(activity.match.players, function(index, player) player._DataChanged:Remove(self, self.OnDataChanged) end )
		
	end
		
    for index, voice in pairs(self.dataBase) do self:UnRegisterSound(voice)
	end	

	self.ingame = false
		 
end

-- OnDataChanged  ------------------------------------------------------------

function UTGameMaster:OnDataChanged(entity, key, value)
	
	self.lastActionTime = quartz.system.time.gettimemicroseconds()

end

-- Play ----------------------------------------------------------------------

function UTGameMaster:Play(path, delegate)

    if (path) then

        -- do not play sound file when volume is set to zero

        local volume = game.settings.audio["volume:gm"]
        if (0 < volume) then

            local result = quartz.framework.audio.loadsound(path)
            if (result) then

		        if (delegate) then

		            local duration = quartz.framework.audio.getduration() * 1000000
		            local context = { __delegate = delegate, __time = quartz.system.time.gettimemicroseconds() + duration }

		            table.insert(self.watch, context)

		        end
				quartz.framework.audio.loadvolume(game.settings.audio["volume:gm"])
		        quartz.framework.audio.playsound()

            elseif (delegate) then
            
                -- make sure to call that delegate,
                -- even though the file was not loaded

                delegate()

		    end
        elseif (delegate) then

            -- make sure to call that delegate,
            -- especially when volume was set to zero

            delegate()

		end
    end

end

-- RegisterSound -------------------------------------------------------------

function UTGameMaster:RegisterSound(data)
	
	local time = quartz.system.time.gettimemicroseconds()
	local voice = { paths = data.paths, probas = data.probas or {}, priority = data.priority or 0, offset = data.offset or 0, nameValue = data.nameValue or "", value = data.value or -1, proba = data.proba or 1, condition = false, timeStart = time}

	self.dataBase[voice] = voice
	
	if( voice.priority == 0) then	
		self.areaPriorityZero[voice] = { beginTime = time + 1000000 * voice.offset - 3 * 1000000, endTime = time + 1000000 * voice.offset + 1 * 1000000}
	end

	self.dataBaseOrder = {}
	
    for voice in pairs(self.dataBase) do 
		if(voice ~= nil) then table.insert(self.dataBaseOrder, voice) 
		end
	end
	
	function comp(v1, v2)

		if (vi and v2) then
			if (v1.priority < v2.priority) then return true
			else
				if (v1.timeStart + 1000000 * v1.offset < v2.timeStart + 1000000 * v2.offset) then return true
				end		
			end
		end		
	end
	
    table.sort(self.dataBaseOrder, comp)

	return voice

end

-- RegisterActivitySound -----------------------------------------------------

function UTGameMaster:RegisterActivitySound()
	
	assert(activity)
	
	self:RegisterSound({ paths = {"base:audio/gamemaster/DLG_GM_GLOBAL_32.wav",
								  "base:audio/gamemaster/DLG_GM_GLOBAL_33.wav",
								  "base:audio/gamemaster/DLG_GM_GLOBAL_34.wav", 
								  "base:audio/gamemaster/DLG_GM_GLOBAL_35.wav",
								  "base:audio/gamemaster/DLG_GM_GLOBAL_125.wav",
								  "base:audio/gamemaster/DLG_GM_GLOBAL_126.wav",
								  "base:audio/gamemaster/DLG_GM_GLOBAL_132.wav",},
						 priority = 4,
						 })

end

-- UnRegisterSound -----------------------------------------------------------

function UTGameMaster:UnRegisterSound(voice)

	if( voice.priority == 0) then	
		self.areaPriorityZero[voice] = nil
	end

	self.dataBase[voice] = nil

	self.dataBaseOrder = {}
	
    for voice in pairs(self.dataBase) do 
		if(self.dataBase[voice] ~= nil) then
			table.insert(self.dataBaseOrder, voice) 
		end
	end
	
	function comp(v1, v2)

		if (vi and v2) then
			if (v1.priority < v2.priority) then return true
			else
				if (v1.timeStart + 1000000 * v1.offset < v2.timeStart + 1000000 * v2.offset) then return true
				end		
			end
		end		
	end
	
    table.sort(self.dataBaseOrder, comp)

end

-- Update --------------------------------------------------------------------

function UTGameMaster:Update()

	local time = quartz.system.time.gettimemicroseconds()

    -- gm watch

    for index, context in ipairs(self.watch) do
        if (time >= context.__time) then
            table.remove(self.watch, index)
            if (context.__delegate) then context.__delegate()
            end
        end
    end

    -- ingame stuff ...

	if (self.ingame == false) then return
	end

    for index, voice in ipairs(self.dataBaseOrder) do
		UTGameMaster.updatePriority[voice.priority](self, voice, time)		
    end

end

-- updatePriority[0] -- FRAME ------------------------------------------------

UTGameMaster.updatePriority[0] = function(self, voice, time)
	
	local leftTime = time - 1000000 * voice.offset - voice.timeStart
	
	if (leftTime > 0) then			
		
		if (voice.probas ~= nil and #voice.probas ~= 0) then
		
			local randValue = math.random()
			
			for index, probas in pairs(voice.probas) do
			
				if (randValue <= probas) then
				
					quartz.framework.audio.loadsound(voice.paths[index])
					break
					
				end
				randValue = randValue - probas
			
			end
			
		else
			
			local randPath = 1
			if( #voice.paths > 1 ) then
			
				randPath = math.random( 1, #voice.paths)
				
			end
			
			quartz.framework.audio.loadsound(voice.paths[randPath])
			
		end
				
		quartz.framework.audio.loadvolume(game.settings.audio["volume:gm"])
		quartz.framework.audio.playsound()
		
		self.nextFreeTime = time + quartz.framework.audio.getduration() * 1000000
						
		self:UnRegisterSound(voice)
	end

end

-- updatePriority[1] -- Reward 0 ---------------------------------------------

UTGameMaster.updatePriority[1] = function(self, voice, time)
	
	local leftTime = time - 1000000 * voice.offset - voice.timeStart
	
	if (leftTime > 0) then		

		local time = quartz.system.time.gettimemicroseconds()
		
		local IsPriorityZeroArea = false
		
		for index, area in pairs(self.areaPriorityZero) do
		
			if (area ~= nil and time > area.beginTime and time < area.endTime) then
			
				IsPriorityZeroArea = true
				break
			end
		
		end	
	
		if (time > self.nextFreeTime and IsPriorityZeroArea == false ) then			

			local randValue = math.random()
			
			if (randValue <= voice.proba) then
			
				if (voice.probas ~= nil and #voice.probas ~= 0) then
				
					local randPath = math.random()
					
					for index, probas in pairs(voice.probas) do
					
						if (randValue <= probas) then
						
							quartz.framework.audio.loadsound(voice.paths[index])
							break
							
						end
						randValue = randValue - probas
					
					end
					
				else
				
					local randPath = 1
					if( #voice.paths > 1 ) then
					
						randPath = math.random( 1, #voice.paths)
						
					end
					quartz.framework.audio.loadsound(voice.paths[randPath])
					
				end
				
				quartz.framework.audio.loadvolume(game.settings.audio["volume:gm"])
				quartz.framework.audio.playsound()
				
				self.nextFreeTime = time + quartz.framework.audio.getduration() * 1000000
			
			end
			
			self:UnRegisterSound(voice)
			
		end
		
	end

end

-- updatePriority[2] -- Reward 1 ---------------------------------------------

UTGameMaster.updatePriority[2] = function(self, voice, time)
	
	local leftTime = time - 1000000 * voice.offset - voice.timeStart	

	if (leftTime > 0) then		
	
		local time = quartz.system.time.gettimemicroseconds()
		
		local IsPriorityZeroArea = false
		
		for index, area in pairs(self.areaPriorityZero) do
		
			if (area ~= nil and time > area.beginTime and time < area.endTime) then
			
				IsPriorityZeroArea = true
				break
			end
		
		end	
	
		if (time > self.nextFreeTime and IsPriorityZeroArea == false ) then			
		
			local randValue = math.random()
			
			if (randValue <= voice.proba) then
			
				if (voice.probas ~= nil and #voice.probas ~= 0) then
				
					local randPath = math.random()
					
					for index, probas in pairs(voice.probas) do
					
						if (randValue <= probas) then
						
							quartz.framework.audio.loadsound(voice.paths[index])
							break
							
						end
						randValue = randValue - probas
					
					end
					
				else
					local randPath = 1
					if( #voice.paths > 1 ) then
					
						randPath = math.random( 1, #voice.paths)
						
					end
					quartz.framework.audio.loadsound(voice.paths[randPath])
					
				end
				
				quartz.framework.audio.loadvolume(game.settings.audio["volume:gm"])
				quartz.framework.audio.playsound()
				
				self.nextFreeTime = time + quartz.framework.audio.getduration() * 1000000
			
			end
			
			self:UnRegisterSound(voice)--
			
		end
		
		self:UnRegisterSound(voice)-- dont play if desynchronized with the action
		
	end

end

-- updatePriority[3] -- Reward 2 ---------------------------------------------

UTGameMaster.updatePriority[3] = function(self, voice, time)
	
	local leftTime = time - 1000000 * voice.offset - voice.timeStart	
	if (leftTime > 0) then	
	
		local time = quartz.system.time.gettimemicroseconds()
		
		local IsPriorityZeroArea = false
		
		for index, area in pairs(self.areaPriorityZero) do
		
			if (area ~= nil and time > area.beginTime and time < area.endTime) then
			
				IsPriorityZeroArea = true
				break
			end
		
		end	
	
	--print("time ", time)
	--print("self.nextFreeTime ", self.nextFreeTime)
		if (time > self.nextFreeTime + 10 * 1000000 and IsPriorityZeroArea == false ) then	 -- to be played only if 10 sec of silence	
		
			local randValue = math.random()
			
			if (randValue <= voice.proba) then
			
				if (voice.probas ~= nil and #voice.probas ~= 0) then
				
					local randPath = math.random()
					
					for index, probas in pairs(voice.probas) do
					
						if (randValue <= probas) then
						
							quartz.framework.audio.loadsound(voice.paths[index])
							break
							
						end
						randValue = randValue - probas
					
					end
					
				else
				
					local randPath = 1
					if( #voice.paths > 1 ) then
					
						randPath = math.random( 1, #voice.paths)
						
					end
					quartz.framework.audio.loadsound(voice.paths[randPath])
					
				end
				
				quartz.framework.audio.loadvolume(game.settings.audio["volume:gm"])
				quartz.framework.audio.playsound()
				
				self.nextFreeTime = time + quartz.framework.audio.getduration() * 1000000
			
			end
			
		end
		
		self:UnRegisterSound(voice) -- dont play if desynchronized with the action
		
	end

end

-- updatePriority[4] -- Ambiance ---------------------------------------------

UTGameMaster.updatePriority[4] = function(self, voice, time)
	
	local IsPriorityZeroArea = false
	
	for index, area in pairs(self.areaPriorityZero) do
	
		if (area ~= nil and time > area.beginTime and time < area.endTime) then
		
			IsPriorityZeroArea = true
			break
		end
	
	end	

	--time > self.lastActionTime + 10 * 1000000
	if (time > self.nextFreeTime + 10 * 1000000 and IsPriorityZeroArea == false ) then -- to be played only if 10 sec of silence and nothing happens	
	
		local randValue = math.random()
		
		if (randValue <= voice.proba) then
		
			if (voice.probas ~= nil and #voice.probas ~= 0) then
			
				local randPath = math.random()
				
				for index, probas in pairs(voice.probas) do
				
					if (randValue <= probas) then
					
						quartz.framework.audio.loadsound(voice.paths[index])
						break
						
					end
					randValue = randValue - probas
				
				end
				
			else
			
				local randPath = 1
				if( #voice.paths > 1 ) then
				
					randPath = math.random( 1, #voice.paths)
					
				end
				quartz.framework.audio.loadsound(voice.paths[randPath])
				
			end
			
			quartz.framework.audio.loadvolume(game.settings.audio["volume:gm"])
			quartz.framework.audio.playsound()
			
			self.nextFreeTime = time + quartz.framework.audio.getduration() * 1000000
		
		end
		
	end
	
end