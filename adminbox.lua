-- ✅ Simple Admin Box GUI with Open/Close buttons (WalkSpeed, Noclip, Infinite Jump)
-- ⚙️ Created by Nasty GBT 😎

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- Create ScreenGui
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)

-- 🟢 Create open button (always visible)
local OpenBtn = Instance.new("TextButton", ScreenGui)
OpenBtn.Size = UDim2.new(0, 60, 0, 60)
OpenBtn.Position = UDim2.new(0, 20, 0.5, -30)
OpenBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
OpenBtn.Text = "Walk"
OpenBtn.TextColor3 = Color3.new(1, 1, 1)
OpenBtn.Font = Enum.Font.GothamBold
OpenBtn.TextSize = 18
OpenBtn.AutoButtonColor = true

local UICorner = Instance.new("UICorner", OpenBtn)
UICorner.CornerRadius = UDim.new(1, 0)

-- Main Frame (hidden at start)
local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 260, 0, 240)
Frame.Position = UDim2.new(0.5, -130, 0.5, -120)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Frame.Visible = false
Frame.Active = true
Frame.Draggable = true
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 12)

-- Title Bar
local TitleBar = Instance.new("Frame", Frame)
TitleBar.Size = UDim2.new(1, 0, 0, 30)
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
