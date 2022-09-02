if _G.FurryHBELoaded ~= nil then
	return
end

_G.FurryHBELoaded = false
if not game:IsLoaded() then
	game.Loaded:Wait()
end

if not isfile("FurryHBE\\KickBypass.txt") then
	if not syn then
		game:GetService("Players").LocalPlayer:Kick("Your exploit is not officially supported. You will bypass this kick from now on, but don't expect the script to completely work.")
		makefolder("FurryHBE")
		writefile("FurryHBE\\KickBypass.txt", "")
		return
	end
end

if KRNL_LOADED then
	loadstring(game:HttpGet("https://raw.githubusercontent.com/zzerexx/scripts/main/SynapseToKrnl.lua"))()
end

if not getgenv().MTAPIMutex then
	loadstring(game:HttpGet("https://raw.githubusercontent.com/RectangularObject/MT-Api-vhookmetamethod/main/__source/mt-api%20v2.lua", true))()
end
loadstring(game:HttpGet("https://raw.githubusercontent.com/LegoHacker1337/legohacks/main/PhysicsServiceOnClient.lua"))()
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/wally-rblx/LinoriaLib/main/Library.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/wally-rblx/LinoriaLib/main/addons/SaveManager.lua"))()
SaveManager:SetLibrary(Library)
SaveManager:SetFolder("FurryHBE")

local Teams = game:GetService("Teams")
local Players = game:GetService("Players")
local Phys = game:GetService("PhysicsService")
local Runs = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local WorldToViewportPoint = Camera.WorldToViewportPoint
local lPlayer = Players.LocalPlayer
local players = {}

Phys:CreateCollisionGroup("furryCollisions")
for _, v in pairs(Phys:GetCollisionGroups()) do
	Phys:CollisionGroupSetCollidable(Phys:GetCollisionGroupName(v.id), "furryCollisions", false)
end

local function updatePlayers()
	if not _G.FurryHBELoaded then return end
	for _, v in pairs(players) do
		task.spawn(function()
			v:Update()
			v:UpdateChams()
		end)
	end
end

Runs.RenderStepped:Connect(function()
	if not _G.FurryHBELoaded then return end
	Camera = Workspace.CurrentCamera
	for _, v in pairs(players) do
		task.spawn(function()
			v:UpdateESP()
		end)
	end
end)

local mainWindow = Library:CreateWindow("Squares's Hitbox Expander")
local mainTab = mainWindow:AddTab("Main")
local mainGroupbox = mainTab:AddLeftGroupbox("Hitbox Expander")
local espGroupbox = mainTab:AddLeftGroupbox("ESP")
local ignoresGroupbox = mainTab:AddRightGroupbox("Ignores")
local collisionsGroupbox = mainTab:AddRightGroupbox("Collisions")
local miscGroupbox = mainTab:AddLeftGroupbox("Keybinds")

local emergencyTab = mainWindow:AddTab("Emergency")
local emergencyGroupbox = emergencyTab:AddLeftGroupbox("Fixes")

mainGroupbox:AddToggle("expanderToggled", { Text = "Toggle" }):OnChanged(updatePlayers)
mainGroupbox:AddSlider("expanderSize", { Text = "Size", Min = 2, Max = 100, Default = 10, Rounding = 1 }):OnChanged(updatePlayers)
mainGroupbox:AddSlider("expanderTransparency", { Text = "Transparency", Min = 0, Max = 1, Default = 0.5, Rounding = 2 }):OnChanged(updatePlayers)
mainGroupbox:AddInput("customPartName", { Text = "Custom Part Name", Default = "HeadHB" }):OnChanged(updatePlayers)
mainGroupbox:AddDropdown("expanderPartList", { Text = "Body Parts", AllowNull = true, Multi = true, Values = { "Custom Part", "Head", "HumanoidRootPart", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg" }, Default = "HumanoidRootPart" }):OnChanged(updatePlayers)

espGroupbox:AddToggle("espNameToggled", { Text = "Name" }):AddColorPicker("espNameColor1", { Title = "Fill Color", Default = Color3.fromRGB(255, 255, 255) }):AddColorPicker("espNameColor2", { Title = "Outline Color", Default = Color3.fromRGB(0, 0, 0) })
Toggles.espNameToggled:OnChanged(updatePlayers)
Options.espNameColor1:OnChanged(updatePlayers)
Options.espNameColor2:OnChanged(updatePlayers)
espGroupbox:AddToggle("espNameUseTeamColor", { Text = "Use Team Color For Name" }):OnChanged(updatePlayers)
espGroupbox:AddDropdown("espNameType", { Text = "Name Type", AllowNull = false, Multi = false, Values = { "Display Name", "Account Name" }, Default = "Display Name" }):OnChanged(updatePlayers)
espGroupbox:AddToggle("espHighlightToggled", { Text = "Chams" }):AddColorPicker("espHighlightColor1", { Title = "Fill Color", Default = Color3.fromRGB(0, 0, 0) }):AddColorPicker("espHighlightColor2", { Title = "Outline Color", Default = Color3.fromRGB(0, 0, 0) })
Toggles.espHighlightToggled:OnChanged(updatePlayers)
Options.espHighlightColor1:OnChanged(updatePlayers)
Options.espHighlightColor2:OnChanged(updatePlayers)
espGroupbox:AddToggle("espHighlightUseTeamColor", { Text = "Use Team Color For Chams" }):OnChanged(updatePlayers)
espGroupbox:AddDropdown("espHighlightDepthMode", { Text = "Chams Depth Mode", AllowNull = false, Multi = false, Values = { "Occluded", "AlwaysOnTop" }, Default = "Occluded" }):OnChanged(updatePlayers)
espGroupbox:AddSlider("espHighlightFillTransparency", { Text = "Chams Fill Transparency", Min = 0, Max = 1, Default = 0.5, Rounding = 2 }):OnChanged(updatePlayers)
espGroupbox:AddSlider("espHighlightOutlineTransparency", { Text = "Chams Outline Transparency", Min = 0, Max = 1, Default = 0, Rounding = 2 }):OnChanged(updatePlayers)

miscGroupbox:AddLabel("Toggle UI"):AddKeyPicker("menuKeybind", { Default = "RightControl", NoUI = true, Text = "Menu Keybind" })
miscGroupbox:AddLabel("Force Update"):AddKeyPicker("forceUpdateKeybind", { Default = "RightAlt", NoUI = true, Text = "Force Update Keybind"})
Options.forceUpdateKeybind:OnClick(updatePlayers)
Library.ToggleKeybind = Options.menuKeybind

ignoresGroupbox:AddToggle("expanderSitCheck", { Text = "Ignore Sitting Players" }):OnChanged(updatePlayers)
ignoresGroupbox:AddToggle("expanderFFCheck", { Text = "Ignore Forcefielded Players" }):OnChanged(updatePlayers)
ignoresGroupbox:AddToggle("ignoreSelectedPlayersToggled", { Text = "Ignore Selected Players" }):OnChanged(updatePlayers)
ignoresGroupbox:AddDropdown("ignorePlayerList", { Text = "Players", AllowNull = true, Multi = true, Values = {} }):OnChanged(updatePlayers)
ignoresGroupbox:AddToggle("ignoreOwnTeamToggled", { Text = "Ignore Own Team" }):OnChanged(updatePlayers)
ignoresGroupbox:AddToggle("ignoreSelectedTeamsToggled", { Text = "Ignore Selected Teams" }):OnChanged(updatePlayers)
ignoresGroupbox:AddDropdown("ignoreTeamList", { Text = "Teams", AllowNull = true, Multi = true, Values = {} }):OnChanged(updatePlayers)

collisionsGroupbox:AddToggle("collisionsToggled", { Text = "Enable Collisions" }):OnChanged(updatePlayers)

SaveManager:BuildConfigSection(mainTab)
SaveManager:LoadAutoloadConfig()

local function updateList(list)
	list:SetValues()
	list:Display()
end

local function addPlayer(player)
	table.insert(Options.ignorePlayerList.Values, player.Name)
	updateList(Options.ignorePlayerList)
	players[player] = { Char = player.Character, defaultProperties = {} }
	local playerIdx = players[player]

	local function isTeammate()
		if game.GameId == 718936923 then -- Neighborhood War
			local selfTeam
			local playerTeam
			pcall(function()
				selfTeam = lPlayer.Character.HumanoidRootPart.Color
				playerTeam = playerIdx.Char.HumanoidRootPart.Color
			end)
			if selfTeam == playerTeam then
				return true
			end
		elseif game.PlaceId == 2158109152 then -- Weapon Kit
			local friendly = playerIdx.Char:FindFirstChild("Friendly", true)
			if friendly then
				return true
			end
		elseif game.PlaceId == 633284182 then -- Fireteam
			local selfTeam
			local playerTeam
			local success
			repeat
				success = pcall(function()
					selfTeam = lPlayer.PlayerData.TeamValue.Value
					playerTeam = player.PlayerData.TeamValue.Value
				end)
				task.wait()
			until success
			if selfTeam == playerTeam then
				return true
			end
		elseif game.PlaceId == 2029250188 then -- Q-Clash
			local selfTeam
			local playerTeam
			pcall(function()
				selfTeam = lPlayer.Character.Parent
				playerTeam = playerIdx.Char.Parent
			end)
			if selfTeam == playerTeam then
				return true
			end
		elseif game.PlaceId == 2978450615 then -- Paintball Reloaded
			local selfTeam = getrenv()._G.PlayerProfiles.Data[lPlayer.Name].Team
			local playerTeam = getrenv()._G.PlayerProfiles.Data[player.Name].Team
			if selfTeam == playerTeam then
				return true
			end
		elseif game.GameId == 1934496708 then -- Project: SCP
			if Workspace.FriendlyFire.Value then
				return false
			end
			if not player.Team then return true end
			if player.Team.Name == "LOBBY" or lPlayer.Team.Name == "LOBBY" or lPlayer.Team == player.Team then
				return true
			end
			local selfTeam
			local playerTeam
			if string.match(lPlayer.Team.Name, "MTF") or lPlayer.Team.Name == "Security Chief" or lPlayer.Team.Name == "Facility Guard" or lPlayer.Team.Name == "Researcher" or lPlayer.Team.Name == "Janitor" then
				selfTeam = "MTF"
			elseif string.match(lPlayer.Team.Name, "CI") or lPlayer.Team.Name == "Class-D" then
				selfTeam = "CD/CI"
			elseif string.match(lPlayer.Team.Name, "SCP") then
				selfTeam = "SCP"
			end
			if string.match(player.Team.Name, "MTF") or player.Team.Name == "Security Chief" or player.Team.Name == "Facility Guard" or player.Team.Name == "Researcher" or player.Team.Name == "Janitor" then
				playerTeam = "MTF"
			elseif string.match(player.Team.Name, "CI") or player.Team.Name == "Class-D" then
				playerTeam = "CD/CI"
			elseif string.match(player.Team.Name, "SCP") then
				playerTeam = "SCP"
			end
			if selfTeam == playerTeam then
				return true
			end
		elseif game.PlaceId == 2622527242 then -- SCP rBreach
			if not player.Team then return true end
			if player.Team.Name == "Intro" or player.Team.Name == "Spectator" or player.Team.Name == "Not Playing" or lPlayer.Team == player.Team then
				return true
			end
			local selfTeam
			local playerTeam
			if lPlayer.Team.Name == "Class-D Personnel" or lPlayer.Team.Name == "Chaos Insurgency" then
				selfTeam = "Chads"
			end
			if lPlayer.Team.Name == "Facility Personnel" or lPlayer.Team.Name == "Security Department" or lPlayer.Team.Name == "Mobile Task Force" or lPlayer.Team.Name == "Unusual Incidents Unit" then
				selfTeam = "Crayon Eaters"
			end
			if lPlayer.Team.Name == "SCPs" or lPlayer.Team.Name == "Serpent's Hand" then
				selfTeam = "Menaces to Society"
			end
			if lPlayer.Team.Name == "Global Occult Coalition" or lPlayer.Team.Name == "Unusual Incidents Unit" then
				selfTeam = "Who?"
			end
			if player.Team.Name == "Class-D Personnel" or player.Team.Name == "Chaos Insurgency" then
				playerTeam = "Chads"
			end
			if player.Team.Name == "Facility Personnel" or player.Team.Name == "Security Department" or player.Team.Name == "Mobile Task Force" or player.Team.Name == "Unusual Incidents Unit" then
				playerTeam = "Crayon Eaters"
			end
			if player.Team.Name == "SCPs" or player.Team.Name == "Serpent's Hand" then
				playerTeam = "Menaces to Society"
			end
			if player.Team.Name == "Global Occult Coalition" or player.Team.Name == "Unusual Incidents Unit" then
				playerTeam = "Who?"
			end
			if selfTeam == playerTeam then
				return true
			end
		elseif game.PlaceId == 8770868695 then -- Anomalous Activities: First Contact
			if player.Team.Name == "Dead" or player.Team.Name == "Inactive" then
				return true
			end
			local selfTeam
			local playerTeam
			pcall(function()
				selfTeam = lPlayer.Character.Parent
				playerTeam = playerIdx.Char.Parent
			end)
			if selfTeam == playerTeam then
				return true
			end
		elseif game.PlaceId == 5884786982 then -- Escape The Darkness
			if lPlayer.Character.Name ~= "Killer" then
				if playerIdx.Char.Name ~= "Killer" then
					return true
				end
			end
		elseif game.GameId == 2162282815 then -- Rush Point
			if not player:FindFirstChild("SelectedTeam") then return true end
			if player.SelectedTeam.Value == lPlayer.SelectedTeam.Value then
				return true
			end
		elseif lPlayer.Team == player.Team then
			return true
		end
		return false
	end

	local function isDead()
		if not playerIdx.Char then
			return true
		end
		local humanoid = playerIdx.Char:FindFirstChildWhichIsA("Humanoid")
		if game.PlaceId == 6172932937 then -- Energy Assault
			if player.ragdolled.Value then
				return true
			end
		elseif game.GameId == 718936923 then -- Neighborhood War
			if playerIdx.Char:FindFirstChild("Dead") then
				return true
			end
		end
		if humanoid and humanoid:GetState() == Enum.HumanoidStateType.Dead then
			return true
		end
		return false
	end

	local function isSitting()
		if Toggles.expanderSitCheck.Value then
			local humanoid = playerIdx.Char:FindFirstChildWhichIsA("Humanoid")
			if humanoid and humanoid.Sit then
				return true
			end
		end
		return false
	end

	local function isFFed()
		if Toggles.expanderFFCheck.Value then
			if game.PlaceId == 4991214437 then -- town
				if playerIdx.Char.Head.Material == Enum.Material.ForceField then
					return true
				end
			end
			local ff = playerIdx.Char:FindFirstChildWhichIsA("ForceField", true)
			if ff and ff.Visible then
				return true
			end
		end
	end

	local function isIgnored()
		if not playerIdx.Char then
			return true
		end
		if Toggles.ignoreOwnTeamToggled.Value then
			if isTeammate() then
				return true
			end
		end
		if Toggles.ignoreSelectedTeamsToggled.Value then
			if table.find(Options.ignoreTeamList:GetActiveValues(), tostring(player.Team)) then
				return true
			end
		end
		if Toggles.ignoreSelectedPlayersToggled.Value then
			if table.find(Options.ignorePlayerList:GetActiveValues(), tostring(player.Name)) then
				return true
			end
		end
		return false
	end

	-- hbe

	local debounce = false
	local function setup(part)
		playerIdx.defaultProperties[part.Name] = {}
		local defaultProperties = playerIdx.defaultProperties[part.Name]
		defaultProperties.Size = part.Size
		defaultProperties.Transparency = part.Transparency
		defaultProperties.Massless = part.Massless
		defaultProperties.CanCollide = part.CanCollide
		defaultProperties.CollisionGroupId = part.CollisionGroupId
		local sizeHook = part:AddGetHook("Size", defaultProperties.Size)
		local transparencyHook = part:AddGetHook("Transparency", defaultProperties.Transparency)
		local masslessHook = part:AddGetHook("Massless", defaultProperties.Massless)
		local canCollideHook = part:AddGetHook("CanCollide", defaultProperties.CanCollide)
		local collisionGroupHook = part:AddGetHook("CollisionGroupId", defaultProperties.CollisionGroupId)
		part:AddSetHook("Size", function(_, value)
			defaultProperties.Size = value
			sizeHook:Modify("Size", defaultProperties.Size)
			if Toggles.expanderToggled.Value then
				local size = Options.expanderSize.Value
				return Vector3.new(size, size, size)
			end
			return defaultProperties.Size
		end)
		part:AddSetHook("Transparency", function(_, value)
			defaultProperties.Transparency = value
			transparencyHook:Modify("Transparency", defaultProperties.Transparency)
			if Toggles.expanderToggled.Value then
				return Options.expanderTransparency.Value
			end
			return defaultProperties.Transparency
		end)
		part:AddSetHook("Massless", function(_, value)
			defaultProperties.Massless = value
			masslessHook:Modify("Massless", defaultProperties.Massless)
			if Toggles.expanderToggled.Value then
				if part.Name ~= "HumanoidRootPart" then
					return true
				end
			end
			return defaultProperties.Massless
		end)
		part:AddSetHook("CanCollide", function(_, value)
			defaultProperties.CanCollide = value
			canCollideHook:Modify("CanCollide", defaultProperties.CanCollide)
			if Toggles.expanderToggled.Value and not Toggles.collisionsToggled.Value then
				if part.Name == "Head" or part.Name == "HumanoidRootPart" then
					return false
				end
			end
			return defaultProperties.CanCollide
		end)
		part:AddSetHook("CollisionGroupId", function(_, value)
			defaultProperties.CollisionGroupId = value
			collisionGroupHook:Modify("CollisionGroupId", defaultProperties.CollisionGroupId)
			if Toggles.expanderToggled.Value and not Toggles.collisionsToggled.Value then
				return Phys:GetCollisionGroupId("furryCollisions")
			end
			return defaultProperties.CollisionGroupId
		end)
		part.Changed:Connect(function(property) -- __namecall isn't replicated to the client when called from a serverscript
			if debounce then return end
			if defaultProperties[property] then
				if defaultProperties[property] ~= part[property] then
					defaultProperties[property] = part[property]
				end
				playerIdx:Update()
			end
		end)
	end

	local function isActive(part)
		local name = part.Name
		local active = Options.expanderPartList:GetActiveValues()
		for _, v in pairs(active) do
			if string.match(name, v) or (v == "Custom Part" and string.match(name, Options.customPartName.Value)) or (v == "Left Arm" and string.match(name, "Left") and (string.match(name, "Arm") or string.match(name, "Hand"))) or (v == "Right Arm" and string.match(name, "Right") and (string.match(name, "Arm") or string.match(name, "Hand"))) or (v == "Left Leg" and string.match(name, "Left") and (string.match(name, "Leg") or string.match(name, "Foot"))) or (v == "Right Leg" and string.match(name, "Right") and (string.match(name, "Leg") or string.match(name, "Foot"))) then
				return true
			end
		end
		return false
	end

	local function resize(part)
		if not playerIdx.defaultProperties[part.Name] then
			setup(part)
		end
		if Toggles.expanderToggled.Value and isActive(part) and not isIgnored() and not isSitting() and not isFFed() and not isDead() then
			if part.Name ~= "HumanoidRootPart" then
				part.Massless = true
			end
			if not Toggles.collisionsToggled.Value then
				if part.Name == "Head" or part.Name == "HumanoidRootPart" then
					part.CanCollide = false
				else
					part.CollisionGroupId = Phys:GetCollisionGroupId("furryCollisions")
				end
			else
				part.CanCollide = playerIdx.defaultProperties[part.Name].CanCollide
				part.CollisionGroupId = playerIdx.defaultProperties[part.Name].CollisionGroupId
			end
			local size = Options.expanderSize.Value
			part.Size = Vector3.new(size, size, size)
			part.Transparency = Options.expanderTransparency.Value
		else
			part.Size = playerIdx.defaultProperties[part.Name].Size
			part.Transparency = playerIdx.defaultProperties[part.Name].Transparency
			part.Massless = playerIdx.defaultProperties[part.Name].Massless
			part.CanCollide = playerIdx.defaultProperties[part.Name].CanCollide
			part.CollisionGroupId = playerIdx.defaultProperties[part.Name].CollisionGroupId
		end
	end

	function playerIdx:Update()
		if not playerIdx.Char then
			return
		end
		debounce = true
		for _, v in pairs(playerIdx.Char:GetChildren()) do
			if v:IsA("BasePart") then
				resize(v)
			end
		end
		debounce = false
	end

	-- esp

	local function FindFirstChildMatching(parent, name)
		if not parent then return nil end
		for _,v in pairs(parent:GetChildren()) do
			if string.match(v.Name, name) then
				return v
			end
		end
	end

	local nameEsp = Drawing.new("Text"); nameEsp.Center = true; nameEsp.Outline = true
	function playerIdx:UpdateESP()
		if not Toggles.espNameToggled.Value or not playerIdx.Char or isIgnored() or isDead() then nameEsp.Visible = false return end
		local target = FindFirstChildMatching(playerIdx.Char, "Torso")
		if target then
			local pos, vis = WorldToViewportPoint(Camera, target.Position)
			if vis then
				if Options.espNameType.Value == "Display Name" then
					nameEsp.Text = player.DisplayName
				else
					nameEsp.Text = player.Name
				end
				if Toggles.espNameUseTeamColor.Value then
					nameEsp.Color = player.TeamColor.Color
				else
					nameEsp.Color = Options.espNameColor1.Value
				end
				nameEsp.OutlineColor = Options.espNameColor2.Value
				nameEsp.Position = Vector2.new(pos.X, pos.Y)
				nameEsp.Size = 1000 / pos.Z + 10
				nameEsp.Visible = true
			else
				nameEsp.Visible = false
			end
		else
			nameEsp.Visible = false
		end
	end

	local chams = Instance.new("Highlight");chams.Parent = game:GetService("CoreGui")
	function playerIdx:UpdateChams()
		if not playerIdx.Char then
			return
		end
		chams.Adornee = playerIdx.Char
		if Toggles.espHighlightToggled.Value and not isIgnored() and not isDead() then
			if Toggles.espHighlightUseTeamColor.Value then
				chams.FillColor = player.TeamColor.Color
				chams.OutlineColor = player.TeamColor.Color
			else
				chams.FillColor = Options.espHighlightColor1.Value
				chams.OutlineColor = Options.espHighlightColor2.Value
			end
			chams.DepthMode = Enum.HighlightDepthMode[Options.espHighlightDepthMode.Value]
			chams.FillTransparency = Options.espHighlightFillTransparency.Value
			chams.OutlineTransparency = Options.espHighlightOutlineTransparency.Value
			chams.Enabled = true
		else
			chams.Enabled = false
		end
	end

	function playerIdx:DeleteVisuals()
		nameEsp:Remove()
		chams:Destroy()
	end

	-- jank fix for CharacterAdded firing too early
	local function WaitForFullChar(char)
		local startTime = tick()
		local humanoid = char:FindFirstChildWhichIsA("Humanoid")
		if not humanoid then
			repeat
				if char == nil then
					return false
				end
				humanoid = char:FindFirstChildWhichIsA("Humanoid")
				task.wait()
			until humanoid or tick()-startTime >= 2
		end
		local loaded = false
		startTime = tick()
		repeat
			local limbs = 0
			for _, v in pairs(char:GetChildren()) do
				if humanoid:GetLimb(v) ~= Enum.Limb.Unknown then
					limbs += 1
				end
			end
			if limbs == 6 or limbs == 15 then
				loaded = true
			end
			task.wait()
		until loaded or tick()-startTime >= 3
		--print(char, "has fully loaded")
		return true
	end

	player.CharacterAdded:Connect(function(character)
		--print(player, "spawned")
		playerIdx.Char = character
		playerIdx.defaultProperties = {}
		if WaitForFullChar(character) then
			playerIdx:Update()
			playerIdx:UpdateChams()
			local humanoid = character:FindFirstChildWhichIsA("Humanoid")
			if humanoid then
				humanoid:GetPropertyChangedSignal("Health"):Connect(function(value)
					if value ~= nil and value <= 0 then
						playerIdx:Update()
						playerIdx:UpdateChams()
					end
				end)
				humanoid.StateChanged:Connect(function(_, newState)
					if newState == Enum.HumanoidStateType.Dead then
						playerIdx:Update()
						playerIdx:UpdateChams()
					end
				end)
			end
			if character:FindFirstChildWhichIsA("ForceField") then
				--print(player, "ff'ed")
				playerIdx:Update()
			end
			character.ChildAdded:Connect(function(child)
				if child:IsA("ForceField") then
					--print(player, "ff'ed")
					playerIdx:Update()
				end
			end)
			character.ChildRemoved:Connect(function(child)
				if child:IsA("ForceField") then
					--print(player, "un-ff'ed")
					playerIdx:Update()
				end
			end)
		end
	end)
	player.CharacterRemoving:Connect(function()
		--print(player, "despawned")
		pcall(function()
			playerIdx.defaultProperties = {}
		end)
	end)
	player:GetPropertyChangedSignal("Team"):Connect(function(team)
		--print(player, "updated team to", team)
		playerIdx:Update()
		playerIdx:UpdateChams()
	end)
	if game.PlaceId == 6172932937 then -- Energy Assault
		local ragdolled = player:WaitForChild("ragdolled")
		ragdolled.Changed:Connect(function()
			playerIdx:Update()
			playerIdx:UpdateChams()
		end)
	end
	if game.GameId == 1934496708 then -- Project: SCP
		local ff = Workspace:WaitForChild("FriendlyFire")
		ff.Changed:Connect(function()
			playerIdx:Update()
			playerIdx:UpdateChams()
		end)
	end
	if game.GameId == 2162282815 then -- Rush Point
		local gamePlayers = Workspace.MapFolder.Players
		for _,v in pairs(gamePlayers:GetChildren()) do
			if v.Name == player.Name then
				playerIdx.Char = v
			end
		end
		gamePlayers.ChildAdded:Connect(function(v)
			if v.Name == player.Name then
				playerIdx.Char = v
			end
		end)
	end
end

local function removePlayer(player)
	if not players[player] then return end
	players[player]:DeleteVisuals()
	table.remove(Options.ignorePlayerList.Values, table.find(Options.ignorePlayerList.Values, player.Name))
	updateList(Options.ignorePlayerList)
	players[player] = nil
end

for _, player in ipairs(Players:GetPlayers()) do
	if player == lPlayer then
		continue
	end
	--print("found player", player.Name)
	addPlayer(player)
end
for _, team in pairs(Teams:GetTeams()) do
	if team:IsA("Team") then
		--print("found team", team.Name)
		table.insert(Options.ignoreTeamList.Values, team.Name)
		updateList(Options.ignoreTeamList)
	end
end
Players.PlayerAdded:Connect(function(player)
	--print(player.Name, "joined")
	addPlayer(player)
end)
Players.PlayerRemoving:Connect(function(player)
	--print(player.Name, "left")
	removePlayer(player)
end)
Teams.ChildAdded:Connect(function(team)
	if team:IsA("Team") then
		--print(team.Name, "created")
		table.insert(Options.ignoreTeamList.Values, team.Name)
		updateList(Options.ignoreTeamList)
	end
end)
Teams.ChildRemoved:Connect(function(team)
	if team:IsA("Team") then
		--print(team.Name, "deleted")
		table.remove(Options.ignoreTeamList.Values, table.find(Options.ignoreTeamList.Values, team.Name))
		updateList(Options.ignoreTeamList)
	end
end)

lPlayer:GetAttributeChangedSignal("Team"):Connect(function()
	updatePlayers()
end)
lPlayer.CharacterAdded:Connect(function()
	updatePlayers()
end)

-- This is a very very very very very very rare bug that I encountered, so here's a button that fixes it
emergencyGroupbox:AddButton("Fix Missing Players", function()
	local found = 0
	for _, player in ipairs(Players:GetPlayers()) do
		if players[player] or player == lPlayer then continue else
			found = found + 1
			addPlayer(player)
		end
	end
	if found > 0 then
		Library:Notify("Found " .. found .. " players")
	else
		Library:Notify("No missing players found")
	end
	updatePlayers()
end):AddTooltip("Attempts to find players that were not detected by the hbe (somehow)")

if game.PlaceId == 111311599 then
	-- Critical Strike Anticheat Disabler
	local anticheat = game:GetService("ReplicatedFirst")["Serverbased AntiCheat"]
	local sValue = lPlayer:WaitForChild("SValue")
	local function constructAnticheatString()
		return "CS-" .. math.random(11111, 99999) .. "-" .. math.random(1111, 9999) .. "-" .. math.random(111111, 999999) .. math.random(1111111, 9999999) .. (sValue.Value * 6) ^ 2 + 18
	end
	task.spawn(function()
		while true do
			task.wait(2)
			game:GetService("ReplicatedStorage").ACDetect:FireServer(sValue.Value, constructAnticheatString())
		end
	end)
	anticheat.Disabled = true
end

_G.FurryHBELoaded = true
updatePlayers()
Library:Notify("hai :3")
Library:Notify("Press " .. Library.ToggleKeybind.Value .. " to open the menu")
