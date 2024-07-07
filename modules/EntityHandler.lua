local Event = require("./Classes/Event.lua")
local Player = require("./Classes/Player.lua")
local Players: Players = cloneref(game:GetService("Players"))
local entityHandler = {
	PlayerAdded = Event.new(),
	PlayerRemoving = Event.new(),
}
local playerList = {}
local connections = {}

local function PlayerAdded(player)
	playerList[player] = Player.new(player)
	entityHandler.PlayerAdded:Fire(playerList[player])
end
local function PlayerRemoving(player)
	entityHandler.PlayerRemoving:Fire(playerList[player])
	playerList[player] = nil
end

function entityHandler:Load()
	for i, player in ipairs(Players:GetPlayers()) do
		if i == 1 then continue end --skip localplayer
		PlayerAdded(player)
	end
	table.insert(connections, Players.PlayerAdded:Connect(PlayerAdded))
	table.insert(connections, Players.PlayerRemoving:Connect(PlayerRemoving))
end
function entityHandler:GetPlayers() return playerList end
function entityHandler:Unload()
	for _, connection in connections do
		connection:Disconnect()
	end
	table.clear(playerList)
end

return entityHandler
