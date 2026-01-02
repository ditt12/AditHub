local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

player.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)

local gui = Instance.new("ScreenGui")
gui.Name = "AutoChatUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.fromScale(0.35,0.35)
frame.Position = UDim2.fromScale(0.325,0.3)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
frame.BorderSizePixel = 0
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,12)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.fromScale(1,0.2)
title.Text = "AUTO CHAT"
title.BackgroundTransparency = 1
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.SourceSansBold
title.TextScaled = true

local closeBtn = Instance.new("TextButton", frame)
closeBtn.Size = UDim2.fromScale(0.1,0.2)
closeBtn.Position = UDim2.fromScale(0.88,0)
closeBtn.Text = "X"
closeBtn.TextScaled = true
closeBtn.Font = Enum.Font.SourceSansBold
closeBtn.BackgroundColor3 = Color3.fromRGB(120,0,0)
closeBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0,8)

local msgBox = Instance.new("TextBox", frame)
msgBox.PlaceholderText = "Isi pesan chat"
msgBox.Size = UDim2.fromScale(0.9,0.2)
msgBox.Position = UDim2.fromScale(0.05,0.25)
msgBox.TextScaled = true
msgBox.Font = Enum.Font.SourceSans
msgBox.BackgroundColor3 = Color3.fromRGB(45,45,45)
msgBox.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", msgBox).CornerRadius = UDim.new(0,8)

local intervalBox = Instance.new("TextBox", frame)
intervalBox.PlaceholderText = "Interval (detik)"
intervalBox.Text = "60"
intervalBox.Size = UDim2.fromScale(0.9,0.15)
intervalBox.Position = UDim2.fromScale(0.05,0.48)
intervalBox.TextScaled = true
intervalBox.Font = Enum.Font.SourceSans
intervalBox.BackgroundColor3 = Color3.fromRGB(45,45,45)
intervalBox.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", intervalBox).CornerRadius = UDim.new(0,8)

local toggleBtn = Instance.new("TextButton", frame)
toggleBtn.Size = UDim2.fromScale(0.9,0.15)
toggleBtn.Position = UDim2.fromScale(0.05,0.7)
toggleBtn.Text = "START"
toggleBtn.TextScaled = true
toggleBtn.Font = Enum.Font.SourceSansBold
toggleBtn.BackgroundColor3 = Color3.fromRGB(0,170,0)
toggleBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0,8)

local openBtn = Instance.new("TextButton", gui)
openBtn.Size = UDim2.fromScale(0.12,0.08)
openBtn.Position = UDim2.fromScale(0.02,0.8)
openBtn.Text = "OPEN"
openBtn.TextScaled = true
openBtn.Font = Enum.Font.SourceSansBold
openBtn.BackgroundColor3 = Color3.fromRGB(40,40,40)
openBtn.TextColor3 = Color3.new(1,1,1)
openBtn.Visible = false
Instance.new("UICorner", openBtn).CornerRadius = UDim.new(0,10)

local dragging, dragStart, startPos

frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

frame.InputChanged:Connect(function(input)
    if dragging and (
        input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch
    ) then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

local running = false

local function sendChat(msg)
    if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
        TextChatService.TextChannels.RBXGeneral:SendAsync(msg)
    else
        ReplicatedStorage.DefaultChatSystemChatEvents
            .SayMessageRequest:FireServer(msg, "All")
    end
end

local function startLoop()
    running = true
    toggleBtn.Text = "STOP"
    toggleBtn.BackgroundColor3 = Color3.fromRGB(170,0,0)

    task.spawn(function()
        while running do
            local msg = msgBox.Text
            local interval = tonumber(intervalBox.Text)
            if msg ~= "" and interval and interval >= 10 then
                sendChat(msg)
                task.wait(interval)
            else
                task.wait(1)
            end
        end
    end)
end

local function stopLoop()
    running = false
    toggleBtn.Text = "START"
    toggleBtn.BackgroundColor3 = Color3.fromRGB(0,170,0)
end

toggleBtn.MouseButton1Click:Connect(function()
    if running then
        stopLoop()
    else
        startLoop()
    end
end)

closeBtn.MouseButton1Click:Connect(function()
    frame.Visible = false
    openBtn.Visible = true
end)

openBtn.MouseButton1Click:Connect(function()
    frame.Visible = true
    openBtn.Visible = false
end)
