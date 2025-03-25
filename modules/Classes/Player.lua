local Dumpster = require("../DumpsterModule.lua")
local Entity = require("./Entity.lua")
local Event = require("./Event.lua")
local multiIndex = require("./multiIndex.lua")

local PlayerStatic = {}
setmetatable(PlayerStatic, { __index = Entity })

local PlayerPublicInstanceMethods = setmetatable({}, { __index = Entity.inheritables.publicMethods })
local PlayerProtectedInstanceMethods = setmetatable({}, { __index = Entity.inheritables.protectedMethods })
local PlayerPrivateInstanceMethods = {}

PlayerStatic.inheritables = {}

type PlayerPublicInstanceVariables = Entity.EntityPublicInstanceVariables & {
	SpawnEvent: Event.Event,
}
type PlayerProtectedInstanceVariables = Entity.EntityProtectedInstanceVariables & {
	playerConnectionDumpster: typeof(Dumpster.new()),
}
type PlayerPrivateInstanceVariables = {
	instance: Player,
}
type PlayerInstanceVariables = PlayerPublicInstanceVariables & PlayerProtectedInstanceVariables & PlayerPrivateInstanceVariables

type Player = typeof(PlayerPublicInstanceMethods) & PlayerPublicInstanceVariables
type PlayerProtected = Player & typeof(PlayerProtectedInstanceMethods) & PlayerProtectedInstanceVariables
type PlayerPrivate = PlayerProtected & typeof(PlayerPrivateInstanceMethods) & PlayerPrivateInstanceVariables

function PlayerStatic.new(plr): Player
	local self: PlayerInstanceVariables = {
		characterConnectionDumpster = Dumpster.new(),
		playerConnectionDumpster = Dumpster.new(),
		CharacterUpdatedEvent = Event.new(),
		SpawnEvent = Event.new(),
		DespawnEvent = Event.new(),
		DeathEvent = Event.new(),
		SeatEvent = Event.new(),
		TeamEvent = Event.new(),
		CustomEvent = Event.new(),
		instance = plr,
	}

	return setmetatable(self, {
		__index = multiIndex(PlayerPublicInstanceMethods, PlayerProtectedInstanceMethods, PlayerPrivateInstanceMethods),
	}) :: Player
end
function PlayerPublicInstanceMethods:GetType(): string return "Player" end
function PlayerPublicInstanceMethods:GetName(): string return self.instance.Name end
function PlayerPublicInstanceMethods:GetDisplayName(): string return self.instance.DisplayName end
function PlayerPublicInstanceMethods:GetCharacter(): Model? return self.instance.Character end
function PlayerPublicInstanceMethods:GetTeam(): Team? return self.instance.Team end
function PlayerPublicInstanceMethods:GetTeamColor(): Color3? return self.instance.TeamColor.Color end

function PlayerPublicInstanceMethods:AddSpawnedEventTrigger(): ()
	self.playerConnectionDumpster:dump(self.instance.CharacterAdded:Connect(function() self.SpawnEvent:Fire() end))
end
function PlayerPublicInstanceMethods:AddTeamEventTrigger(): ()
	self.playerConnectionDumpster:dump(self.instance:GetPropertyChangedSignal("Team"):Connect(function() self.TeamEvent:Fire() end))
end
function PlayerPublicInstanceMethods:RefreshCharacterDumpster(): ()
	self.characterConnectionDumpster:burn()
	self.characterConnectionDumpster = Dumpster.new()
end
function PlayerPublicInstanceMethods:CleanUpConnections(): ()
	self.characterConnectionDumpster:burn()
	self.playerConnectionDumpster:burn()
	self.SpawnEvent:Destroy()
	self.DespawnEvent:Destroy()
	self.DeathEvent:Destroy()
	self.SeatEvent:Destroy()
	self.TeamEvent:Destroy()
	self.CustomEvent:Destroy()
end

function PlayerStatic.OverrideMethod(method: string, func: (...any) -> ...any): ()
	if PlayerPublicInstanceMethods[method] then PlayerPublicInstanceMethods[method] = func end
end

return PlayerStatic
