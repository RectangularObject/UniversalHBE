if not game:IsLoaded() then game.Loaded:Wait() end

local EntityHandler = require("./modules/EntityHandler.lua")
local HitboxHandler = require("./modules/HitboxHandler.lua")
local UI = require("./modules/UI.lua")
local VisualHandler = require("./modules/VisualHandler.lua")
local gameoverride = require("./modules/Overrides.lua")
local lib = UI.Library

UI:Load()
EntityHandler:Load()
VisualHandler:Load()
HitboxHandler:Load()

lib:Notify("hai :3", nil, 8549385246)
lib:Notify(`Press {lib.ToggleKeybind.Value} to open the menu`, nil, 8549385246)
if gameoverride then lib:Notify("This game has custom support!", nil, 8549385246) end

lib:OnUnload(function()
	VisualHandler:Unload()
	EntityHandler:Unload()
	HitboxHandler:Unload()
end)
