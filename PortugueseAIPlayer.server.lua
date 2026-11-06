local Players = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")
local Chat = game:GetService("Chat")

local NPC_NAME = "JogadorIA"
local SPAWN_POSITION = Vector3.new(0, 5, 0)
local PATROL_RADIUS = 35
local PATROL_INTERVAL = 8
local RESPONSE_COOLDOWN = 2

local dialogue = {
	{keywords = {"oi", "ola", "olá", "bom dia", "boa tarde", "boa noite"}, response = "Olá! Eu sou o seu companheiro de equipe. Como posso ajudar?"},
	{keywords = {"ajuda", "help"}, response = "Posso patrulhar a área, acompanhar a equipe e conversar em português."},
	{keywords = {"nome"}, response = "Meu nome é JogadorIA."},
	{keywords = {"obrigado", "obrigada", "valeu"}, response = "De nada! Vamos continuar juntos."},
	{keywords = {"tchau", "adeus"}, response = "Até logo! Estarei por aqui se precisar."},
}

local function normalize(text)
	text = string.lower(text)
	text = text:gsub("[áàãâä]", "a")
	text = text:gsub("[éèêë]", "e")
	text = text:gsub("[íìîï]", "i")
	text = text:gsub("[óòõôö]", "o")
	text = text:gsub("[úùûü]", "u")
	text = text:gsub("ç", "c")
	return text
end

local function chooseResponse(message)
	local normalized = normalize(message)
	for _, entry in ipairs(dialogue) do
		for _, keyword in ipairs(entry.keywords) do
			if string.find(normalized, normalize(keyword), 1, true) then
				return entry.response
			end
		end
	end
	return "Entendi. Vou ficar atento à área e acompanhar você."
end

local function createPart(parent, name, size, color, cframe, shape)
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.Color = color
	part.CFrame = cframe
	part.Shape = shape or Enum.PartType.Block
	part.CanCollide = true
	part.Parent = parent
	return part
end

local function createNPC()
	local existing = workspace:FindFirstChild(NPC_NAME)
	if existing then
		existing:Destroy()
	end

	local model = Instance.new("Model")
	model.Name = NPC_NAME
	model.Parent = workspace

	local root = createPart(model, "HumanoidRootPart", Vector3.new(2, 2, 1), Color3.fromRGB(55, 55, 65), CFrame.new(SPAWN_POSITION))
	root.Transparency = 1
	root.CanCollide = false

	local torso = createPart(model, "Torso", Vector3.new(2, 2, 1), Color3.fromRGB(37, 99, 235), CFrame.new(SPAWN_POSITION + Vector3.new(0, 1.5, 0)))
	local head = createPart(model, "Head", Vector3.new(2, 1, 1), Color3.fromRGB(255, 204, 153), CFrame.new(SPAWN_POSITION + Vector3.new(0, 3, 0)))
	local leftArm = createPart(model, "Left Arm", Vector3.new(1, 2, 1), Color3.fromRGB(37, 99, 235), CFrame.new(SPAWN_POSITION + Vector3.new(-1.5, 1.5, 0)))
	local rightArm = createPart(model, "Right Arm", Vector3.new(1, 2, 1), Color3.fromRGB(37, 99, 235), CFrame.new(SPAWN_POSITION + Vector3.new(1.5, 1.5, 0)))
	local leftLeg = createPart(model, "Left Leg", Vector3.new(1, 2, 1), Color3.fromRGB(31, 41, 55), CFrame.new(SPAWN_POSITION + Vector3.new(-0.5, -0.5, 0)))
	local rightLeg = createPart(model, "Right Leg", Vector3.new(1, 2, 1), Color3.fromRGB(31, 41, 55), CFrame.new(SPAWN_POSITION + Vector3.new(0.5, -0.5, 0)))

	local humanoid = Instance.new("Humanoid")
	humanoid.DisplayName = "Jogador IA"
	humanoid.WalkSpeed = 10
	humanoid.MaxHealth = 100
	humanoid.Health = 100
	humanoid.Parent = model

	local welds = {
		{root, torso}, {torso, head}, {torso, leftArm}, {torso, rightArm}, {torso, leftLeg}, {torso, rightLeg},
	}
	for _, pair in ipairs(welds) do
		local weld = Instance.new("WeldConstraint")
		weld.Part0 = pair[1]
		weld.Part1 = pair[2]
		weld.Parent = pair[1]
	end
	model.PrimaryPart = root

	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Conversar"
	prompt.ObjectText = "JogadorIA"
	prompt.KeyboardKeyCode = Enum.KeyCode.E
	prompt.MaxActivationDistance = 12
	prompt.RequiresLineOfSight = false
	prompt.Parent = head

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "NameTag"
	billboard.Size = UDim2.fromOffset(180, 40)
	billboard.StudsOffset = Vector3.new(0, 2, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = head
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Text = "JogadorIA | PT-BR"
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextStrokeTransparency = 0.25
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.Parent = billboard

	return model, humanoid, prompt
end

local npc, humanoid, prompt = createNPC()
local lastResponse = {}

local function sayToPlayer(player, message)
	local now = os.clock()
	if lastResponse[player] and now - lastResponse[player] < RESPONSE_COOLDOWN then
		return
	end
	lastResponse[player] = now
	Chat:Chat(npc.Head, message, Enum.ChatColor.Blue)
end

prompt.Triggered:Connect(function(player)
	sayToPlayer(player, "Olá, " .. player.DisplayName .. "! Precisa de alguma coisa?")
end)

Players.PlayerAdded:Connect(function(player)
	player.Chatted:Connect(function(message)
		if not npc.Parent or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
			return
		end
		local distance = (player.Character.HumanoidRootPart.Position - npc.PrimaryPart.Position).Magnitude
		if distance <= 20 then
			sayToPlayer(player, chooseResponse(message))
		end
	end)
end)

local function getPatrolPoint()
	local offset = Vector3.new(math.random(-PATROL_RADIUS, PATROL_RADIUS), 0, math.random(-PATROL_RADIUS, PATROL_RADIUS))
	local origin = npc.PrimaryPart.Position + offset + Vector3.new(0, 20, 0)
	local rayResult = workspace:Raycast(origin, Vector3.new(0, -50, 0))
	return rayResult and rayResult.Position + Vector3.new(0, 3, 0) or npc.PrimaryPart.Position
end

local function walkTo(destination)
	local path = PathfindingService:CreatePath({AgentRadius = 2, AgentHeight = 5, AgentCanJump = true})
	local success = pcall(function()
		path:ComputeAsync(npc.PrimaryPart.Position, destination)
	end)
	if not success or path.Status ~= Enum.PathStatus.Success then
		humanoid:MoveTo(destination)
		humanoid.MoveToFinished:Wait(4)
		return
	end
	for _, waypoint in ipairs(path:GetWaypoints()) do
		if waypoint.Action == Enum.PathWaypointAction.Jump then
			humanoid.Jump = true
		end
		humanoid:MoveTo(waypoint.Position)
		local reached = humanoid.MoveToFinished:Wait()
		if not reached then
			break
		end
	end
end

task.spawn(function()
	while npc.Parent and humanoid.Health > 0 do
		walkTo(getPatrolPoint())
		task.wait(PATROL_INTERVAL)
	end
end)

Players.PlayerRemoving:Connect(function(player)
	lastResponse[player] = nil
end)
