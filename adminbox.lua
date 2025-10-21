-- Pandel v4 (Player Tools) - Complete Script
-- Made by Nasty Gbt 😎
-- Paste to GitHub and load via raw link with your executor

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local VirtualUser = game:GetService("VirtualUser")

local player = Players.LocalPlayer

-- keep references so respawn will rebind
local state = {
    screenGui = nil,
    frame = nil,
    openBtn = nil,
    hud = {},
    places = {},
    esp = {},
    espEnabled = false,
    fpsEnabled = false,
    fpsLabel = nil,
    antiAfkEnabled = false,
    afkConn = nil,
    instantEnabled = false,
    instantConn = nil,
    noclip = false,
    noclipConn = nil,
    infJump = false,
    flyEnabled = false,
    flySpeed = 50,
    flyObjects = {},
    connections = {}
}

-- helper: safe WaitForChild for character
local function getHumanoidAndRoot()
    local char = player.Character
    if not char then return nil, nil end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart
    return humanoid, root
end

-- utility: create UI element helper
local function new(inst, parent, props)
    local o = Instance.new(inst)
    if parent then o.Parent = parent end
    if props then
        for k,v in pairs(props) do
            if k == "Parent" then o.Parent = v
            else pcall(function() o[k] = v end) end
        end
    end
    return o
end

-- remove any existing GUI created by older runs
pcall(function()
    local old = game.CoreGui:FindFirstChild("PandelGUI_v4")
    if old then old:Destroy() end
end)

-- create UI
local function buildGui()
    -- ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "PandelGUI_v4"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = game.CoreGui
    state.screenGui = screenGui

    -- Blue round open button (bottom-left)
    local openBtn = new("TextButton", screenGui, {
        Name = "OpenBtn",
        Size = UDim2.new(0,60,0,60),
        Position = UDim2.new(0,20,0.5,-30),
        BackgroundColor3 = Color3.fromRGB(0,150,255),
        Text = "Menu",
        TextColor3 = Color3.new(1,1,1),
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        AutoButtonColor = true
    })
    new("UICorner", openBtn).CornerRadius = UDim.new(1,0)
    state.openBtn = openBtn

    -- Main frame (center)
    local frame = new("Frame", screenGui, {
        Name = "PandelFrame",
        Size = UDim2.new(0, 340, 0, 420),
        Position = UDim2.new(0.5, -170, 0.5, -210),
        BackgroundTransparency = 0,
        BackgroundColor3 = Color3.fromRGB(20,40,70),
        Visible = false,
        Active = true,
        ZIndex = 2
    })
    -- friendly transparent blue (slight transparency)
    frame.BackgroundTransparency = 0.15
    new("UICorner", frame).CornerRadius = UDim.new(0,12)
    state.frame = frame

    -- subtle shadow (Frame overlay)
    local shadow = new("Frame", frame, {
        Size = UDim2.new(1,0,1,0),
        Position = UDim2.new(0,0,0,0),
        BackgroundTransparency = 0.8,
    })
    shadow.ZIndex = 0

    -- Title bar
    local titleBar = new("Frame", frame, {
        Size = UDim2.new(1,0,0,34),
        BackgroundColor3 = Color3.fromRGB(34,54,90)
    })
    new("UICorner", titleBar).CornerRadius = UDim.new(0,12)
    titleBar.ZIndex = 3

    local title = new("TextLabel", titleBar, {
        Text = "Pandel",
        TextColor3 = Color3.new(1,1,1),
        BackgroundTransparency = 1,
        Size = UDim2.new(1,-80,1,0),
        Position = UDim2.new(0,10,0,0),
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local minBtn = new("TextButton", titleBar, {
        Text = "-",
        Size = UDim2.new(0,28,0,24),
        Position = UDim2.new(1,-68,0,5),
        BackgroundColor3 = Color3.fromRGB(100,100,0),
        TextColor3 = Color3.new(1,1,1)
    })
    new("UICorner", minBtn).CornerRadius = UDim.new(0,6)
    local closeBtn = new("TextButton", titleBar, {
        Text = "X",
        Size = UDim2.new(0,28,0,24),
        Position = UDim2.new(1,-34,0,5),
        BackgroundColor3 = Color3.fromRGB(150,0,0),
        TextColor3 = Color3.new(1,1,1)
    })
    new("UICorner", closeBtn).CornerRadius = UDim.new(0,6)

    -- content holder (scrollable)
    local content = new("ScrollingFrame", frame, {
        Size = UDim2.new(1,-20,1,-70),
        Position = UDim2.new(0,10,0,40),
        CanvasSize = UDim2.new(0,0,2,0),
        BackgroundTransparency = 1,
        VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar
    })
    content.ScrollBarThickness = 6
    content.ZIndex = 3

    -- layout for vertical stacking
    local layout = new("UIListLayout", content, {
        Padding = UDim.new(0,8),
        SortOrder = Enum.SortOrder.LayoutOrder
    })
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    -- small helper for creating buttons stacked
    local function addSmallButton(text, width)
        width = width or 300
        local btn = new("TextButton", content, {
            Size = UDim2.new(0, width, 0, 30),
            BackgroundColor3 = Color3.fromRGB(60,70,90),
            Text = text,
            TextColor3 = Color3.new(1,1,1),
            Font = Enum.Font.Gotham,
            TextSize = 14
        })
        new("UICorner", btn).CornerRadius = UDim.new(0,6)
        return btn
    end

    -- walker speeds label and buttons as a single line
    local walkLabel = new("TextLabel", content, {
        Size = UDim2.new(0,300,0,20),
        Text = "WalkSpeed",
        BackgroundTransparency = 1,
        TextColor3 = Color3.new(1,1,1),
        Font = Enum.Font.GothamBold,
        TextSize = 14
    })

    local walkRow = new("Frame", content, {Size = UDim2.new(0,300,0,34), BackgroundTransparency = 1})
    local function addSmallOptionButton(parent, text, x)
        local b = new("TextButton", parent, {
            Size = UDim2.new(0,80,0,28),
            Position = UDim2.new(0,x,0,3),
            BackgroundColor3 = Color3.fromRGB(80,90,110),
            Text = text,
            TextColor3 = Color3.new(1,1,1),
            Font = Enum.Font.Gotham,
            TextSize = 14
        })
        new("UICorner", b).CornerRadius = UDim.new(0,6)
        return b
    end
    local ws25 = addSmallOptionButton(walkRow,"25",0)
    local ws50 = addSmallOptionButton(walkRow,"50",100)
    local ws100 = addSmallOptionButton(walkRow,"100",200)

    -- Noclip
    local noclipBtn = addSmallButton("Noclip: OFF")
    -- Infinite Jump
    local infJumpBtn = addSmallButton("Infinite Jump: OFF")

    -- Instant Anything
    local instantBtn = addSmallButton("Instant Anything: OFF")

    -- Fly toggle + speed row
    local flyBtn = addSmallButton("Fly: OFF")
    local flyLabel = new("TextLabel", content, {
        Size = UDim2.new(0,300,0,18),
        Text = "Fly Speed",
        BackgroundTransparency = 1,
        TextColor3 = Color3.new(1,1,1),
        Font = Enum.Font.GothamBold,
        TextSize = 13
    })
    local flyRow = new("Frame", content, {Size = UDim2.new(0,300,0,34), BackgroundTransparency = 1})
    local fly25 = addSmallOptionButton(flyRow, "25", 0)
    local fly50 = addSmallOptionButton(flyRow, "50", 100)
    local fly100 = addSmallOptionButton(flyRow, "100", 200)

    -- Teleport main label and teleport buttons (compact vertical)
    local telLabel = new("TextLabel", content, {
        Size = UDim2.new(0,300,0,20), Text = "Teleport+", BackgroundTransparency = 1,
        TextColor3 = Color3.new(1,1,1), Font = Enum.Font.GothamBold, TextSize = 14
    })
    local save1 = addSmallButton("Save Place 1", 300)
    local place1 = addSmallButton("Place 1", 300)
    local save2 = addSmallButton("Save Place 2", 300)
    local place2 = addSmallButton("Place 2", 300)
    local save3 = addSmallButton("Save Place 3", 300)
    local place3 = addSmallButton("Place 3", 300)

    -- Visual Tools
    local visLabel = new("TextLabel", content, {Size = UDim2.new(0,300,0,20), Text = "Visual Tools", BackgroundTransparency = 1, TextColor3 = Color3.new(1,1,1), Font = Enum.Font.GothamBold, TextSize = 14})
    local espBtn = addSmallButton("ESP: OFF")
    local fpsBtn = addSmallButton("FPS: OFF")

    -- Server tools (Anti-AFK, Rejoin, ServerHop)
    local servLabel = new("TextLabel", content, {Size = UDim2.new(0,300,0,20), Text = "Server Tools", BackgroundTransparency = 1, TextColor3 = Color3.new(1,1,1), Font = Enum.Font.GothamBold, TextSize = 14})
    local antiAfkBtn = addSmallButton("Anti-AFK: OFF")
    local rjBtn = addSmallButton("Rejoin", 300)
    local hopBtn = addSmallButton("ServerHop", 300)

    -- Footer
    local footer = new("TextLabel", frame, {
        Text = "Made by Nasty Gbt 😎",
        Size = UDim2.new(1,0,0,24),
        Position = UDim2.new(0,0,1,-24),
        BackgroundTransparency = 1,
        TextColor3 = Color3.fromRGB(180,220,255),
        Font = Enum.Font.GothamBold,
        TextSize = 14
    })

    -- FPS label (bottom-right corner)
    local fpsLabel = new("TextLabel", screenGui, {
        Text = "",
        Size = UDim2.new(0,120,0,20),
        Position = UDim2.new(1,-130,1,-40),
        BackgroundTransparency = 0.6,
        BackgroundColor3 = Color3.fromRGB(10,10,10),
        TextColor3 = Color3.fromRGB(200,200,200),
        Font = Enum.Font.Gotham,
        TextSize = 14,
        Visible = false
    })
    new("UICorner", fpsLabel).CornerRadius = UDim.new(0,6)
    state.fpsLabel = fpsLabel

    -- store UI references to state
    state.hud = {
        ws25 = ws25, ws50 = ws50, ws100 = ws100,
        noclipBtn = noclipBtn, infJumpBtn = infJumpBtn,
        instantBtn = instantBtn, flyBtn = flyBtn, fly25 = fly25, fly50 = fly50, fly100 = fly100,
        save1 = save1, place1 = place1, save2 = save2, place2 = place2, save3 = save3, place3 = place3,
        espBtn = espBtn, fpsBtn = fpsBtn,
        antiAfkBtn = antiAfkBtn, rjBtn = rjBtn, hopBtn = hopBtn,
        minBtn = minBtn, closeBtn = closeBtn, openBtn = openBtn, frame = frame
    }

    -- small open/close animation
    openBtn.MouseButton1Click:Connect(function()
        if frame.Visible == false then
            frame.Visible = true
            frame.Position = UDim2.new(0.5, -170, 0.5, -210)
            frame.Size = UDim2.new(0, 300, 0, 360)
            frame.Visible = true
            frame.Scale = 0 -- not real property; we'll do simple tween-like appearance
            -- quick simple fade via transparency tween on children
            for _,child in pairs(frame:GetDescendants()) do
                if child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("Frame") then
                    pcall(function() child.TextTransparency = 1 end)
                    pcall(function() child.BackgroundTransparency = (child.BackgroundTransparency or 0) + 1 end)
                end
            end
            -- small delay then reveal (no heavy tween libs used)
            task.delay(0.06, function()
                for _,child in pairs(frame:GetDescendants()) do
                    pcall(function() child.TextTransparency = 0 end)
                    pcall(function() child.BackgroundTransparency = (child.BackgroundTransparency or 0) end)
                end
            end)
        else
            frame.Visible = false
        end
    end)

    -- Minimize + Close
    minBtn.MouseButton1Click:Connect(function() frame.Visible = false end)
    closeBtn.MouseButton1Click:Connect(function()
        if screenGui then screenGui:Destroy() end
    end)

    -- Draggable
    frame.Active = true
    frame.Draggable = true

    -- ===== Functionality wiring =====

    -- ensure we always have updated humanoid/root references on use
    local function currentChar()
        return player.Character or player.CharacterAdded:Wait()
    end
    local function currentHumRoot()
        local h, r = getHumanoidAndRoot()
        return h, r
    end

    -- WalkSpeed buttons
    ws25.MouseButton1Click:Connect(function()
        local h,_ = currentHumRoot()
        if h then h.WalkSpeed = 25 end
    end)
    ws50.MouseButton1Click:Connect(function()
        local h,_ = currentHumRoot()
        if h then h.WalkSpeed = 50 end
    end)
    ws100.MouseButton1Click:Connect(function()
        local h,_ = currentHumRoot()
        if h then h.WalkSpeed = 100 end
    end)

    -- Noclip toggle
    noclipBtn.MouseButton1Click:Connect(function()
        state.noclip = not state.noclip
        if state.noclip then
            noclipBtn.Text = "Noclip: ON"; noclipBtn.BackgroundColor3 = Color3.fromRGB(0,120,0)
        else
            noclipBtn.Text = "Noclip: OFF"; noclipBtn.BackgroundColor3 = Color3.fromRGB(100,0,0)
        end
    end)
    -- noclip runner
    state.noclipConn = RunService.Stepped:Connect(function()
        if state.noclip then
            local char = player.Character
            if char then
                for _,part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end
    end)

    -- Infinite Jump
    infJumpBtn.MouseButton1Click:Connect(function()
        state.infJump = not state.infJump
        if state.infJump then
            infJumpBtn.Text = "Infinite Jump: ON"; infJumpBtn.BackgroundColor3 = Color3.fromRGB(0,120,0)
        else
            infJumpBtn.Text = "Infinite Jump: OFF"; infJumpBtn.BackgroundColor3 = Color3.fromRGB(100,0,0)
        end
    end)
    local jumpConn = UserInputService.JumpRequest:Connect(function()
        if state.infJump then
            local h,_ = currentHumRoot()
            if h then h:ChangeState("Jumping") end
        end
    end)
    table.insert(state.connections, jumpConn)

    -- Instant Anything
    instantBtn.MouseButton1Click:Connect(function()
        state.instantEnabled = not state.instantEnabled
        if state.instantEnabled then
            instantBtn.Text = "Instant Anything: ON"; instantBtn.BackgroundColor3 = Color3.fromRGB(0,120,0)
            for _,obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("ProximityPrompt") then
                    pcall(function() obj.HoldDuration = 0 end)
                end
            end
            -- connect to future prompts
            state.instantConn = workspace.DescendantAdded:Connect(function(obj)
                if obj:IsA("ProximityPrompt") and state.instantEnabled then
                    pcall(function() obj.HoldDuration = 0 end)
                end
            end)
        else
            instantBtn.Text = "Instant Anything: OFF"; instantBtn.BackgroundColor3 = Color3.fromRGB(100,0,0)
            for _,obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("ProximityPrompt") then
                    pcall(function() obj.HoldDuration = 1 end)
                end
            end
            if state.instantConn then state.instantConn:Disconnect(); state.instantConn = nil end
        end
    end)

    -- Fly implementation (client-side)
    local flyBodyVel, flyBodyGyro, flyConnection, control = nil, nil, nil, {f=0,b=0,l=0,r=0,u=0,d=0}
    local function startFly(speed)
        if state.flyEnabled then return end
        local _, root = currentHumRoot()
        local humanoid = (player.Character and player.Character:FindFirstChildOfClass("Humanoid"))
        if not root or not humanoid then return end
        state.flyEnabled = true
        humanoid.PlatformStand = true
        flyBodyVel = Instance.new("BodyVelocity")
        flyBodyVel.MaxForce = Vector3.new(9e9,9e9,9e9)
        flyBodyVel.Velocity = Vector3.new(0,0,0)
        flyBodyVel.Parent = root
        flyBodyGyro = Instance.new("BodyGyro")
        flyBodyGyro.MaxTorque = Vector3.new(9e9,9e9,9e9)
        flyBodyGyro.CFrame = root.CFrame
        flyBodyGyro.Parent = root
        state.flySpeed = speed or state.flySpeed

        flyConnection = RunService.RenderStepped:Connect(function()
            local cam = workspace.CurrentCamera
            local forward = cam.CFrame.LookVector
            local right = cam.CFrame.RightVector
            local move = Vector3.new(0,0,0)
            if control.f==1 then move = move + forward end
            if control.b==1 then move = move - forward end
            if control.l==1 then move = move - right end
            if control.r==1 then move = move + right end
            -- vertical
            if control.u==1 then move = move + Vector3.new(0,1,0) end
            if control.d==1 then move = move - Vector3.new(0,1,0) end
            local mv = move.Unit * state.flySpeed
            if move.Magnitude == 0 then mv = Vector3.new(0,0,0) end
            flyBodyVel.Velocity = mv
            flyBodyGyro.CFrame = cam.CFrame
        end)
    end
    local function stopFly()
        if not state.flyEnabled then return end
        state.flyEnabled = false
        local humanoid = (player.Character and player.Character:FindFirstChildOfClass("Humanoid"))
        if humanoid then humanoid.PlatformStand = false end
        if flyBodyVel then flyBodyVel:Destroy(); flyBodyVel = nil end
        if flyBodyGyro then flyBodyGyro:Destroy(); flyBodyGyro = nil end
        if flyConnection then flyConnection:Disconnect(); flyConnection = nil end
    end

    -- fly button toggle
    flyBtn.MouseButton1Click:Connect(function()
        if state.flyEnabled then
            stopFly()
            flyBtn.Text = "Fly: OFF"; flyBtn.BackgroundColor3 = Color3.fromRGB(100,0,0)
        else
            startFly(state.flySpeed or 50)
            flyBtn.Text = "Fly: ON"; flyBtn.BackgroundColor3 = Color3.fromRGB(0,120,0)
        end
    end)
    -- fly speed choices
    fly25.MouseButton1Click:Connect(function() state.flySpeed = 25 end)
    fly50.MouseButton1Click:Connect(function() state.flySpeed = 50 end)
    fly100.MouseButton1Click:Connect(function() state.flySpeed = 100 end)

    -- capture WASD for fly controls
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.UserInputType == Enum.UserInputType.Keyboard then
            local k = input.KeyCode
            if k == Enum.KeyCode.W then control.f = 1 end
            if k == Enum.KeyCode.S then control.b = 1 end
            if k == Enum.KeyCode.A then control.l = 1 end
            if k == Enum.KeyCode.D then control.r = 1 end
            if k == Enum.KeyCode.E then control.u = 1 end
            if k == Enum.KeyCode.Q then control.d = 1 end
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Keyboard then
            local k = input.KeyCode
            if k == Enum.KeyCode.W then control.f = 0 end
            if k == Enum.KeyCode.S then control.b = 0 end
            if k == Enum.KeyCode.A then control.l = 0 end
            if k == Enum.KeyCode.D then control.r = 0 end
            if k == Enum.KeyCode.E then control.u = 0 end
            if k == Enum.KeyCode.Q then control.d = 0 end
        end
    end)

    -- Teleport save/place logic
    local function savePlace(i)
        local _, root = currentHumRoot()
        if root then
            state.places[i] = root.CFrame
            -- flash the SaveBtn
            local b = state.hud["save"..i]
            if b then
                b.BackgroundColor3 = Color3.fromRGB(0,120,0)
                task.delay(0.25, function() if b then b.BackgroundColor3 = Color3.fromRGB(50,50,50) end end)
            end
        end
    end
    local function gotoPlace(i)
        local cf = state.places[i]
        local _, root = currentHumRoot()
        if cf and root then
            pcall(function()
                root.CFrame = cf + Vector3.new(0,1,0)
            end)
        end
    end
    -- bind save/place UI
    save1.MouseButton1Click:Connect
