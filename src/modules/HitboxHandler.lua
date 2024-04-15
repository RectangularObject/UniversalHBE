if not getgenv().MTAPIMutex then loadstring(game:HttpGet("https://raw.githubusercontent.com/RectangularObject/MT-Api-v2/main/__source/mt-api%20v2.lua", true))() end
local lPlayer: Player = cloneref(game:GetService("Players").LocalPlayer)
local EntHandler = require("./EntityHandler.lua")
local UI = require("./UI.lua")
local Toggles = UI.Toggles
local Options = UI.Options
local hitboxHandler = {}
local connections = {}
local unloading = false

local function addEntity(entity: table)
	local spoofedProperties = {}
	local debounce = false

	local function unSpoofPart(part: BasePart)
		if not spoofedProperties[part] then return end
		local partHooks = spoofedProperties[part].hooks
		partHooks.getSizeHook:Remove()
		partHooks.setSizeHook:Remove()
		partHooks.getTransparencyHook:Remove()
		partHooks.setTransparencyHook:Remove()
		partHooks.getMasslessHook:Remove()
		partHooks.setMasslessHook:Remove()
		partHooks.getCanCollideHook:Remove()
		partHooks.setCanCollideHook:Remove()
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
		partHooks.setMasslessHook = part:AddSetHook("Massless", function(self, value)
			partProperties.Massless = value
			return if Toggles.hitboxToggle.Value then if self.Name == "HumanoidRootPart" then true else value else value
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
		decalHooks.getTransparencyHook:Remove()
		decalHooks.setTransparencyHook:Remove()
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
	local function isInvalidTarget()
		-- stylua: ignore
		return entity:isDead()
			or if Toggles.ignoreFF.Value then entity:isFFed() else false
			or if Toggles.ignoreTeammates.Value then entity:isTeammate() else false
			or if Toggles.ignoreSitting.Value then entity:isSitting() else false
			or entity:isIgnored()
	end

	local function resizePart(part, condition)
		spoofPart(part)
		debounce = true
		if not unloading and Toggles.hitboxToggle.Value and condition and not isInvalidTarget() then
			local size = Options.hitboxSize.Value
			part.Massless = if part ~= part.Parent.PrimaryPart then true else false
			part.CanCollide = Toggles.collisionsToggle.Value
			part.Transparency = Options.hitboxTransparency.Value
			part.Size = Vector3.new(size, size, size)
			for _, child in part:GetChildren() do
				if not child:IsA("Decal") then continue end
				spoofDecal(child)
				child.Transparency = Options.hitboxTransparency.Value
			end
			return
		end
		part.Size = spoofedProperties[part].Size
		part.Transparency = spoofedProperties[part].Transparency
		part.CanCollide = spoofedProperties[part].CanCollide
		part.Massless = spoofedProperties[part].Massless
		if unloading then unSpoofPart(part) end
		for _, child in part:GetChildren() do
			if not child:IsA("Decal") then continue end
			if unloading then
				unSpoofDecal(child)
				continue
			end
			spoofDecal(child)
			child.Transparency = spoofedProperties[child].Transparency
		end
		debounce = false
	end

	function entity:hitboxStep()
		local character: Model = self:GetCharacter()
		if not character then return end
		local humanoid: Humanoid = self:GetHumanoid()
		local activeValues = {}
		for _, value in Options.hitboxPartList:GetActiveValues() do
			local formattedValue = string.gsub(value, "%s+", "")
			activeValues[formattedValue] = true
		end
		for _, part in character:GetChildren() do
			if not part:IsA("BasePart") then continue end
			if string.match(part.Name, Options.customPartName.Value) then
				resizePart(part, activeValues["Custom Part"])
				continue
			end
			if part == self:GetRootPart() then
				resizePart(part, activeValues["PrimaryPart"])
				continue
			end
			if humanoid:GetLimb(part) ~= Enum.Limb.Unknown then resizePart(part, activeValues[humanoid:GetLimb(part).Name]) end
		end
	end

	if entity:GetType() == "Player" then
		local player: Player = entity.entity

		-- jank fix for CharacterAdded firing too early
		local function waitForFullChar(char) -- TODO: this function sucks! find a way to handle this better
			local startTime = tick()
			local humanoid = char:FindFirstChildWhichIsA("Humanoid")
			if not humanoid then
				repeat
					task.wait()
					if char == nil then return false end
					humanoid = char:FindFirstChildWhichIsA("Humanoid")
				until humanoid or tick() - startTime >= 2
			end
			local loaded = false
			local goal = if humanoid.RigType == Enum.HumanoidRigType.R6 then 6 else 15
			startTime = tick()
			repeat
				task.wait()
				local limbs = 0
				for _, v in pairs(char:GetChildren()) do
					if humanoid:GetLimb(v) ~= Enum.Limb.Unknown then
						limbs += 1
					end
				end
				if limbs == goal then loaded = true end
			until loaded or tick() - startTime >= 3
			return true
		end

		player.CharacterAdded:Connect(function(character)
			if not waitForFullChar(character) then return end
			entity:hitboxStep()
			local humanoid = entity:GetHumanoid()
			humanoid.StateChanged:Connect(function() entity:hitboxStep() end)
			if character:FindFirstAncestorWhichIsA("ForceField") then entity:hitboxStep() end
			character.ChildAdded:Connect(function(child)
				if child:IsA("ForceField") then entity:hitboxStep() end
			end)
			character.ChildRemoved:Connect(function(child)
				if child:IsA("ForceField") then entity:hitboxStep() end
			end)
		end)
		player:GetPropertyChangedSignal("Team"):Connect(function() entity:hitboxStep() end)
	end
end

function hitboxHandler:updateHitbox()
	-- stylua: ignore
	for _, player in EntHandler:GetPlayers() do
		player:hitboxStep()
	end
end
function hitboxHandler:Load()
    -- stylua: ignore
	for _, player in EntHandler:GetPlayers() do addEntity(player) end
	table.insert(connections, EntHandler.onPlayerAdded:Connect(addEntity))
	table.insert(connections, lPlayer:GetAttributeChangedSignal("Team"):Connect(hitboxHandler.updateHitbox))
	table.insert(connections, lPlayer.CharacterAdded:Connect(hitboxHandler.updateHitbox))
end
function hitboxHandler:Unload()
	-- stylua: ignore
	for _, connection in connections do connection:Disconnect() end
	unloading = true
	hitboxHandler:updateHitbox()
end

return hitboxHandler
