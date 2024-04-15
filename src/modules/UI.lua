local LinoriaLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/mstudio45/LinoriaLib/main/Library.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/mstudio45/LinoriaLib/main/addons/SaveManager.lua"))()
SaveManager:SetLibrary(LinoriaLib)
SaveManager:SetFolder("UniversalHBE")
local UI = {
	Library = LinoriaLib,
	Options = getgenv().Options,
	Toggles = getgenv().Toggles,
}

function UI:Load()
	local mainWindow = LinoriaLib:CreateWindow({ Title = "Universal Hitbox Expander", TabPadding = 6, MenuFadeTime = 0, Size = UDim2.fromOffset(550, 620) })
	local mainTab = mainWindow:AddTab("Main")

	local hitboxGroup = mainTab:AddLeftGroupbox("Hitbox Expander")
	hitboxGroup:AddToggle("hitboxToggle", { Text = "Toggle" }):AddKeyPicker("hitboxToggleBind", { Default = "End", Text = "Hitbox Keybind", SyncToggleState = true })
	hitboxGroup:AddToggle("collisionsToggle", { Text = "Collisions" })
	hitboxGroup:AddSlider("hitboxSize", { Text = "Size", Min = 2, Max = 100, Default = 5, Rounding = 0 })
	hitboxGroup:AddSlider("hitboxTransparency", { Text = "Transparency", Min = 0, Max = 1, Default = 0.5, Rounding = 2 })
	hitboxGroup:AddInput("customPartName", { Text = "Custom Part Name", Default = "HeadHB" })
	hitboxGroup:AddDropdown("hitboxPartList", {
		Text = "Body Parts",
		AllowNull = true,
		Multi = true,
		Values = { "Custom Part", "Head", "PrimaryPart", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg" },
		Default = "PrimaryPart",
	})

	local espGroup = mainTab:AddLeftGroupbox("ESP")
	espGroup
		:AddToggle("nameToggle", { Text = "Name" })
		:AddColorPicker("nameFillColor", { Title = "Fill Color", Default = Color3.fromRGB(255, 255, 255) })
		:AddColorPicker("nameOutlineColor", { Title = "Outline Color", Default = Color3.fromRGB(0, 0, 0) })
	espGroup:AddToggle("nameUseTeamColor", { Text = "Use Team Color For Name" })
	espGroup:AddDropdown("nameType", { Text = "Name Type", AllowNull = false, Multi = false, Values = { "Display Name", "Account Name" }, Default = "Display Name" })
	espGroup
		:AddToggle("chamsToggle", { Text = "Chams" })
		:AddColorPicker("chamsFillColor", { Title = "Fill Color", Default = Color3.fromRGB(0, 0, 0), Transparency = 0.5 })
		:AddColorPicker("chamsOutlineColor", { Title = "Outline Color", Default = Color3.fromRGB(255, 255, 255), Transparency = 0.5 })
	espGroup:AddToggle("chamsUseTeamColor", { Text = "Use Team Color For Chams" })
	espGroup:AddDropdown("chamsDepthMode", { Text = "Chams Depth Mode", AllowNull = false, Multi = false, Values = { "Occluded", "AlwaysOnTop" }, Default = "Occluded" })

	local miscGroup = mainTab:AddLeftGroupbox("Misc")
	miscGroup:AddLabel("Toggle UI"):AddKeyPicker("menuKeybind", { Default = "Delete", NoUI = true, Text = "Menu Keybind" })
	miscGroup:AddButton("Unload", LinoriaLib.Unload)

	local ignoresGroup = mainTab:AddRightGroupbox("Ignores")
	ignoresGroup:AddToggle("ignoreTeammates", { Text = "Ignore Teammates" })
	ignoresGroup:AddToggle("ignoreFF", { Text = "Ignore Forcefielded Players" })
	ignoresGroup:AddToggle("ignoreSitting", { Text = "Ignore Sitting Players" })
	ignoresGroup:AddToggle("ignoreSelectedPlayers", { Text = "Ignore Selected Players" })
	ignoresGroup:AddDropdown("ignorePlayerList", { Text = "Players", SpecialType = "Player", Multi = true })
	ignoresGroup:AddToggle("ignoreSelectedTeams", { Text = "Ignore Selected Teams" })
	ignoresGroup:AddDropdown("ignoreTeamList", { Text = "Teams", SpecialType = "Team", Multi = true })

	LinoriaLib.ToggleKeybind = UI.Options.menuKeybind
	SaveManager:BuildConfigSection(mainTab)
	SaveManager:LoadAutoloadConfig()

	return self
end
return UI
