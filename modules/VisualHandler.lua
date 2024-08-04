local EntHandler = require("./EntityHandler.lua")
local UI = require("./UI.lua")
local RunService = cloneref(game:GetService("RunService"))
local Workspace = cloneref(game:GetService("Workspace"))
local Camera = Workspace.CurrentCamera
local WorldToViewportPoint = Camera.WorldToViewportPoint
local Toggles = UI.Toggles
local Options = UI.Options
local visualHandler = {}
local connections = {
	Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function() Camera = Workspace.CurrentCamera end),
}

type Entity = typeof(require("./Classes/Entity.lua").new(Instance.new("Model"))) & { nameEsp: DrawingText, chams: Highlight | nil, espStep: (Entity) -> () }
local function addEntity(entity: Entity)
	local nameEsp: DrawingText = Drawing.new("Text")
	nameEsp.Center = true
	nameEsp.Outline = true
	entity.nameEsp = nameEsp
	entity.chams = nil

	local function hideEsp() nameEsp.Visible = false end
	local function updateEsp(pos)
		nameEsp.Text = if Options.nameType.Value == "Display Name" then entity:GetDisplayName() else entity:GetName()
		nameEsp.Color = if Toggles.nameUseTeamColor.Value then entity:GetTeamColor() else Options.nameFillColor.Value
		nameEsp.OutlineColor = Options.nameOutlineColor.Value
		nameEsp.Position = Vector2.new(pos.X, pos.Y)
		nameEsp.Size = math.clamp(1000 / pos.Z, 10, math.huge)
		nameEsp.Visible = true
	end
	local function hideChams()
		if entity.chams then
			entity.chams:Destroy()
			entity.chams = nil
		end
	end
	local function updateChams()
		if not entity.chams then entity.chams = Instance.new("Highlight") end
		local chams = entity.chams
		local useTeamColor = Toggles.chamsUseTeamColor.Value
		local teamColor = entity:GetTeamColor()
		chams.FillColor = if useTeamColor then teamColor else Options.chamsFillColor.Value
		chams.FillTransparency = Options.chamsFillColor.Transparency
		chams.OutlineColor = if useTeamColor then teamColor else Options.chamsOutlineColor.Value
		chams.OutlineTransparency = Options.chamsOutlineColor.Transparency
		chams.DepthMode = Enum.HighlightDepthMode[Options.chamsDepthMode.Value]
		chams.Adornee = entity:GetCharacter()
		chams.Enabled = true
		chams.Parent = gethui()
	end
	local function hideEspAndChams()
		hideEsp()
		hideChams()
	end

	function entity:espStep()
		if self:isDead() then
			hideEspAndChams()
			return
		end
		local pos, vis = WorldToViewportPoint(Camera, self:GetPosition())
		if not vis then
			hideEspAndChams()
			return
		end
		-- stylua: ignore start
		local validTarget = (
				if Toggles.ignoreTeammates.Value       and self:isTeammate() then false
			elseif Toggles.ignoreFF.Value              and self:isFFed()     then false
			elseif Toggles.ignoreSitting.Value         and self:isSitting()  then false
			elseif Toggles.ignoreSelectedPlayers.Value and table.find(Options.ignorePlayerList:GetActiveValues(), self:GetName())         then false
			elseif Toggles.ignoreSelectedTeams.Value   and table.find(Options.ignoreTeamList:GetActiveValues(), tostring(self:GetTeam())) then false
			else true
		)
		-- stylua: ignore end
		if Toggles.nameToggle.Value and validTarget then
			updateEsp(pos)
		else
			hideEsp()
		end
		if Toggles.chamsToggle.Value and validTarget then
			updateChams()
		else
			hideChams()
		end
	end
end
local function removeEntity(entity: Entity)
	entity.nameEsp:Destroy()
	if entity.chams then entity.chams:Destroy() end
end

function visualHandler:Load()
	for _, entity in EntHandler:GetPlayers() do
		addEntity(entity)
	end
	table.insert(connections, EntHandler.PlayerAdded:Connect(addEntity))
	table.insert(connections, EntHandler.PlayerRemoving:Connect(removeEntity))
	RunService:BindToRenderStep("furryESP", Enum.RenderPriority.Camera.Value - 1, function()
		for _, player in EntHandler:GetPlayers() do
			task.spawn(player.espStep, player)
		end
	end)
end
function visualHandler:Unload()
	for _, connection in connections do
		connection:Disconnect()
	end
	RunService:UnbindFromRenderStep("furryESP")
	for _, player in EntHandler:GetPlayers() do
		removeEntity(player)
	end
end

return visualHandler

--[[
TODO: rewrite this to only update properties when needed (like the hitbox handler)
]]
