local _linorialib = request({ Url = "https://raw.githubusercontent.com/RectangularObject/LinoriaLib/main/Library.lua" })
assert(_linorialib.StatusCode == 200, "Failed to request Library.lua")
local _savemanager = request({ Url = "https://raw.githubusercontent.com/RectangularObject/LinoriaLib/main/addons/SaveManager.lua" })
assert(_savemanager.StatusCode == 200, "Failed to request SaveManager.lua")

local EntityHandler = require("./EntityHandler.lua")
local HitboxHandler = require("./HitboxHandler.lua")
local VisualHandler = require("./VisualHandler.lua")

local LinoriaLib = (loadstring(_linorialib.Body) :: (...any) -> ...any)()
local SaveManager = (loadstring(_savemanager.Body) :: (...any) -> ...any)()
SaveManager:SetLibrary(LinoriaLib)
SaveManager:SetFolder("UniversalHBE")

local UI = {
	Library = LinoriaLib,
	Options = getgenv().Options,
	Toggles = getgenv().Toggles,
}

function UI:Load()
	local mainWindow = LinoriaLib:CreateWindow({
		Title = "Universal Hitbox Expander",
		TabPadding = 6,
		MenuFadeTime = 0,
		Size = UDim2.fromOffset(550, 620),
	})
	local mainTab = mainWindow:AddTab("Main")

	local hitboxGroup = mainTab:AddLeftGroupbox("Hitbox Expander")
	local hitboxToggle = hitboxGroup:AddToggle("hitboxToggle", { Text = "Toggle", Risky = true })
	hitboxToggle:AddKeyPicker("hitboxToggleBind", { Default = "End", Text = "Hitbox Keybind", SyncToggleState = true })
	local collisionsToggle = hitboxGroup:AddToggle("collisionsToggle", { Text = "Collisions" })

	local hitboxSize = hitboxGroup:AddSlider("hitboxSize", { Text = "Size", Min = 2, Max = 100, Default = 5, Rounding = 0 })
	local hitboxTransparency = hitboxGroup:AddSlider("hitboxTransparency", { Text = "Transparency", Min = 0, Max = 1, Default = 0.5, Rounding = 2 })
	local customPartName = hitboxGroup:AddInput("customPartName", { Text = "Custom Part Name", Default = "HeadHB" })
	local hitboxPartList = hitboxGroup:AddDropdown("hitboxPartList", {
		Text = "Body Parts",
		AllowNull = true,
		Multi = true,
		Values = { "Custom Part", "Head", "HumanoidRootPart", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg" },
		Default = "HumanoidRootPart",
	})

	local espGroup = mainTab:AddLeftGroupbox("ESP")
	local nameToggle = espGroup:AddToggle("nameToggle", { Text = "Name" })
	nameToggle:OnChanged(function(value) VisualHandler.drawName = value end)
	local nameFillColor = nameToggle:AddColorPicker("nameFillColor", { Title = "Fill Color", Default = Color3.fromRGB(255, 255, 255) })
	nameFillColor:OnChanged(function(value) VisualHandler.nameFillColor = value end)
	local nameOutlineColor = nameToggle:AddColorPicker("nameOutlineColor", { Title = "Outline Color", Default = Color3.fromRGB(0, 0, 0) })
	nameOutlineColor:OnChanged(function(value) VisualHandler.nameOutlineColor = value end)
	local nameUseTeamColor = espGroup:AddToggle("nameUseTeamColor", { Text = "Use Team Color For Name" })
	nameUseTeamColor:OnChanged(function(value) VisualHandler.nameUseTeamColor = value end)
	local nameType = espGroup:AddDropdown("nameType", {
		Text = "Name Type",
		AllowNull = false,
		Multi = false,
		Values = { "Account Name", "Display Name" },
		Default = "Display Name",
	})
	nameType:OnChanged(function(value) VisualHandler.nameType = if value == "Display Name" then 2 else 1 end)

	local chamsToggle = espGroup:AddToggle("chamsToggle", { Text = "Chams" })
	local chamsFillColor = chamsToggle:AddColorPicker("chamsFillColor", { Title = "Fill Color", Default = Color3.fromRGB(0, 0, 0), Transparency = 0.5 })
	chamsFillColor:OnChanged(function(value)
		VisualHandler.chamsFillColor = value
		VisualHandler.chamsFillTransparency = chamsFillColor.Transparency
	end)
	local chamsOutlineColor = chamsToggle:AddColorPicker("chamsOutlineColor", { Title = "Outline Color", Default = Color3.fromRGB(255, 255, 255), Transparency = 0.5 })
	chamsOutlineColor:OnChanged(function(value)
		VisualHandler.chamsOutlineColor = value
		VisualHandler.chamsOutlineTransparency = chamsOutlineColor.Transparency
	end)
	local chamsUseTeamColor = espGroup:AddToggle("chamsUseTeamColor", { Text = "Use Team Color For Chams" })
	chamsUseTeamColor:OnChanged(function(value) VisualHandler.chamsUseTeamColor = value end)
	local chamsDepthMode = espGroup:AddDropdown("chamsDepthMode", {
		Text = "Chams Depth Mode",
		AllowNull = false,
		Multi = false,
		Values = { "Occluded", "AlwaysOnTop" },
		Default = "Occluded",
	})
	chamsDepthMode:OnChanged(function(value) VisualHandler.chamsDepthMode = Enum.HighlightDepthMode[value] end)

	local miscGroup = mainTab:AddLeftGroupbox("Misc")
	miscGroup:AddLabel("Toggle UI"):AddKeyPicker("menuKeybind", { Default = "Delete", NoUI = true, Text = "Menu Keybind" })
	miscGroup:AddButton({ Text = "Unload", DoubleClick = true, Func = LinoriaLib.Unload })

	local ignoresGroup = mainTab:AddRightGroupbox("Ignores")
	local ignoreTeammates = ignoresGroup:AddToggle("ignoreTeammates", { Text = "Ignore Teammates" })
	ignoreTeammates:OnChanged(function(value) VisualHandler.ignoreTeammates = value end)
	local ignoreFF = ignoresGroup:AddToggle("ignoreFF", { Text = "Ignore Forcefielded Players" })
	ignoreFF:OnChanged(function(value) VisualHandler.ignoreFF = value end)
	local ignoreSitting = ignoresGroup:AddToggle("ignoreSitting", { Text = "Ignore Sitting Players" })
	ignoreSitting:OnChanged(function(value) VisualHandler.ignoreSitting = value end)
	local ignoreSelectedPlayers = ignoresGroup:AddToggle("ignoreSelectedPlayers", { Text = "Ignore Selected Players" })
	ignoreSelectedPlayers:OnChanged(function(value) VisualHandler.ignoreSelectedPlayers = value end)
	local ignorePlayerList = ignoresGroup:AddDropdown("ignorePlayerList", { Text = "Players", Multi = true, AllowNull = true, Values = {} })
	ignorePlayerList:OnChanged(function(value) VisualHandler.ignorePlayerList = ignorePlayerList:GetActiveValues() end)
	local ignoreSelectedTeams = ignoresGroup:AddToggle("ignoreSelectedTeams", { Text = "Ignore Selected Teams" })
	ignoreSelectedTeams:OnChanged(function(value) VisualHandler.ignoreSelectedTeams = value end)
	local ignoreTeamList = ignoresGroup:AddDropdown("ignoreTeamList", { Text = "Teams", Multi = true, SpecialType = "Team" })
	ignoreTeamList:OnChanged(function(value) VisualHandler.ignoreTeamList = value end)

	local function updateList() -- Force linoria to update dropdown lists
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

	for _, v in
		{
			hitboxToggle,
			collisionsToggle,
			hitboxSize,
			hitboxTransparency,
			customPartName,
			hitboxPartList,
			ignoreTeammates,
			ignoreFF,
			ignoreSitting,
			ignoreSelectedPlayers,
			ignorePlayerList,
			ignoreSelectedTeams,
			ignoreTeamList,
		}
	do
		v.Callback = HitboxHandler.updateHitbox
	end

	UI.Library:OnUnload(function()
		hitboxToggle:SetValue(false)
		HitboxHandler:Unload()
		VisualHandler:Unload()
		EntityHandler:Unload()
		getgenv().FurryHBE = nil
	end)

	LinoriaLib.ToggleKeybind = UI.Options.menuKeybind
	SaveManager:BuildConfigSection(mainTab)
	SaveManager:LoadAutoloadConfig()

	return self
end

return UI
