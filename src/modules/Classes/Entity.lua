local baseEntity = {}
baseEntity.__index = baseEntity

function baseEntity.new(ent)
	local entity = setmetatable({ entity = ent }, baseEntity)
	return entity
end
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
function baseEntity:GetHealth()
	local humanoid = self:GetHumanoid()
	return if humanoid then humanoid.Health else 0
end
function baseEntity:GetTeam() return nil end
function baseEntity:GetTeamColelse() return nil end
function baseEntity:isDead()
	local humanoid = self:GetHumanoid()
	return if humanoid then humanoid:GetState() == Enum.HumanoidStateType.Dead else true
end

return baseEntity
