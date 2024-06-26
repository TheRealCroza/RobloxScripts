--[[

░█████╗░██████╗░░█████╗░███████╗░█████╗░
██╔══██╗██╔══██╗██╔══██╗╚════██║██╔══██╗
██║░░╚═╝██████╔╝██║░░██║░░███╔═╝███████║
██║░░██╗██╔══██╗██║░░██║██╔══╝░░██╔══██║
╚█████╔╝██║░░██║╚█████╔╝███████╗██║░░██║
░╚════╝░╚═╝░░╚═╝░╚════╝░╚══════╝╚═╝░░╚═╝
Silent Aim Created By TheRealC_Roza

]]--

local SilentSettings = {
    IsTargetting = true,
    Prediction = 0.157, 
    TargetPart = "HumanoidRootPart",
    WallCheck = true,
    FOV = {
        Radius = 50,
        Visible = true
    }
}

local Inset = game:GetService("GuiService"):GetGuiInset().Y
local Mouse = game.Players.LocalPlayer:GetMouse()
local Client = game.Players.LocalPlayer
local Cam = workspace.CurrentCamera

local FOV = Drawing.new("Circle")
FOV.Transparency = 0.5
FOV.Thickness = 1.6
FOV.Color = Color3.fromRGB(230, 230, 250)
FOV.Filled = false

-- Function to update FOV
local function UpdateFOV(Radius)
    if not FOV then return end
    FOV.Position = Vector2.new(Mouse.X, Mouse.Y + Inset)
    FOV.Visible = SilentSettings.FOV.Visible
    FOV.Radius = Radius * 3.067
end

-- Coroutine to continuously update FOV
task.spawn(function()
    while true do
        task.wait()
        UpdateFOV(SilentSettings.FOV.Radius)
    end
end)

-- Function to check for obstacles
local function WallCheck(destination, ignoreList)
    if SilentSettings.WallCheck then
        local Origin = Cam.CFrame.p
        local CheckRay = Ray.new(Origin, destination - Origin)
        local Hit = game.Workspace:FindPartOnRayWithIgnoreList(CheckRay, ignoreList)
        return Hit == nil
    else
        return true
    end
end

-- Function to find the closest character
local function GetClosestChar()
    local ClosestDistance = math.huge
    local ClosestCharacter = nil
    
    for _, player in ipairs(game.Players:GetPlayers()) do
        if player ~= Client and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local Character = player.Character
            local RootPart = Character.HumanoidRootPart
            local Position, OnScreen = Cam:WorldToScreenPoint(RootPart.Position)
            local Distance = (Vector2.new(Position.X, Position.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
            
            if FOV.Radius > Distance and Distance < ClosestDistance and OnScreen and
                WallCheck(RootPart.Position, {Client, Character}) then
                ClosestDistance = Distance
                ClosestCharacter = player
            end
        end
    end
    
    return ClosestCharacter
end

-- Hook method to override mouse hit
local OldIndex = hookmetamethod(game, "__index", function(self, key)
    if self:IsA("Mouse") and key == "Hit" then
        local Target = GetClosestChar()
        if Target then
            local TargetPart = Target.Character[SilentSettings.TargetPart]
            if TargetPart then
                return TargetPart.CFrame + (TargetPart.Velocity * SilentSettings.Prediction)
            end
        end
    end
    return OldIndex(self, key)
end)
