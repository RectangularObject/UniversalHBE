local entity = require("./Entity.lua")
local basePlayer = {}
basePlayer.__index = basePlayer
setmetatable(basePlayer, entity)

function basePlayer.new(plr)
	local player = entity.new(plr)
	setmetatable(player, basePlayer)
	return player
end
function basePlayer:GetName() return self.entity.Name end
function basePlayer:GetDisplayName() return self.entity.DisplayName end
function basePlayer:GetCharacter() return self.entity.Character end
function basePlayer:GetRootPart()
	local humanoid = self:GetHumanoid()
	return humanoid.RootPart
end
function basePlayer:GetTeam() return self.entity.Team end
function basePlayer:GetTeamColor() return self.entity.TeamColor.Color end

return basePlayer
