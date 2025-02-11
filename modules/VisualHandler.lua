local EntHandler = require("./EntityHandler.lua")
local RunService = cloneref(game:GetService("RunService"))
local Workspace = cloneref(game:GetService("Workspace"))
local Camera = Workspace.CurrentCamera
local WorldToViewportPoint = Camera.WorldToViewportPoint
local connections = {}

local visualHandler = {
	drawName = false,
	nameType = 1, -- 1 = Account Name, 2 = Display Name
	nameUseTeamColor = false,
	nameFillColor = Color3.fromRGB(0, 0, 0),
	nameOutlineColor = Color3.fromRGB(255, 255, 255),

	drawChams = false,
	chamsUseTeamColor = false,
	chamsFillColor = Color3.fromRGB(0, 0, 0),
	chamsFillTransparency = 0,
	chamsOutlineColor = Color3.fromRGB(255, 255, 255),
	chamsOutlineTransparency = 0,
	chamsDepthMode = Enum.HighlightDepthMode.AlwaysOnTop,

	ignoreTeammates = false,
	ignoreFF = false,
	ignoreSitting = false,
	ignoreSelectedPlayers = false,
	ignorePlayerList = {},
	ignoreSelectedTeams = false,
	ignoreTeamList = {},
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
		nameEsp.Text = if visualHandler.nameType == 2 then entity:GetDisplayName() else entity:GetName()
		nameEsp.Color = if visualHandler.nameUseTeamColor then entity:GetTeamColor() else visualHandler.nameFillColor
		nameEsp.OutlineColor = visualHandler.nameOutlineColor
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
		local useTeamColor = visualHandler.chamsUseTeamColor
		local teamColor = entity:GetTeamColor()
		chams.FillColor = if useTeamColor then teamColor else visualHandler.chamsFillColor
		chams.FillTransparency = visualHandler.chamsFillTransparency
		chams.OutlineColor = if useTeamColor then teamColor else visualHandler.chamsOutlineColor
		chams.OutlineTransparency = visualHandler.chamsOutlineTransparency
		chams.DepthMode = visualHandler.chamsDepthMode
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
				if visualHandler.ignoreTeammates       and self:isTeammate()                                                  then false
			elseif visualHandler.ignoreFF              and self:isFFed()                                                      then false
			elseif visualHandler.ignoreSitting         and self:isSitting()                                                   then false
			elseif visualHandler.ignoreSelectedPlayers and table.find(visualHandler.ignorePlayerList, self:GetName())         then false
			elseif visualHandler.ignoreSelectedTeams   and table.find(visualHandler.ignoreTeamList, tostring(self:GetTeam())) then false
			else true
		)
		-- stylua: ignore end
		if visualHandler.drawName and validTarget then
			updateEsp(pos)
		else
			hideEsp()
		end
		if visualHandler.drawChams and validTarget then
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
	table.insert(connections, Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function() Camera = Workspace.CurrentCamera end))
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
