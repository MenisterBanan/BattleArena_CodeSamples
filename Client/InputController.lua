local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Player = game.Players.LocalPlayer
local Mouse = Player:GetMouse()

local StarterGui = game:GetService("StarterGui")
repeat task.wait() until game:IsLoaded()
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, false)
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)

local AbilityEvent = ReplicatedStorage:WaitForChild("RemoteEvents") :WaitForChild("AbilityEvent")
local DashRequest = ReplicatedStorage:WaitForChild("RemoteEvents") :WaitForChild("DashRequest")


-- lock input
local inputLocked = false

UserInputService.InputBegan:Connect(function(input, gameProcessed)

	if gameProcessed or inputLocked then return end

	local mousePos = Mouse.Hit.Position

	local Root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")

	if input.KeyCode == Enum.KeyCode.LeftControl then

		print("Pressed Dash")

		DashRequest:FireServer()

	end

	if input.KeyCode == Enum.KeyCode.Q then

		print("Pressed Q")

		AbilityEvent:FireServer("Q", mousePos, Root.CFrame)

	end

	if input.KeyCode == Enum.KeyCode.E then

		print("Pressed E")

		AbilityEvent:FireServer("E", mousePos, Root.CFrame)

	end

	if input.KeyCode == Enum.KeyCode.R then

		print("Pressed R")
		
		AbilityEvent:FireServer("R", mousePos, Root.CFrame)
		
	end


end)


-- disable and unlock movement
local movementLocked = false

AbilityEvent.OnClientEvent:Connect(function(action)

	if action == "LockMovement" then
		
		movementLocked = true
		
		local character = Player.Character
		
		local humanoid = character:FindFirstChild("Humanoid")
		
		humanoid.WalkSpeed = 0
		humanoid.JumpHeight = 0
		humanoid.AutoRotate = false


	elseif action == "UnlockMovement" then
		
		movementLocked = false
		
		local character = Player.Character

		local humanoid = character:FindFirstChild("Humanoid")
		
		humanoid.WalkSpeed = 25
		humanoid.JumpHeight = 10
		humanoid.AutoRotate = true

	end

end)


RunService.RenderStepped:Connect(function()

	if movementLocked then

		local character = Player.Character

		if character then

			local humanoid = character:FindFirstChild("Humanoid")

			if humanoid then

				humanoid:Move(Vector3.zero, true)

			end
		end
	end
end)

-- lock and unlock input

AbilityEvent.OnClientEvent:Connect(function(action)

	if action == "LockInput" then

		inputLocked = true

	elseif action == "UnlockInput" then

		inputLocked = false

	end

end)
