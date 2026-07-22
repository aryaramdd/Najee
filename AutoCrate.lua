-- Auto Crate Opener v1
-- Support: Ladder Crate, Roleplay Crate

local Remote = game:GetService("ReplicatedStorage"):WaitForChild("SharedModules"):WaitForChild("Packet"):WaitForChild("RemoteEvent")

local function fire(name, op)
    local buf = buffer.fromstring("\133\000" .. op .. string.char(#name) .. name)
    Remote:FireServer(buf)
end

local function openCrate(name)
    if name == "Ladder Crate" then
        fire(name, '"')  -- 0x22
        fire(name, "$")  -- 0x24
    elseif name == "Roleplay Crate" then
        fire(name, ".")  -- 0x2E
        fire(name, "4")  -- 0x34
    else
        return false
    end
    return true
end

-- UI
local player = game:GetService("Players").LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "AutoCrateGUI"
gui.ResetOnSpawn = false

local f = Instance.new("Frame")
f.Size = UDim2.new(0, 280, 0, 240)
f.Position = UDim2.new(0.5, -140, 0.5, -120)
f.BackgroundColor3 = Color3.fromRGB(15, 23, 42)
f.BorderSizePixel = 0
f.Active = true
f.Draggable = true
f.Parent = gui
Instance.new("UICorner", f).CornerRadius = UDim.new(0, 8)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 34)
title.BackgroundColor3 = Color3.fromRGB(30, 41, 59)
title.TextColor3 = Color3.fromRGB(245, 158, 11)
title.Text = "Auto Crate Opener"
title.Font = Enum.Font.GothamBold
title.TextSize = 14
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 8)
title.Parent = f

local stat = Instance.new("TextLabel")
stat.Size = UDim2.new(1, -20, 0, 18)
stat.Position = UDim2.new(0, 10, 0, 38)
stat.BackgroundTransparency = 1
stat.TextColor3 = Color3.fromRGB(148, 163, 184)
stat.Text = "Idle"
stat.Font = Enum.Font.Gotham
stat.TextSize = 12
stat.TextXAlignment = Enum.TextXAlignment.Left
stat.Parent = f

-- Crate rows
local crates = {"Ladder Crate", "Roleplay Crate"}
local toggles = {}
local y = 60

for _, name in ipairs(crates) do
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -20, 0, 24)
    row.Position = UDim2.new(0, 10, 0, y)
    row.BackgroundTransparency = 1
    row.Parent = f

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0, 150, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = Color3.fromRGB(226, 232, 240)
    lbl.Text = name
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 50, 0, 22)
    btn.Position = UDim2.new(1, -50, 0.5, -11)
    btn.BackgroundColor3 = Color3.fromRGB(34, 197, 94)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = "ON"
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    toggles[name] = {btn = btn, on = true}
    btn.MouseButton1Click:Connect(function()
        toggles[name].on = not toggles[name].on
        btn.BackgroundColor3 = toggles[name].on and Color3.fromRGB(34, 197, 94) or Color3.fromRGB(100, 116, 139)
        btn.Text = toggles[name].on and "ON" or "OFF"
    end)
    btn.Parent = row
    y = y + 28
end

-- Delay row
y = y + 2
local dRow = Instance.new("Frame")
dRow.Size = UDim2.new(1, -20, 0, 24)
dRow.Position = UDim2.new(0, 10, 0, y)
dRow.BackgroundTransparency = 1
dRow.Parent = f

local dLbl = Instance.new("TextLabel")
dLbl.Size = UDim2.new(0, 100, 1, 0)
dLbl.BackgroundTransparency = 1
dLbl.TextColor3 = Color3.fromRGB(148, 163, 184)
dLbl.Text = "Speed:"
dLbl.Font = Enum.Font.Gotham
dLbl.TextSize = 12
dLbl.TextXAlignment = Enum.TextXAlignment.Left
dLbl.Parent = dRow

local dBox = Instance.new("TextBox")
dBox.Size = UDim2.new(0, 60, 0, 22)
dBox.Position = UDim2.new(0, 100, 0.5, -11)
dBox.BackgroundColor3 = Color3.fromRGB(15, 23, 42)
dBox.TextColor3 = Color3.fromRGB(226, 232, 240)
dBox.PlaceholderColor3 = Color3.fromRGB(100, 116, 139)
dBox.Text = "0.05"
dBox.Font = Enum.Font.Gotham
dBox.TextSize = 12
dBox.ClearTextOnFocus = false
Instance.new("UICorner", dBox).CornerRadius = UDim.new(0, 4)
dBox.Parent = dRow

local dLbl2 = Instance.new("TextLabel")
dLbl2.Size = UDim2.new(0, 80, 1, 0)
dLbl2.Position = UDim2.new(0, 166, 0, 0)
dLbl2.BackgroundTransparency = 1
dLbl2.TextColor3 = Color3.fromRGB(148, 163, 184)
dLbl2.Text = "delay per cycle"
dLbl2.Font = Enum.Font.Gotham
dLbl2.TextSize = 10
dLbl2.TextXAlignment = Enum.TextXAlignment.Left
dLbl2.Parent = dRow

-- Buttons
y = y + 32
local startBtn = Instance.new("TextButton")
startBtn.Size = UDim2.new(0.5, -16, 0, 30)
startBtn.Position = UDim2.new(0, 10, 0, y)
startBtn.BackgroundColor3 = Color3.fromRGB(34, 197, 94)
startBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
startBtn.Text = "Start"
startBtn.Font = Enum.Font.GothamBold
startBtn.TextSize = 13
Instance.new("UICorner", startBtn).CornerRadius = UDim.new(0, 6)
startBtn.Parent = f

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0.5, -16, 0, 30)
closeBtn.Position = UDim2.new(0.5, 6, 0, y)
closeBtn.BackgroundColor3 = Color3.fromRGB(239, 68, 68)
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Text = "Close"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 13
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)
closeBtn.Parent = f

-- Logic
local running = false
local thread

startBtn.MouseButton1Click:Connect(function()
    running = not running
    if running then
        startBtn.Text = "Stop"
        startBtn.BackgroundColor3 = Color3.fromRGB(239, 68, 68)
        stat.Text = "Running..."
        stat.TextColor3 = Color3.fromRGB(34, 197, 94)
        thread = task.spawn(runLoop)
    else
        startBtn.Text = "Start"
        startBtn.BackgroundColor3 = Color3.fromRGB(34, 197, 94)
        stat.Text = "Stopped"
        stat.TextColor3 = Color3.fromRGB(239, 68, 68)
    end
end)

closeBtn.MouseButton1Click:Connect(function()
    running = false
    if thread then task.cancel(thread) end
    gui:Destroy()
end)

function runLoop()
    while running do
        local count = 0
        for _, name in ipairs(crates) do
            if not running then break end
            if toggles[name] and toggles[name].on then
                pcall(openCrate, name)
                count = count + 1
            end
        end
        if count > 0 then
            stat.Text = "Opened " .. tostring(count) .. " crate(s)"
        end
        local delay = tonumber(dBox.Text) or 0.05
        if delay < 0 then delay = 0 end
        task.wait(delay)
    end
end

gui.Parent = player:WaitForChild("PlayerGui")
