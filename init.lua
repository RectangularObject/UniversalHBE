if not game:IsLoaded() then game.Loaded:Wait() end
if getgenv().FurryHBE then return end
getgenv().FurryHBE = true

local EntityHandler = require("./modules/EntityHandler.lua")
local HitboxHandler = require("./modules/HitboxHandler.lua")
local UI = require("./modules/UI.lua")
local VisualHandler = require("./modules/VisualHandler.lua")
local override = require("./modules/Overrides.lua")

UI:Load()
VisualHandler:Load()
HitboxHandler:Load()
EntityHandler:Load()

HitboxHandler.updateHitbox()

UI.Library:Notify("hai :3")
UI.Library:Notify(`Press {UI.Library.ToggleKeybind.Value} to open the menu`)
if override then UI.Library:Notify("This game has custom support!") end
