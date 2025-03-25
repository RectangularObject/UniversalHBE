local Entity = require("./Classes/Entity.lua")
local Player = require("./Classes/Player.lua")

local overrides = {
	--[[ [1430993116] = function() -- a literal baseplate
		Player.OverrideMethod("GetName", function(self): () return "my name is david" end)
		Player.OverrideMethod("GetDisplayName", function(self): () return "my name is edwin" end)
	end, ]]
}

local override = overrides[game.GameId]
if override then
	override()
	return true
end
return false
