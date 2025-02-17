local Dumpster = require("./DumpsterModule.lua")
local EntHandler = require("./EntityHandler.lua")

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
	oldProperties: { [Instance]: { debounce: boolean, Size: Vector3?, Transparency: number?, Massless: boolean?, CanCollide: boolean? } },
	dumpsters: { [Instance]: typeof(Dumpster.new()) },
	hitboxStep: (Entity) -> (),
}
local function addEntity(entity: Entity)
	entity.oldProperties = {}
	entity.dumpsters = {}

	local function spoofPart(part: BasePart)
		if not part:IsA("BasePart") then return end
		entity.oldProperties[part] = {
			debounce = false,
			Size = part.Size,
			Transparency = part.Transparency,
			Massless = part.Massless,
			CanCollide = part.CanCollide,
		}
		entity.dumpsters[part] = Dumpster.new()
		local partProperties = entity.oldProperties[part]
		local partDumpster = entity.dumpsters[part]

		partDumpster:dump(part:AddGetHook("Size", function() return partProperties.Size end))
		partDumpster:dump(part:AddGetHook("size", function() return partProperties.Size end))
		partDumpster:dump(part:AddGetHook("Transparency", function() return partProperties.Transparency end))
		partDumpster:dump(part:AddGetHook("Massless", function() return partProperties.Massless end))
		partDumpster:dump(part:AddGetHook("CanCollide", function() return partProperties.CanCollide end))

		partDumpster:dump(part:AddSetHook("Size", function(_, value)
			partProperties.Size = value
			return if hitboxHandler.extendHitbox then hitboxHandler.hitboxSize else value
		end))
		partDumpster:dump(part:AddSetHook("size", function(_, value)
			partProperties.Size = value
			return if hitboxHandler.extendHitbox then hitboxHandler.hitboxSize else value
		end))
		partDumpster:dump(part:AddSetHook("Transparency", function(_, value)
			partProperties.Transparency = value
			return if hitboxHandler.extendHitbox then hitboxHandler.hitboxTransparency else value
		end))
		partDumpster:dump(part:AddSetHook("Massless", function(_, value)
			partProperties.Massless = value
			return if hitboxHandler.extendHitbox then part.Name ~= "HumanoidRootPart" else value
		end))
		partDumpster:dump(part:AddSetHook("CanCollide", function(_, value)
			partProperties.CanCollide = value
			return if hitboxHandler.extendHitbox then hitboxHandler.hitboxCanCollide else value
		end))

		-- properties don't trigger sethooks when set from a serverscript
		partDumpster:dump(part.Changed:Connect(function(property)
			if partProperties.debounce then return end
			if partProperties[property] then partProperties[property] = part[property] end
		end))
		partDumpster:dump(part.AncestryChanged:Connect(function(_, parent)
			if parent ~= nil then return end
			partProperties = nil
			partDumpster:burn()
		end))
		--print("spoofed:", part)
	end
	local function spoofDecal(decal: Decal)
		if not decal:IsA("Decal") then return end
		entity.oldProperties[decal] = {
			debounce = false,
			Transparency = decal.Transparency,
		}
		entity.dumpsters[decal] = Dumpster.new()
		local decalProperties = entity.oldProperties[decal]
		local decalDumpster = entity.dumpsters[decal]

		decalDumpster:dump(decal:AddGetHook("Transparency", function() return decalProperties.Transparency end))
		decalDumpster:dump(decal:AddSetHook("Transparency", function(_, value)
			decalProperties.Transparency = value
			return if hitboxHandler.extendHitbox then hitboxHandler.hitboxTransparency else value
		end))

		decalDumpster:dump(decal.Changed:Connect(function(property)
			if decalProperties.debounce then return end
			if decalProperties[property] then decalProperties[property] = decal[property] end
		end))
		decalDumpster:dump(decal.AncestryChanged:Connect(function(_, parent)
			if parent ~= nil then return end
			decalProperties = nil
			decalDumpster:burn()
		end))
		--print("spoofed:", decal)
	end

	local function extendPart(part: BasePart)
		local oldPartProperties = entity.oldProperties[part]
		--print("extendPart:", part)
		oldPartProperties.debounce = true
		if part ~= entity:GetRootPart() then part.Massless = true end
		part.CanCollide = hitboxHandler.hitboxCanCollide
		part.Size = hitboxHandler.hitboxSize
		part.Transparency = hitboxHandler.hitboxTransparency
		oldPartProperties.debounce = false
		for _, child in pairs(part:GetChildren()) do
			if child:IsA("Decal") then
				--print("extendDecal:", child)
				local oldDecalProperties = entity.oldProperties[child]
				oldDecalProperties.debounce = true
				child.Transparency = hitboxHandler.hitboxTransparency
				oldDecalProperties.debounce = false
			end
		end
	end
	local function resetPart(part: BasePart)
		--print("resetPart:", part)
		local oldPartProperties = entity.oldProperties[part]
		oldPartProperties.debounce = true
		if part ~= entity:GetRootPart() then part.Massless = oldPartProperties.Massless :: boolean end
		part.CanCollide = oldPartProperties.CanCollide :: boolean
		part.Size = oldPartProperties.Size :: Vector3
		part.Transparency = oldPartProperties.Transparency :: number
		oldPartProperties.debounce = false
		for _, child in pairs(part:GetChildren()) do
			if child:IsA("Decal") then
				--print("resetDecal:", child)
				local oldDecalProperties = entity.oldProperties[child]
				oldDecalProperties.debounce = true
				child.Transparency = oldDecalProperties.Transparency :: number
				oldDecalProperties.debounce = false
			end
		end
	end
	function entity:hitboxStep()
		--print("hitboxStep:", self:GetName())
		local character = self:GetCharacter()
		if not character then
			--print("character not found")
			return
		end

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
		--print("validTarget:", validTarget)
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
		--print("addUpdateEvents:", entity:GetName(), character)
		if not character then
			--print("character not found")
			return
		end
		-- Roblox still hasn't fixed CharacterAdded firing before all of the limbs are loaded
		-- https://devforum.roblox.com/t/avatar-loading-event-ordering-improvements/269607
		local humanoid
		local loaded = false
		local startTime = tick()
		while not loaded and tick() - startTime <= 2 do
			task.wait()
			--print("addUpdateEvents loop")
			for name, _ in hitboxHandler.hitboxPartList do
				--print("checking part", name .. ":", character:FindFirstChild(name) ~= nil)
				if not character:FindFirstChild(name) then return end
			end
			humanoid = character:FindFirstChildWhichIsA("Humanoid")
			--print("checking humanoid:", humanoid ~= nil)
			if not humanoid then return end
			loaded = true
		end
		if humanoid then
			humanoid:GetPropertyChangedSignal("Health"):Connect(function()
				if humanoid.Health <= 0 then entity:hitboxStep() end
				--print(entity:GetName(), "died")
			end)
			humanoid.StateChanged:Connect(function(_, newState)
				if newState == Enum.HumanoidStateType.Dead then entity:hitboxStep() end
			end)
		end
		character.ChildAdded:Connect(function(child)
			if child:IsA("ForceField") then entity:hitboxStep() end
			--print(entity:GetName(), "invulnerable")
		end)
		character.ChildRemoved:Connect(function(child)
			if child:IsA("ForceField") then entity:hitboxStep() end
			--print(entity:GetName(), "vulnerable")
		end)
		entity:hitboxStep()
	end

	if entity:GetType() == "Player" then
		local player = entity.instance :: Player
		entity.dumpsters[player] = Dumpster.new()
		local playerConnectionDumpster = entity.dumpsters[player]

		playerConnectionDumpster:dump(player.CharacterAdded:Connect(addUpdateEvents))
		playerConnectionDumpster:dump(player.CharacterRemoving:Connect(function() entity.oldProperties = {} end))
		playerConnectionDumpster:dump(player:GetPropertyChangedSignal("Team"):Connect(entity.hitboxStep))
	end

	addUpdateEvents(entity:GetCharacter())
end
local function removeEntity(entity: Entity)
	entity.oldProperties = {}
	for _, dumpster in entity.dumpsters do
		dumpster:burn()
	end
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
local eventConnections = {}
function hitboxHandler:Load()
	for _, player in EntHandler:GetPlayers() do
		addEntity(player)
	end
	table.insert(eventConnections, EntHandler.PlayerAdded:Connect(addEntity))
	table.insert(eventConnections, EntHandler.PlayerRemoving:Connect(removeEntity))
end
function hitboxHandler:Unload()
	for _, connection in eventConnections do
		connection:Disconnect()
	end
	for _, player: Entity in EntHandler:GetPlayers() do
		removeEntity(player)
	end
end
return hitboxHandler
