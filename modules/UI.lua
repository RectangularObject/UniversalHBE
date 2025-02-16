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
		Title = "Universal Hitbox Extender",
		TabPadding = 6,
		MenuFadeTime = 0,
		Size = UDim2.fromOffset(550, 620),
	})
	local mainTab = mainWindow:AddTab("Main")

	local hitboxGroup = mainTab:AddLeftGroupbox("Hitbox Extender")
	local hitboxToggle = hitboxGroup:AddToggle("hitboxToggle", { Text = "Toggle", Risky = true })
	hitboxToggle:AddKeyPicker("hitboxToggleBind", { Default = "End", Text = "Hitbox Keybind", SyncToggleState = true })
	local collisionsToggle = hitboxGroup:AddToggle("collisionsToggle", { Text = "Collisions" })

	hitboxToggle:OnChanged(function(value) HitboxHandler.extendHitbox = value end)
	collisionsToggle:OnChanged(function(value) HitboxHandler.hitboxCanCollide = value end)

	local hitboxSize = hitboxGroup:AddSlider("hitboxSize", { Text = "Size", Min = 2, Max = 100, Default = 5, Rounding = 0 })
	local hitboxTransparency = hitboxGroup:AddSlider("hitboxTransparency", { Text = "Transparency", Min = 0, Max = 1, Default = 0.5, Rounding = 2 })
	local customPartName = hitboxGroup:AddInput("customPartName", { Text = "Custom Part Name", Default = "HeadHB" })
	local hitboxPartList = hitboxGroup:AddDropdown("hitboxPartList", {
		Text = "Body Parts",
		AllowNull = true,
		Multi = true,
		Values = { "Custom Part", "Head", "RootPart", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg" },
		Default = "RootPart",
	})

	hitboxSize:OnChanged(function(value) HitboxHandler.hitboxSize = Vector3.new(value, value, value) end)
	hitboxTransparency:OnChanged(function(value) HitboxHandler.hitboxTransparency = value end)
	customPartName:OnChanged(function(value)
		HitboxHandler.customPartName = value
		HitboxHandler:updatePartList(hitboxPartList:GetActiveValues())
	end)
	hitboxPartList:OnChanged(function(value) HitboxHandler:updatePartList(hitboxPartList:GetActiveValues()) end)

	local espGroup = mainTab:AddLeftGroupbox("ESP")
	local nameToggle = espGroup:AddToggle("nameToggle", { Text = "Name" })
	nameToggle:AddColorPicker("nameFillColor", { Title = "Fill Color", Default = Color3.fromRGB(255, 255, 255) })
	nameToggle:AddColorPicker("nameOutlineColor", { Title = "Outline Color", Default = Color3.fromRGB(0, 0, 0) })
	local nameUseTeamColor = espGroup:AddToggle("nameUseTeamColor", { Text = "Use Team Color For Name" })
	local nameType = espGroup:AddDropdown("nameType", {
		Text = "Name Type",
		AllowNull = false,
		Multi = false,
		Values = { "Account Name", "Display Name" },
		Default = "Display Name",
	})

	-- Personal note: Colorpickers return their parent obj, not themselves, so you can't do nameFillColor:OnChanged
	nameToggle:OnChanged(function(value) VisualHandler.drawName = value end)
	UI.Options["nameFillColor"]:OnChanged(function(value) VisualHandler.nameFillColor = value end)
	UI.Options["nameOutlineColor"]:OnChanged(function(value) VisualHandler.nameOutlineColor = value end)
	nameUseTeamColor:OnChanged(function(value) VisualHandler.nameUseTeamColor = value end)
	nameType:OnChanged(function(value) VisualHandler.nameType = if value == "Display Name" then 2 else 1 end)

	local chamsToggle = espGroup:AddToggle("chamsToggle", { Text = "Chams" })
	chamsToggle:AddColorPicker("chamsFillColor", { Title = "Fill Color", Default = Color3.fromRGB(0, 0, 0), Transparency = 0.5 })
	chamsToggle:AddColorPicker("chamsOutlineColor", { Title = "Outline Color", Default = Color3.fromRGB(255, 255, 255), Transparency = 0.5 })
	local chamsUseTeamColor = espGroup:AddToggle("chamsUseTeamColor", { Text = "Use Team Color For Chams" })
	local chamsDepthMode = espGroup:AddDropdown("chamsDepthMode", {
		Text = "Chams Depth Mode",
		AllowNull = false,
		Multi = false,
		Values = { "Occluded", "AlwaysOnTop" },
		Default = "Occluded",
	})

	chamsToggle:OnChanged(function(value) VisualHandler.drawChams = value end)
	UI.Options["chamsFillColor"]:OnChanged(function(color, transparency)
		VisualHandler.chamsFillColor = color
		VisualHandler.chamsFillTransparency = transparency
	end)
	UI.Options["chamsOutlineColor"]:OnChanged(function(color, transparency)
		VisualHandler.chamsOutlineColor = color
		VisualHandler.chamsOutlineTransparency = transparency
	end)
	chamsUseTeamColor:OnChanged(function(value) VisualHandler.chamsUseTeamColor = value end)
	chamsDepthMode:OnChanged(function(value) VisualHandler.chamsDepthMode = Enum.HighlightDepthMode[value] end)

	local miscGroup = mainTab:AddLeftGroupbox("Misc")
	miscGroup:AddLabel("Toggle UI"):AddKeyPicker("menuKeybind", { Default = "Delete", NoUI = true, Text = "Menu Keybind" })
	miscGroup:AddButton({ Text = "Unload", DoubleClick = true, Func = LinoriaLib.Unload })

	local ignoresGroup = mainTab:AddRightGroupbox("Ignores")
	local ignoreTeammates = ignoresGroup:AddToggle("ignoreTeammates", { Text = "Ignore Teammates" })
	local ignoreFF = ignoresGroup:AddToggle("ignoreFF", { Text = "Ignore Forcefielded Players" })
	local ignoreSitting = ignoresGroup:AddToggle("ignoreSitting", { Text = "Ignore Sitting Players" })
	local ignoreSelectedPlayers = ignoresGroup:AddToggle("ignoreSelectedPlayers", { Text = "Ignore Selected Players" })
	local ignorePlayerList = ignoresGroup:AddDropdown("ignorePlayerList", { Text = "Players", Multi = true, AllowNull = true, Values = {} })
	local ignoreSelectedTeams = ignoresGroup:AddToggle("ignoreSelectedTeams", { Text = "Ignore Selected Teams" })
	local ignoreTeamList = ignoresGroup:AddDropdown("ignoreTeamList", { Text = "Teams", Multi = true, SpecialType = "Team", ReturnInstanceInstead = true })

	ignoreTeammates:OnChanged(function(value)
		VisualHandler.ignoreTeammates = value
		HitboxHandler.ignoreTeammates = value
	end)
	ignoreFF:OnChanged(function(value)
		VisualHandler.ignoreFF = value
		HitboxHandler.ignoreFF = value
	end)
	ignoreSitting:OnChanged(function(value)
		VisualHandler.ignoreSitting = value
		HitboxHandler.ignoreSitting = value
	end)
	ignoreSelectedPlayers:OnChanged(function(value)
		VisualHandler.ignoreSelectedPlayers = value
		HitboxHandler.ignoreSelectedPlayers = value
	end)
	ignorePlayerList:OnChanged(function(value)
		VisualHandler.ignorePlayerList = value
		HitboxHandler.ignorePlayerList = value
	end)
	ignoreSelectedTeams:OnChanged(function(value)
		VisualHandler.ignoreSelectedTeams = value
		HitboxHandler.ignoreSelectedTeams = value
	end)
	ignoreTeamList:OnChanged(function(value)
		VisualHandler.ignoreTeamList = value
		HitboxHandler.ignoreTeamList = value
	end)

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
