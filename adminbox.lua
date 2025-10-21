-- ✅ Player Tools GUI (WalkSpeed, Noclip, Infinite Jump, Instant Prompt, Anti-AFK, Teleport+)
-- Created by Nasty GBT 😎

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- Create ScreenGui
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)

-- 🟦 Blue round open button
local OpenBtn = Instance.new("TextButton", ScreenGui)
OpenBtn.Size = UDim2.new(0, 60, 0, 60)
OpenBtn.Position = UDim2.new(0, 20, 0.5, -30)
OpenBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
OpenBtn.Text = "Tools"
OpenBtn.TextColor3 = Color3.new(1, 1, 1)
OpenBtn.Font = Enum.Font.GothamBold
OpenBtn.TextSize = 18
OpenBtn.AutoButtonColor = true
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(1, 0)

-- 📦 Main Frame
local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 280, 0, 280)
Frame.Position = UDim2.new(0.5, -140, 0.5, -140)
Frame.BackgroundColor3 = Color3.fromRGB(35, 40, 50)
Frame.Visible = false
Frame.Active = true
Frame.Draggable = true
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 12)

-- Title Bar
local TitleBar = Instance.new("Frame", Frame)
TitleBar.Size = UDim2.new(1, 0, 0, 30)
TitleBar.BackgroundColor3 = Color3.fromRGB(50, 55, 65)
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 12)

local Title = Instance.new("TextLabel", TitleBar)
Title.Text = "Player Tools"
Title.Size = UDim2.new(1, -60, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.TextColor3 = Color3.new(1, 1, 1)
Title.BackgroundTransparency = 1
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16

-- Minimize (-)
local MinBtn = Instance.new("TextButton", TitleBar)
MinBtn.Text = "-"
MinBtn.Size = UDim2.new(0, 25, 0, 25)
MinBtn.Position = UDim2.new(1, -55, 0, 2)
MinBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 0)
MinBtn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 8)

-- Close (X)
local CloseBtn = Instance.new("TextButton", TitleBar)
CloseBtn.Text = "X"
CloseBtn.Size = UDim2.new(0, 25, 0, 25)
CloseBtn.Position = UDim2.new(1, -28, 0, 2)
CloseBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
CloseBtn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 8)

-- === Player Tools ===
-- WalkSpeed
local speeds = {25, 50, 100}
for i, speed in ipairs(speeds) do
	local btn = Instance.new("TextButton", Frame)
	btn.Size = UDim2.new(0, 70, 0, 25)
	btn.Position = UDim2.new(0, 10 + (i - 1) * 90, 0, 40)
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

-- Noclip
local noclip = false
local NoclipBtn = Instance.new("TextButton", Frame)
NoclipBtn.Size = UDim2.new(0, 110, 0, 30)
NoclipBtn.Position = UDim2.new(0, 10, 0, 80)
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
	if noclip and character then
		for _, part in pairs(character:GetDescendants()) do
			if part:IsA("BasePart") then
				part.CanCollide = false
			end
		end
	end
end)

-- Infinite Jump
local infJump = false
local JumpBtn = Instance.new("TextButton", Frame)
JumpBtn.Size = UDim2.new(0, 150, 0, 30)
JumpBtn.Position = UDim2.new(0, 10, 0, 120)
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

-- Instant Prompt
local instant = false
local InstantBtn = Instance.new("TextButton", Frame)
InstantBtn.Size = UDim2.new(0, 150, 0, 30)
InstantBtn.Position = UDim2.new(0, 10, 0, 160)
InstantBtn.Text = "Instant Prompt: OFF"
InstantBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
InstantBtn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", InstantBtn).CornerRadius = UDim.new(0, 6)

InstantBtn.MouseButton1Click:Connect(function()
	instant = not instant
	if instant then
		InstantBtn.Text = "Instant Prompt: ON"
		InstantBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
		for _, v in pairs(workspace:GetDescendants()) do
			if v:IsA("ProximityPrompt") then
				v.HoldDuration = 0
			end
		end
	else
		InstantBtn.Text = "Instant Prompt: OFF"
		InstantBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
		for _, v in pairs(workspace:GetDescendants()) do
			if v:IsA("ProximityPrompt") then
				v.HoldDuration = 1
			end
		end
	end
end)

-- Anti-AFK
local AntiAfk = false
local AfkBtn = Instance.new("TextButton", Frame)
AfkBtn.Size = UDim2.new(0, 120, 0, 30)
AfkBtn.Position = UDim2.new(0, 10, 0, 200)
AfkBtn.Text = "Anti-AFK: OFF"
AfkBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
AfkBtn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", AfkBtn).CornerRadius = UDim.new(0, 6)

AfkBtn.MouseButton1Click:Connect(function()
	AntiAfk = not AntiAfk
	if AntiAfk then
		AfkBtn.Text = "Anti-AFK: ON"
		AfkBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
		task.spawn(function()
			while AntiAfk do
				game:GetService("VirtualUser"):Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
				task.wait(30)
			end
		end)
	else
		AfkBtn.Text = "Anti-AFK: OFF"
		AfkBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
	end
end)

-- Teleport+
local places = {}
for i = 1, 3 do
	local SaveBtn = Instance.new("TextButton", Frame)
	SaveBtn.Size = UDim2.new(0, 120, 0, 25)
	SaveBtn.Position = UDim2.new(0, 150, 0, 40 + (i - 1) * 50)
	SaveBtn.Text = "Save Place " .. i
	SaveBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	SaveBtn.TextColor3 = Color3.new(1, 1, 1)
	Instance.new("UICorner", SaveBtn).CornerRadius = UDim.new(0, 6)

	local PlaceBtn = Instance.new("TextButton", Frame)
	PlaceBtn.Size = UDim2.new(0, 120, 0, 25)
	PlaceBtn.Position = UDim2.new(0, 150, 0, 65 + (i - 1) * 50)
	PlaceBtn.Text = "Place " .. i
	PlaceBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
	PlaceBtn.TextColor3 = Color3.new(1, 1, 1)
	Instance.new("UICorner", PlaceBtn).CornerRadius = UDim.new(0, 6)

	SaveBtn.MouseButton1Click:Connect(function()
		if character:FindFirstChild("HumanoidRootPart") then
			places[i] = character.HumanoidRootPart.CFrame
			SaveBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
			task.wait(0.3)
			SaveBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
		end
	end)

	PlaceBtn.MouseButton1Click:Connect(function()
		if places[i] then
			character:MoveTo(places[i].Position)
		end
	end)
end

-- Button actions
OpenBtn.MouseButton1Click:Connect(function()
	Frame.Visible = true
end)
MinBtn.MouseButton1Click:Connect(function()
	Frame.Visible = false
end)
CloseBtn.MouseButton1Click:Connect(function()
	ScreenGui:Destroy()
end)
