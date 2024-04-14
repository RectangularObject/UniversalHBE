local EntHandler = require("./EntityHandler.lua")
local UI = require("./UI.lua")
local RunService: RunService = cloneref(game:GetService("RunService"))
local Workspace: Workspace = cloneref(game:GetService("Workspace"))
local CoreGui: CoreGui = cloneref(game:GetService("CoreGui"))
local Camera = Workspace.CurrentCamera
local WorldToViewportPoint = clonefunction(Camera.WorldToViewportPoint)
local Toggles = UI.Toggles
local Options = UI.Options
local visualHandler = {}
local connections = {
	[1] = Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function() Camera = Workspace.CurrentCamera end),
}

local function updateEsp(self, pos)
	local nameEsp = self.nameEsp
	-- stylua: ignore
	if not Toggles.nameToggle.Value then nameEsp.Visible = false return end
	nameEsp.Text = if Options.nameType.Value == "Display Name" then self:GetDisplayName() else self:GetName()
	nameEsp.Color = if Toggles.nameUseTeamColor.Value then self:GetTeamColor() else Options.nameFillColor.Value
	nameEsp.OutlineColor = Options.nameOutlineColor.Value
	nameEsp.Position = Vector2.new(pos.X, pos.Y)
	nameEsp.Size = 1000 / pos.Z + 10
	nameEsp.Visible = true
end

local function updateChams(self)
	-- stylua: ignore
	if not Toggles.chamsToggle.Value then if self.chams then self.chams:Destroy() self.chams = nil end return end
	if not self.chams then self.chams = Instance.new("Highlight", CoreGui) end
	local chams = self.chams
	local useTeamColor = Toggles.chamsUseTeamColor.Value
	local teamColor = self:GetTeamColor()
	chams.FillColor = if useTeamColor then teamColor else Options.chamsFillColor.Value
	chams.FillTransparency = Options.chamsFillColor.Transparency
	chams.OutlineColor = if useTeamColor then teamColor else Options.chamsOutlineColor.Value
	chams.OutlineTransparency = Options.chamsOutlineColor.Transparency
	chams.DepthMode = Enum.HighlightDepthMode[Options.chamsDepthMode.Value]
	chams.Adornee = self:GetCharacter()
	chams.Enabled = true
end

local function addEntity(entity: table)
	-- stylua: ignore
	local nameEsp = Drawing.new("Text") nameEsp.Center = true nameEsp.Outline = true
	entity.nameEsp = nameEsp
	entity.chams = nil

	function entity:espStep()
		-- stylua: ignore start
		if not self:GetCharacter() then if self.chams then self.chams:Destroy() self.chams = nil end nameEsp.Visible = false return end
		local pos, vis = WorldToViewportPoint(Camera, self:GetPosition())
		if not vis then if self.chams then self.chams:Destroy() self.chams = nil end nameEsp.Visible = false return end
		-- stylua: ignore end
		updateEsp(self, pos)
		updateChams(self)
	end
end
local function removeEntity(entity: table)
	entity.nameEsp:Destroy()
	if entity.chams then entity.chams:Destroy() end
end

function visualHandler:Load()
	-- stylua: ignore
	for _, entity in EntHandler:GetPlayers() do addEntity(entity) end
	table.insert(connections, EntHandler.onPlayerAdded:Connect(addEntity))
	table.insert(connections, EntHandler.onPlayerRemoved:Connect(removeEntity))
	RunService:BindToRenderStep("furryWalls", Enum.RenderPriority.Camera.Value - 1, function(deltaTime)
		-- stylua: ignore
		for _, player in EntHandler:GetPlayers() do player:espStep() end
	end)
end
function visualHandler:Unload()
	for _, connection in connections do
		connection:Disconnect()
	end
	RunService:UnbindFromRenderStep("furryWalls")
	for _, player in EntHandler:GetPlayers() do
		removeEntity(player)
	end
end

return visualHandler
