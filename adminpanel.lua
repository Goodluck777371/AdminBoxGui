-- Pandel (Final) - Player Tools
-- Made by Nasty GBT 😎
-- Paste to GitHub raw and load with your executor

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local VirtualUser = game:GetService("VirtualUser")
local workspace = game:GetService("Workspace")

local player = Players.LocalPlayer

-- state
local S = {
    gui = nil,
    frame = nil,
    openBtn = nil,
    hud = {},
    places = {},
    esp = {},
    espEnabled = false,
    fpsEnabled = false,
    fpsConn = nil,
    afkConn = nil,
    instantConn = nil,
    noclip = false,
    infJump = false,
    connections = {}
}

-- utils
local function new(class, parent, props)
    local obj = Instance.new(class)
    if parent then obj.Parent = parent end
    if props then
        for k,v in pairs(props) do
            pcall(function() obj[k] = v end)
        end
    end
    return obj
end

local function getHumanoidAndRoot()
    local char = player.Character
    if not char then return nil, nil end
    local h = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart
    return h, root
end

-- cleanup any old GUI
pcall(function()
    local old = game.CoreGui:FindFirstChild("Pandel_vFinal")
    if old then old:Destroy() end
end)

-- build GUI
local function build()
    -- ScreenGui
    local screen = new("ScreenGui", game.CoreGui, {Name = "Pandel_vFinal", ResetOnSpawn = false})
    S.gui = screen

    -- Blue round open button (bottom-left)
    local openBtn = new("TextButton", screen, {
        Name = "OpenBtn",
        Size = UDim2.new(0,60,0,60),
        Position = UDim2.new(0,20,0.9,-60),
        BackgroundColor3 = Color3.fromRGB(0,150,255),
        Text = "Menu",
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        TextColor3 = Color3.new(1,1,1),
        AutoButtonColor = true
    })
    new("UICorner", openBtn).CornerRadius = UDim.new(1,0)
    S.openBtn = openBtn

    -- main frame (center)
    local frame = new("Frame", screen, {
        Name = "PandelFrame",
        Size = UDim2.new(0,380,0,520),
        Position = UDim2.new(0.5, -190, 0.5, -260),
        BackgroundColor3 = Color3.fromRGB(30,60,110),
        BackgroundTransparency = 0.28,
        Visible = false,
        Active = true
    })
    new("UICorner", frame).CornerRadius = UDim.new(0,12)
    S.frame = frame

    -- titlebar
    local titleBar = new("Frame", frame, {Size = UDim2.new(1,0,0,36), BackgroundColor3 = Color3.fromRGB(24,44,82)})
    new("UICorner", titleBar).CornerRadius = UDim.new(0,12)
    local title = new("TextLabel", titleBar, {
        Text = "Pandel",
        TextColor3 = Color3.new(1,1,1),
        BackgroundTransparency = 1,
        Position = UDim2.new(0,12,0,0),
        Size = UDim2.new(1,-100,1,0),
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    local minBtn = new("TextButton", titleBar, {
        Text = "-",
        Size = UDim2.new(0,30,0,24),
        Position = UDim2.new(1,-80,0,6),
        BackgroundColor3 = Color3.fromRGB(100,100,0),
        TextColor3 = Color3.new(1,1,1)
    })
    new("UICorner", minBtn).CornerRadius = UDim.new(0,6)
    local closeBtn = new("TextButton", titleBar, {
        Text = "X",
        Size = UDim2.new(0,30,0,24),
        Position = UDim2.new(1,-40,0,6),
        BackgroundColor3 = Color3.fromRGB(150,0,0),
        TextColor3 = Color3.new(1,1,1)
    })
    new("UICorner", closeBtn).CornerRadius = UDim.new(0,6)

    -- scrolling content
    local content = new("ScrollingFrame", frame, {
        Position = UDim2.new(0,12,0,44),
        Size = UDim2.new(1,-24,1,-88),
        BackgroundTransparency = 1,
        CanvasSize = UDim2.new(0,0,2,0),
        VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar
    })
    content.ScrollBarThickness = 6
    local layout = new("UIListLayout", content, {Padding = UDim.new(0,8), SortOrder = Enum.SortOrder.LayoutOrder, HorizontalAlignment = Enum.HorizontalAlignment.Center})

    -- small button creator
    local function smallBtn(text, w)
        w = w or 340
        local b = new("TextButton", content, {
            Size = UDim2.new(0,w,0,34),
            BackgroundColor3 = Color3.fromRGB(55,75,110),
            Text = text,
            TextColor3 = Color3.new(1,1,1),
            Font = Enum.Font.Gotham,
            TextSize = 15
        })
        new("UICorner", b).CornerRadius = UDim.new(0,6)
        return b
    end

    local function smallLabel(text)
        return new("TextLabel", content, {Size = UDim2.new(0,340,0,20), BackgroundTransparency = 1, Text = text, TextColor3 = Color3.new(1,1,1), Font = Enum.Font.GothamBold, TextSize = 14})
    end

    -- WalkSpeed row (label + options)
    smallLabel("WalkSpeed")
    local wsRow = new("Frame", content, {Size = UDim2.new(0,340,0,40), BackgroundTransparency = 1})
    local function optBtn(parent, txt, x)
        local b = new("TextButton", parent, {
            Size = UDim2.new(0,100,0,32),
            Position = UDim2.new(0,x,0,4),
            BackgroundColor3 = Color3.fromRGB(80,95,130),
            Text = txt, TextColor3 = Color3.new(1,1,1), Font = Enum.Font.Gotham, TextSize = 14
        })
        new("UICorner", b).CornerRadius = UDim.new(0,6)
        return b
    end
    local ws25 = optBtn(wsRow,"25",10)
    local ws50 = optBtn(wsRow,"50",125)
    local ws100 = optBtn(wsRow,"100",240)

    -- Noclip, Infinite Jump, Instant Anything, Anti-AFK
    local noclipBtn = smallBtn("Noclip: OFF")
    local infJumpBtn = smallBtn("Infinite Jump: OFF")
    local instantBtn = smallBtn("Instant Anything: OFF")
    local afkBtn = smallBtn("Anti-AFK: OFF")

    -- Teleport+ stacked
    smallLabel("Teleport+")
    local save1 = smallBtn("Save Place 1")
    local place1 = smallBtn("Place 1")
    local save2 = smallBtn("Save Place 2")
    local place2 = smallBtn("Place 2")
    local save3 = smallBtn("Save Place 3")
    local place3 = smallBtn("Place 3")

    -- ESP and FPS
    local espBtn = smallBtn("ESP: OFF")
    local fpsBtn = smallBtn("FPS: OFF")

    -- Server tools
    local rjBtn = smallBtn("Rejoin")
    local hopBtn = smallBtn("ServerHop")

    -- footer
    local footer = new("TextLabel", frame, {Text = "Made by Nasty GBT 😎", Size = UDim2.new(1,0,0,24), Position = UDim2.new(0,0,1,-24), BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(190,220,255), Font = Enum.Font.GothamBold, TextSize = 14})

    -- fps label
    local fpsLabel = new("TextLabel", screen, {Text = "", Size = UDim2.new(0,100,0,20), Position = UDim2.new(1,-120,1,-40), BackgroundTransparency = 0.6, BackgroundColor3 = Color3.fromRGB(10,10,10), TextColor3 = Color3.fromRGB(220,220,220), Font = Enum.Font.Gotham, TextSize = 14, Visible = false})
    new("UICorner", fpsLabel).CornerRadius = UDim.new(0,6)

    -- store refs
    S.hud = {
        ws25=ws25, ws50=ws50, ws100=ws100,
        noclipBtn=noclipBtn, infJumpBtn=infJumpBtn, instantBtn=instantBtn, afkBtn=afkBtn,
        save1=save1, place1=place1, save2=save2, place2=place2, save3=save3, place3=place3,
        espBtn=espBtn, fpsBtn=fpsBtn, rjBtn=rjBtn, hopBtn=hopBtn,
        minBtn=minBtn, closeBtn=closeBtn, openBtn=openBtn, frame=frame
    }
    S.fpsLabel = fpsLabel

    -- show/hide
    openBtn.MouseButton1Click:Connect(function()
        frame.Visible = not frame.Visible
    end)
    minBtn.MouseButton1Click:Connect(function() frame.Visible = false end)
    closeBtn.MouseButton1Click:Connect(function() if screen then screen:Destroy() end end)

    -- Draggable
    frame.Active = true; frame.Draggable = true

    -- Function helpers
    local function currentHumRoot()
        return getHumanoidAndRoot()
    end

    -- WalkSpeed handlers
    ws25.MouseButton1Click:Connect(function() local h,_ = currentHumRoot(); if h then h.WalkSpeed = 25 end end)
    ws50.MouseButton1Click:Connect(function() local h,_ = currentHumRoot(); if h then h.WalkSpeed = 50 end end)
    ws100.MouseButton1Click:Connect(function() local h,_ = currentHumRoot(); if h then h.WalkSpeed = 100 end end)

    -- Noclip toggle
    noclipBtn.MouseButton1Click:Connect(function()
        S.noclip = not S.noclip
        if S.noclip then noclipBtn.Text="Noclip: ON"; noclipBtn.BackgroundColor3=Color3.fromRGB(0,140,0)
        else noclipBtn.Text="Noclip: OFF"; noclipBtn.BackgroundColor3=Color3.fromRGB(100,0,0) end
    end)
    -- run noclip each frame
    local noclipConn = RunService.Stepped:Connect(function()
        if S.noclip and player.Character then
            for _,part in pairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
    table.insert(S.connections, noclipConn)

    -- Infinite Jump
    infJumpBtn.MouseButton1Click:Connect(function()
        S.infJump = not S.infJump
        if S.infJump then infJumpBtn.Text="Infinite Jump: ON"; infJumpBtn.BackgroundColor3=Color3.fromRGB(0,140,0)
        else infJumpBtn.Text="Infinite Jump: OFF"; infJumpBtn.BackgroundColor3=Color3.fromRGB(100,0,0) end
    end)
    local jumpConn = UserInputService.JumpRequest:Connect(function()
        if S.infJump then local h,_ = currentHumRoot(); if h then h:ChangeState("Jumping") end end
    end)
    table.insert(S.connections, jumpConn)

    -- Instant Anything (ProximityPrompt HoldDuration = 0)
    instantBtn.MouseButton1Click:Connect(function()
        S.instantEnabled = not S.instantEnabled
        if S.instantEnabled then
            instantBtn.Text="Instant Anything: ON"; instantBtn.BackgroundColor3=Color3.fromRGB(0,140,0)
            for _,p in pairs(workspace:GetDescendants()) do if p:IsA("ProximityPrompt") then pcall(function() p.HoldDuration = 0 end) end end
            S.instantConn = workspace.DescendantAdded:Connect(function(obj) if obj:IsA("ProximityPrompt") and S.instantEnabled then pcall(function() obj.HoldDuration = 0 end) end end)
        else
            instantBtn.Text="Instant Anything: OFF"; instantBtn.BackgroundColor3=Color3.fromRGB(100,0,0)
            for _,p in pairs(workspace:GetDescendants()) do if p:IsA("ProximityPrompt") then pcall(function() p.HoldDuration = 1 end) end end
            if S.instantConn then S.instantConn:Disconnect(); S.instantConn=nil end
        end
    end)

    -- Anti-AFK
    afkBtn.MouseButton1Click:Connect(function()
        S.afkEnabled = not S.afkEnabled
        if S.afkEnabled then
            afkBtn.Text="Anti-AFK: ON"; afkBtn.BackgroundColor3=Color3.fromRGB(0,140,0)
            if not S.afkConn then
                S.afkConn = player.Idled:Connect(function()
                    VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                    task.wait(0.5)
                    VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                end)
            end
        else
            afkBtn.Text="Anti-AFK: OFF"; afkBtn.BackgroundColor3=Color3.fromRGB(100,0,0)
            if S.afkConn then S.afkConn:Disconnect(); S.afkConn=nil end
        end
    end)

    -- Teleport Save & Place handlers
    local function savePlace(i)
        local _, root = currentHumRoot()
        if root then
            S.places[i] = root.CFrame
            local b = S.hud["save"..i]
            if b then
                b.BackgroundColor3 = Color3.fromRGB(0,160,0)
                task.delay(0.25, function() if b then b.BackgroundColor3 = Color3.fromRGB(55,75,110) end end)
            end
        end
    end
    local function gotoPlace(i)
        local cf = S.places[i]
        local _, root = currentHumRoot()
        if cf and root then
            pcall(function() root.CFrame = cf + Vector3.new(0,1,0) end)
        end
    end
    save1.MouseButton1Click:Connect(function() savePlace(1) end)
    place1.MouseButton1Click:Connect(function() gotoPlace(1) end)
    save2.MouseButton1Click:Connect(function() savePlace(2) end)
    place2.MouseButton1Click:Connect(function() gotoPlace(2) end)
    save3.MouseButton1Click:Connect(function() savePlace(3) end)
    place3.MouseButton1Click:Connect(function() gotoPlace(3) end)

    -- ESP: selection box + billboard with name + distance
    local function createESPForPlayer(plr)
        if not plr.Character then return end
        local root = plr.Character:FindFirstChild("HumanoidRootPart") or plr.Character.PrimaryPart
        if not root then return end
        -- selection box
        local box = Instance.new("SelectionBox")
        box.Adornee = root
        box.LineThickness = 0.05
        box.Color3 = Color3.fromRGB(0,200,255)
        box.Parent = workspace
        -- billboard
        local bg = Instance.new("BillboardGui")
        bg.Adornee = root
        bg.Size = UDim2.new(0,160,0,40)
        bg.StudsOffset = Vector3.new(0,2.4,0)
        bg.AlwaysOnTop = true
        local label = Instance.new("TextLabel", bg)
        label.Size = UDim2.new(1,0,1,0)
        label.BackgroundTransparency = 1
        label.TextColor3 = Color3.new(1,1,1)
        label.Font = Enum.Font.GothamBold
        label.TextSize = 14
        label.Text = plr.Name
        bg.Parent = workspace
        return {box=box, label=label, gui=bg, plr=plr}
    end

    local function updateESP()
        for name,entry in pairs(S.esp) do
            pcall(function()
                local plr = entry.plr
                if plr and plr.Character and entry.box and entry.label then
                    local root = plr.Character:FindFirstChild("HumanoidRootPart") or plr.Character.PrimaryPart
                    if root and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        local dist = (root.Position - player.Character.HumanoidRootPart.Position).Magnitude
                        entry.label.Text = plr.Name .. " [" .. tostring(math.floor(dist)) .. "m]"
                        entry.box.Adornee = root
                        entry.gui.Adornee = root
                        entry.box.Visible = true
                        entry.gui.Enabled = true
                    else
                        entry.box.Visible = false
                        entry.gui.Enabled = false
                    end
                end
            end)
        end
    end

    local function enableESP(enable)
        S.espEnabled = enable
        if enable then
            -- create for all players except local
            for _,plr in pairs(Players:GetPlayers()) do
                if plr ~= player and plr.Character then
                    local e = createESPForPlayer(plr)
                    if e then S.esp[plr.Name] = e end
                end
            end
            -- connect new players and respawns
            S.connections.espAdded = Players.PlayerAdded:Connect(function(plr)
                plr.CharacterAdded:Connect(function(ch)
                    task.wait(0.5)
                    if S.espEnabled and plr ~= player then
                        local e = createESPForPlayer(plr)
                        if e then S.esp[plr.Name] = e end
                    end
                end)
            end)
            for _,plr in pairs(Players:GetPlayers()) do
                plr.CharacterAdded:Connect(function(ch)
                    task.wait(0.5)
                    if S.espEnabled and plr ~= player then
                        local e = createESPForPlayer(plr)
                        if e then S.esp[plr.Name] = e end
                    end
                end)
            end
            -- update loop
            S.connections.espUpdate = RunService.RenderStepped:Connect(updateESP)
        else
            -- destroy
            for k,v in pairs(S.esp) do
                pcall(function()
                    if v.box then v.box:Destroy() end
                    if v.gui then v.gui:Destroy() end
                end)
                S.esp[k] = nil
            end
            if S.connections.espAdded then S.connections.espAdded:Disconnect(); S.connections.espAdded = nil end
            if S.connections.espUpdate then S.connections.espUpdate:Disconnect(); S.connections.espUpdate = nil end
        end
    end

    -- ESP button
    espBtn.MouseButton1Click:Connect(function()
        S.espEnabled = not S.espEnabled
        if S.espEnabled then espBtn.Text="ESP: ON"; espBtn.BackgroundColor3=Color3.fromRGB(0,140,0); enableESP(true)
        else espBtn.Text="ESP: OFF"; espBtn.BackgroundColor3=Color3.fromRGB(100,0,0); enableESP(false) end
    end)

    -- FPS counter
    fpsBtn.MouseButton1Click:Connect(function()
        S.fpsEnabled = not S.fpsEnabled
        fpsLabel.Visible = S.fpsEnabled
        if S.fpsEnabled then
            fpsBtn.Text="FPS: ON"; fpsBtn.BackgroundColor3=Color3.fromRGB(0,140,0)
            local last = tick(); local frames = 0
            S.fpsConn = RunService.RenderStepped:Connect(function()
                frames = frames + 1
                local now = tick()
                if now - last >= 1 then
                    fpsLabel.Text = "FPS: "..tostring(frames)
                    frames = 0; last = now
                end
            end)
        else
            fpsBtn.Text="FPS: OFF"; fpsBtn.BackgroundColor3=Color3.fromRGB(100,0,0)
            if S.fpsConn then S.fpsConn:Disconnect(); S.fpsConn=nil end
        end
    end)

    -- Rejoin
    rjBtn.MouseButton1Click:Connect(function()
        pcall(function() TeleportService:Teleport(game.PlaceId, player) end)
    end)
    -- ServerHop (best-effort)
    hopBtn.MouseButton1Click:Connect(function()
        pcall(function() TeleportService:Teleport(game.PlaceId, player) end)
    end)

    -- Rebind on CharacterAdded to keep humanoid root access
    player.CharacterAdded:Connect(function()
        task.wait(0.5)
        -- nothing heavy required; handlers call currentHumRoot() each time
    end)

    -- cleanup when GUI destroyed
    screen.Destroying:Connect(function()
        -- disconnect connections
        for k,v in pairs(S.connections) do
            if v and v.Disconnect then pcall(function() v:Disconnect() end) end
        end
        if S.instantConn then S.instantConn:Disconnect(); S.instantConn=nil end
        if S.afkConn then S.afkConn:Disconnect(); S.afkConn=nil end
        if S.fpsConn then S.fpsConn:Disconnect(); S.fpsConn=nil end
        enableESP(false)
    end)
end

-- build initially
build()

-- convenience: loader hotkey (M)
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.M then
        if S.frame and S.frame.Visible then S.frame.Visible = false
        else if S.frame then S.frame.Visible = true end end
    end
end)

-- ensure GUI exists (rebuild if removed)
if not S.gui or not S.gui.Parent then
    build()
end

-- NOTES:
-- - Teleport saves are session-only (temporary).
-- - ESP shows name + distance (meters) and a selection box.
-- - Instant Anything sets ProximityPrompt.HoldDuration = 0 (best-effort).
-- - Anti-AFK uses VirtualUser to prevent idle kick.
