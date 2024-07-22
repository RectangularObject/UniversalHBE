local entity = require("./Entity.lua")

type PlayerImpl = {
	__index: PlayerImpl,
	new: (plr: Player) -> PlayerEnt,
}
type PlayerEnt = typeof(setmetatable({} :: {}, {} :: PlayerImpl))

local basePlayer: PlayerImpl = {} :: PlayerImpl
basePlayer.__index = basePlayer
setmetatable(basePlayer, entity)

function basePlayer.new(plr)
	local player = entity.new(plr)
	setmetatable(player, basePlayer)
	return player
end
function basePlayer:GetName() return self.model.Name end
function basePlayer:GetDisplayName() return self.model.DisplayName end
function basePlayer:GetCharacter() return self.model.Character end
function basePlayer:GetTeam() return self.model.Team end
function basePlayer:GetTeamColor() return self.model.TeamColor.Color end

return basePlayer
