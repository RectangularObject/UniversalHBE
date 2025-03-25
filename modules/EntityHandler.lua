local Dumpster = require("./DumpsterModule.lua")
local Entity = require("./Classes/Entity.lua")
local Event = require("./Classes/Event.lua")
local Player = require("./Classes/Player.lua")
local Players = cloneref(game:GetService("Players"))
local entityHandler = {
	PlayerAdded = Event.new(),
	PlayerRemoving = Event.new(),
	EntityAdded = Event.new(),
	EntityRemoving = Event.new(),
}
local playerList = {}
local entityList = {}
local connections = Dumpster.new()

local function PlayerAdded(plr: Player)
	playerList[plr] = Player.new(plr)
	local playerObj = playerList[plr]

	playerObj:AddCharacterUpdatedTrigger()
	playerObj:AddSpawnedEventTrigger()
	playerObj:AddDespawnEventTrigger()
	playerObj:AddDeathEventTrigger()
	playerObj:AddSeatEventTrigger()
	playerObj:AddTeamEventTrigger()
	playerObj:AddCustomEventTrigger()

	playerObj.SpawnEvent:Connect(function()
		playerObj:AddCharacterUpdatedTrigger()
		playerObj:AddDespawnEventTrigger()
		playerObj:AddDeathEventTrigger()
		playerObj:AddSeatEventTrigger()
	end)
	playerObj.DespawnEvent:Connect(function() playerObj:RefreshCharacterDumpster() end)

	entityHandler.PlayerAdded:Fire(playerList[plr])
end
local function PlayerRemoving(plr: Player)
	local playerObj = playerList[plr]
	if not playerObj then return end
	playerObj:CleanUpConnections()
	entityHandler.PlayerRemoving:Fire(playerObj)
	playerList[plr] = nil
end
local function EntityAdded(ent: Model)
	entityList[ent] = Entity.new(ent)
	local entityObj = entityList[ent]

	entityObj:AddCharacterUpdatedTrigger()
	entityObj:AddDespawnEventTrigger()
	entityObj:AddDeathEventTrigger()
	entityObj:AddSeatEventTrigger()
	entityObj:AddTeamEventTrigger()
	entityObj:AddCustomEventTrigger()

	entityHandler.EntityAdded:Fire(entityList[ent])
end
local function EntityRemoving(ent: Model)
	local entityObj = entityList[ent]
	entityObj:CleanUpConnections()
	entityHandler.EntityRemoving:Fire(entityObj)
	entityList[ent] = nil
end

function entityHandler:Load()
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= Players.LocalPlayer then PlayerAdded(plr) end
	end
	connections:dump(Players.PlayerAdded:Connect(PlayerAdded))
	connections:dump(Players.PlayerRemoving:Connect(PlayerRemoving))
end
function entityHandler:addEntity(ent) EntityAdded(ent) end
function entityHandler:removeEntity(ent) EntityRemoving(ent) end
function entityHandler:GetPlayers() return playerList end
function entityHandler:GetEntities() return entityList end
function entityHandler:Unload()
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= Players.LocalPlayer then PlayerRemoving(plr) end
	end
	connections:burn()
	self = nil
end

return entityHandler
