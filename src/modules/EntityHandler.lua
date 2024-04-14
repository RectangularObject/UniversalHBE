local Event = require("./Classes/Event.lua")
local Player = require("./Classes/Player.lua")
local PlayerService: Players = cloneref(game:GetService("Players"))
local entityHandler = {
	onPlayerAdded = Event.new(),
	onPlayerRemoved = Event.new(),
}
local connections = {}
local playerList = {}

local function PlayerAdded(player)
	playerList[player] = Player.new(player)
	entityHandler.onPlayerAdded:Fire(playerList[player])
end
local function PlayerRemoving(player)
	entityHandler.onPlayerRemoved:Fire(playerList[player])
	playerList[player] = nil
end

function entityHandler:Load()
	for i, player in ipairs(PlayerService:GetPlayers()) do
		if i == 1 then continue end --skip localplayer
		PlayerAdded(player)
	end
	table.insert(connections, PlayerService.PlayerAdded:Connect(PlayerAdded))
	table.insert(connections, PlayerService.PlayerRemoving:Connect(PlayerRemoving))
end
function entityHandler:GetPlayers() return playerList end
function entityHandler:Unload()
	for _, connection in pairs(connections) do
		connection:Disconnect()
	end

	playerList = nil
end

return entityHandler
