local classes = {
	Entity = require("./Classes/Entity.lua"),
	Player = require("./Classes/Player.lua"),
}

local overrides = {}

local override = overrides[game.GameId]
if override then
	for class, funcs in override do
		for func, callback in funcs do
			classes[class][func] = callback
		end
	end
end
return override ~= nil
