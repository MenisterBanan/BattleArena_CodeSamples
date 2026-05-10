local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Player = game.Players.LocalPlayer

local AbilityEvent = ReplicatedStorage:WaitForChild("RemoteEvents") :WaitForChild("AbilityEvent")


AbilityEvent.OnClientEvent:Connect(function(action)
	if action == "EarthRAnimation" then

		local EarthRAnimation = Instance.new("Animation")
		EarthRAnimation.AnimationId = "rbxassetid://71524294748903"

		local humanoid = Player.Character:FindFirstChild("Humanoid")
		local animator = humanoid:FindFirstChildOfClass("Animator")
		
		local track = animator:LoadAnimation(EarthRAnimation)
		
		track.Priority = Enum.AnimationPriority.Action

		track:Play()
	end
end)
