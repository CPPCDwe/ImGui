-- Tsunami UI Library v1.0
-- A custom UI library for Roblox with draggable/resizable UI, night gradient theme, animations, keybind, custom cursor, and notifications.

local TsunamiUI = {}
TsunamiUI.__index = TsunamiUI

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- Helper function for creating UIGradient
local function createGradient(colors, rotation)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new(colors)
    gradient.Rotation = rotation or 0
    return gradient
end

-- Main UI creation
function TsunamiUI.new(title)
    local self = setmetatable({}, TsunamiUI)
    
    -- ScreenGui
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Parent = player:WaitForChild("PlayerGui")
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.IgnoreGuiInset = true
    
    -- Main Frame (draggable and resizable)
    self.MainFrame = Instance.new("Frame")
    self.MainFrame.Size = UDim2.new(0, 300, 0, 200)
    self.MainFrame.Position = UDim2.new(0.5, -150, 0.5, -100)
    self.MainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0) -- Base black
    self.MainFrame.BorderSizePixel = 0
    self.MainFrame.Parent = self.ScreenGui
    self.MainFrame.Visible = false
    
    -- Night gradient (black-white animated)
    local baseGradient = createGradient({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
    }, 45)
    baseGradient.Parent = self.MainFrame
    
    -- Animate gradient overflow (perlin-like effect)
    self.GradientAnimation = coroutine.wrap(function()
        while true do
            for i = 0, 1, 0.01 do
                baseGradient.Offset = Vector2.new(i, 0)
                RunService.Heartbeat:Wait()
            end
        end
    end)()
    
    -- Title Label
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 30)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title or "Tsunami UI"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 18
    titleLabel.Parent = self.MainFrame
    
    -- Make draggable
    local dragging, dragInput, dragStart, startPos
    titleLabel.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = self.MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    titleLabel.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            self.MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    -- Make resizable (bottom-right corner)
    local resizeHandle = Instance.new("Frame")
    resizeHandle.Size = UDim2.new(0, 10, 0, 10)
    resizeHandle.Position = UDim2.new(1, -10, 1, -10)
    resizeHandle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    resizeHandle.Parent = self.MainFrame
    
    local resizing, resizeStart, frameStartSize
    resizeHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = true
            resizeStart = input.Position
            frameStartSize = self.MainFrame.Size
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - resizeStart
            self.MainFrame.Size = UDim2.new(frameStartSize.X.Scale, frameStartSize.X.Offset + delta.X, frameStartSize.Y.Scale, frameStartSize.Y.Offset + delta.Y)
        end
    end)
    
    -- Notification Frame
    self.NotifyFrame = Instance.new("Frame")
    self.NotifyFrame.Size = UDim2.new(0, 200, 0, 50)
    self.NotifyFrame.Position = UDim2.new(1, -210, 0, 10)
    self.NotifyFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    self.NotifyFrame.BorderSizePixel = 0
    self.NotifyFrame.Parent = self.ScreenGui
    self.NotifyFrame.Visible = false
    
    -- Colorful gradient for notification (rainbow-like overflow)
    local notifyGradient = createGradient({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
        ColorSequenceKeypoint.new(0.2, Color3.fromRGB(255, 165, 0)),
        ColorSequenceKeypoint.new(0.4, Color3.fromRGB(255, 255, 0)),
        ColorSequenceKeypoint.new(0.6, Color3.fromRGB(0, 255, 0)),
        ColorSequenceKeypoint.new(0.8, Color3.fromRGB(0, 0, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(238, 130, 238))
    }, 0)
    notifyGradient.Parent = self.NotifyFrame
    
    -- Animate notification gradient
    coroutine.wrap(function()
        while true do
            for i = 0, 360, 1 do
                notifyGradient.Rotation = i
                RunService.Heartbeat:Wait()
            end
        end
    end)()
    
    local notifyText = Instance.new("TextLabel")
    notifyText.Size = UDim2.new(1, 0, 1, 0)
    notifyText.BackgroundTransparency = 1
    notifyText.Text = "Tsunami UI Opened!"
    notifyText.TextColor3 = Color3.fromRGB(255, 255, 255)
    notifyText.Font = Enum.Font.Gotham
    notifyText.TextSize = 14
    notifyText.Parent = self.NotifyFrame
    
    -- Open/Close state
    self.IsOpen = false
    
    -- Custom cursor when open
    self.DefaultCursor = mouse.Icon
    self.CustomCursor = "rbxasset://textures\\GunCursor.png" -- Replace with your custom cursor asset ID
    
    -- Keybind for open/close (K)
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.K then
            self:Toggle()
        end
    end)
    
    return self
end

-- Toggle function with animation
function TsunamiUI:Toggle()
    self.IsOpen = not self.IsOpen
    local goal = self.IsOpen and {Size = UDim2.new(0, 300, 0, 200)} or {Size = UDim2.new(0, 300, 0, 0)}
    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(self.MainFrame, tweenInfo, goal)
    tween:Play()
    
    self.MainFrame.Visible = true -- Ensure visible during animation
    
    if self.IsOpen then
        mouse.Icon = self.CustomCursor
        self.NotifyFrame.Visible = true
        wait(2) -- Show notification for 2 seconds
        self.NotifyFrame.Visible = false
    else
        mouse.Icon = self.DefaultCursor
        wait(0.5) -- Wait for close animation
        self.MainFrame.Visible = false
    end
end

-- Example usage: local ui = TsunamiUI.new("My Menu")
-- To add more elements, extend the library with methods like AddButton, AddSlider, etc.

return TsunamiUI
