if not game:IsLoaded() then game.Loaded:Wait() end
if _G.FurryHBE then return end
_G.FurryHBE = true

local EntityHandler = require("./modules/EntityHandler.lua")
local HitboxHandler = require("./modules/HitboxHandler.lua")
local UI = require("./modules/UI.lua")
local VisualHandler = require("./modules/VisualHandler.lua")
local override = require("./modules/Overrides.lua")

UI:Load()

local ignorePlayerList = UI.Options.ignorePlayerList
local function updateList()
	ignorePlayerList:SetValues()
	ignorePlayerList:Display()
end
for _, player in EntityHandler:GetPlayers() do
	table.insert(ignorePlayerList.Values, player:GetName())
end
updateList()
EntityHandler.PlayerAdded:Connect(function(player)
	table.insert(ignorePlayerList.Values, player:GetName())
	updateList()
end)
EntityHandler.PlayerRemoving:Connect(function(player)
	table.remove(ignorePlayerList.Values, table.find(ignorePlayerList.Values, player:GetName()))
	updateList()
end)

EntityHandler:Load()
VisualHandler:Load()
HitboxHandler:Load()

local configList = {
	UI.Toggles.hitboxToggle,
	UI.Toggles.collisionsToggle,
	UI.Options.hitboxSize,
	UI.Options.hitboxTransparency,
	UI.Options.customPartName,
	UI.Options.hitboxPartList,
	UI.Toggles.ignoreTeammates,
	UI.Toggles.ignoreFF,
	UI.Toggles.ignoreSitting,
	UI.Toggles.ignoreSelectedPlayers,
	ignorePlayerList,
	UI.Toggles.ignoreSelectedTeams,
	UI.Options.ignoreTeamList,
}
for _, v in configList do
	v.Callback = HitboxHandler.updateHitbox
end

UI.Library:OnUnload(function()
	for _, v in configList do
		v.Callback = nil
	end
	HitboxHandler:Unload()
	VisualHandler:Unload()
	EntityHandler:Unload()
	_G.FurryHBE = nil
end)

HitboxHandler.updateHitbox()

UI.Library:Notify("hai :3")
UI.Library:Notify(`Press {UI.Library.ToggleKeybind.Value} to open the menu`)
if override then UI.Library:Notify("This game has custom support!") end
