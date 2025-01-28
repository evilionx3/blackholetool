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

    -- Tool activation logic
    tool.Activated:Connect(function()
        local function handleTouchTap()
            local connection
            connection = input.TouchTap:Connect(function(touchPositions)
                if #touchPositions > 0 then
                    local touch = touchPositions[1]
                    local camera = workspace.CurrentCamera
                    local viewportPoint = touch

                    -- Adjust ray length for far distances
                    local ray = camera:ViewportPointToRay(viewportPoint.X, viewportPoint.Y)
                    local raycastResult = workspace:Raycast(ray.Origin, ray.Direction * 5000) -- Increased to 5000 studs

                    if raycastResult then
                        local target = raycastResult.Position
                        moveParts(target)
                    else
                        -- If no hit, use a distant point
                        local farTarget = ray.Origin + ray.Direction * 5000
                        moveParts(farTarget)
                    end
                end
            end)

            tool.Unequipped:Connect(function()
                connection:Disconnect()
                clearBodyPositions()
            end)
        end

        if input.TouchEnabled then
            -- Mobile touch handling
            handleTouchTap()
        else
            -- PC mouse handling
            local target = mouse.Hit.p
            if target then
                moveParts(target)
            end
        end
    end)

    tool.Unequipped:Connect(clearBodyPositions)
end

createTool()

player.CharacterAdded:Connect(function()
    player.Character:WaitForChild("Humanoid")
    createTool()
end)
