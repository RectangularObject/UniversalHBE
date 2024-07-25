local localPlayer = cloneref(game:GetService("Players")).LocalPlayer

type EntityImpl = {
	__index: EntityImpl,
	new: (ent: Instance) -> Entity,
	GetType: (self: Entity) -> string,
	GetCharacter: (self: Entity) -> Model?,
	GetName: (self: Entity) -> string,
	GetDisplayName: (self: Entity) -> string,
	GetPosition: (self: Entity) -> Vector3?,
	GetCFrame: (self: Entity) -> CFrame?,
	GetHumanoid: (self: Entity) -> Humanoid?,
	GetRootPart: (self: Entity) -> BasePart?,
	GetTeam: (self: Entity) -> Team?,
	GetTeamColor: (self: Entity) -> Color3,
	isDead: (self: Entity) -> boolean,
	isFFed: (self: Entity) -> boolean,
	isSitting: (self: Entity) -> boolean,
	isTeammate: (self: Entity) -> boolean,
}
type Entity = typeof(setmetatable({} :: { instance: Instance }, {} :: EntityImpl))

local Entity: EntityImpl = {} :: EntityImpl
Entity.__index = Entity

function Entity.new(entity) return setmetatable({ instance = entity }, Entity) end
function Entity:GetType() return typeof(self.instance) end
function Entity:GetCharacter() return self.instance end
function Entity:GetName() return tostring(self:GetCharacter()) end
function Entity:GetDisplayName() return self:GetName() end
function Entity:GetPosition()
	local cframe = self:GetCFrame()
	return if cframe then cframe.Position else nil
end
function Entity:GetCFrame()
	local character = self:GetCharacter()
	return if character then character:GetPivot() else nil
end
function Entity:GetHumanoid()
	local character = self:GetCharacter()
	return if character then character:FindFirstChildWhichIsA("Humanoid") else nil
end
function Entity:GetRootPart()
	local character = self:GetCharacter()
	return if character then character.PrimaryPart else nil
end
function Entity:GetTeam() return nil end
function Entity:GetTeamColor() return Color3.fromRGB(255, 255, 255) end

function Entity:isDead()
	local humanoid = self:GetHumanoid()
	return if humanoid then humanoid:GetState() == Enum.HumanoidStateType.Dead else true
end
function Entity:isFFed()
	local character = self:GetCharacter()
	return if character then character:FindFirstChildWhichIsA("ForceField") ~= nil else false
end
function Entity:isSitting()
	local humanoid = self:GetHumanoid()
	return if humanoid then humanoid.Sit else false
end
function Entity:isTeammate() return localPlayer.Team == self:GetTeam() end

return Entity
