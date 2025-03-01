local localPlayer = cloneref(game:GetService("Players").LocalPlayer)

type EntityImpl = {
	__index: EntityImpl | any, -- stupid workaround for inheritance
	new: (entity: Instance) -> EntityClass,

	instance: Instance,

	GetType: (self: EntityClass) -> string,
	GetCharacter: (self: EntityClass) -> Model?,
	GetName: (self: EntityClass) -> string,
	GetDisplayName: (self: EntityClass) -> string,
	GetPosition: (self: EntityClass) -> Vector3?,
	GetCFrame: (self: EntityClass) -> CFrame?,
	GetHumanoid: (self: EntityClass) -> Humanoid?,
	GetRootPart: (self: EntityClass) -> BasePart?,
	GetTeam: (self: EntityClass) -> Team?,
	GetTeamColor: (self: EntityClass) -> Color3,

	isDead: (self: EntityClass) -> boolean,
	isFFed: (self: EntityClass) -> boolean,
	isSitting: (self: EntityClass) -> boolean,
	isTeammate: (self: EntityClass) -> boolean,
}

local module = {}
local Entity: EntityImpl = {} :: EntityImpl
Entity.__index = Entity

export type EntityClass = typeof(setmetatable({} :: EntityImpl, {} :: EntityImpl))

function Entity.new(entity)
	local self = setmetatable({}, Entity) :: EntityClass
	self.instance = entity
	return self
end
function Entity:GetType() return self.instance.ClassName end
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
	local humanoid = self:GetHumanoid()
	if humanoid then return humanoid.RootPart end
	local character = self:GetCharacter()
	if character then return character.PrimaryPart end
	return nil
end
function Entity:GetTeam() return nil end
function Entity:GetTeamColor() return Color3.fromRGB(255, 255, 255) end

function Entity:isDead()
	local humanoid = self:GetHumanoid()
	return if humanoid then humanoid:GetState() == Enum.HumanoidStateType.Dead or humanoid.Health <= 0 else true
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
