local EntHandler = require("./EntityHandler.lua")
local UI = require("./UI.lua")
local Toggles = UI.Toggles
local Options = UI.Options
local hitboxHandler = {}
local connections = {}

if not getgenv().MTAPIMutex then
	local _mtapi = request({ Url = "https://raw.githubusercontent.com/RectangularObject/MT-Api-v2/main/__source/mt-api%20v2.lua" })
	assert(_mtapi.Success, "Failed to request mt-api v2.lua")
	loadstring(_mtapi.Body)
end
local function addEntity(entity)
	local oldProperties = {}

	local function spoofPart(part: BasePart)
		if not part:IsA("BasePart") then return end
		oldProperties[part] = {}
		local partProperties = oldProperties[part]
		partProperties.debounce = false
		partProperties.Size = part.Size
		partProperties.Transparency = part.Transparency
		partProperties.Massless = part.Massless
		partProperties.CanCollide = part.CanCollide

		partProperties.hooks = {}
		local partHooks = partProperties.hooks
		partHooks.getSizeHook = part:AddGetHook("Size", function() return partProperties.Size end)
		partHooks.getsizeHook = part:AddGetHook("size", function() return partProperties.Size end)
		partHooks.getTransparencyHook = part:AddGetHook("Transparency", function() return partProperties.Transparency end)
		partHooks.getMasslessHook = part:AddGetHook("Massless", function() return partProperties.Massless end)
		partHooks.getCanCollideHook = part:AddGetHook("CanCollide", function() return partProperties.CanCollide end)

		partHooks.setSizeHook = part:AddSetHook("Size", function(_, value)
			partProperties.Size = value
			local hitboxSize = Options.hitboxSize.Value
			return if Toggles.hitboxToggle.Value then Vector3.new(hitboxSize, hitboxSize, hitboxSize) else value
		end)
		partHooks.setSizeHook = part:AddSetHook("size", function(_, value)
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
			return if Toggles.hitboxToggle.Value then part.Name ~= "HumanoidRootPart" else value
		end)
		partHooks.setCanCollideHook = part:AddSetHook("CanCollide", function(_, value)
			partProperties.CanCollide = value
			return if Toggles.hitboxToggle.Value then Toggles.collisionsToggle.Value else value
		end)

		part.Changed:Connect(function(property) -- __namecall isn't replicated to the client when called from a serverscript
			if partProperties.debounce then return end
			if partProperties[property] then partProperties[property] = part[property] end
		end)
		part.Destroying:Connect(function()
			for _, hook in partHooks do
				hook:Remove()
			end
			partProperties = nil
		end)
	end
	local function spoofDecal(decal: Decal)
		if not decal:IsA("Decal") then return end
		oldProperties[decal] = {}
		local decalProperties = oldProperties[decal]
		decalProperties.Transparency = decal.Transparency

		local decalHooks = decalProperties.hooks
		decalHooks.getTransparencyHook = decal:AddGetHook("Transparency", function() return decalProperties.Transparency end)
		decalHooks.setTransparencyHook = decal:AddSetHook("Transparency", function(_, value)
			decalProperties.Transparency = value
			return if Toggles.hitboxToggle.Value then Options.hitboxTransparency.Value else value
		end)

		decal.Changed:Connect(function(property)
			if decalProperties.debounce then return end
			if decalProperties[property] then decalProperties[property] = decal[property] end
		end)
		decal.Destroying:Connect(function()
			for _, hook in decalHooks do
				hook:Remove()
			end
			decalProperties = nil
		end)
	end

	function entity:hitboxStep() end
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
	EntHandler.PlayerAdded:Connect(addEntity)
end
function hitboxHandler:Unload()
	for _, connection in connections do
		connection:Disconnect()
	end
	Toggles.hitboxToggle:SetValue(false)
end
return hitboxHandler
