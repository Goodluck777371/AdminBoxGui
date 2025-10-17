-- ⚙️ AdminBox v3 — Mobile Fly Edition (transparent blue, persistent settings)
-- Created by Nasty GBT 😎
-- Features: WalkSpeed, Noclip, Infinite Jump, Fly (uses default thumbstick + jump to ascend), Fly speeds, persistent settings, draggable UI, tap Walk to toggle

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

-- ---------- Character refs ----------
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:FindFirstChildOfClass("Humanoid") or character:WaitForChild("Humanoid")
local function setCharacterRefs(char)
	character = char
	humanoid = char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid")
end
player.CharacterAdded:Connect(function(char) task.wait(0.06); setCharacterRefs(char) end)

-- ---------- Persistent attributes (ensure defaults) ----------
local function ensureAttr(name, default)
	if player:GetAttribute(name) == nil then
		player:SetAttribute(name, default)
	end
end

ensureAttr("NBT_walkSpeed", 25)
ensureAttr("NBT_noclip", false)
ensureAttr("NBT_infJump", false)
ensureAttr("NBT_flying", false)
ensureAttr("NBT_flySpeed", 50)

-- local mirrors
local noclip = player:GetAttribute("NBT_noclip")
local infJump = player:GetAttribute("NBT_infJump")
local flying = player:GetAttribute("NBT_flying")
local flySpeed = player:GetAttribute("NBT_flySpeed") or 50

-- ---------- GUI root ----------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NastyGBT_AdminBox"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game.CoreGui

-- small open button (tap to open/close)
local OpenBtn = Instance.new("TextButton", ScreenGui)
OpenBtn.Size = UDim2.new(0,60,0,60)
OpenBtn.Position = UDim2.new(0,20,0.5,-30)
OpenBtn.AnchorPoint = Vector2.new(0,0.5)
OpenBtn.Text = "Walk"
OpenBtn.Font = Enum.Font.GothamBold
OpenBtn.TextSize = 18
OpenBtn.BackgroundColor3 = Color3.fromRGB(6,130,230)
OpenBtn.TextColor3 = Color3.new(1,1,1)
OpenBtn.AutoButtonColor = true
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(1,0)

-- main frame (transparent blue)
local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0,360,0,420)
Frame.Position = UDim2.new(0.5,-180,0.5,-210)
Frame.BackgroundColor3 = Color3.fromRGB(12,95,180)
Frame.BackgroundTransparency = 0.6
Frame.Active = true
Frame.Draggable = true
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0,12)
Frame.Visible = false
Frame.ClipsDescendants = true

-- Titlebar (for minimize & close)
local TitleBar = Instance.new("Frame", Frame)
TitleBar.Size = UDim2.new(1,0,0,36)
TitleBar.Position = UDim2.new(0,0,0,0)
TitleBar.BackgroundColor3 = Color3.fromRGB(10,80,155)
TitleBar.BackgroundTransparency = 0.5
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0,12)

local TitleText = Instance.new("TextLabel", TitleBar)
TitleText.Text = "⚙️ Admin Box"
TitleText.Size = UDim2.new(1,-120,1,0)
TitleText.Position = UDim2.new(0,12,0,0)
TitleText.BackgroundTransparency = 1
TitleText.TextColor3 = Color3.new(1,1,1)
TitleText.Font = Enum.Font.GothamBold
TitleText.TextSize = 16
TitleText.TextXAlignment = Enum.TextXAlignment.Left

local MinBtn = Instance.new("TextButton", TitleBar)
MinBtn.Text = "-"
MinBtn.Size = UDim2.new(0,36,0,28)
MinBtn.Position = UDim2.new(1,-128,0,3)
MinBtn.BackgroundColor3 = Color3.fromRGB(8,70,140)
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0,6)

local CloseBtn = Instance.new("TextButton", TitleBar)
CloseBtn.Text = "X"
CloseBtn.Size = UDim2.new(0,36,0,28)
CloseBtn.Position = UDim2.new(1,-74,0,3)
CloseBtn.BackgroundColor3 = Color3.fromRGB(12,90,170)
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0,6)

-- Footer
local Footer = Instance.new("TextLabel", Frame)
Footer.Text = "Created by Nasty GBT 😎"
Footer.Size = UDim2.new(1,-14,0,24)
Footer.Position = UDim2.new(0,7,1,-32)
Footer.BackgroundTransparency = 0.6
Footer.TextColor3 = Color3.fromRGB(180,235,255)
Footer.Font = Enum.Font.GothamBold
Footer.TextSize = 14
Instance.new("UICorner", Footer).CornerRadius = UDim.new(0,8)

-- ---------------- WalkSpeed ----------------
local leftX = 14
local WalkLabel = Instance.new("TextLabel", Frame)
WalkLabel.Text = "WalkSpeed"
WalkLabel.Size = UDim2.new(0,140,0,22)
WalkLabel.Position = UDim2.new(0,leftX,0,54)
WalkLabel.BackgroundTransparency = 1
WalkLabel.TextColor3 = Color3.fromRGB(230,250,255)
WalkLabel.Font = Enum.Font.Gotham
WalkLabel.TextSize = 14
WalkLabel.TextXAlignment = Enum.TextXAlignment.Left

local speeds = {25,30,50,100}
local speedButtons = {}
for i, speed in ipairs(speeds) do
	local btn = Instance.new("TextButton", Frame)
	btn.Size = UDim2.new(0,80,0,34)
	btn.Position = UDim2.new(0,leftX + (i-1)*86,0,82)
	btn.Text = tostring(speed)
	btn.Font = Enum.Font.Gotham
	btn.TextSize = 14
	btn.BackgroundColor3 = Color3.fromRGB(20,60,110)
	btn.TextColor3 = Color3.fromRGB(220,245,255)
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)
	speedButtons[tostring(speed)] = btn
	btn.MouseButton1Click:Connect(function()
		player:SetAttribute("NBT_walkSpeed", speed)
		if humanoid then humanoid.WalkSpeed = speed end
		updateButtonStates()
	end)
end

-- ---------------- Noclip ----------------
local NoclipBtn = Instance.new("TextButton", Frame)
NoclipBtn.Size = UDim2.new(0,170,0,34)
NoclipBtn.Position = UDim2.new(0,leftX,0,132)
NoclipBtn.Text = "Noclip: OFF"
NoclipBtn.Font = Enum.Font.Gotham
NoclipBtn.TextSize = 14
NoclipBtn.BackgroundColor3 = Color3.fromRGB(150,40,40)
NoclipBtn.TextColor3 = Color3.fromRGB(230,245,255)
Instance.new("UICorner", NoclipBtn).CornerRadius = UDim.new(0,8)
NoclipBtn.MouseButton1Click:Connect(function()
	noclip = not noclip
	player:SetAttribute("NBT_noclip", noclip)
	updateButtonStates()
end)

RunService.Stepped:Connect(function()
	if noclip and character then
		for _, p in pairs(character:GetDescendants()) do
			if p:IsA("BasePart") then p.CanCollide = false end
		end
	end
end)

-- ---------------- Infinite Jump ----------------
local JumpBtn = Instance.new("TextButton", Frame)
JumpBtn.Size = UDim2.new(0,260,0,34)
JumpBtn.Position = UDim2.new(0,leftX,0,182)
JumpBtn.Text = "Infinite Jump: OFF"
JumpBtn.Font = Enum.Font.Gotham
JumpBtn.TextSize = 14
JumpBtn.BackgroundColor3 = Color3.fromRGB(150,40,40)
JumpBtn.TextColor3 = Color3.fromRGB(230,245,255)
Instance.new("UICorner", JumpBtn).CornerRadius = UDim.new(0,8)
JumpBtn.MouseButton1Click:Connect(function()
	infJump = not infJump
	player:SetAttribute("NBT_infJump", infJump)
	updateButtonStates()
end)

local jumpConn
if not jumpConn then
	jumpConn = UserInputService.JumpRequest:Connect(function()
		if infJump and humanoid then humanoid:ChangeState("Jumping") end
	end)
end

-- ---------------- Fly (mobile thumbstick + jump ascend) ----------------
local FlyBtn = Instance.new("TextButton", Frame)
FlyBtn.Size = UDim2.new(0,170,0,34)
FlyBtn.Position = UDim2.new(0,leftX,0,232)
FlyBtn.Text = "Fly: OFF"
FlyBtn.Font = Enum.Font.Gotham
FlyBtn.TextSize = 14
FlyBtn.BackgroundColor3 = Color3.fromRGB(150,40,40)
FlyBtn.TextColor3 = Color3.fromRGB(230,245,255)
Instance.new("UICorner", FlyBtn).CornerRadius = UDim.new(0,8)

-- Fly speed buttons
local fSpeeds = {25,50,100}
local fButtons = {}
for i, fs in ipairs(fSpeeds) do
	local b = Instance.new("TextButton", Frame)
	b.Size = UDim2.new(0,80,0,30)
	b.Position = UDim2.new(0,leftX + (i-1)*86,0,274)
	b.Text = tostring(fs)
	b.Font = Enum.Font.Gotham
	b.TextSize = 14
	b.BackgroundColor3 = Color3.fromRGB(20,60,110)
	b.TextColor3 = Color3.fromRGB(220,245,255)
	Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)
	fButtons[tostring(fs)] = b
	b.MouseButton1Click:Connect(function()
		flySpeed = fs
		player:SetAttribute("NBT_flySpeed", flySpeed)
		updateButtonStates()
	end)
end

-- fly controllers
local bodyGyro, bodyVel, flyConn
local jumpPressed = false

-- track JumpRequest pressed state (works for mobile jump button)
UserInputService.JumpRequest:Connect(function() jumpPressed = true; task.delay(0.12, function() jumpPressed = false end) end)

FlyBtn.MouseButton1Click:Connect(function()
	flying = not flying
	player:SetAttribute("NBT_flying", flying)
	updateButtonStates()
	-- create or remove controllers as needed
	if flying then
		-- attempt to create controllers when possible
		if character and character.PrimaryPart then
			if bodyGyro then bodyGyro:Destroy() end
			if bodyVel then bodyVel:Destroy() end
			bodyGyro = Instance.new("BodyGyro", character.PrimaryPart)
			bodyGyro.MaxTorque = Vector3.new(9e9,9e9,9e9)
			bodyGyro.P = 10000
			bodyVel = Instance.new("BodyVelocity", character.PrimaryPart)
			bodyVel.MaxForce = Vector3.new(9e9,9e9,9e9)
			bodyVel.Velocity = Vector3.new(0,0,0)
		end
		if not flyConn then
			flyConn = RunService.RenderStepped:Connect(function()
				if flying and character and character.PrimaryPart and bodyGyro and bodyVel and humanoid then
					-- use Humanoid.MoveDirection for joystick input (works on mobile)
					local moveDir = humanoid.MoveDirection -- Vector3 relative to world (camera-relative)
					-- camera forward/right for orientation
					local cam = workspace.CurrentCamera
					local forward = cam.CFrame.LookVector
					local right = cam.CFrame.RightVector
					-- project moveDir onto camera axes to get local movement vector
					local move = (forward * moveDir.Z) + (right * moveDir.X)
					-- vertical control: use jump button to ascend a bit; otherwise steady hover
					local vertical = 0
					if jumpPressed then vertical = 1 end
					-- assemble velocity
					local horizontalVelocity = move.Unit.Magnitude > 0 and move.Unit * flySpeed or Vector3.new(0,0,0)
					-- scale by magnitude (humanoid.MoveDirection magnitude is mostly 1 or 0)
					horizontalVelocity = horizontalVelocity * move.Magnitude
					bodyGyro.CFrame = cam.CFrame
					bodyVel.Velocity = Vector3.new(horizontalVelocity.X, vertical * flySpeed * 0.7, horizontalVelocity.Z)
					-- keep Humanoid in platformstand so default gravity doesn't fight too hard (optional)
					-- some games may behave better if humanoid.PlatformStand = true; avoid forcing it globally.
					-- We'll lightly reduce humanoid state to prevent weird stuttering:
					-- if humanoid and humanoid.Parent then humanoid:ChangeState(Enum.HumanoidStateType.Physics) end
				end
			end)
		end
	else
		if flyConn then flyConn:Disconnect(); flyConn = nil end
		if bodyGyro then bodyGyro:Destroy(); bodyGyro = nil end
		if bodyVel then bodyVel:Destroy(); bodyVel = nil end
	end
end)

-- ---------------- UI update function ----------------
function updateButtonStates()
	-- WalkSpeed
	local ws = player:GetAttribute("NBT_walkSpeed") or 25
	if humanoid then humanoid.WalkSpeed = ws end
	for s, btn in pairs(speedButtons) do
		if tonumber(s) == ws then btn.BackgroundColor3 = Color3.fromRGB(0,160,0)
		else btn.BackgroundColor3 = Color3.fromRGB(20,60,110) end
	end

	-- noclip
	noclip = player:GetAttribute("NBT_noclip")
	if noclip then NoclipBtn.Text = "Noclip: ON"; NoclipBtn.BackgroundColor3 = Color3.fromRGB(0,160,0)
	else NoclipBtn.Text = "Noclip: OFF"; NoclipBtn.BackgroundColor3 = Color3.fromRGB(150,40,40) end

	-- inf jump
	infJump = player:GetAttribute("NBT_infJump")
	if infJump then JumpBtn.Text = "Infinite Jump: ON"; JumpBtn.BackgroundColor3 = Color3.fromRGB(0,160,0)
	else JumpBtn.Text = "Infinite Jump: OFF"; JumpBtn.BackgroundColor3 = Color3.fromRGB(150,40,40) end

	-- fly
	flying = player:GetAttribute("NBT_flying")
	flySpeed = player:GetAttribute("NBT_flySpeed") or flySpeed
	if flying then FlyBtn.Text = "Fly: ON"; FlyBtn.BackgroundColor3 = Color3.fromRGB(0,160,0)
	else FlyBtn.Text = "Fly: OFF"; FlyBtn.BackgroundColor3 = Color3.fromRGB(150,40,40) end
	for s, b in pairs(fButtons) do
		if tonumber(s) == flySpeed then b.BackgroundColor3 = Color3.fromRGB(0,160,0) else b.BackgroundColor3 = Color3.fromRGB(20,60,110) end
	end
end

-- ensure initial states
updateButtonStates()

-- reapply walk speed and recreate fly controllers after respawn
player.CharacterAdded:Connect(function(char)
	task.wait(0.06)
	setCharacterRefs(char)
	local ws = player:GetAttribute("NBT_walkSpeed") or 25
	if humanoid then humanoid.WalkSpeed = ws end
	-- recreate fly controllers if still flying
	if player:GetAttribute("NBT_flying") then
		-- cleanup old
		if bodyGyro then bodyGyro:Destroy(); bodyGyro=nil end
		if bodyVel then bodyVel:Destroy(); bodyVel=nil end
		-- create new when available
		if character and character.PrimaryPart then
			bodyGyro = Instance.new("BodyGyro", character.PrimaryPart)
			bodyGyro.MaxTorque = Vector3.new(9e9,9e9,9e9)
			bodyGyro.P = 10000
			bodyVel = Instance.new("BodyVelocity", character.PrimaryPart)
			bodyVel.MaxForce = Vector3.new(9e9,9e9,9e9)
		end
	end
	task.delay(0.12, updateButtonStates)
end)

-- ---------- Open/close animation (fade + slide) ----------
local function tweenShow()
	Frame.Visible = true
	Frame.Position = UDim2.new(0.5,-180,0.5,-240)
	Frame.BackgroundTransparency = 1
	local t1 = TweenService:Create(Frame, TweenInfo.new(0.22, Enum.EasingStyle.Quad), {BackgroundTransparency = 0.6, Position = UDim2.new(0.5,-180,0.5,-210)})
	t1:Play()
end
local function tweenHide()
	local t = TweenService:Create(Frame, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {BackgroundTransparency = 1, Position = UDim2.new(0.5,-180,0.5,-240)})
	t:Play()
	t.Completed:Connect(function() Frame.Visible = false end)
end

OpenBtn.MouseButton1Click:Connect(function()
	if Frame.Visible then
		tweenHide()
	else
		tweenShow()
	end
end)

-- Min button hides (same as tap)
MinBtn.MouseButton1Click:Connect(function() tweenHide() end)

CloseBtn.MouseButton1Click:Connect(function()
	-- cleanup fly controllers
	if flyConn then flyConn:Disconnect(); flyConn=nil end
	if bodyGyro then bodyGyro:Destroy(); bodyGyro=nil end
	if bodyVel then bodyVel:Destroy(); bodyVel=nil end
	ScreenGui:Destroy()
end)

-- housekeeping: apply noclip each step if on
RunService.Stepped:Connect(function()
	if noclip and character then
		for _, p in pairs(character:GetDescendants()) do
			if p:IsA("BasePart") then p.CanCollide = false end
		end
	end
end)

-- keep UI colors updated lightly
RunService.Heartbeat:Connect(function()
	updateButtonStates()
end)

-- Ensure initial humanoid walkspeed from attribute
task.delay(0.1, function()
	local ws = player:GetAttribute("NBT_walkSpeed") or 25
	if humanoid then humanoid.WalkSpeed = ws end
end)

-- Done — paste and test. If mobile fly feels too slow or too floaty, tell me and I will tweak damping/vertical scale.local flySpeed = player:GetAttribute("NBT_flySpeed") or 80
local killEnabled = player:GetAttribute("NBT_killEnabled")
local auraRadius = player:GetAttribute("NBT_auraRadius") or 100

-- ---------- GUI root ----------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NastyGBT_AdminBox"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game.CoreGui

-- small open button
local OpenBtn = Instance.new("TextButton", ScreenGui)
OpenBtn.Size = UDim2.new(0,60,0,60)
OpenBtn.Position = UDim2.new(0,20,0.5,-30)
OpenBtn.Text = "Walk"
OpenBtn.Font = Enum.Font.GothamBold
OpenBtn.TextSize = 18
OpenBtn.BackgroundColor3 = Color3.fromRGB(6, 130, 230)
OpenBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(1,0)

-- main frame (transparent blue)
local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0,420,0,520)
Frame.Position = UDim2.new(0.5,-210,0.5,-260)
Frame.BackgroundColor3 = Color3.fromRGB(12, 95, 180) -- blue tint
Frame.BackgroundTransparency = 0.55 -- see-through
Frame.Active = true
Frame.Draggable = true
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0,12)
Frame.Visible = false

-- Titlebar
local TitleBar = Instance.new("Frame", Frame)
TitleBar.Size = UDim2.new(1,0,0,36)
TitleBar.Position = UDim2.new(0,0,0,0)
TitleBar.BackgroundColor3 = Color3.fromRGB(10,80,155)
TitleBar.BackgroundTransparency = 0.45
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0,12)

local TitleText = Instance.new("TextLabel", TitleBar)
TitleText.Text = "⚙️ Admin Box"
TitleText.Size = UDim2.new(1,-120,1,0)
TitleText.Position = UDim2.new(0,12,0,0)
TitleText.BackgroundTransparency = 1
TitleText.TextColor3 = Color3.new(1,1,1)
TitleText.Font = Enum.Font.GothamBold
TitleText.TextSize = 16
TitleText.TextXAlignment = Enum.TextXAlignment.Left

local MinBtn = Instance.new("TextButton", TitleBar)
MinBtn.Text = "-"
MinBtn.Size = UDim2.new(0,34,0,30)
MinBtn.Position = UDim2.new(1,-124,0,3)
MinBtn.BackgroundColor3 = Color3.fromRGB(8,70,140)
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0,6)

local CloseBtn = Instance.new("TextButton", TitleBar)
CloseBtn.Text = "X"
CloseBtn.Size = UDim2.new(0,34,0,30)
CloseBtn.Position = UDim2.new(1,-74,0,3)
CloseBtn.BackgroundColor3 = Color3.fromRGB(12,90,170)
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0,6)

-- Footer
local Footer = Instance.new("TextLabel", Frame)
Footer.Text = "Created by Nasty GBT 😎"
Footer.Size = UDim2.new(1,-14,0,24)
Footer.Position = UDim2.new(0,7,1,-32)
Footer.BackgroundTransparency = 0.5
Footer.TextColor3 = Color3.fromRGB(180,235,255)
Footer.Font = Enum.Font.GothamBold
Footer.TextSize = 14
Instance.new("UICorner", Footer).CornerRadius = UDim.new(0,8)

-- convenience layout variables
local leftX = 14

-- ---------------- WalkSpeed Section ----------------
local WalkLabel = Instance.new("TextLabel", Frame)
WalkLabel.Text = "WalkSpeed"
WalkLabel.Size = UDim2.new(0,140,0,22)
WalkLabel.Position = UDim2.new(0,leftX,0,54)
WalkLabel.BackgroundTransparency = 1
WalkLabel.TextColor3 = Color3.fromRGB(230,250,255)
WalkLabel.Font = Enum.Font.Gotham
WalkLabel.TextSize = 14
WalkLabel.TextXAlignment = Enum.TextXAlignment.Left

local speeds = {25,30,50,100}
local speedButtons = {}
for i, speed in ipairs(speeds) do
	local btn = Instance.new("TextButton", Frame)
	btn.Size = UDim2.new(0,86,0,34)
	btn.Position = UDim2.new(0,leftX + (i-1)*92,0,82)
	btn.Text = tostring(speed)
	btn.Font = Enum.Font.Gotham
	btn.TextSize = 14
	btn.BackgroundColor3 = Color3.fromRGB(22,60,120)
	btn.TextColor3 = Color3.fromRGB(220,245,255)
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)
	speedButtons[tostring(speed)] = btn
	btn.MouseButton1Click:Connect(function()
		player:SetAttribute("NBT_walkSpeed", speed)
		if humanoid then humanoid.WalkSpeed = speed end
		updateButtonStates()
	end)
end

-- ---------------- Noclip ----------------
local NoclipBtn = Instance.new("TextButton", Frame)
NoclipBtn.Size = UDim2.new(0,170,0,34)
NoclipBtn.Position = UDim2.new(0,leftX,0,132)
NoclipBtn.Text = "Noclip: OFF"
NoclipBtn.Font = Enum.Font.Gotham
NoclipBtn.TextSize = 14
NoclipBtn.BackgroundColor3 = Color3.fromRGB(150,40,40)
NoclipBtn.TextColor3 = Color3.fromRGB(230,245,255)
Instance.new("UICorner", NoclipBtn).CornerRadius = UDim.new(0,8)
NoclipBtn.MouseButton1Click:Connect(function()
	noclip = not noclip
	player:SetAttribute("NBT_noclip", noclip)
	updateButtonStates()
end)

RunService.Stepped:Connect(function()
	if noclip and character then
		for _, p in pairs(character:GetDescendants()) do
			if p:IsA("BasePart") then p.CanCollide = false end
		end
	end
end)

-- ---------------- Infinite Jump ----------------
local JumpBtn = Instance.new("TextButton", Frame)
JumpBtn.Size = UDim2.new(0,260,0,34)
JumpBtn.Position = UDim2.new(0,leftX,0,182)
JumpBtn.Text = "Infinite Jump: OFF"
JumpBtn.Font = Enum.Font.Gotham
JumpBtn.TextSize = 14
JumpBtn.BackgroundColor3 = Color3.fromRGB(150,40,40)
JumpBtn.TextColor3 = Color3.fromRGB(230,245,255)
Instance.new("UICorner", JumpBtn).CornerRadius = UDim.new(0,8)
JumpBtn.MouseButton1Click:Connect(function()
	infJump = not infJump
	player:SetAttribute("NBT_infJump", infJump)
	updateButtonStates()
end)

local jumpConn
if not jumpConn then
	jumpConn = UserInputService.JumpRequest:Connect(function()
		if infJump and humanoid then humanoid:ChangeState("Jumping") end
	end)
end

-- ---------------- Fly Section ----------------
local FlyBtn = Instance.new("TextButton", Frame)
FlyBtn.Size = UDim2.new(0,170,0,34)
FlyBtn.Position = UDim2.new(0,leftX,0,232)
FlyBtn.Text = "Fly: OFF"
FlyBtn.Font = Enum.Font.Gotham
FlyBtn.TextSize = 14
FlyBtn.BackgroundColor3 = Color3.fromRGB(150,40,40)
FlyBtn.TextColor3 = Color3.fromRGB(230,245,255)
Instance.new("UICorner", FlyBtn).CornerRadius = UDim.new(0,8)

-- Fly speed buttons (50,100,200)
local fSpeeds = {50,100,200}
local fButtons = {}
for i, fs in ipairs(fSpeeds) do
	local b = Instance.new("TextButton", Frame)
	b.Size = UDim2.new(0,86,0,30)
	b.Position = UDim2.new(0,leftX + (i-1)*92,0,274)
	b.Text = tostring(fs)
	b.Font = Enum.Font.Gotham
	b.TextSize = 14
	b.BackgroundColor3 = Color3.fromRGB(22,60,120)
	b.TextColor3 = Color3.fromRGB(220,245,255)
	Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)
	fButtons[tostring(fs)] = b
	b.MouseButton1Click:Connect(function()
		flySpeed = fs
		player:SetAttribute("NBT_flySpeed", flySpeed)
		updateButtonStates()
	end)
end

-- fly controllers
local bodyGyro, bodyVel, flyConnection
FlyBtn.MouseButton1Click:Connect(function()
	flying = not flying
	player:SetAttribute("NBT_flying", flying)
	if flying then
		-- try create controllers
		if character and character.PrimaryPart then
			if bodyGyro then bodyGyro:Destroy() end
			if bodyVel then bodyVel:Destroy() end
			bodyGyro = Instance.new("BodyGyro", character.PrimaryPart)
			bodyGyro.MaxTorque = Vector3.new(9e9,9e9,9e9)
			bodyGyro.P = 10000
			bodyVel = Instance.new("BodyVelocity", character.PrimaryPart)
			bodyVel.MaxForce = Vector3.new(9e9,9e9,9e9)
			bodyVel.Velocity = Vector3.new(0,0,0)
		end
		if not flyConnection then
			flyConnection = RunService.RenderStepped:Connect(function()
				if flying and character and character.PrimaryPart and bodyGyro and bodyVel then
					bodyGyro.CFrame = workspace.CurrentCamera.CFrame
					local move = Vector3.new()
					if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + workspace.CurrentCamera.CFrame.LookVector end
					if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - workspace.CurrentCamera.CFrame.LookVector end
					if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - workspace.CurrentCamera.CFrame.RightVector end
					if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + workspace.CurrentCamera.CFrame.RightVector end
					if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0,1,0) end
					if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move = move - Vector3.new(0,1,0) end
					if move.Magnitude > 0 then bodyVel.Velocity = move.Unit * flySpeed else bodyVel.Velocity = Vector3.new(0,0,0) end
				end
			end)
		end
	else
		if flyConnection then flyConnection:Disconnect(); flyConnection=nil end
		if bodyGyro then bodyGyro:Destroy(); bodyGyro=nil end
		if bodyVel then bodyVel:Destroy(); bodyVel=nil end
	end
	updateButtonStates()
end)

-- ---------------- Kill Aura Section ----------------
local KillLabel = Instance.new("TextLabel", Frame)
KillLabel.Text = "Kill Aura (NPCs only)"
KillLabel.Size = UDim2.new(0,260,0,20)
KillLabel.Position = UDim2.new(0,leftX,0,322)
KillLabel.BackgroundTransparency = 1
KillLabel.TextColor3 = Color3.fromRGB(230,250,255)
KillLabel.Font = Enum.Font.Gotham
KillLabel.TextSize = 14
KillLabel.TextXAlignment = Enum.TextXAlignment.Left

local KillBtn = Instance.new("TextButton", Frame)
KillBtn.Size = UDim2.new(0,140,0,36)
KillBtn.Position = UDim2.new(0,leftX,0,348)
KillBtn.Text = "Kill: OFF"
KillBtn.Font = Enum.Font.Gotham
KillBtn.TextSize = 14
KillBtn.BackgroundColor3 = Color3.fromRGB(150,40,40)
KillBtn.TextColor3 = Color3.fromRGB(230,245,255)
Instance.new("UICorner", KillBtn).CornerRadius = UDim.new(0,8)

local RadiusLabel = Instance.new("TextLabel", Frame)
RadiusLabel.Text = "Radius: " .. tostring(auraRadius)
RadiusLabel.Size = UDim2.new(0,180,0,20)
RadiusLabel.Position = UDim2.new(0,leftX+154,0,354)
RadiusLabel.BackgroundTransparency = 1
RadiusLabel.TextColor3 = Color3.fromRGB(200,230,255)
RadiusLabel.Font = Enum.Font.Gotham
RadiusLabel.TextSize = 14
RadiusLabel.TextXAlignment = Enum.TextXAlignment.Left

-- slider UI
local SliderBg = Instance.new("Frame", Frame)
SliderBg.Size = UDim2.new(0,260,0,16)
SliderBg.Position = UDim2.new(0,leftX,0,390)
SliderBg.BackgroundColor3 = Color3.fromRGB(25,60,110)
Instance.new("UICorner", SliderBg).CornerRadius = UDim.new(0,8)

local SliderFill = Instance.new("Frame", SliderBg)
local sliderWidth = 260
local initPct = (auraRadius / 300)
SliderFill.Size = UDim2.new(0, math.floor(initPct * sliderWidth), 1, 0)
SliderFill.BackgroundColor3 = Color3.fromRGB(6,180,255)
Instance.new("UICorner", SliderFill).CornerRadius = UDim.new(0,8)

local Knob = Instance.new("TextButton", SliderBg)
Knob.Size = UDim2.new(0,20,0,20)
Knob.Position = UDim2.new(0, math.clamp(initPct*sliderWidth - 10, 0, sliderWidth-10), -0.125, 0)
Knob.BackgroundColor3 = Color3.fromRGB(235,240,245)
Knob.Text = ""
Instance.new("UICorner", Knob).CornerRadius = UDim.new(1,0)
Knob.AutoButtonColor = false

-- ring visual
local ringPart = nil
local function ensureRing()
	if not character or not character.PrimaryPart then return end
	if not ringPart then
		ringPart = Instance.new("Part")
		ringPart.Name = "NastyKillRing"
		ringPart.Anchored = true
		ringPart.CanCollide = false
		ringPart.Transparency = 0.7
		ringPart.Size = Vector3.new(2,0.4,2)
		ringPart.Material = Enum.Material.Neon
		ringPart.Color = Color3.fromRGB(200,50,50)
		ringPart.Parent = workspace
	end
	local diameter = math.clamp(auraRadius, 2, 300) * 2
	ringPart.Size = Vector3.new(diameter, 0.4, diameter)
end
ensureRing()

RunService.RenderStepped:Connect(function()
	if ringPart and character and character.PrimaryPart then
		local pos = character.PrimaryPart.Position
		ringPart.CFrame = CFrame.new(pos.X, pos.Y - (character.PrimaryPart.Size.Y/2) + 0.3, pos.Z)
		if killEnabled then ringPart.Color = Color3.fromRGB(0,220,120) else ringPart.Color = Color3.fromRGB(200,50,50) end
	end
end)

-- slider logic
local dragging = false
local function updateSliderFromX(x)
	local absX = math.clamp(x - SliderBg.AbsolutePosition.X, 0, sliderWidth)
	local pct = absX / sliderWidth
	auraRadius = math.max(1, math.floor(pct * 300))
	player:SetAttribute("NBT_auraRadius", auraRadius)
	SliderFill.Size = UDim2.new(0, math.floor(pct * sliderWidth), 1, 0)
	Knob.Position = UDim2.new(0, math.floor(pct * sliderWidth) - 10, -0.125, 0)
	RadiusLabel.Text = "Radius: " .. tostring(auraRadius)
	ensureRing()
end

Knob.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true end
end)
UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
end)
UserInputService.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then updateSliderFromX(input.Position.X) end
end)
SliderBg.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		updateSliderFromX(input.Position.X); dragging = true
	end
end)

KillBtn.MouseButton1Click:Connect(function()
	killEnabled = not killEnabled
	player:SetAttribute("NBT_killEnabled", killEnabled)
	if killEnabled then KillBtn.BackgroundColor3 = Color3.fromRGB(0,160,0); KillBtn.Text = "Kill: ON"
	else KillBtn.BackgroundColor3 = Color3.fromRGB(150,40,40); KillBtn.Text = "Kill: OFF" end
end)

-- helper: find tool held
local function getHeldTool()
	if not character then return nil end
	for _, c in pairs(character:GetChildren()) do
		if c:IsA("Tool") then return c end
	end
	return nil
end

-- scanning loop (kill aura)
spawn(function()
	local last = 0
	local scanInterval = 0.16
	while ScreenGui.Parent do
		local now = tick()
		if now - last >= scanInterval then
			last = now
			if killEnabled and character and character.PrimaryPart then
				local held = getHeldTool()
				if held then
					local origin = character.PrimaryPart.Position
					for _, obj in pairs(workspace:GetDescendants()) do
						if obj:IsA("Model") then
							local hum = obj:FindFirstChildOfClass("Humanoid")
							if hum and hum.Health > 0 then
								local pl = Players:GetPlayerFromCharacter(obj)
								if pl == nil then -- NPC only
									local part = obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart
									if part then
										local dist = (part.Position - origin).Magnitude
										if dist <= auraRadius then
											local damage = 40
											local dmgVal = held:FindFirstChild("Damage") or held:FindFirstChildWhichIsA("NumberValue")
											if dmgVal and tonumber(dmgVal.Value) then damage = tonumber(dmgVal.Value) end
											local attr = held.GetAttribute and held:GetAttribute("Damage")
											if type(attr) == "number" then damage = attr end
											if hum.Health > 0 then pcall(function() hum:TakeDamage(damage) end) end
										end
									end
								end
							end
						end
					end
				end
			end
		end
		task.wait(0.06)
	end
end)

-- ---------- UI state updater ----------
local function updateButtonStates()
	-- WalkSpeed buttons
	local ws = player:GetAttribute("NBT_walkSpeed") or 25
	if humanoid then humanoid.WalkSpeed = ws end
	for s, btn in pairs(speedButtons) do
		if tonumber(s) == ws then btn.BackgroundColor3 = Color3.fromRGB(0,160,0)
		else btn.BackgroundColor3 = Color3.fromRGB(22,60,120) end
	end

	-- noclip
	noclip = player:GetAttribute("NBT_noclip")
	if noclip then NoclipBtn.Text = "Noclip: ON"; NoclipBtn.BackgroundColor3 = Color3.fromRGB(0,160,0)
	else NoclipBtn.Text = "Noclip: OFF"; NoclipBtn.BackgroundColor3 = Color3.fromRGB(150,40,40) end

	-- inf jump
	infJump = player:GetAttribute("NBT_infJump")
	if infJump then JumpBtn.Text = "Infinite Jump: ON"; JumpBtn.BackgroundColor3 = Color3.fromRGB(0,160,0)
	else JumpBtn.Text = "Infinite Jump: OFF"; JumpBtn.BackgroundColor3 = Color3.fromRGB(150,40,40) end

	-- fly
	flying = player:GetAttribute("NBT_flying")
	flySpeed = player:GetAttribute("NBT_flySpeed") or flySpeed
	if flying then FlyBtn.Text = "Fly: ON"; FlyBtn.BackgroundColor3 = Color3.fromRGB(0,160,0)
	else FlyBtn.Text = "Fly: OFF"; FlyBtn.BackgroundColor3 = Color3.fromRGB(150,40,40) end
	for s, b in pairs(fButtons) do
		if tonumber(s) == flySpeed then b.BackgroundColor3 = Color3.fromRGB(0,160,0) else b.BackgroundColor3 = Color3.fromRGB(22,60,120) end
	end

	-- kill
	killEnabled = player:GetAttribute("NBT_killEnabled")
	if killEnabled then KillBtn.Text = "Kill: ON"; KillBtn.BackgroundColor3 = Color3.fromRGB(0,160,0)
	else KillBtn.Text = "Kill: OFF"; KillBtn.BackgroundColor3 = Color3.fromRGB(150,40,40) end

	-- radius visuals
	auraRadius = player:GetAttribute("NBT_auraRadius") or auraRadius
	RadiusLabel.Text = "Radius: " .. tostring(auraRadius)
	ensureRing()
end

-- initial UI state
updateButtonStates()

-- ensure ring visuals initial
SliderFill.Size = UDim2.new(0, math.floor((auraRadius/300) * sliderWidth), 1, 0)
Knob.Position = UDim2.new(0, math.floor((auraRadius/300) * sliderWidth) - 10, -0.125, 0)
ensureRing()

-- reapply walkSpeed on respawn & re-create fly controllers if needed
player.CharacterAdded:Connect(function(char)
	task.wait(0.06)
	setCharacterRefs(char)
	-- reapply walk speed
	local ws = player:GetAttribute("NBT_walkSpeed") or 25
	if humanoid then humanoid.WalkSpeed = ws end
	-- attempt re-create fly controllers if flying is true
	if player:GetAttribute("NBT_flying") then
		-- cleanup old
		if bodyGyro then bodyGyro:Destroy(); bodyGyro=nil end
		if bodyVel then bodyVel:Destroy(); bodyVel=nil end
		-- create new when PrimaryPart available
		if character and character.PrimaryPart then
			bodyGyro = Instance.new("BodyGyro", character.PrimaryPart)
			bodyGyro.MaxTorque = Vector3.new(9e9,9e9,9e9)
			bodyGyro.P = 10000
			bodyVel = Instance.new("BodyVelocity", character.PrimaryPart)
			bodyVel.MaxForce = Vector3.new(9e9,9e9,9e9)
		end
	end
	task.delay(0.12, updateButtonStates)
end)

-- Open / Min / Close
OpenBtn.MouseButton1Click:Connect(function() Frame.Visible = true end)
MinBtn.MouseButton1Click:Connect(function() Frame.Visible = false end)
CloseBtn.MouseButton1Click:Connect(function()
	if ringPart then ringPart:Destroy(); ringPart = nil end
	ScreenGui:Destroy()
end)

-- update UI regularly lightly
RunService.Heartbeat:Connect(function() updateButtonStates() end)metleBar.Size = UDim2.new(1, 0, 0, 30)
TitleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 12)

-- Title Text
local Title = Instance.new("TextLabel", TitleBar)
Title.Text = "Player Menu"
Title.Size = UDim2.new(1, -60, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.TextColor3 = Color3.new(1, 1, 1)
Title.BackgroundTransparency = 1
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16

-- Minimize Button
local MinBtn = Instance.new("TextButton", TitleBar)
MinBtn.Text = "-"
MinBtn.Size = UDim2.new(0, 25, 0, 25)
MinBtn.Position = UDim2.new(1, -55, 0, 2)
MinBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 0)
MinBtn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 8)

-- Close Button
local CloseBtn = Instance.new("TextButton", TitleBar)
CloseBtn.Text = "X"
CloseBtn.Size = UDim2.new(0, 25, 0, 25)
CloseBtn.Position = UDim2.new(1, -28, 0, 2)
CloseBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
CloseBtn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 8)

-- WalkSpeed Buttons
local speeds = {25, 50, 100}
for i, speed in ipairs(speeds) do
	local btn = Instance.new("TextButton", Frame)
	btn.Size = UDim2.new(0, 70, 0, 25)
	btn.Position = UDim2.new(0, 10 + (i - 1) * 80, 0, 50)
	btn.Text = tostring(speed)
	btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Font = Enum.Font.Gotham
	btn.TextSize = 14
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
	btn.MouseButton1Click:Connect(function()
		humanoid.WalkSpeed = speed
	end)
end

-- Noclip Button
local noclip = false
local NoclipBtn = Instance.new("TextButton", Frame)
NoclipBtn.Size = UDim2.new(0, 110, 0, 30)
NoclipBtn.Position = UDim2.new(0, 10, 0, 90)
NoclipBtn.Text = "Noclip: OFF"
NoclipBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
NoclipBtn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", NoclipBtn).CornerRadius = UDim.new(0, 6)

NoclipBtn.MouseButton1Click:Connect(function()
	noclip = not noclip
	if noclip then
		NoclipBtn.Text = "Noclip: ON"
		NoclipBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
	else
		NoclipBtn.Text = "Noclip: OFF"
		NoclipBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
	end
end)

game:GetService("RunService").Stepped:Connect(function()
	if noclip then
		for _, part in pairs(character:GetDescendants()) do
			if part:IsA("BasePart") then
				part.CanCollide = false
			end
		end
	end
end)

-- Infinite Jump Button
local infJump = false
local JumpBtn = Instance.new("TextButton", Frame)
JumpBtn.Size = UDim2.new(0, 150, 0, 30)
JumpBtn.Position = UDim2.new(0, 10, 0, 130)
JumpBtn.Text = "Infinite Jump: OFF"
JumpBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
JumpBtn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", JumpBtn).CornerRadius = UDim.new(0, 6)

JumpBtn.MouseButton1Click:Connect(function()
	infJump = not infJump
	if infJump then
		JumpBtn.Text = "Infinite Jump: ON"
		JumpBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
	else
		JumpBtn.Text = "Infinite Jump: OFF"
		JumpBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
	end
end)

game:GetService("UserInputService").JumpRequest:Connect(function()
	if infJump then
		humanoid:ChangeState("Jumping")
	end
end)

-- Footer text
local Footer = Instance.new("TextLabel", Frame)
Footer.Text = "Created by Nasty GBT 😎"
Footer.Size = UDim2.new(1, 0, 0, 20)
Footer.Position = UDim2.new(0, 0, 1, -22)
Footer.BackgroundTransparency = 1
Footer.TextColor3 = Color3.fromRGB(0, 170, 255)
Footer.Font = Enum.Font.GothamBold
Footer.TextSize = 14

-- Button Functions
OpenBtn.MouseButton1Click:Connect(function()
	Frame.Visible = true
end)

MinBtn.MouseButton1Click:Connect(function()
	Frame.Visible = false
end)

CloseBtn.MouseButton1Click:Connect(function()
	ScreenGui:Destroy()
end)
