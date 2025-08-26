-- Função para adicionar uma hitbox azul grandona
local function addBigHitbox(character)
    local hrp = character:WaitForChild("HumanoidRootPart", 5)
    local humanoid = character:FindFirstChild("Humanoid")
    if not hrp or not humanoid then return end

    -- Se já tiver, não cria de novo
    if hrp:FindFirstChild("BigHitbox") then return end

    -- Cria o Part transparente azul
    local hitbox = Instance.new("Part")
    hitbox.Name = "BigHitbox"
    hitbox.Size = Vector3.new(10, 14, 10) -- bem maior que o player
    hitbox.Transparency = 0.7
    hitbox.Color = Color3.fromRGB(0, 0, 255) -- azul
    hitbox.Material = Enum.Material.ForceField -- efeito translúcido bonito
    hitbox.Anchored = false
    hitbox.CanCollide = false
    hitbox.Massless = true
    hitbox.CFrame = hrp.CFrame
    hitbox.Parent = hrp

    -- Faz o hitbox seguir o player
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = hrp
    weld.Part1 = hitbox
    weld.Parent = hrp

    -- Dano quando encostar
    hitbox.Touched:Connect(function(hit)
        local tool = hit.Parent
        if tool and tool:FindFirstChild("IsWeapon") then
            humanoid:TakeDamage(20) -- aplica dano
        end
    end)
end

-- Botão de ativar hitbox azul gigante
createButton("Destacar Players", 1.02, function()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character then
            addBigHitbox(plr.Character)
        end
        plr.CharacterAdded:Connect(function(char)
            addBigHitbox(char)
        end)
    end
end)
