local Override = {}

local Dumpster = require("./DumpsterModule.lua")
local Entity = require("./Classes/Entity.lua")
local Player = require("./Classes/Player.lua")

local overrideDumpsters = {}
local overrides = {
	--[[ [1430993116] = function() -- a literal baseplate
		Player.OverrideMethod("GetName", function(self): () return "my name is david" end)
		Player.OverrideMethod("GetDisplayName", function(self): () return "my name is edwin" end)
	end, ]]
}


local overriden = false
function Override:Load()
	local override = overrides[game.GameId]
	if override then
		overriden = true
		override()
	end
end
function Override:Unload()
	overriden = false
	for _, dumpster in overrideDumpsters do
		dumpster:burn()
	end
end
function Override:Loaded() return overriden end

return Override
