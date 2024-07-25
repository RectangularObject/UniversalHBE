local Entity = require("./Entity.lua")

type PlayerImpl = {
	__index: PlayerImpl,
	new: (plr: Player) -> PlayerEnt,
}
type PlayerEnt = typeof(setmetatable({} :: {}, {} :: PlayerImpl))

local basePlayer: PlayerImpl = {} :: PlayerImpl
basePlayer.__index = basePlayer
setmetatable(basePlayer, Entity)

function basePlayer.new(plr)
	local player = Entity.new(plr)
	return setmetatable(player, basePlayer)
end
function basePlayer:GetName() return self.instance.Name end
function basePlayer:GetDisplayName() return self.instance.DisplayName end
function basePlayer:GetCharacter() return self.instance.Character end
function basePlayer:GetTeam() return self.instance.Team end
function basePlayer:GetTeamColor() return self.instance.TeamColor.Color end

return basePlayer
