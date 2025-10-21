-- ⚙️ Admin Box GUI (Compact + Respawn Safe + Instant Prompt + Anti-AFK)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local player = Players.LocalPlayer

-- Create GUI
local function createGui()
	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:WaitForChild("Humanoid")

	local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
	local Frame = Instance.new("Frame", ScreenGui)
	Frame.Size = UDim2.new(0, 190, 0, 250)
	Frame.Position = UDim2.new(0.85, 0, 0.4, 0)
	Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	Frame.Active = true
	Frame.Draggable = true
	Frame.BorderSizePixel = 0

	local Title = Instance.new("TextLabel", Frame)
	Title.Size = UDim2.new(1, 0, 0, 25)
	Title.Text = "Admin Box 😎"
	Title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	Title.TextColor3 = Color3.new(1, 1, 1)
	Title.Font = Enum.Font.GothamBold
	Title.TextSize = 16

	-- WalkSpeed Buttons
	local speeds = {25, 50, 100}
	for i, speed in ipairs(speeds) do
		local btn = Instance.new("TextButton", Frame)
		btn.Size = UDim2.new(0, 50, 0, 22)
		btn.Position = UDim2.new(0, 10 + (i - 1) * 55, 0, 35)
		btn.Text = tostring(speed)
		btn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
		btn.TextColor3 = Color3.new(1, 1, 1)
		btn.Font = Enum.Font.Gotham
		btn.TextSize = 14
		btn.MouseButton1Click:Connect(function()
			humanoid.WalkSpeed = speed
		end)
	end

	-- 🧱 Noclip
	local noclip = false
	local NoclipBtn = Instance.new("TextButton", Frame)
	NoclipBtn.Size = UDim2.new(0, 150, 0, 28)
	NoclipBtn.Position = UDim2.new(0, 10, 0, 70)
	NoclipBtn.Text = "Noclip: OFF"
	NoclipBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
	NoclipBtn.TextColor3 = Color3.new(1, 1, 1)
	NoclipBtn.Font = Enum.Font.Gotham
	NoclipBtn.TextSize = 14

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

	RunService.Stepped:Connect(function()
		if noclip and character then
			for _, part in pairs(character:GetDescendants()) do
				if part:IsA("BasePart") then
					part.CanCollide = false
				end
			end
		end
	end)

	-- 🦘 Infinite Jump
	local infJump = false
	local JumpBtn = Instance.new("TextButton", Frame)
	JumpBtn.Size = UDim2.new(0, 150, 0, 28)
	JumpBtn.Position = UDim2.new(0, 10, 0, 105)
	JumpBtn.Text = "Infinite Jump: OFF"
	JumpBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
	JumpBtn.TextColor3 = Color3.new(1, 1, 1)
	JumpBtn.Font = Enum.Font.Gotham
	JumpBtn.TextSize = 14

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
		if infJump and humanoid then
			humanoid:ChangeState("Jumping")
		end
	end)

	-- ⚡ Instant Prompt
	local instantPrompt = false
	local InstantBtn = Instance.new("TextButton", Frame)
	InstantBtn.Size = UDim2.new(0, 150, 0, 28)
	InstantBtn.Position = UDim2.new(0, 10, 0, 140)
	InstantBtn.Text = "Instant Prompt: OFF"
	InstantBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
	InstantBtn.TextColor3 = Color3.new(1, 1, 1)
	InstantBtn.Font = Enum.Font.Gotham
	InstantBtn.TextSize = 14

	InstantBtn.MouseButton1Click:Connect(function()
		instantPrompt = not instantPrompt
		if instantPrompt then
			InstantBtn.Text = "Instant Prompt: ON"
			InstantBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
			for _, prompt in pairs(workspace:GetDescendants()) do
				if prompt:IsA("ProximityPrompt") then
					prompt.HoldDuration = 0
				end
			end
			workspace.DescendantAdded:Connect(function(obj)
				if instantPrompt and obj:IsA("ProximityPrompt") then
					obj.HoldDuration = 0
				end
			end)
		else
			InstantBtn.Text = "Instant Prompt: OFF"
			InstantBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
			for _, prompt in pairs(workspace:GetDescendants()) do
				if prompt:IsA("ProximityPrompt") then
					prompt.HoldDuration = 0.5
				end
			end
		end
	end)

	-- 💤 Anti-AFK
	local antiAFK = false
	local AFKBtn = Instance.new("TextButton", Frame)
	AFKBtn.Size = UDim2.new(0, 150, 0, 28)
	AFKBtn.Position = UDim2.new(0, 10, 0, 175)
	AFKBtn.Text = "Anti-AFK: OFF"
	AFKBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
	AFKBtn.TextColor3 = Color3.new(1, 1, 1)
	AFKBtn.Font = Enum.Font.Gotham
	AFKBtn.TextSize = 14

	local afkConnection
	AFKBtn.MouseButton1Click:Connect(function()
		antiAFK = not antiAFK
		if antiAFK then
			AFKBtn.Text = "Anti-AFK: ON"
			AFKBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
			afkConnection = player.Idled:Connect(function()
				VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
				task.wait(1)
				VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
			end)
		else
			AFKBtn.Text = "Anti-AFK: OFF"
			AFKBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
			if afkConnection then
				afkConnection:Disconnect()
				afkConnection = nil
			end
		end
	end)

	-- 👑 Credit
	local Credit = Instance.new("TextLabel", Frame)
	Credit.Size = UDim2.new(1, 0, 0, 25)
	Credit.Position = UDim2.new(0, 0, 1, -25)
	Credit.Text = "Made by Nasty GBT 😎"
	Credit.TextColor3 = Color3.fromRGB(200, 200, 200)
	Credit.BackgroundTransparency = 1
	Credit.Font = Enum.Font.GothamBold
	Credit.TextSize = 12
end

-- Respawn-safe recreate
player.CharacterAdded:Connect(function()
	wait(1)
	createGui()
end)

createGui()
