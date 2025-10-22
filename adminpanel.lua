-- Created by 𝕹𝖆𝖘𝖙𝖞 𝕹𝖚𝖓
-- Features:
-- WalkSpeed (25,50,100) | Noclip | Infinite Jump | Instant Anything (always on)
-- Anti-AFK | Teleport Save/Place 1-3 (stacked) | Rainbow ESP + distance | FPS counter
-- Rejoin | ServerHop | Movable blue Menu button | Minimize (-) | Close (X)
-- Respawn-safe as much as possible, client-side features.

-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer

-- STATE
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
    conns = {}
}

-- helper to create instances
local function new(cls, parent, props)
    local obj = Instance.new(cls)
    if parent then obj.Parent = parent end
    if props then
        for k,v in pairs(props) do
            pcall(function() obj[k] = v end)
        end
    end
    return obj
end

-- helper to get current humanoid/root
local function getHumanoidRoot()
    local char = player.Character
    if not char then return nil, nil end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart
    return humanoid, root
end

-- cleanup existing GUI if present (avoid duplicates)
pcall(function()
    local existing = player:FindFirstChild("PlayerGui") and player.PlayerGui:FindFirstChild("Pandel_vFinal")
    if existing then existing:Destroy() end
end)

-- Build GUI function
local function buildGui()
    -- don't rebuild if exists
    if player:FindFirstChild("PlayerGui") and player.PlayerGui:FindFirstChild("Pandel_vFinal") then
        S.gui = player.PlayerGui:FindFirstChild("Pandel_vFinal")
        S.frame = S.gui:FindFirstChild("PandelFrame")
        return
    end

    -- ScreenGui parented to PlayerGui (safer)
    local screen = new("ScreenGui", player:WaitForChild("PlayerGui"), {Name = "Pandel_vFinal", ResetOnSpawn = false})
    S.gui = screen

    -- Blue round movable Menu button (draggable)
    local openBtn = new("TextButton", screen, {
        Name = "PandelOpenBtn",
        Size = UDim2.new(0,60,0,60),
        Position = UDim2.new(0,20,0.85,-60),
        BackgroundColor3 = Color3.fromRGB(0,150,255),
        Text = "Menu",
        TextColor3 = Color3.new(1,1,1),
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        AutoButtonColor = true
    })
    new("UICorner", openBtn).CornerRadius = UDim.new(1,0)
    openBtn.Active = true
    openBtn.Draggable = true
    S.openBtn = openBtn

    -- Main Frame center screen (semi-transparent)
    local frame = new("Frame", screen, {
        Name = "PandelFrame",
        Size = UDim2.new(0,360,0,520),
        Position = UDim2.new(0.5,-180,0.5,-260),
        BackgroundColor3 = Color3.fromRGB(20,40,70),
        BackgroundTransparency = 0.28,
        Visible = false,
        Active = true
    })
    new("UICorner", frame).CornerRadius = UDim.new(0,12)
    S.frame = frame

    -- Titlebar with minimize & close
    local titleBar = new("Frame", frame, {Size = UDim2.new(1,0,0,36), BackgroundColor3 = Color3.fromRGB(18,34,60)})
    new("UICorner", titleBar).CornerRadius = UDim.new(0,12)
    local title = new("TextLabel", titleBar, {
        Text = "Pandel",
        TextColor3 = Color3.new(1,1,1),
        BackgroundTransparency = 1,
        Position = UDim2.new(0,12,0,0),
        Size = UDim2.new(1,-120,1,0),
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local minBtn = new("TextButton", titleBar, {Text = "-", Size = UDim2.new(0,30,0,24), Position = UDim2.new(1,-80,0,6), BackgroundColor3 = Color3.fromRGB(100,100,0), TextColor3 = Color3.new(1,1,1)})
    new("UICorner", minBtn).CornerRadius = UDim.new(0,6)
    local closeBtn = new("TextButton", titleBar, {Text = "X", Size = UDim2.new(0,30,0,24), Position = UDim2.new(1,-42,0,6), BackgroundColor3 = Color3.fromRGB(150,0,0), TextColor3 = Color3.new(1,1,1)})
    new("UICorner", closeBtn).CornerRadius = UDim.new(0,6)

    -- Scrolling content
    local content = new("ScrollingFrame", frame, {Position = UDim2.new(0,12,0,44), Size = UDim2.new(1,-24,1,-92), BackgroundTransparency = 1, CanvasSize = UDim2.new(0,0,2,0), VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar})
    content.ScrollBarThickness = 6
    local layout = new("UIListLayout", content, {Padding = UDim.new(0,8), SortOrder = Enum.SortOrder.LayoutOrder, HorizontalAlignment = Enum.HorizontalAlignment.Center})

    -- small label & button helpers
    local function smallLabel(text)
        return new("TextLabel", content, {Size = UDim2.new(0,320,0,20), BackgroundTransparency = 1, Text = text, TextColor3 = Color3.new(1,1,1), Font = Enum.Font.GothamBold, TextSize = 14})
    end
    local function smallBtn(text, width)
        width = width or 320
        local b = new("TextButton", content, {Size = UDim2.new(0,width,0,34), BackgroundColor3 = Color3.fromRGB(40,60,95), Text = text, TextColor3 = Color3.new(1,1,1), Font = Enum.Font.Gotham, TextSize = 15})
        new("UICorner", b).CornerRadius = UDim.new(0,6)
        return b
    end

    -- WalkSpeed label + row of options
    smallLabel("WalkSpeed")
    local walkRow = new("Frame", content, {Size = UDim2.new(0,320,0,40), BackgroundTransparency = 1})
    local function optionBtn(parent, txt, posX)
        local b = new("TextButton", parent, {Size = UDim2.new(0,100,0,32), Position = UDim2.new(0,posX,0,4), BackgroundColor3 = Color3.fromRGB(65,85,120), Text = txt, TextColor3 = Color3.new(1,1,1), Font = Enum.Font.Gotham, TextSize = 14})
        new("UICorner", b).CornerRadius = UDim.new(0,6)
        return b
    end
    local ws25 = optionBtn(walkRow,"25",6)
    local ws50 = optionBtn(walkRow,"50",110)
    local ws100 = optionBtn(walkRow,"100",214)

    -- Noclip, Infinite Jump, Instant Anything (always-on), Anti-AFK
    local noclipBtn = smallBtn("Noclip: OFF")
    local infJumpBtn = smallBtn("Infinite Jump: OFF")
    local instantLabel = smallLabel("Instant Anything (always enabled)")
    -- Anti-AFK
    local afkBtn = smallBtn("Anti-AFK: OFF")

    -- Teleport stacked
    smallLabel("Teleport+")
    local save1 = smallBtn("Save Place 1")
    local place1 = smallBtn("Place 1")
    local save2 = smallBtn("Save Place 2")
    local place2 = smallBtn("Place 2")
    local save3 = smallBtn("Save Place 3")
    local place3 = smallBtn("Place 3")

    -- ESP/FPS
    local espBtn = smallBtn("ESP: OFF")
    local fpsBtn = smallBtn("FPS: OFF")

    -- Server Tools
    local rjBtn = smallBtn("Rejoin")
    local hopBtn = smallBtn("ServerHop")

    -- Footer
    local footer = new("TextLabel", frame, {Text = "Created by 𝕹𝖆𝖘𝖙𝖞 𝕹𝖚𝖓", Size = UDim2.new(1,0,0,24), Position = UDim2.new(0,0,1,-24), BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(180,220,255), Font = Enum.Font.GothamBold, TextSize = 14})

    -- FPS label
    local fpsLabel = new("TextLabel", screen, {Text = "", Size = UDim2.new(0,120,0,20), Position = UDim2.new(1,-140,1,-38), BackgroundTransparency = 0.6, BackgroundColor3 = Color3.fromRGB(10,10,10), TextColor3 = Color3.fromRGB(220,220,220), Font = Enum.Font.Gotham, TextSize = 14, Visible = false})
    new("UICorner", fpsLabel).CornerRadius = UDim.new(0,6)

    -- store refs
    S.hud = {
        ws25=ws25, ws50=ws50, ws100=ws100,
        noclipBtn=noclipBtn, infJumpBtn=infJumpBtn, afkBtn=afkBtn,
        save1=save1, place1=place1, save2=save2, place2=place2, save3=save3, place3=place3,
        espBtn=espBtn, fpsBtn=fpsBtn, rjBtn=rjBtn, hopBtn=hopBtn,
        minBtn=minBtn, closeBtn=closeBtn, openBtn=openBtn, frame=frame
    }
    S.fpsLabel = fpsLabel

    -- OPEN / MIN / CLOSE
    openBtn.MouseButton1Click:Connect(function() frame.Visible = not frame.Visible end)
    minBtn.MouseButton1Click:Connect(function() frame.Visible = false end)
    closeBtn.MouseButton1Click:Connect(function() screen:Destroy() end)

    -- frame draggable
    frame.Active = true; frame.Draggable = true

    -- ===== Functionality wiring =====

    local function currentHumRoot()
        return getHumanoidRoot()
    end

    -- Walkspeed handlers
    ws25.MouseButton1Click:Connect(function() local h,_ = currentHumRoot(); if h then h.WalkSpeed = 25 end end)
    ws50.MouseButton1Click:Connect(function() local h,_ = currentHumRoot(); if h then h.WalkSpeed = 50 end end)
    ws100.MouseButton1Click:Connect(function() local h,_ = currentHumRoot(); if h then h.WalkSpeed = 100 end end)

    -- noclip toggle
    noclipBtn.MouseButton1Click:Connect(function()
        S.noclip = not S.noclip
        if S.noclip then noclipBtn.Text = "Noclip: ON"; noclipBtn.BackgroundColor3 = Color3.fromRGB(0,150,0)
        else noclipBtn.Text = "Noclip: OFF"; noclipBtn.BackgroundColor3 = Color3.fromRGB(100,0,0) end
    end)

    local noclipRunner = RunService.Stepped:Connect(function()
        if S.noclip and player.Character then
            for _,part in pairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
    table.insert(S.conns, noclipRunner)

    -- Infinite Jump toggle
    infJumpBtn.MouseButton1Click:Connect(function()
        S.infJump = not S.infJump
        if S.infJump then infJumpBtn.Text = "Infinite Jump: ON"; infJumpBtn.BackgroundColor3 = Color3.fromRGB(0,150,0)
        else infJumpBtn.Text = "Infinite Jump: OFF"; infJumpBtn.BackgroundColor3 = Color3.fromRGB(100,0,0) end
    end)
    local jumpConn = UserInputService.JumpRequest:Connect(function()
        if S.infJump then
            local h,_ = currentHumRoot()
            if h then h:ChangeState("Jumping") end
        end
    end)
    table.insert(S.conns, jumpConn)

    -- Instant Anything (always on): apply to current prompts + new ones
    local function makePromptInstant(prom)
        if not prom then return end
        pcall(function() prom.HoldDuration = 0 end)
    end
    -- apply now
    for _,p in pairs(Workspace:GetDescendants()) do
        if p:IsA("ProximityPrompt") then makePromptInstant(p) end
    end
    -- connect for new prompts
    S.instantConn = Workspace.DescendantAdded:Connect(function(obj)
        if obj:IsA("ProximityPrompt") then
            makePromptInstant(obj)
        end
    end)

    -- Anti-AFK toggle
    afkBtn.MouseButton1Click:Connect(function()
        if not S.afkEnabled then
            S.afkEnabled = true
            afkBtn.Text = "Anti-AFK: ON"; afkBtn.BackgroundColor3 = Color3.fromRGB(0,150,0)
            if not S.afkConn then
                S.afkConn = player.Idled:Connect(function()
                    -- non-intrusive VirtualUser click to prevent idle
                    VirtualUser:Button2Down(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
                    task.wait(0.5)
                    VirtualUser:Button2Up(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
                end)
            end
        else
            S.afkEnabled = false
            afkBtn.Text = "Anti-AFK: OFF"; afkBtn.BackgroundColor3 = Color3.fromRGB(100,0,0)
            if S.afkConn then S.afkConn:Disconnect(); S.afkConn = nil end
        end
    end)

    -- Teleport Save & Place (stacked)
    local function savePlace(i)
        local _, root = currentHumRoot()
        if root then
            S.places[i] = root.CFrame
            local b = S.hud["save"..i]
            if b then
                b.BackgroundColor3 = Color3.fromRGB(0,160,0)
                task.delay(0.25, function() if b then b.BackgroundColor3 = Color3.fromRGB(40,60,95) end end)
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

    -- ESP: rainbow animated SelectionBox + name+distance billboard
    local function hsvToRgb(h, s, v)
        -- h:0-1, s:0-1, v:0-1
        local i = math.floor(h * 6)
        local f = h * 6 - i
        local p = v * (1 - s)
        local q = v * (1 - f * s)
        local t = v * (1 - (1 - f) * s)
        i = i % 6
        if i == 0 then return Color3.new(v, t, p) end
        if i == 1 then return Color3.new(q, v, p) end
        if i == 2 then return Color3.new(p, v, t) end
        if i == 3 then return Color3.new(p, q, v) end
        if i == 4 then return Color3.new(t, p, v) end
        return Color3.new(v, p, q)
    end

    local function createESPEntry(plr)
        if not plr.Character then return end
        local root = plr.Character:FindFirstChild("HumanoidRootPart") or plr.Character.PrimaryPart
        if not root then return end
        local box = Instance.new("SelectionBox")
        box.Adornee = root
        box.LineThickness = 0.06
        box.Parent = Workspace
        local bill = Instance.new("BillboardGui")
        bill.Adornee = root
        bill.Size = UDim2.new(0,160,0,36)
        bill.StudsOffset = Vector3.new(0,2.6,0)
        bill.AlwaysOnTop = true
        local label = Instance.new("TextLabel", bill)
        label.Size = UDim2.new(1,0,1,0)
        label.BackgroundTransparency = 1
        label.TextColor3 = Color3.new(1,1,1)
        label.Font = Enum.Font.GothamBold
        label.TextSize = 14
        label.Text = plr.Name
        bill.Parent = Workspace
        return {plr=plr, box=box, bill=bill, label=label}
    end

    local function enableESP(enable)
        S.espEnabled = enable
        if enable then
            -- create for existing players except local
            for _,plr in pairs(Players:GetPlayers()) do
                if plr ~= player and plr.Character then
                    local entry = createESPEntry(plr)
                    if entry then S.esp[plr.Name] = entry end
                end
            end
            -- connect to new players
            S.conns.espPlayerAdded = Players.PlayerAdded:Connect(function(plr)
                plr.CharacterAdded:Connect(function(ch)
                    task.wait(0.5)
                    if S.espEnabled and plr ~= player then
                        local e = createESPEntry(plr)
                        if e then S.esp[plr.Name] = e end
                    end
                end)
            end)
            -- character respawn
            for _,plr in pairs(Players:GetPlayers()) do
                plr.CharacterAdded:Connect(function(ch)
                    task.wait(0.5)
                    if S.espEnabled and plr ~= player then
                        if S.esp[plr.Name] then
                            -- destroy old then recreate
                            pcall(function()
                                if S.esp[plr.Name].box then S.esp[plr.Name].box:Destroy() end
                                if S.esp[plr.Name].bill then S.esp[plr.Name].bill:Destroy() end
                            end)
                            S.esp[plr.Name] = nil
                        end
                        local e = createESPEntry(plr)
                        if e then S.esp[plr.Name] = e end
                    end
                end)
            end
            -- start update loop (rainbow balanced speed)
            S.conns.espUpdate = RunService.RenderStepped:Connect(function(dt)
                -- hue cycles over ~6 seconds (balanced)
                local t = tick()
                local hueBase = (t % 6) / 6
                for name,entry in pairs(S.esp) do
                    pcall(function()
                        local plr = entry.plr
                        if plr and plr.Character and entry.box and entry.label and entry.bill then
                            local root = plr.Character:FindFirstChild("HumanoidRootPart") or plr.Character.PrimaryPart
                            if root and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                                local dist = math.floor((root.Position - player.Character.HumanoidRootPart.Position).Magnitude)
                                entry.label.Text = plr.Name .. " [" .. tostring(dist) .. "m]"
                                -- generate hue per-player offset for variety
                                local offset = (tonumber(tostring(string.byte(name,1))) or 1) % 10 / 10
                                local hue = (hueBase + offset) % 1
                                local color = hsvToRgb(hue, 0.9, 0.95)
                                entry.box.Color3 = color
                                -- Billboard text color cycles too (slightly)
                                entry.label.TextColor3 = color
                                entry.box.Adornee = root
                                entry.bill.Adornee = root
                                entry.box.Visible = true
                                entry.bill.Enabled = true
                            else
                                entry.box.Visible = false
                                entry.bill.Enabled = false
                            end
                        end
                    end)
                end
            end)
        else
            -- disable and cleanup
            for k,v in pairs(S.esp) do
                pcall(function()
                    if v.box then v.box:Destroy() end
                    if v.bill then v.bill:Destroy() end
                end)
                S.esp[k] = nil
            end
            if S.conns.espPlayerAdded then S.conns.espPlayerAdded:Disconnect(); S.conns.espPlayerAdded = nil end
            if S.conns.espUpdate then S.conns.espUpdate:Disconnect(); S.conns.espUpdate = nil end
        end
    end

    -- esp button toggle
    espBtn.MouseButton1Click:Connect(function()
        S.espEnabled = not S.espEnabled
        if S.espEnabled then espBtn.Text = "ESP: ON"; espBtn.BackgroundColor3 = Color3.fromRGB(0,150,0); enableESP(true)
        else espBtn.Text = "ESP: OFF"; espBtn.BackgroundColor3 = Color3.fromRGB(100,0,0); enableESP(false) end
    end)

    -- FPS counter toggle
    fpsBtn.MouseButton1Click:Connect(function()
        S.fpsEnabled = not S.fpsEnabled
        fpsLabel.Visible = S.fpsEnabled
        if S.fpsEnabled then
            fpsBtn.Text = "FPS: ON"; fpsBtn.BackgroundColor3 = Color3.fromRGB(0,150,0)
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
            fpsBtn.Text = "FPS: OFF"; fpsBtn.BackgroundColor3 = Color3.fromRGB(100,0,0)
            if S.fpsConn then S.fpsConn:Disconnect(); S.fpsConn = nil end
        end
    end)

    -- Rejoin
    rjBtn.MouseButton1Click:Connect(function()
        pcall(function() TeleportService:Teleport(game.PlaceId, player) end)
    end)

    -- ServerHop (best-effort)
    hopBtn.MouseButton1Click:Connect(function()
        -- attempt to fetch public server list and join a different instanatures
