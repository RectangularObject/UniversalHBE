local EntHandler = require("./EntityHandler.lua")
local UI = require("./UI.lua")
local Toggles = UI.Toggles
local Options = UI.Options
local hitboxHandler = {}
local connections = {}

if not getgenv().MTAPIMutex then
	local _mtapi = request({ Url = "https://raw.githubusercontent.com/RectangularObject/MT-Api-v2/main/__source/mt-api%20v2.lua" })
	assert(_mtapi.StatusCode == 200, "Failed to request mt-api v2.lua");
	(loadstring(_mtapi.Body) :: (...any) -> ...any)()
	getgenv().MTAPIMutex = true -- getgenv still broken on celery
end

type Entity = typeof(require("./Classes/Entity.lua").new(Instance.new("Model"))) & {
	oldProperties: { [Instance]: { debounce: boolean?, Size: Vector3?, Transparency: number?, Massless: boolean?, CanCollide: boolean? } },
	hooks: { [string]: mtapiHook },
	hitboxStep: (Entity) -> (),
}
local function addEntity(entity: Entity)
	entity.oldProperties = {}
	entity.hooks = {}

	local function spoofPart(part: BasePart)
		if not part:IsA("BasePart") then return end
		entity.oldProperties[part] = {
			debounce = false,
			Size = part.Size,
			Transparency = part.Transparency,
			Massless = part.Massless,
			CanCollide = part.CanCollide,
		}
		local partProperties = entity.oldProperties[part]

		local partHooks = entity.hooks
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
		entity.oldProperties[decal] = {
			Transparency = decal.Transparency,
		}
		local decalProperties = entity.oldProperties[decal]

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
	table.insert(connections, EntHandler.PlayerAdded:Connect(addEntity))
end
function hitboxHandler:Unload()
	for _, connection in connections do
		connection:Disconnect()
	end
	Toggles.hitboxToggle:SetValue(false)
	for _, player: Entity in EntHandler:GetPlayers() do
		for _, hook in player.hooks do
			hook:Remove()
		end
	end
end
return hitboxHandler
