if not game:IsLoaded() then game.Loaded:Wait() end

local EntHandler = require("./modules/EntityHandler.lua")
local UI = require("./modules/UI.lua")
local VisHandler = require("./modules/VisualHandler.lua")
local gameoverride = require("./modules/Overrides.lua")

EntHandler:Load()
UI:Load()
VisHandler:Load()

if gameoverride then UI.Library:Notify("This game has custom support!", nil, 8549385246) end

UI.Library:OnUnload(function()
	VisHandler:Unload()
	EntHandler:Unload()
end)
