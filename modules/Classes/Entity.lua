local localPlayer: Player = cloneref(game:GetService("Players")).LocalPlayer

local baseEntity = {}
baseEntity.__index = baseEntity

function baseEntity.new(ent)
	local entity = setmetatable({ entity = ent }, baseEntity)
	return entity
end
function baseEntity:GetType() return typeof(self.entity) end
function baseEntity:GetCharacter() return self.entity end
function baseEntity:GetName() return tostring(self:GetCharacter()) end
function baseEntity:GetDisplayName() return self:GetName() end
function baseEntity:GetPosition()
	local cframe = self:GetCFrame()
	return if cframe then cframe.Position else nil
end
function baseEntity:GetCFrame()
	local character = self:GetCharacter()
	return if character then character:GetPivot() else nil
end
function baseEntity:GetHumanoid()
	local character = self:GetCharacter()
	return if character then character:FindFirstChildWhichIsA("Humanoid") else nil
end
function baseEntity:GetRootPart()
	local character = self:GetCharacter()
	return if character then character.PrimaryPart else nil
end
function baseEntity:GetTeam() return nil end
function baseEntity:GetTeamColor() return Color3.fromRGB(255, 255, 255) end

function baseEntity:isDead()
	local humanoid = self:GetHumanoid()
	return if humanoid then humanoid:GetState() == Enum.HumanoidStateType.Dead else true
end
function baseEntity:isFFed()
	local character = self:GetCharacter()
	return if character then character:FindFirstChildWhichIsA("ForceField") ~= nil else false
end
function baseEntity:isSitting()
	local humanoid = self:GetHumanoid()
	return if humanoid then humanoid.Sit else false
end
function baseEntity:isTeammate() return localPlayer.Team == self:GetTeam() end

return baseEntity
