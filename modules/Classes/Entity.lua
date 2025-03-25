local localPlayer = cloneref(game:GetService("Players").LocalPlayer)
local Dumpster = require("../DumpsterModule.lua")
local Event = require("./Event.lua")
local multiIndex = require("./multiIndex.lua")

local EntityStatic = {}

local EntityPublicInstanceMethods = {}
local EntityProtectedInstanceMethods = {}
local EntityPrivateInstanceMethods = {}

EntityStatic.inheritables = {
	publicMethods = setmetatable({}, { __index = EntityPublicInstanceMethods }),
	protectedMethods = setmetatable({}, { __index = EntityProtectedInstanceMethods }),
}

export type EntityPublicInstanceVariables = {
	CharacterUpdatedEvent: Event.Event,
	DespawnEvent: Event.Event,
	DeathEvent: Event.Event,
	SeatEvent: Event.Event,
	TeamEvent: Event.Event,
	CustomEvent: Event.Event,
}
export type EntityProtectedInstanceVariables = {
	characterConnectionDumpster: typeof(Dumpster.new()),
}
type EntityPrivateInstanceVariables = {
	instance: Model,
}
type EntityInstanceVariables = EntityPublicInstanceVariables & EntityProtectedInstanceVariables & EntityPrivateInstanceVariables

type Entity = typeof(EntityPublicInstanceMethods) & EntityPublicInstanceVariables
type EntityProtected = Entity & typeof(EntityProtectedInstanceMethods) & EntityProtectedInstanceVariables
type EntityPrivate = EntityProtected & typeof(EntityPrivateInstanceMethods) & EntityPrivateInstanceVariables

function EntityStatic.new(entity): Entity
	local self: EntityInstanceVariables = {
		characterConnectionDumpster = Dumpster.new(),
		CharacterUpdatedEvent = Event.new(),
		DespawnEvent = Event.new(),
		DeathEvent = Event.new(),
		SeatEvent = Event.new(),
		TeamEvent = Event.new(),
		CustomEvent = Event.new(),
		instance = entity,
	}

	return setmetatable(self, {
		__index = multiIndex(EntityPublicInstanceMethods, EntityProtectedInstanceMethods, EntityPrivateInstanceMethods),
	}) :: Entity
end
function EntityPublicInstanceMethods:GetType(): string return "Entity" end
function EntityPublicInstanceMethods:GetCharacter(): Model? return self.instance end
function EntityPublicInstanceMethods:GetName(): string return tostring(self:GetCharacter()) end
function EntityPublicInstanceMethods:GetDisplayName(): string return self:GetName() end
function EntityPublicInstanceMethods:GetPosition(): Vector3?
	local cframe = self:GetCFrame()
	return if cframe then cframe.Position else nil
end
function EntityPublicInstanceMethods:GetCFrame(): CFrame?
	local character = self:GetCharacter()
	return if character then character:GetPivot() else nil
end
function EntityPublicInstanceMethods:GetHumanoid(): Humanoid?
	local character = self:GetCharacter()
	return if character then character:FindFirstChildWhichIsA("Humanoid") else nil
end
function EntityPublicInstanceMethods:GetRootPart(): Part?
	local humanoid = self:GetHumanoid()
	if humanoid then return humanoid.RootPart end
	local character = self:GetCharacter()
	if character then return character.PrimaryPart end
	return nil
end
function EntityPublicInstanceMethods:GetTeam(): Team? return nil end
function EntityPublicInstanceMethods:GetTeamColor(): Color3 return Color3.fromRGB(255, 255, 255) end

function EntityPublicInstanceMethods:isDead(): boolean
	local humanoid = self:GetHumanoid()
	return if humanoid then humanoid:GetState() == Enum.HumanoidStateType.Dead or humanoid.Health <= 0 else true
end
function EntityPublicInstanceMethods:isFFed(): boolean
	local character = self:GetCharacter()
	return if character then character:FindFirstChildWhichIsA("ForceField") ~= nil else false
end
function EntityPublicInstanceMethods:isSitting(): boolean
	local humanoid = self:GetHumanoid()
	return if humanoid then humanoid.Sit else false
end
function EntityPublicInstanceMethods:isTeammate(): boolean return localPlayer.Team == self:GetTeam() end

function EntityPublicInstanceMethods:AddCharacterUpdatedTrigger(): ()
	local character = self:GetCharacter()
	if not character then return end
	self.characterConnectionDumpster:dump(character.ChildAdded:Connect(function() self.CharacterUpdatedEvent:Fire() end))
	self.characterConnectionDumpster:dump(character.ChildRemoved:Connect(function() self.CharacterUpdatedEvent:Fire() end))
end
function EntityPublicInstanceMethods:AddDespawnEventTrigger(): ()
	local character = self:GetCharacter()
	if not character then return end
	self.characterConnectionDumpster:dump(character.AncestryChanged:Connect(function(_, parent)
		if parent == nil then self.DespawnEvent:Fire() end
	end))
end
function EntityPublicInstanceMethods:AddDeathEventTrigger(): ()
	local humanoid = self:GetHumanoid()
	if not humanoid then return end
	self.characterConnectionDumpster:dump(humanoid:GetPropertyChangedSignal("Health"):Connect(function()
		if humanoid.Health <= 0 then self.DeathEvent:Fire() end
	end))
end
function EntityPublicInstanceMethods:AddSeatEventTrigger(): ()
	local humanoid = self:GetHumanoid()
	if not humanoid then return end
	self.characterConnectionDumpster:dump(humanoid.Seated:Connect(function() self.SeatEvent:Fire() end))
end
function EntityPublicInstanceMethods:AddTeamEventTrigger(): () end
function EntityPublicInstanceMethods:AddCustomEventTrigger(): () end

function EntityPublicInstanceMethods:CleanUpConnections(): ()
	self.characterConnectionDumpster:burn()
	self.CharacterUpdatedEvent:Destroy()
	self.DespawnEvent:Destroy()
	self.DeathEvent:Destroy()
	self.SeatEvent:Destroy()
	self.TeamEvent:Destroy()
	self.CustomEvent:Destroy()
end

function EntityStatic.OverrideMethod(method: string, func: (...any) -> ...any): ()
	if EntityPublicInstanceMethods[method] then EntityPublicInstanceMethods[method] = func end
end

return EntityStatic
