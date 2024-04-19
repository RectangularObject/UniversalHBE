if not getgenv().MTAPIMutex then loadstring(game:HttpGet("https://raw.githubusercontent.com/RectangularObject/MT-Api-v2/main/__source/mt-api%20v2.lua", true))() end
local lPlayer: Player = cloneref(game:GetService("Players").LocalPlayer)
local EntHandler = require("./EntityHandler.lua")
local UI = require("./UI.lua")
local Toggles = UI.Toggles
local Options = UI.Options
local hitboxHandler = {}
local connections = {}

local function addEntity(entity: table)
	local spoofedProperties = {}
	local debounce = false

	local function unSpoofPart(part: BasePart)
		if not spoofedProperties[part] then return end
		local partHooks = spoofedProperties[part].hooks
		for _, hook in partHooks do
			hook:Remove()
		end
		spoofedProperties[part] = nil
	end
	local function spoofPart(part: BasePart)
		if spoofedProperties[part] then return end
		spoofedProperties[part] = {
			hooks = {},
		}
		local partProperties = spoofedProperties[part]
		local partHooks = spoofedProperties[part].hooks
		partProperties.Size = part.Size
		partProperties.Transparency = part.Transparency
		partProperties.Massless = part.Massless
		partProperties.CanCollide = part.CanCollide

		partHooks.getSizeHook = part:AddGetHook("Size", function() return partProperties.Size end)
		partHooks.getTransparencyHook = part:AddGetHook("Transparency", function() return partProperties.Transparency end)
		partHooks.getMasslessHook = part:AddGetHook("Massless", function() return partProperties.Massless end)
		partHooks.getCanCollideHook = part:AddGetHook("CanCollide", function() return partProperties.CanCollide end)

		partHooks.setSizeHook = part:AddSetHook("Size", function(_, value)
			partProperties.Size = value
			local hitboxSize = Options.hitboxSize.Value
			return if Toggles.hitboxToggle.Value then Vector3.new(hitboxSize, hitboxSize, hitboxSize) else value
		end)
		partHooks.setTransparencyHook = part:AddSetHook("Transparency", function(_, value)
			partProperties.Transparency = value
			return if Toggles.hitboxToggle.Value then Options.hitboxTransparency.Value else value
		end)
		partHooks.setMasslessHook = part:AddSetHook("Massless", function(_, value)
			partProperties.Massless = value
			return if Toggles.hitboxToggle.Value then part ~= entity:GetRootPart() else value
		end)
		partHooks.setCanCollideHook = part:AddSetHook("CanCollide", function(_, value)
			partProperties.CanCollide = value
			return if Toggles.hitboxToggle.Value then Toggles.collisionsToggle.Value else value
		end)

		part.Changed:Connect(function(property) -- __namecall isn't replicated to the client when called from a serverscript
			if debounce then return end
			if partProperties[property] then
				partProperties[property] = part[property]
				entity:hitboxStep()
			end
		end)
		part.Destroying:Connect(function() unSpoofPart(part) end)
	end
	local function unSpoofDecal(decal: Decal)
		if not spoofedProperties[decal] then return end
		local decalHooks = spoofedProperties[decal].hooks
		for _, hook in decalHooks do
			hook:Remove()
		end
		spoofedProperties[decal] = nil
	end
	local function spoofDecal(decal: Decal)
		if spoofedProperties[decal] then return end
		spoofedProperties[decal] = {
			hooks = {},
		}
		local decalProperties = spoofedProperties[decal]
		local decalHooks = spoofedProperties[decal].hooks
		decalProperties.Transparency = decal.Transparency

		decalHooks.getTransparencyHook = decal:AddGetHook("Transparency", function() return decalProperties.Transparency end)
		decalHooks.setTransparencyHook = decal:AddSetHook("Transparency", function(_, value)
			decalProperties.Transparency = value
			return if Toggles.hitboxToggle.Value then Options.hitboxTransparency.Value else value
		end)

		decal:GetPropertyChangedSignal("Transparency"):Connect(function()
			if debounce then return end
			decalProperties.Transparency = decal.Transparency
		end)
		decal.Destroying:Connect(function() unSpoofDecal(decal) end)
	end

	local function expandPart(part)
		debounce = true
		spoofPart(part)
		local size = Options.hitboxSize.Value
		part.Massless = part ~= entity:GetRootPart()
		part.CanCollide = Toggles.collisionsToggle.Value
		part.Transparency = Options.hitboxTransparency.Value
		part.Size = Vector3.new(size, size, size)
		for _, child in part:GetChildren() do
			if not child:IsA("Decal") then continue end
			spoofDecal(child)
			child.Transparency = Options.hitboxTransparency.Value
		end
		debounce = false
		return
	end
	local function contractPart(part)
		if not spoofedProperties[part] then return end
		debounce = true
		part.Size = spoofedProperties[part].Size
		part.Transparency = spoofedProperties[part].Transparency
		part.CanCollide = spoofedProperties[part].CanCollide
		part.Massless = spoofedProperties[part].Massless
		for _, child in part:GetChildren() do
			if not child:IsA("Decal") or not spoofedProperties[child] then continue end
			child.Transparency = spoofedProperties[child].Transparency
		end
		debounce = false
	end

	local function isIgnored()
		local playerNames = {}
		local teamNames = {}
		for _, value in Options.ignorePlayerList:GetActiveValues() do
			playerNames[value] = true
		end
		for _, value in Options.ignoreTeamList:GetActiveValues() do
			teamNames[value] = true
		end
		return entity:isDead()
			or (Toggles.ignoreSelectedPlayers.Value and playerNames[entity:GetName()])
			or (Toggles.ignoreSelectedTeams.Value and teamNames[entity:GetTeam()])
			or (Toggles.ignoreTeammates.Value and entity:isTeammate())
			or (Toggles.ignoreFF.Value and entity:isFFed())
			or (Toggles.ignoreSitting.Value and entity:isSitting())
	end

	local function resizePart(part, condition)
		if not part:IsA("BasePart") then return end
		if Toggles.hitboxToggle.Value and condition then
			expandPart(part)
			return
		end
		contractPart(part)
	end

	function entity:hitboxStep()
		local character: Model = self:GetCharacter()
		if not character then return end
		local humanoid: Humanoid = self:GetHumanoid()
		if not humanoid then return end
		local activeValues = {}
		for _, value in Options.hitboxPartList:GetActiveValues() do
			local formattedValue = string.gsub(value, "%s+", "")
			activeValues[formattedValue] = true
		end
		local condition = not isIgnored()
		for _, part in character:GetChildren() do
			resizePart(
				part,
				condition
					and (
						(activeValues["Custom Part"] and string.match(part.Name, Options.customPartName.Value))
						or (activeValues["PrimaryPart"] and part == self:GetRootPart())
						or activeValues[humanoid:GetLimb(part).Name]
					)
			)
		end
	end
	if entity:GetType() == "Player" then
		local player: Player = entity.entity
		player.CharacterAdded:Connect(function(character)
			if character:FindFirstChildWhichIsA("ForceField") then entity:hitboxStep() end
			character.ChildAdded:Connect(function(child)
				if child:IsA("Humanoid") then child.StateChanged:Connect(function() entity:hitboxStep() end) end
				entity:hitboxStep()
			end)
			character.ChildRemoved:Connect(function(child)
				if child:IsA("ForceField") then entity:hitboxStep() end
			end)
		end)
		player:GetPropertyChangedSignal("Team"):Connect(function() entity:hitboxStep() end)
	end
end

function hitboxHandler:updateHitbox()
	for _, player in EntHandler:GetPlayers() do
		player:hitboxStep()
	end
end
function hitboxHandler:Load()
	for _, player in EntHandler:GetPlayers() do
		addEntity(player)
	end
	table.insert(connections, EntHandler.onPlayerAdded:Connect(addEntity))
	table.insert(connections, lPlayer:GetAttributeChangedSignal("Team"):Connect(hitboxHandler.updateHitbox))
	table.insert(connections, lPlayer.CharacterAdded:Connect(hitboxHandler.updateHitbox))
end
function hitboxHandler:Unload()
	for _, connection in connections do
		connection:Disconnect()
	end
	Toggles.hitboxToggle:SetValue(false)
end
return hitboxHandler
