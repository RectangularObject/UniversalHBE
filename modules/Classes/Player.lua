local Entity = require("./Entity.lua")

type PlayerImpl = Entity.EntityClass & {
	__index: PlayerImpl,
}

local module = {}
local Player: PlayerImpl = {} :: PlayerImpl
Player.__index = Player
setmetatable(Player, Entity)

export type PlayerClass = typeof(setmetatable({} :: PlayerImpl, {} :: PlayerImpl))

function module.new(plr: Player): PlayerClass
	local self = Entity.new(plr)
	return setmetatable(self, Player)
end
function Player:GetName() return self.instance.Name end
function Player:GetDisplayName() return self.instance.DisplayName end
function Player:GetCharacter() return self.instance.Character end
function Player:GetTeam() return self.instance.Team end
function Player:GetTeamColor() return self.instance.TeamColor.Color end

return module
