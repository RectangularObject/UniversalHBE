local EntHandler = require("./EntityHandler.lua")
local connections = {}

if not getgenv().MTAPIMutex then
	local _mtapi = request({ Url = "https://raw.githubusercontent.com/RectangularObject/MT-Api-v2/main/__source/mt-api%20v2.lua" })
	assert(_mtapi.StatusCode == 200, "Failed to request mt-api v2.lua");
	(loadstring(_mtapi.Body) :: (...any) -> ...any)()
end

local hitboxHandler = {
	extendHitbox = false,
	hitboxSize = Vector3.new(5, 5, 5),
	hitboxTransparency = 0,
	hitboxCanCollide = false,
	customPartName = "HeadHB",
	hitboxPartList = {},

	ignoreTeammates = false,
	ignoreFF = false,
	ignoreSitting = false,
	ignoreSelectedPlayers = false,
	ignorePlayerList = {},
	ignoreSelectedTeams = false,
	ignoreTeamList = {},
}

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
			return if hitboxHandler.extendHitbox then hitboxHandler.hitboxSize else value
		end)
		partHooks.setSizeHook = part:AddSetHook("size", function(_, value)
			partProperties.Size = value
			return if hitboxHandler.extendHitbox then hitboxHandler.hitboxSize else value
		end)
		partHooks.setTransparencyHook = part:AddSetHook("Transparency", function(_, value)
			partProperties.Transparency = value
			return if hitboxHandler.extendHitbox then hitboxHandler.hitboxTransparency else value
		end)
		partHooks.setMasslessHook = part:AddSetHook("Massless", function(_, value)
			partProperties.Massless = value
			return if hitboxHandler.extendHitbox then part.Name ~= "HumanoidRootPart" else value
		end)
		partHooks.setCanCollideHook = part:AddSetHook("CanCollide", function(_, value)
			partProperties.CanCollide = value
			return if hitboxHandler.extendHitbox then hitboxHandler.hitboxCanCollide else value
		end)

		part.Changed:Connect(function(property) -- __namecall isn't replicated to the client when called from a serverscript
			if partProperties.debounce then return end
			if partProperties[property] then partProperties[property] = part[property] end
		end)
		part.AncestryChanged:Connect(function(instance, parent)
			if parent ~= nil then return end
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

		local decalHooks = entity.hooks
		decalHooks.getTransparencyHook = decal:AddGetHook("Transparency", function() return decalProperties.Transparency end)
		decalHooks.setTransparencyHook = decal:AddSetHook("Transparency", function(_, value)
			decalProperties.Transparency = value
			return if hitboxHandler.extendHitbox then hitboxHandler.hitboxTransparency else value
		end)

		decal.Changed:Connect(function(property)
			if decalProperties.debounce then return end
			if decalProperties[property] then decalProperties[property] = decal[property] end
		end)
		decal.AncestryChanged:Connect(function(instance, parent)
			if parent ~= nil then return end
			for _, hook in decalHooks do
				hook:Remove()
			end
			decalProperties = nil
		end)
	end

	local function extendPart(part: BasePart)
		entity.oldProperties[part].debounce = true
		if part ~= entity:GetRootPart() then part.Massless = true end
		part.CanCollide = hitboxHandler.hitboxCanCollide
		part.Size = hitboxHandler.hitboxSize
		part.Transparency = hitboxHandler.hitboxTransparency
		for _, child in pairs(part:GetChildren()) do
			if child:IsA("Decal") then
				entity.oldProperties[child].debounce = true
				child.Transparency = hitboxHandler.hitboxTransparency
				entity.oldProperties[child].debounce = false
			end
		end
		entity.oldProperties[part].debounce = false
	end
	local function resetPart(part: BasePart)
		entity.oldProperties[part].debounce = true
		if part ~= entity:GetRootPart() then part.Massless = entity.oldProperties[part].Massless :: boolean end
		part.CanCollide = entity.oldProperties[part].CanCollide :: boolean
		part.Size = entity.oldProperties[part].Size :: Vector3
		part.Transparency = entity.oldProperties[part].Transparency :: number
		for _, child in pairs(part:GetChildren()) do
			if child:IsA("Decal") then
				entity.oldProperties[child].debounce = true
				child.Transparency = entity.oldProperties[child].Transparency :: number
				entity.oldProperties[child].debounce = false
			end
		end
		entity.oldProperties[part].debounce = false
	end
	function entity:hitboxStep()
		local character = self:GetCharacter()
		if not character then return end

		-- stylua: ignore start
		local validTarget = (
				if self:isDead()                                                                          then false
			elseif hitboxHandler.ignoreTeammates       and self:isTeammate()                              then false
			elseif hitboxHandler.ignoreFF              and self:isFFed()                                  then false
			elseif hitboxHandler.ignoreSitting         and self:isSitting()                               then false
			elseif hitboxHandler.ignoreSelectedPlayers and hitboxHandler.ignorePlayerList[self:GetName()] then false
			elseif hitboxHandler.ignoreSelectedTeams   and hitboxHandler.ignoreTeamList[self:GetTeam()]   then false
			else true
		)
		-- stylua: ignore end

		for _, part: BasePart in pairs(character:GetChildren()) do
			if not part:IsA("BasePart") then continue end
			if not self.oldProperties[part] then spoofPart(part) end
			for _, child in pairs(part:GetChildren()) do
				if child:IsA("Decal") and not self.oldProperties[child] then spoofDecal(child) end
			end

			if hitboxHandler.extendHitbox and validTarget and hitboxHandler.hitboxPartList[tostring(part)] then
				extendPart(part)
			else
				resetPart(part)
			end
		end
	end

	local function addUpdateEvents(character: Model?)
		if not character then return end
		-- Roblox still hasn't fixed CharacterAdded firing before all of the limbs are loaded
		-- https://devforum.roblox.com/t/avatar-loading-event-ordering-improvements/269607
		local humanoid
		local loaded = false
		local startTime = tick()
		while not loaded and tick() - startTime <= 2 do
			task.wait()
			for name, _ in hitboxHandler.hitboxPartList do
				if not character:FindFirstChild(name) then return end
			end
			humanoid = character:FindFirstChildWhichIsA("Humanoid")
			if not humanoid then return end
			loaded = true
		end
		if humanoid then
			humanoid:GetPropertyChangedSignal("Health"):Connect(function()
				if humanoid.Health <= 0 then entity:hitboxStep() end
			end)
			humanoid.StateChanged:Connect(function(_, newState)
				if newState == Enum.HumanoidStateType.Dead then entity:hitboxStep() end
			end)
		end
		character.ChildAdded:Connect(function(child)
			if child:IsA("ForceField") then entity:hitboxStep() end
		end)
		character.ChildRemoved:Connect(function(child)
			if child:IsA("ForceField") then entity:hitboxStep() end
		end)
	end

	if entity:GetType() == "Player" then
		local player = entity.instance :: Player

		player.CharacterAdded:Connect(addUpdateEvents)
		player.CharacterRemoving:Connect(function(character)
			if entity then entity.oldProperties = {} end
		end)
		player:GetPropertyChangedSignal("Team"):Connect(entity.hitboxStep)
	end

	addUpdateEvents(entity:GetCharacter())
end

function hitboxHandler:updatePartList(list: { [string]: boolean })
	hitboxHandler.hitboxPartList = {}
	local partMap: { [string]: { string } } = {
		["Custom Part"] = { hitboxHandler.customPartName },
		["Head"] = { "Head" },
		["RootPart"] = { "HumanoidRootPart" },
		["Torso"] = { "UpperTorso", "LowerTorso", "Torso" },
		["Left Arm"] = { "LeftHand", "LeftLowerArm", "LeftUpperArm", "Left Arm" },
		["Right Arm"] = { "RightHand", "RightLowerArm", "RightUpperArm", "Right Arm" },
		["Left Leg"] = { "LeftFoot", "LeftLowerLeg", "LeftUpperLeg", "Left Leg" },
		["Right Leg"] = { "RightFoot", "RightLowerLeg", "RightUpperLeg", "Right Leg" },
	}
	for _, selectedPart in list do
		if partMap[selectedPart] then
			for _, relevantPart in partMap[selectedPart] do
				hitboxHandler.hitboxPartList[relevantPart] = true
			end
		end
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
	table.insert(connections, EntHandler.PlayerAdded:Connect(addEntity))
end
function hitboxHandler:Unload()
	for _, connection in connections do
		connection:Disconnect()
	end
	for _, player: Entity in EntHandler:GetPlayers() do
		for _, hook in player.hooks do
			hook:Remove()
		end
	end
end
return hitboxHandler
