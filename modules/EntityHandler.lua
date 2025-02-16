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
local connections = {}

local function PlayerAdded(plr)
	playerList[plr] = Player.new(plr)
	entityHandler.PlayerAdded:Fire(playerList[plr])
end
local function PlayerRemoving(plr)
	entityHandler.PlayerRemoving:Fire(playerList[plr])
	playerList[plr] = nil
end
local function EntityAdded(ent)
	entityList[ent] = Entity.new(ent)
	entityHandler.EntityAdded:Fire(entityList[ent])
end
local function EntityRemoving(ent)
	entityHandler.EntityAdded:Fire(entityList[ent])
	entityList[ent] = nil
end

function entityHandler:Load()
	for i, plr in ipairs(Players:GetPlayers()) do
		if plr == Players.LocalPlayer then continue end
		PlayerAdded(plr)
	end
	table.insert(connections, Players.PlayerAdded:Connect(PlayerAdded))
	table.insert(connections, Players.PlayerRemoving:Connect(PlayerRemoving))
end
function entityHandler:addEntity(ent) EntityAdded(ent) end
function entityHandler:removeEntity(ent) EntityRemoving(ent) end
function entityHandler:GetPlayers() return playerList end
function entityHandler:GetEntities() return entityList end
function entityHandler:Unload()
	for _, connection in connections do
		connection:Disconnect()
	end
	table.clear(playerList)
end

return entityHandler
