loadstring(game:HttpGet("https://raw.githubusercontent.com/evilionx3/new-scripts/refs/heads/main/partclaim.lua"))()
loadstring(game:HttpGet("https://raw.githubusercontent.com/evilionx3/discord/refs/heads/main/r"))()
-- not obfuscated because i used chatgpt lmao

local input = game:GetService("UserInputService")
local players = game:GetService("Players")
local player = players.LocalPlayer
local mouse = player:GetMouse()

local createdBodyPositions = {}

-- Function to create and set up the tool
local function createTool()
    local tool = Instance.new("Tool")
    tool.RequiresHandle = false
    tool.Name = "evilions blackhole tool"
    tool.Parent = player.Backpack
    tool.ToolTip = "Unequip = stop bringing parts"

    local function moveParts(target)
        local function updatePart(part)
            if part:IsA("BasePart") and not part.Anchored and not part:IsDescendantOf(player.Character) then
                local bp = part:FindFirstChildOfClass("BodyPosition")
                if not bp then
                    bp = Instance.new("BodyPosition")
                    bp.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                    bp.Parent = part
                    table.insert(createdBodyPositions, bp)
                end
                bp.Position = target
            end
        end

        for _, part in pairs(workspace:GetDescendants()) do
            updatePart(part)
        end

        workspace.DescendantAdded:Connect(updatePart)
    end

    local function clearBodyPositions()
        for _, bp in pairs(createdBodyPositions) do
            if bp and bp.Parent then
                bp:Destroy()
            end
        end
        createdBodyPositions = {}
    end

    local isHolding = false

    local function updatePartsFollowingMouse()
        while isHolding do
            currentTarget = mouse.Hit.p
            if currentTarget then
                moveParts(currentTarget)
            end
            task.wait(0) -- Update every frame
        end
    end

    -- Tool activation logic
    tool.Activated:Connect(function()
        if not isHolding then
            isHolding = true
            if input.TouchEnabled then
                -- Mobile: Set position once on tap
                local targetPosition = mouse.Hit.p
                moveParts(targetPosition)
                isHolding = false
            else
                -- PC: Start dragging
                updatePartsFollowingMouse()
            end
        end
    end)

    -- Tool unequipped logic
    tool.Unequipped:Connect(function()
        isHolding = false
        clearBodyPositions()
    end)

    -- Listen for mouse button events (PC)
    input.InputBegan:Connect(function(inputObj)
        if inputObj.UserInputType == Enum.UserInputType.MouseButton1 and player.Character:FindFirstChildOfClass("Tool") == tool then
            if not isHolding and not input.TouchEnabled then
                isHolding = true
                updatePartsFollowingMouse()
            end
        end
    end)

    input.InputEnded:Connect(function(inputObj)
        if inputObj.UserInputType == Enum.UserInputType.MouseButton1 and player.Character:FindFirstChildOfClass("Tool") == tool then
            isHolding = false
        end
    end)

    -- Listen for touch events in the world (Mobile)
    input.TouchTapInWorld:Connect(function(touchPositions, gameProcessedEvent)
        if not gameProcessedEvent and player.Character:FindFirstChildOfClass("Tool") == tool then
            local touchPosition = touchPositions[1]
            local targetPosition = workspace.CurrentCamera:ScreenPointToRay(touchPosition.X, touchPosition.Y).Origin
            moveParts(targetPosition)
        end
    end)
end

createTool()

player.CharacterAdded:Connect(function()
    player.Character:WaitForChild("Humanoid")
    createTool()
end)
