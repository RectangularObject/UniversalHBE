local Event = require("./Classes/Event.lua")
local Player = require("./Classes/Player.lua")
local Players = cloneref(game:GetService("Players"))
local entityHandler = {
	PlayerAdded = Event.new(),
	PlayerRemoving = Event.new(),
}
local playerList = {}
local connections = {}

local function PlayerAdded(plr)
	playerList[plr] = Player.new(plr)
	entityHandler.PlayerAdded:Fire(playerList[plr])
end
local function PlayerRemoving(plr)
	entityHandler.PlayerRemoving:Fire(playerList[plr])
	playerList[plr] = nil
end

function entityHandler:Load()
	for i, plr in ipairs(Players:GetPlayers()) do
		if i == 1 then continue end --skip localplayer
		PlayerAdded(plr)
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
