if not game:IsLoaded() then
	game.Loaded:Wait()
end

if not syn then
	-- thanks Iris (https://v3rmillion.net/showthread.php?tid=1172094)
	loadstring(game:HttpGet("https://irisapp.ca/api/Scripts/IrisBetterCompat.lua"))()
end

-- thanks 3ds and kiko metatables r hard (https://v3rmillion.net/showthread.php?tid=1089069)
-- my version uses hookmetamethod :D
if not getgenv().MTAPIMutex then loadstring(game:HttpGet("https://raw.githubusercontent.com/RectangularObject/MT-Api-vhookmetamethod/main/__source/mt-api%20v2.lua", true))() end
-- thanks lego hacker I love you for making this (https://v3rmillion.net/showthread.php?tid=1140873)
loadstring(game:HttpGet("https://raw.githubusercontent.com/LegoHacker1337/legohacks/main/PhysicsServiceOnClient.lua"))()
-- thanks Iris (https://v3rmillion.net/showthread.php?pid=8154179)
--loadstring(game:HttpGet("https://api.irisapp.ca/Scripts/IrisInstanceProtect.lua"))()
local Plrs = game:GetService("Players")
local lPlayer = Plrs.LocalPlayer or Plrs.PlayerAdded:Wait()
local Workspace = game:GetService("Workspace")
local physService = game:GetService("PhysicsService")
local RunService = game:GetService("RunService")
local Teams = game:GetService("Teams")
physService:CreateCollisionGroup("squarehookhackcheatexploit")
local function disableCollisions(group)
	physService:CollisionGroupSetCollidable("squarehookhackcheatexploit", group, false)
end

if game.PlaceId == 111311599 then -- Critical Strike
	local anticheat = game:GetService("ReplicatedFirst")["Serverbased AntiCheat"] -- then why put it in a localscript?
	-- I literally copied the rest of this from the "Serverbased Anticheat"
	local sValue = game:GetService("Players").LocalPlayer:WaitForChild("SValue")
	local function constructAnticheatString()
		return "CS-" .. math.random(11111, 99999) .. "-" .. math.random(1111, 9999) .. "-" .. math.random(111111, 999999) .. math.random(1111111, 9999999) .. (sValue.Value * 6) ^ 2 + 18
	end
	-- to be fair the game hasn't been updated in over a year
	task.spawn(function()
		while true do
			task.wait(2)
			game:GetService("ReplicatedStorage").ACDetect:FireServer(sValue.Value, constructAnticheatString())
		end
	end)
	anticheat.Disabled = true
end

-- thanks inori and wally
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/wally-rblx/LinoriaLib/main/Library.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/wally-rblx/LinoriaLib/main/addons/SaveManager.lua"))()
SaveManager:SetLibrary(Library)
SaveManager:SetFolder("HitboxExtender")

local mainWindow = Library:CreateWindow("cheaters get banned.")
local mainTab = mainWindow:AddTab("Main")
local mainGroupbox = mainTab:AddLeftGroupbox("Hitbox Extender")
local ignoresGroupbox = mainTab:AddRightGroupbox("Ignores")
local espGroupbox = mainTab:AddLeftGroupbox("ESP")
local miscGroupbox = mainTab:AddLeftGroupbox("Misc")
local collisionsGroupbox = mainTab:AddRightGroupbox("Collisions")

local extenderToggled = mainGroupbox:AddToggle("extenderToggled", { Text = "Toggle" })
local extenderSize = mainGroupbox:AddSlider("extenderSize", { Text = "Size", Min = 2, Max = 100, Default = 10, Rounding = 1 })
local extenderTransparency = mainGroupbox:AddSlider("extenderTransparency", { Text = "Transparency", Min = 0, Max = 1, Default = 0.5, Rounding = 2 })
local customPartNameInput = mainGroupbox:AddInput("customPartList", { Text = "Custom Part Name", Default = "HeadHB" })
local extenderPartList = mainGroupbox:AddDropdown("extenderPartList", { Text = "Body Parts", AllowNull = true, Multi = true, Values = { "Custom Part", "Head", "HumanoidRootPart", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg" }, Default = "Head" })
local extenderUpdateRate = miscGroupbox:AddSlider("extenderUpdateRate", { Text = "Update Rate", Min = 0, Max = 1000, Default = 0, Rounding = 0, Suffix = "ms" })

local espNameToggled = espGroupbox:AddToggle("espNameToggled", { Text = "Name" }):AddColorPicker("espNameColor1", { Title = "Fill Color", Default = Color3.fromRGB(255, 255, 255) }):AddColorPicker("espNameColor2", { Title = "Outline Color", Default = Color3.fromRGB(0, 0, 0) })
local espNameUseTeamColor = espGroupbox:AddToggle("espNameUseTeamColor", { Text = "Use Team Color For Name" })
local espNameType = espGroupbox:AddDropdown("espNameType", { Text = "Name Type", AllowNull = false, Multi = false, Values = { "Display Name", "Account Name" }, Default = "Display Name" })
local espHighlightToggled = espGroupbox:AddToggle("espHighlightToggled", { Text = "Chams" }):AddColorPicker("espHighlightColor1", { Title = "Fill Color", Default = Color3.fromRGB(0, 0, 0) }):AddColorPicker("espHighlightColor2", { Title = "Outline Color", Default = Color3.fromRGB(0, 0, 0) })
local espHighlightUseTeamColor = espGroupbox:AddToggle("espHighlightUseTeamColor", { Text = "Use Team Color For Chams" })
local espHighlightDepthMode = espGroupbox:AddDropdown("espHighlightDepthMode", { Text = "Chams Depth Mode", AllowNull = false, Multi = false, Values = { "Occluded", "AlwaysOnTop" }, Default = "Occluded" })
local espHighlightFillTransparency = espGroupbox:AddSlider("espHighlightFillTransparency", { Text = "Chams Fill Transparency", Min = 0, Max = 1, Default = 0.5, Rounding = 2 })
local espHighlightOutlineTransparency = espGroupbox:AddSlider("espHighlightOutlineTransparency", { Text = "Chams Outline Transparency", Min = 0, Max = 1, Default = 0, Rounding = 2 })

local extenderSitCheck = ignoresGroupbox:AddToggle("extenderSitCheck", { Text = "Ignore Sitting Players" })
local extenderFFCheck = ignoresGroupbox:AddToggle("extenderFFCheck", { Text = "Ignore Forcefielded Players" })
local ignoreSelectedPlayersToggled = ignoresGroupbox:AddToggle("ignoreSelectedPlayersToggled", { Text = "Ignore Selected Players" })
local ignorePlayerList = ignoresGroupbox:AddDropdown("ignorePlayerList", { Text = "Players", AllowNull = true, Multi = true, Values = {} })
local ignoreSelfTeamToggled = ignoresGroupbox:AddToggle("ignoreSelfTeamToggled", { Text = "Ignore Own Team" })
local ignoreSelectedTeamsToggled = ignoresGroupbox:AddToggle("ignoreSelectedTeamsToggled", { Text = "Ignore Selected Teams" })
local ignoreTeamList = ignoresGroupbox:AddDropdown("ignoreTeamList", { Text = "Teams", AllowNull = true, Multi = true, Values = {} })

local collisionsToggled = collisionsGroupbox:AddToggle("collisionsToggled", {Text = "Enable Collisions"})

local function updateList(list)
	list:SetValues()
	list:Display()
end

Plrs.PlayerAdded:Connect(function(player)
	--print(player.Name, "joined")
	table.insert(ignorePlayerList.Values, player.Name)
	updateList(ignorePlayerList)
end)
Plrs.PlayerRemoving:Connect(function(player)
	--print(player.Name, "left")
	table.remove(ignorePlayerList.Values, table.find(ignorePlayerList.Values, player.Name))
	updateList(ignorePlayerList)
end)
Teams.ChildAdded:Connect(function(team)
	--print(team.Name, "created")
	table.insert(ignoreTeamList.Values, team.Name)
	updateList(ignoreTeamList)
end)
Teams.ChildRemoved:Connect(function(team)
	--print(team.Name, "deleted")
	table.remove(ignoreTeamList.Values, table.find(ignoreTeamList.Values, team.Name))
	updateList(ignoreTeamList)
end)
for _,player in ipairs(Plrs:GetPlayers()) do
	if player == lPlayer then continue end
	--print("found", player.Name)
	table.insert(ignorePlayerList.Values, player.Name)
end
for _,team in pairs(Teams:GetTeams()) do
	--print("found", team.Name)
	table.insert(ignoreTeamList.Values, team.Name)
end
updateList(ignorePlayerList)
updateList(ignoreTeamList)

SaveManager:BuildConfigSection(mainTab)
SaveManager:LoadAutoloadConfig()
Library:Notify("hai :3")
Library:Notify("Press right ctrl to open the menu")

local function WaitForChildWhichIsA(parent, name)
	while parent:FindFirstChildWhichIsA(name) == nil do
		if parent == nil then
			return nil
		end
		task.wait()
	end
	return parent:FindFirstChildWhichIsA(name)
end

-- Returns a table of every possible bodypart in a character, or nil if the character does not exist.
local function getBodyParts(character)
	local parts = {
		Head = character:WaitForChild("Head", 1),
		HumanoidRootPart = character:WaitForChild("HumanoidRootPart", 1),
		Humanoid = WaitForChildWhichIsA(character, "Humanoid"),
		Torso = {},
		["Left Arm"] = {},
		["Right Arm"] = {},
		["Left Leg"] = {},
		["Right Leg"] = {},
	}
	if parts.Humanoid == nil then
		--print(character.Name, "humanoid error")
		return nil
	end
	for _, v in pairs(character:GetChildren()) do
		if v:IsA("BasePart") and parts.Humanoid:GetLimb(v) ~= Enum.Limb.Unknown then
			if string.match(v.Name, "Torso") then
				parts.Torso[v.Name] = v
				continue
			end
			if string.match(v.Name, "Left") then
				if string.match(v.Name, "Arm") or string.match(v.Name, "Hand") then
					parts["Left Arm"][v.Name] = v
					continue
				end
				if string.match(v.Name, "Leg") or string.match(v.Name, "Foot") then
					parts["Left Leg"][v.Name] = v
					continue
				end
			end
			if string.match(v.Name, "Right") then
				if string.match(v.Name, "Arm") or string.match(v.Name, "Hand") then
					parts["Right Arm"][v.Name] = v
					continue
				end
				if string.match(v.Name, "Leg") or string.match(v.Name, "Foot") then
					parts["Right Leg"][v.Name] = v
					continue
				end
			end
		end
	end
	return parts
end
local function getTeam(player, character)
	if game.GameId == 718936923 then -- Neighborhood War
		local selfTeam
		local playerTeam
		pcall(function()
			selfTeam = lPlayer.Character.HumanoidRootPart.Color
			playerTeam = character.HumanoidRootPart.Color
		end)
		if selfTeam == playerTeam then
			return true
		end
	elseif game.PlaceId == 2158109152 then -- Weapon Kit
		local friendly = character:FindFirstChild("Friendly", true)
		if friendly then
			return true
		end
	elseif game.PlaceId == 633284182 then -- Fireteam
		local selfTeam
		local playerTeam
		pcall(function()
			selfTeam = lPlayer.PlayerData.TeamValue.Value
			playerTeam = player.PlayerData.TeamValue.Value
		end)
		if selfTeam == playerTeam then
			return true
		end
	elseif game.PlaceId == 2029250188 then -- Q-Clash
		local selfTeam
		local playerTeam
		pcall(function()
			selfTeam = lPlayer.Character.Parent
			playerTeam = character.Parent
		end)
		if selfTeam == playerTeam then
			return true
		end
	elseif game.PlaceId == 2978450615 then -- Paintball Reloaded (hi kringly :troll:)
		local selfTeam = getrenv()._G.PlayerProfiles.Data[lPlayer.Name].Team
		local playerTeam = getrenv()._G.PlayerProfiles.Data[player.Name].Team
		if selfTeam == playerTeam then
			return true
		end
	elseif game.GameId == 1934496708 then -- Project: SCP
		if player.Team == "LOBBY" or lPlayer.Team == player.Team then return true end
		if lPlayer.PlayerGui.MainUI.Frame.EndScreen.AnchorPoint.X < 1 then return false end
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
	elseif lPlayer.Team == player.Team then
		return true
	else
		return false
	end
end
-- Main function
local function addCharacter(player, character)
	--print(character.Name, "added")
	local timer = 0
	local originals = {}
	local bodyParts = getBodyParts(character)
	if bodyParts == nil or player == nil then
		--print(character.Name, "is broken:\nbodyParts = ", bodyParts, "\nplayer = ", player)
		return
	end
	-- Sets up original sizes and creates hooks to bypass localscript anticheats
	local function setup(i, v)
		for _,connection in pairs(getconnections(v:GetPropertyChangedSignal("Size"))) do
			connection:Disable()
		end
		if not originals[i] then
			originals[i] = {}
			originals[i].Size = v.Size
			originals[i].Transparency = v.Transparency
			originals[i].Massless = v.Massless
			originals[i].CollisionGroupId = v.CollisionGroupId
			local sizeHook = v:AddGetHook("Size", originals[i].Size)
			local transparencyHook = v:AddGetHook("Transparency", originals[i].Transparency)
			local masslessHook = v:AddGetHook("Massless", originals[i].Massless)
			local collisionHook = v:AddGetHook("CollisionGroupId", originals[i].CollisionGroupId)
			v:AddSetHook("Size", function(self, value)
				originals[i].Size = value
				sizeHook:Modify("Size", value)
				return value
			end)
			v:AddSetHook("Transparency", function(self, value)
				originals[i].Transparency = value
				transparencyHook:Modify("Transparency", value)
				return value
			end)
			v:AddSetHook("Massless", function(self, value)
				originals[i].Massless = value
				masslessHook:Modify("Massless", value)
				return value
			end)
			v:AddSetHook("CollisionGroupId", function(self, value)
				originals[i].CollisionGroupId = value
				collisionHook:Modify("CollisionGroupId", value)
				return value
			end)
		end
	end
	-- resets the properties of the selected part.
	-- if "all" is passed, will reset every part
	local function reset(part)
		if part == "custompart" or part == "all" then
			local customPart = character:FindFirstChild(customPartNameInput.Value)
			if customPart and customPart:IsA("BasePart") then
				if not originals[customPart.Name] then
					setup(customPart.Name, customPart)
				end
				customPart.Size = originals[customPart.Name].Size
				customPart.Transparency = originals[customPart.Name].Transparency
				customPart.Massless = originals[customPart.Name].Massless
				customPart.CollisionGroupId = originals[customPart.Name].CollisionGroupId
			end
		end
		for i, v in pairs(bodyParts) do
			if string.lower(part) == string.lower(i) or part == "all" then
				if i ~= "Humanoid" and type(v) ~= "table" then
					if not originals[i] then
						setup(i, v)
					end
					v.Size = originals[i].Size
					v.Transparency = originals[i].Transparency
					v.Massless = originals[i].Massless
					v.CollisionGroupId = originals[i].CollisionGroupId
				elseif type(v) == "table" then
					for o, b in pairs(v) do
						if not originals[o] then
							setup(o, b)
						end
						b.Size = originals[o].Size
						b.Transparency = originals[o].Transparency
						b.Massless = originals[o].Massless
						b.CollisionGroupId = originals[o].CollisionGroupId
					end
				end
			end
		end
	end
	local function getChecks()
		-- dead checks
		if bodyParts.Humanoid:GetState() == Enum.HumanoidStateType.Dead or bodyParts.Humanoid.Health <= 0 then
			--print(character.Name, "died")
			return 2
		end
		if player.Character ~= character then
			--print(character.Name, "stopped existing")
			return 2
		end
		if game.PlaceId == 6172932937 then -- Energy Assault
			if player.ragdolled.Value then
				return 1
			end
		end
		if game.PlaceId == 633284182 then -- Fireteam
			local down
			pcall(function()
				if character.Torso.NeckBallSocket.Enabled then
					down = true
				end
			end)
			if down then
				return 1
			end
		end
		-- other checks
		if extenderSitCheck.Value then
			if bodyParts.Humanoid.Sit then
				return 1
			end
		end
		if extenderFFCheck.Value then
			if game.PlaceId == 4991214437 then -- town
				if bodyParts.Head.Material == Enum.Material.ForceField then
					return 1
				end
			end
			local ff = character:FindFirstChildWhichIsA("ForceField", true)
			if ff and ff.Visible then
				return 1
			end
		end
		if ignoreSelfTeamToggled.Value then
			local teammate = getTeam(player, character)
			if teammate then
				return 1
			end
		end
		if ignoreSelectedTeamsToggled.Value then
			local teamList = ignoreTeamList:GetActiveValues()
			if table.find(teamList, tostring(player.Team)) then
				return 1
			end
		end
		if ignoreSelectedPlayersToggled.Value then
			local playerList = ignorePlayerList:GetActiveValues()
			if table.find(playerList, tostring(player.Name)) then
				return 1
			end
		end
		return 0
	end
	-- loops and stuff
	local nameEsp = Drawing.new("Text")
	nameEsp.Center = true
	nameEsp.Outline = true
	local chams = Instance.new("Highlight")
	chams.Enabled = false
	chams.Parent = game:GetService("CoreGui")
	chams.Adornee = character
	--ProtectInstance(chams)
	local RenderStepped
	RenderStepped = RunService.RenderStepped:Connect(function(deltaTime)
		timer += deltaTime
		if espNameToggled.Value then
			local espPart = character:FindFirstChild("HumanoidRootPart")
			if not espPart then
				espPart = bodyParts.Torso[1]
			end
			if espPart then
				local pos, onScreen = Workspace.CurrentCamera:WorldToViewportPoint(espPart.Position)
				if onScreen and getChecks() == 0 then
					if espNameType.Value == "Display Name" then
						nameEsp.Text = player.DisplayName
					else
						nameEsp.Text = player.Name
					end
					if espNameUseTeamColor.Value then
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
		else
			nameEsp.Visible = false
		end
		local checks = getChecks()
		if timer >= (extenderUpdateRate.Value / 1000) then -- divided by 1000 because milliseconds
			timer = 0
			if espHighlightToggled.Value and checks == 0 then
				if espHighlightUseTeamColor.Value then
					chams.FillColor = player.TeamColor.Color
					chams.OutlineColor = player.TeamColor.Color
				else
					chams.FillColor = Options.espHighlightColor1.Value
					chams.OutlineColor = Options.espHighlightColor2.Value
				end
				chams.DepthMode = Enum.HighlightDepthMode[espHighlightDepthMode.Value]
				chams.FillTransparency = espHighlightFillTransparency.Value
				chams.OutlineTransparency = espHighlightOutlineTransparency.Value
				chams.Enabled = true
			else
				chams.Enabled = false
			end
			local bodyPartList = extenderPartList:GetActiveValues()
			if checks == 2 then
				--print(character, "failed check 2")
				reset("all")
				nameEsp:Remove()
				nameEsp = nil
				chams:Destroy()
				RenderStepped:Disconnect()
				return
			elseif checks == 1 then
				reset("all")
				return
			end
			if extenderToggled.Value then
				if table.find(bodyPartList, "Custom Part") then
					local customPart = character:FindFirstChild(customPartNameInput.Value)
					if customPart and customPart:IsA("BasePart") then
						if not originals[customPart.Name] then
							setup(customPart.Name, customPart)
						end
						customPart.Massless = true
						if collisionsToggled.Value then
							customPart.CollisionGroupId = originals[customPart.Name].CollisionGroupId
						else
							customPart.CollisionGroupId = physService:GetCollisionGroupId("squarehookhackcheatexploit")
						end
						customPart.Size = Vector3.new(extenderSize.Value, extenderSize.Value, extenderSize.Value)
						customPart.Transparency = extenderTransparency.Value
					end
				else
					reset("custompart")
				end
				for i, v in pairs(bodyParts) do
					if table.find(bodyPartList, i) then
						if type(v) ~= "table" then
							if not originals[i] then
								setup(i, v)
							end
							if i ~= "HumanoidRootPart" then
								v.Massless = true
							end
							if collisionsToggled.Value then
								v.CollisionGroupId = originals[i].CollisionGroupId
							else
								v.CollisionGroupId = physService:GetCollisionGroupId("squarehookhackcheatexploit")
							end
							v.Size = Vector3.new(extenderSize.Value, extenderSize.Value, extenderSize.Value)
							v.Transparency = extenderTransparency.Value
						else
							for o, b in pairs(v) do
								if not originals[o] then
									setup(o, b)
								end
								b.Massless = true
								if collisionsToggled.Value then
									b.CollisionGroupId = originals[o].CollisionGroupId
								else
									b.CollisionGroupId = physService:GetCollisionGroupId("squarehookhackcheatexploit")
								end
								b.Size = Vector3.new(extenderSize.Value, extenderSize.Value, extenderSize.Value)
								b.Transparency = extenderTransparency.Value
							end
						end
					else
						reset(i)
					end
				end
			else
				reset("all")
			end
		end
	end)
	local PlayerRemoving
	PlayerRemoving = Plrs.PlayerRemoving:Connect(function(v)
		if v == player then
			--print(player, "leaving")
			reset("all")
			if nameEsp then
				nameEsp:Remove()
			end
			chams:Destroy()
			RenderStepped:Disconnect()
			PlayerRemoving:Disconnect()
		end
	end)
end
for _, player in ipairs(Plrs:GetPlayers()) do
	if player ~= lPlayer then
		player.CharacterAdded:Connect(function(character)
			addCharacter(player, character)
		end)
		local Char = player.Character
		if Char then
			addCharacter(player, Char)
		end
	else
		local function onDescendantAdded(descendant)
			if string.find(descendant.Name, "Torso") and descendant:IsA("BasePart") then
				disableCollisions(physService:GetCollisionGroupName(descendant.CollisionGroupId))
			end
		end
		local function onCharacterAdded(character)
			for _, v in pairs(character:GetDescendants()) do
				onDescendantAdded(v)
			end
			character.DescendantAdded:Connect(onDescendantAdded)
		end
		player.CharacterAdded:Connect(onCharacterAdded)
		local Char = player.Character
		if Char then
			onCharacterAdded(Char)
		end
	end
end
Plrs.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(Char)
		addCharacter(player, Char)
	end)
end)
-- I'm sorry for your eyes
