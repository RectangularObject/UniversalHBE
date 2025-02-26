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
	hitboxPartList = {} :: { [string]: boolean },

	ignoreTeammates = false,
	ignoreFF = false,
	ignoreSitting = false,
	ignoreSelectedPlayers = false,
	ignorePlayerList = {} :: { string },
	ignoreSelectedTeams = false,
	ignoreTeamList = {} :: { string },
}

type Entity = typeof(require("./Classes/Entity.lua").new(Instance.new("Model"))) & {
	oldProperties: {
		[Instance]: { debounce: boolean, Size: Vector3?, Transparency: number?, Massless: boolean?, CanCollide: boolean?, Scale: Vector3?, TextureID: string?, CageMeshId: string? },
	},
	dumpsters: { [Instance]: typeof(Dumpster.new()) },
	hitboxStep: (Entity) -> (),
}
local function addEntity(entity: Entity)
	entity.oldProperties = {}
	entity.dumpsters = {}

	local function spoofInstance(instance)
		entity.oldProperties[instance] = {
			debounce = false,
		}
		entity.dumpsters[instance] = Dumpster.new()
		local oldProperties = entity.oldProperties[instance]
		local dumpster = entity.dumpsters[instance]

		local propertyMap = {
			["Size"] = function(_, value)
				oldProperties.Size = value
				return if hitboxHandler.extendHitbox then hitboxHandler.hitboxSize else value
			end,
			["size"] = function(_, value)
				oldProperties.Size = value
				return if hitboxHandler.extendHitbox then hitboxHandler.hitboxSize else value
			end,
			["Transparency"] = function(_, value)
				oldProperties.Transparency = value
				return if hitboxHandler.extendHitbox then hitboxHandler.hitboxTransparency else value
			end,
			["Massless"] = function(_, value)
				oldProperties.Massless = value
				return if hitboxHandler.extendHitbox then instance ~= entity:GetRootPart() else value
			end,
			["CanCollide"] = function(_, value)
				oldProperties.CanCollide = value
				return if hitboxHandler.extendHitbox then hitboxHandler.hitboxCanCollide else value
			end,
			["Scale"] = function(_, value)
				oldProperties.Scale = value
				return if hitboxHandler.extendHitbox then hitboxHandler.hitboxSize else value
			end,
			["TextureID"] = function(_, value) -- MeshPart
				oldProperties.TextureID = value
				return if hitboxHandler.extendHitbox then "" else value
			end,
			["TextureId"] = function(_, value) -- FileMesh
				oldProperties.TextureID = value
				return if hitboxHandler.extendHitbox then "" else value
			end,
			["CageMeshId"] = function(_, value) -- BaseWrap
				oldProperties.CageMeshId = value
				return if hitboxHandler.extendHitbox then "" else value
			end,
		}
		for property, v in propertyMap do
			if not pcall(function() return not instance[property] end) then continue end -- ohh noo a single pcall this code is TRASH
			oldProperties[property] = instance[property]
			dumpster:dump(instance:AddGetHook(property, function() return oldProperties[property] end))
			dumpster:dump(instance:AddSetHook(property, v))
		end

		-- Serverscripts don't trigger hooks when setting properties
		dumpster:dump(instance.Changed:Connect(function(property)
			if oldProperties.debounce then return end -- Prevent our own modifications from affecting oldProperties
			if oldProperties[property] then oldProperties[property] = instance[property] end
		end))
		dumpster:dump(instance.AncestryChanged:Connect(function(_, parent)
			if parent ~= nil then return end
			oldProperties = nil
			dumpster:burn()
		end))
		--print("spoofed:", instance)
	end

	local function updatePart(part: BasePart, extend: boolean)
		local oldPartProperties = entity.oldProperties[part]
		--print("updatePart:", extend, part)
		oldPartProperties.debounce = true

		-- Parts that are too big will freeze the character in place if they aren't Massless
		if part ~= entity:GetRootPart() then part.Massless = extend or oldPartProperties.Massless end
		part.CanCollide = if extend then hitboxHandler.hitboxCanCollide else oldPartProperties.CanCollide
		part.Size = if extend then hitboxHandler.hitboxSize else oldPartProperties.Size
		-- Some textures cause the part to go invisible when transparency > 0, so nuke them all
		if part:IsA("FileMesh") then part.TextureID = if extend and hitboxHandler.hitboxTransparency > 0 then "" else oldPartProperties.TextureID end
		part.Transparency = if extend then hitboxHandler.hitboxTransparency else oldPartProperties.Transparency

		oldPartProperties.debounce = false

		for _, child in pairs(part:GetChildren()) do
			if child:IsA("Decal") then
				--print("updateDecal:", child)
				local oldDecalProperties = entity.oldProperties[child]
				oldDecalProperties.debounce = true

				child.Transparency = if extend then hitboxHandler.hitboxTransparency else oldDecalProperties.Transparency

				oldDecalProperties.debounce = false
			elseif child:IsA("SpecialMesh") and child.MeshType == Enum.MeshType.FileMesh then
				--print("updateMesh:", child)
				local oldMeshProperties = entity.oldProperties[child]
				oldMeshProperties.debounce = true

				child.TextureId = if extend and hitboxHandler.hitboxTransparency > 0 then "" else oldMeshProperties.TextureId
				-- FileMesh doesn't care about the size of the part, so we have to change the scale of the mesh too
				child.Scale = if extend then hitboxHandler.hitboxSize else oldMeshProperties.Scale

				oldMeshProperties.debounce = false
			elseif child:IsA("BaseWrap") then -- dynamic clothing
				--print("updateWrap:", child)
				local oldWrapProperties = entity.oldProperties[child]
				oldWrapProperties.debounce = true

				-- Can't set the transparency of this, so nuke it too
				child.CageMeshId = if extend and hitboxHandler.hitboxTransparency > 0 then "" else oldWrapProperties.CageMeshId

				oldWrapProperties.debounce = false
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

			if not self.oldProperties[part] then spoofInstance(part) end
			for _, child in pairs(part:GetChildren()) do
				if self.oldProperties[child] then continue end
				if child:IsA("Decal") or (child:IsA("SpecialMesh") and child.MeshType == Enum.MeshType.FileMesh) or child:IsA("BaseWrap") then spoofInstance(child) end
			end

			updatePart(part, hitboxHandler.extendHitbox and validTarget and hitboxHandler.hitboxPartList[tostring(part)])
		end
	end

	local function addUpdateEvents()
		local character = entity:WaitForCharacter()
		--print("addUpdateEvents:", entity:GetName())
		-- Roblox still hasn't fixed CharacterAdded firing too early
		-- https://devforum.roblox.com/t/avatar-loading-event-ordering-improvements/269607
		local humanoid = character:FindFirstChildWhichIsA("Humanoid")
		local startTime = tick()
		while not humanoid and tick() - startTime <= 2 do
			task.wait()
			--print("addUpdateEvents loop")
			-- I sure hope limbs loading before the humanoid is consistent behavior! Seems fine in my 3 minutes of testing.
			humanoid = character:FindFirstChildWhichIsA("Humanoid")
			--print("checking humanoid:", humanoid ~= nil)
		end
		entity.dumpsters[character] = Dumpster.new()
		local connectionDumpster = entity.dumpsters[character]
		if humanoid then
			connectionDumpster:dump(humanoid:GetPropertyChangedSignal("Health"):Connect(function()
				if humanoid.Health <= 0 then
					--print("0Health:", entity:GetName())
					entity:hitboxStep()
				end
			end))
		end
		connectionDumpster:dump(character.ChildAdded:Connect(function(child)
			if child:IsA("ForceField") then
				--print("+forcefield:", entity:GetName())
				entity:hitboxStep()
			end
		end))
		connectionDumpster:dump(character.ChildRemoved:Connect(function(child)
			if child:IsA("ForceField") then
				--print("-forcefield:", entity:GetName())
				entity:hitboxStep()
			end
		end))
		connectionDumpster:dump(character.AncestryChanged:Connect(function(_, parent)
			if parent ~= nil then return end
			connectionDumpster:burn()
		end))
		entity:hitboxStep()
	end

	if entity:GetType() == "Player" then
		local player = entity.instance :: Player
		entity.dumpsters[player] = Dumpster.new()
		local playerConnectionDumpster = entity.dumpsters[player]

		playerConnectionDumpster:dump(player.CharacterAdded:Connect(addUpdateEvents))
		playerConnectionDumpster:dump(player.CharacterRemoving:Connect(function() entity.oldProperties = {} end))
	end

	addUpdateEvents()
end
local function removeEntity(entity: Entity)
	entity.oldProperties = {}
	for _, dumpster in entity.dumpsters do
		dumpster:burn()
	end
end

function hitboxHandler:updatePartList(list: { string })
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
	for _, player: Entity in EntHandler:GetPlayers() do
		player:hitboxStep()
	end
end
local eventConnections: { RBXScriptConnection | typeof(EntHandler.PlayerAdded:Connect(function() end)) } = {}
function hitboxHandler:Load()
	for _, player in EntHandler:GetPlayers() do
		addEntity(player)
	end
	table.insert(eventConnections, EntHandler.PlayerAdded:Connect(addEntity))
	table.insert(eventConnections, EntHandler.PlayerRemoving:Connect(removeEntity))
	table.insert(eventConnections, game:GetService("Players").LocalPlayer:GetPropertyChangedSignal("Team"):Connect(hitboxHandler.updateHitbox))
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
