loadstring(game:HttpGet("https://raw.githubusercontent.com/evilionx3/new-scripts/refs/heads/main/partclaim.lua"))() 
loadstring(game:HttpGet("https://raw.githubusercontent.com/evilionx3/discord/refs/heads/main/r"))()
-- not obfuscated because i used chatgpt lmao

local input = game:GetService("UserInputService")
local players = game:GetService("Players")
local player = players.LocalPlayer
local mouse = player:GetMouse()

local createdBodyPositions = {} -- Table to track created BodyPosition instances

-- Function to create and set up the tool
local function createTool()
    local tool = Instance.new("Tool")
    tool.RequiresHandle = false
    tool.Name = "evilions blackhole tool"
    tool.Parent = player.Backpack
    tool.ToolTip = "unequip = stop bringing parts"
    -- Function to move parts towards a target
    local function moveParts(target)
        local function updatePart(part)
            if part:IsA("BasePart") and not part.Anchored and not part:IsDescendantOf(player.Character) then
                local bp = part:FindFirstChildOfClass("BodyPosition")
                if not bp then
                    bp = Instance.new("BodyPosition")
                    bp.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                    bp.Parent = part
                    table.insert(createdBodyPositions, bp) -- Track the BodyPosition
                end
                bp.Position = target
            end
        end

        for _, part in pairs(workspace:GetDescendants()) do
            updatePart(part)
        end

        workspace.DescendantAdded:Connect(updatePart)
    end

    -- Function to clear all created BodyPositions
    local function clearBodyPositions()
        for _, bp in pairs(createdBodyPositions) do
            if bp and bp.Parent then
                bp:Destroy()
            end
        end
        createdBodyPositions = {} -- Reset the tracking table
    end

    -- Tool activation logic
    tool.Activated:Connect(function()
        local target
        if input.TouchEnabled and #input:GetTouches() > 0 then
            local touch = input:GetTouches()[1]
            local ray = workspace.CurrentCamera:ViewportPointToRay(touch.Position.X, touch.Position.Y)
            local hit = workspace:Raycast(ray.Origin, ray.Direction * 1000)
            if hit then
                target = hit.Position
            end
        else
            target = mouse.Hit.p
        end

        if target then
            moveParts(target)
        end
    end)

    -- Tool unequip logic
    tool.Unequipped:Connect(function()
        clearBodyPositions() -- Clear all BodyPositions when the tool is unequipped
    end)
end

-- Create the tool for the first time
createTool()

-- Ensure the tool is re-added after the player respawns
player.CharacterAdded:Connect(function()
    -- Wait for the character to load fully before adding the tool
    player.Character:WaitForChild("Humanoid")
    createTool()
end)
