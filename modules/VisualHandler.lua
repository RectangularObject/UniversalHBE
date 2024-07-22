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

local function addEntity(entity)
	local nameEsp = Drawing.new("Text")
	nameEsp.Center = true
	nameEsp.Outline = true
	entity.nameEsp = nameEsp
	entity.chams = nil

	local function updateEsp(pos)
		if not Toggles.nameToggle.Value then
			nameEsp.Visible = false
			return
		end
		nameEsp.Text = if Options.nameType.Value == "Display Name" then entity:GetDisplayName() else entity:GetName()
		nameEsp.Color = if Toggles.nameUseTeamColor.Value then entity:GetTeamColor() else Options.nameFillColor.Value
		nameEsp.OutlineColor = Options.nameOutlineColor.Value
		nameEsp.Position = Vector2.new(pos.X, pos.Y)
		nameEsp.Size = math.clamp(1000 / pos.Z, 10, math.huge)
		nameEsp.Visible = true
	end
	local function updateChams()
		if not Toggles.chamsToggle.Value then
			if entity.chams then
				entity.chams:Destroy()
				entity.chams = nil
			end
			return
		end
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

	function entity:espStep()
		if not self:GetCharacter() or self:isDead() then
			if self.chams then
				self.chams:Destroy()
				self.chams = nil
			end
			nameEsp.Visible = false
			return
		end
		local pos, vis = WorldToViewportPoint(Camera, self:GetPosition())
		if not vis then
			if self.chams then
				self.chams:Destroy()
				self.chams = nil
			end
			nameEsp.Visible = false
			return
		end
		updateEsp(pos)
		updateChams()
	end
end
local function removeEntity(entity)
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
			player:espStep()
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
