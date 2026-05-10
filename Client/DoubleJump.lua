local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local AbilityEvent = ReplicatedStorage:WaitForChild("RemoteEvents") :WaitForChild("AbilityEvent")

local flipAnimation = Instance.new("Animation")
flipAnimation.AnimationId = "rbxassetid://126846992927040"


local player = Players.LocalPlayer


local canDoubleJump = false

local hasDoubleJumped = false

local inAnimation = false

local function setupCharacter(character)

	local humanoid = character:WaitForChild("Humanoid")

	local root = character:WaitForChild("HumanoidRootPart")

	local flipTrack = humanoid:LoadAnimation(flipAnimation)

	canDoubleJump = false

	hasDoubleJumped = false

	humanoid.StateChanged:Connect(function(old, new)

		if new == Enum.HumanoidStateType.Landed then

			canDoubleJump = false

			hasDoubleJumped = false

		elseif new == Enum.HumanoidStateType.Freefall then

			canDoubleJump = true

		end

	end)

	UserInputService.InputBegan:Connect(function(input, gameProcessed)

		if gameProcessed then return end

		if input.KeyCode == Enum.KeyCode.Space then

			if canDoubleJump and not hasDoubleJumped and not inAnimation then

				hasDoubleJumped = true


				root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, 70, root.AssemblyLinearVelocity.Z)
				
				flipTrack:Play()
				
				flipTrack:AdjustSpeed(1.5)
			end
		end
	end)
end


if player.Character then
	
	setupCharacter(player.Character)
	
end

player.CharacterAdded:Connect(setupCharacter)

AbilityEvent.OnClientEvent:Connect(function(action)
	
	if action == "InAnimation" then
		
		inAnimation = true
		
	elseif action == "NotInAnimation" then
		
		inAnimation = false
		
	end
	
	
end)
