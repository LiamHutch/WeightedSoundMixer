
local class = {}
class.__index = class

----

local DEFAULT_WEIGHT = 1 -- because sometimes you're lazy and don't care
local DEFAULT_FADE = 1 -- 0 never changes, 1 instant changes, 0<->1 is lerp behavior

local MIX_MIN_DELTA = 1/144 -- won't mix unless this much time has passed
local STRENGTH_FADE_RATE = 1/60 -- fixed timestamp lerping on this rate
local PROCESS_TIME_CAP = 0.2 -- max amount of processing time between :Mix() calls

----

local function getMaxWeight(configs)
	local max = 0

	for index, config in next, configs do
		if config.Weight > max then
			max = config.Weight
		end
	end

	return max
end

local function processMix(config, maxWeight, deltaTime)
	local weightFade = config.Weight / maxWeight
	local newVolume = config.MaxVolume * weightFade

	-- no need to bother with extra work
	if config.FadeStrength == 1 then
		config.Sound.Volume = newVolume

	-- fixed rate lerping towards the new volume goal
	-- done this way to be more consistent
	else
		local workTime = math.min(deltaTime, PROCESS_TIME_CAP)

		while workTime >= STRENGTH_FADE_RATE do
			local current = config.Sound.Volume
			local diff = newVolume - current

			config.Sound.Volume = current + diff * config.FadeStrength
			workTime = workTime - STRENGTH_FADE_RATE
		end
	end
end

----

function class.new()
	local self = {
		Configs = {},
		WeightMax = 0,
		Destroyed = false,
		LastMix = os.clock()
	}

	return setmetatable(self, class)
end

----

function class:Destroy()
	self.Destroyed = true

	for index = #self.Configs, 1, -1 do
		local config = table.remove(self.Configs, index)

		if config then
			config.Sound = nil
		end
	end
end

function class:Mix()
	local delta = os.clock() - self.LastMix
	
	-- no reason to process if there hasn't been
	-- "substantial" time between calls
	if delta >= MIX_MIN_DELTA then
		self.LastMix = os.clock()

		-- cuz div/0 sucks
		-- safe to assume there flat out is no work
		-- to of WeightMax == 0 anyways
		if self.WeightMax > 0 then
			for _, config in next, self.Configs do
				processMix(config, self.WeightMax, delta)
			end
		end
	end
end

function class:Rebase()
	self.WeightMax = getMaxWeight(self.Configs)

	self:Mix()
end

function class:Add(sound, weight, fadeStrength)
	if self.Destroyed then
		warn("Cannot mix sound, mixer is destroyed", sound.Name)
		print(debug.traceback())

		return
	end

	----

	table.insert(self.Configs, {
		Sound = sound,
		MaxVolume = sound.Volume,
		OriginalVolume = sound.Volume,

		Weight = weight or DEFAULT_WEIGHT,
		FadeStrength = fadeStrength or DEFAULT_FADE,
	})

	self:Rebase()
end

function class:Remove(sound)
	for index = #self.Configs, 1, -1 do
		local config = self.Configs[index]

		if config.Sound == sound then
			table.remove(self.Configs, index)

			config.Sound.Volume = config.OriginalVolume
			config.Sound = nil

			self:Rebase()

			break
		end
	end
end

function class:SetVolume(sound, volume)
	for _, config in next, self.Configs do
		if config.Sound == sound then
			config.MaxVolume = volume
			config.OriginalVolume = volume

			self:Rebase()

			break
		end
	end
end

function class:SetWeight(sound, weight)
	for _, config in next, self.Configs do
		if config.Sound == sound then
			config.Weight = weight

			self:Rebase()

			break
		end
	end
end

function class:SetFadeStrength(sound, fadeStrength)
	for _, config in next, self.Configs do
		if config.Sound == sound then
			config.FadeStrength = fadeStrength

			self:Rebase()

			break
		end
	end
end

----

return class
