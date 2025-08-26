-- LocalScript em StarterGui
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ==============================
-- GUI PRINCIPAL
-- ==============================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CyberSocietyUI"
screenGui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 400, 0, 380)
mainFrame.Position = UDim2.new(0.5, -200, 0.5, -190)
mainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 15)
corner.Parent = mainFrame

-- Texto inicial
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0.3, 0)
title.Position = UDim2.new(0, 0, 0, 40)
title.BackgroundTransparency = 1
title.Text = "Cyber Society"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = mainFrame

-- Animação de fade in/out
title.TextTransparency = 1
for i = 1, 10 do
	task.wait(0.1)
	title.TextTransparency = 1 - (i * 0.1)
end
wait(2)
for i = 1, 10 do
	task.wait(0.05)
	title.TextTransparency = i * 0.1
end
title.Visible = false

-- ==============================
-- FUNÇÕES AUXILIARES
-- ==============================
local function getHumanoid()
	local char = player.Character or player.CharacterAdded:Wait()
	return char:WaitForChild("Humanoid")
end

-- Criador de botões
local function createButton(text, yPosition, callback)
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(0.8, 0, 0.1, 0)
	button.Position = UDim2.new(0.1, 0, yPosition, 0)
	button.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	button.Text = text
	button.TextScaled = true
	button.TextColor3 = Color3.fromRGB(0, 255, 0)
	button.Font = Enum.Font.GothamBold
	button.Parent = mainFrame

	local bcorner = Instance.new("UICorner")
	bcorner.CornerRadius = UDim.new(0, 8)
	bcorner.Parent = button

	button.MouseButton1Click:Connect(callback)
end

-- ==============================
-- BOTÕES DE MOVIMENTO
-- ==============================
createButton("Velocidade Correr", 0.25, function()
	getHumanoid().WalkSpeed = 32
end)

createButton("Velocidade Pular", 0.36, function()
	getHumanoid().JumpPower = 100
end)

createButton("Velocidade Andar", 0.47, function()
	getHumanoid().WalkSpeed = 8
end)

createButton("Resetar", 0.58, function()
	getHumanoid().WalkSpeed = 16
	getHumanoid().JumpPower = 50
end)

-- ==============================
-- FUNÇÃO VOAR
-- ==============================
local flying = false
local flyConn
createButton("Voar", 0.69, function()
	if flying then
		flying = false
		if flyConn then flyConn:Disconnect() end
	else
		flying = true
		local char = player.Character or player.CharacterAdded:Wait()
		local hrp = char:WaitForChild("HumanoidRootPart")
		flyConn = RunService.RenderStepped:Connect(function()
			local cam = workspace.CurrentCamera
			hrp.Velocity = Vector3.new()
			if flying then
				hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + cam.CFrame.LookVector)
				if player:GetMouse().W then
					hrp.CFrame = hrp.CFrame + cam.CFrame.LookVector * 0.8
				end
			end
		end)
	end
end)

-- ==============================
-- FUNÇÃO NO CLIP
-- ==============================
local noclip = false
local noclipConn
createButton("No Clip", 0.80, function()
	if noclip then
		noclip = false
		if noclipConn then noclipConn:Disconnect() end
	else
		noclip = true
		noclipConn = RunService.Stepped:Connect(function()
			if player.Character then
				for _, part in pairs(player.Character:GetDescendants()) do
					if part:IsA("BasePart") then
						part.CanCollide = false
					end
				end
			end
		end)
	end
end)

-- ==============================
-- MIRA ASSISTIDA (Lock-on)
-- ==============================
local function getClosestEnemy()
	local char = player.Character
	if not char then return nil end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return nil end
	local closest, dist = nil, 50
	for _, npc in pairs(workspace:GetChildren()) do
		if npc:FindFirstChild("Humanoid") and npc:FindFirstChild("HumanoidRootPart") and npc:FindFirstChild("Enemy") then
			local d = (npc.HumanoidRootPart.Position - hrp.Position).Magnitude
			if d < dist then
				closest = npc
				dist = d
			end
		end
	end
	return closest
end

createButton("Mira Assistida", 0.91, function()
	local target = getClosestEnemy()
	if target then
		local cam = workspace.CurrentCamera
		local conn
		conn = RunService.RenderStepped:Connect(function()
			if target and target:FindFirstChild("HumanoidRootPart") and target:FindFirstChild("Humanoid").Health > 0 then
				cam.CFrame = CFrame.new(cam.CFrame.Position, target.HumanoidRootPart.Position)
			else
				conn:Disconnect()
			end
		end)
	end
end)

-- ==============================
-- ESP + HITBOX
-- ==============================
local function addBoxAndHitbox(character)
	local hrp = character:WaitForChild("HumanoidRootPart", 5)
	local humanoid = character:FindFirstChild("Humanoid")
	if not hrp or not humanoid then return end

	-- ESP visual
	if not hrp:FindFirstChild("DebugBox") then
		local box = Instance.new("BoxHandleAdornment")
		box.Name = "DebugBox"
		box.Adornee = hrp
		box.Parent = hrp
		box.AlwaysOnTop = true
		box.ZIndex = 5
		box.Color3 = Color3.fromRGB(0, 255, 0)
		box.Transparency = 0.5
		box.Size = Vector3.new(6, 8, 6)
	end

	-- Hitbox expandida
	if not hrp:FindFirstChild("Hitbox") then
		local hitbox = Instance.new("Part")
		hitbox.Name = "Hitbox"
		hitbox.Size = Vector3.new(6, 8, 6)
		hitbox.Transparency = 1
		hitbox.Anchored = false
		hitbox.CanCollide = false
		hitbox.Massless = true
		hitbox.CFrame = hrp.CFrame
		hitbox.Parent = hrp

		local weld = Instance.new("WeldConstraint")
		weld.Part0 = hrp
		weld.Part1 = hitbox
		weld.Parent = hrp

		hitbox.Touched:Connect(function(hit)
			local tool = hit.Parent
			if tool and tool:FindFirstChild("IsWeapon") then
				humanoid:TakeDamage(20)
			end
		end)
	end
end

createButton("Destacar Players", 1.02, function()
	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= player and plr.Character then
			addBoxAndHitbox(plr.Character)
		end
		plr.CharacterAdded:Connect(function(char)
			addBoxAndHitbox(char)
		end)
	end
end)
