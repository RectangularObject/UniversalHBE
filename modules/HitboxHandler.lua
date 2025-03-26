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
	ignorePlayerList = {} :: { [string]: boolean },
	ignoreSelectedTeams = false,
	ignoreTeamList = {} :: { [string]: boolean },
}

type EntityObj = typeof(require("./Classes/Entity.lua").new(...)) & {
	hitboxStep: (EntityObj) -> (),
}
type PlayerObj = typeof(require("./Classes/Player.lua").new(...))

local entityInstanceDumpsters: { [EntityObj]: { [Instance]: typeof(Dumpster.new()) } } = {}
local function addEntity(entity: EntityObj)
	local oldProperties: {
		[Instance]: {
			Size: Vector3?,
			Transparency: number?,
			Massless: boolean?,
			CanCollide: boolean?,
			Scale: Vector3?,
			TextureID: string?,
			TextureId: string?,
			CageMeshId: string?,
		},
	} = -- stylua is weird
		{}
	local propertyDebounces: { [Instance]: { [string]: boolean } } = {}
	entityInstanceDumpsters[entity] = {}
	local instanceDumpsters = entityInstanceDumpsters[entity]

	local function isValidPart(part) return hitboxHandler.extendHitbox and hitboxHandler.hitboxPartList[tostring(part)] end
	local function isValidTarget()
		-- stylua: ignore start
		return (
				if entity:isDead()                                                                                  then false
			elseif hitboxHandler.ignoreTeammates       and entity:isTeammate()                                      then false
			elseif hitboxHandler.ignoreFF              and entity:isFFed()                                          then false
			elseif hitboxHandler.ignoreSitting         and entity:isSitting()                                       then false
			elseif hitboxHandler.ignoreSelectedPlayers and hitboxHandler.ignorePlayerList[entity:GetName()]         then false
			elseif hitboxHandler.ignoreSelectedTeams   and hitboxHandler.ignoreTeamList[tostring(entity:GetTeam())] then false
			else true
		)
		-- stylua: ignore end
	end

	local function updateProperty(part: Instance, property: string, value: any)
		--print("\t" .. property, value)
		propertyDebounces[part][property] = true
		part[property] = value
		-- have to defer the debounce because of a race condition with the changed event
		task.defer(function() propertyDebounces[part][property] = false end)
	end
	local function spoofInstance(instance)
		--print(entity:GetName(), "spoofing", tostring(instance))
		propertyDebounces[instance] = {}
		local instancePropertyDebounces = propertyDebounces[instance]
		oldProperties[instance] = {}
		local oldInstanceProperties = oldProperties[instance]
		instanceDumpsters[instance] = Dumpster.new()
		local dumpster = instanceDumpsters[instance]

		local propertyMap = {
			["Size"] = function() return hitboxHandler.hitboxSize end,
			["size"] = function() return hitboxHandler.hitboxSize end,
			["Transparency"] = function() return hitboxHandler.hitboxTransparency end,
			["Massless"] = function() return instance ~= entity:GetRootPart() end,
			["CanCollide"] = function() return hitboxHandler.hitboxCanCollide end,
			["Scale"] = function() return hitboxHandler.hitboxSize end,
			["TextureID"] = function() return "" end, -- MeshPart
			["TextureId"] = function() return "" end, -- FileMesh
			["CageMeshId"] = function() return "" end, -- BaseWrap
		}
		for property, callback in propertyMap do
			if not pcall(function() return not instance[property] end) then continue end -- ohh noo a pcall this code is TRASH
			--print("\t" .. property, instance[property])
			oldInstanceProperties[property] = instance[property]
			dumpster:dump(instance:AddGetHook(property, function() return oldInstanceProperties[property] end))
			dumpster:dump(instance:AddSetHook(property, function(oldValue, newValue): any
				oldInstanceProperties[property] = newValue
				return if isValidPart(instance) and isValidTarget() then callback() else newValue
			end))
			if not pcall(function() return instance:GetPropertyChangedSignal(property) end) then continue end -- a second pcall has hit the hitbox extender this SUCKS
			dumpster:dump(instance:GetPropertyChangedSignal(property):Connect(function() -- Serverscripts don't trigger hooks when setting properties
				if instancePropertyDebounces[property] or oldInstanceProperties[property] == instance[property] then
					--print(entity:GetName(), "debounce hit", tostring(instance), property, instance[property])
					return
				end
				--print(entity:GetName(), "changed event", tostring(instance), property, instance[property])
				oldInstanceProperties[property] = instance[property]
				if isValidPart(instance) and isValidTarget() then updateProperty(instance, property, callback()) end
			end))
		end

		dumpster:dump(instance.AncestryChanged:Connect(function(_, parent)
			if parent ~= nil then return end
			oldProperties[instance] = nil
			dumpster:burn()
		end))
		--print(entity:GetName(), "spoofed", tostring(instance))
	end
	local function updatePart(part: BasePart, extend: boolean)
		--print(entity:GetName(), "updating", tostring(part), extend)
		local oldPartProperties = oldProperties[part]

		-- Parts that are too big will freeze the character if they aren't Massless
		-- Setting the RootPart to Massless will also freeze the character
		updateProperty(part, "Massless", if extend then part ~= entity:GetRootPart() else oldPartProperties.Massless)
		updateProperty(part, "CanCollide", if extend then hitboxHandler.hitboxCanCollide else oldPartProperties.CanCollide)
		updateProperty(part, "Size", if extend then hitboxHandler.hitboxSize else oldPartProperties.Size)
		-- Some textures cause the part to go invisible when transparency > 0, so nuke them all
		if part:IsA("FileMesh") then updateProperty(part, "TextureID", if extend and hitboxHandler.hitboxTransparency > 0 then "" else oldPartProperties.TextureID) end
		updateProperty(part, "Transparency", if extend then hitboxHandler.hitboxTransparency else oldPartProperties.Transparency)

		for _, child in pairs(part:GetChildren()) do
			local oldChildProperties = oldProperties[child]
			if not oldChildProperties then continue end
			if child:IsA("Decal") then
				--print(entity:GetName(), "updateDecal", tostring(child))
				updateProperty(child, "Transparency", if extend then hitboxHandler.hitboxTransparency else oldChildProperties.Transparency)
			elseif child:IsA("SpecialMesh") and child.MeshType == Enum.MeshType.FileMesh then
				--print(entity:GetName(), "updateMesh", tostring(child))
				updateProperty(child, "TextureId", if extend and hitboxHandler.hitboxTransparency > 0 then "" else oldChildProperties.TextureId)
				-- FileMesh doesn't care about the size of the part, so we have to change the scale of the mesh too
				updateProperty(child, "Scale", if extend then hitboxHandler.hitboxSize else oldChildProperties.Scale)
			elseif child:IsA("BaseWrap") then -- dynamic clothing
				--print(entity:GetName(), "updateWrap", tostring(child))
				-- Can't set the transparency of this, so nuke it too
				updateProperty(child, "CageMeshId", if extend and hitboxHandler.hitboxTransparency > 0 then "" else oldChildProperties.CageMeshId)
			end
		end
		--print(entity:GetName(), "update done", tostring(part), extend)
	end

	function entity.hitboxStep()
		--print(entity:GetName(), "hitboxStep:")
		local character = entity:GetCharacter()
		if not character then
			--print("character not found")
			return
		end

		local validTarget = isValidTarget()
		--print("validTarget:", validTarget)
		for _, part: BasePart in pairs(character:GetChildren()) do
			if not part:IsA("BasePart") then continue end

			if not oldProperties[part] then spoofInstance(part) end
			for _, child in pairs(part:GetChildren()) do
				if oldProperties[child] then continue end
				if child:IsA("Decal") or (child:IsA("SpecialMesh") and child.MeshType == Enum.MeshType.FileMesh) or child:IsA("BaseWrap") then spoofInstance(child) end
			end

			updatePart(part, isValidPart(part) and validTarget)
		end
	end

	entity.CharacterUpdatedEvent:Connect(entity.hitboxStep)
	entity.DeathEvent:Connect(entity.hitboxStep)
	entity.DespawnEvent:Connect(entity.hitboxStep)
	entity.TeamEvent:Connect(entity.hitboxStep)
	entity.SeatEvent:Connect(entity.hitboxStep)
	entity.CustomEvent:Connect(entity.hitboxStep)

	entity.hitboxStep()
end
local function removeEntity(entity: EntityObj)
	for _, dumpster in entityInstanceDumpsters[entity] do
		dumpster:burn()
	end
end

function hitboxHandler:updatePartList(list: { string })
	hitboxHandler.hitboxPartList = {}
	local partMap: { [string]: { string } } = {
		["Custom Part"] = string.split(hitboxHandler.customPartName, ","),
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
	for _, player: PlayerObj in EntHandler:GetPlayers() do
		player:hitboxStep()
	end
end
-- TODO: change this to use a dumpster instead (implement custom event support to dumpster)
local eventConnections: { RBXScriptConnection | typeof(EntHandler.PlayerAdded:Connect(function() end)) } = {}
function hitboxHandler:Load()
	for _, player in EntHandler:GetPlayers() do
		addEntity(player)
	end
	for _, entity in EntHandler:GetEntities() do
		addEntity(entity)
	end
	table.insert(eventConnections, EntHandler.PlayerAdded:Connect(addEntity))
	table.insert(eventConnections, EntHandler.PlayerRemoving:Connect(removeEntity))
	table.insert(eventConnections, EntHandler.EntityAdded:Connect(addEntity))
	table.insert(eventConnections, EntHandler.EntityRemoving:Connect(removeEntity))
	table.insert(eventConnections, game:GetService("Players").LocalPlayer:GetPropertyChangedSignal("Team"):Connect(hitboxHandler.updateHitbox))
end
function hitboxHandler:Unload()
	for _, connection in eventConnections do
		connection:Disconnect()
	end
	self = nil
end
return hitboxHandler
