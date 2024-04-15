if not game:IsLoaded() then game.Loaded:Wait() end

local EntityHandler = require("./modules/EntityHandler.lua")
local HitboxHandler = require("./modules/HitboxHandler.lua")
local UI = require("./modules/UI.lua")
local VisualHandler = require("./modules/VisualHandler.lua")
local gameoverride = require("./modules/Overrides.lua")

UI:Load()
EntityHandler:Load()
VisualHandler:Load()
HitboxHandler:Load()

UI.Library:OnUnload(function()
	HitboxHandler:Unload()
	VisualHandler:Unload()
	EntityHandler:Unload()
end)

UI.Toggles.hitboxToggle:OnChanged(HitboxHandler.updateHitbox)
UI.Toggles.collisionsToggle:OnChanged(HitboxHandler.updateHitbox)
UI.Options.hitboxSize:OnChanged(HitboxHandler.updateHitbox)
UI.Options.hitboxTransparency:OnChanged(HitboxHandler.updateHitbox)
UI.Options.customPartName:OnChanged(HitboxHandler.updateHitbox)
UI.Options.hitboxPartList:OnChanged(HitboxHandler.updateHitbox)
UI.Toggles.ignoreTeammates:OnChanged(HitboxHandler.updateHitbox)
UI.Toggles.ignoreFF:OnChanged(HitboxHandler.updateHitbox)
UI.Toggles.ignoreSitting:OnChanged(HitboxHandler.updateHitbox)
UI.Toggles.ignoreSelectedPlayers:OnChanged(HitboxHandler.updateHitbox)
UI.Options.ignorePlayerList:OnChanged(HitboxHandler.updateHitbox)
UI.Toggles.ignoreSelectedTeams:OnChanged(HitboxHandler.updateHitbox)
UI.Options.ignoreTeamList:OnChanged(HitboxHandler.updateHitbox)

UI.Library:Notify("hai :3", nil, 8549385246)
UI.Library:Notify(`Press {UI.Library.ToggleKeybind.Value} to open the menu`, nil, 8549385246)
if gameoverride then UI.Library:Notify("This game has custom support!", nil, 8549385246) end
