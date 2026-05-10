local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local VFXEvent = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("VFXEvent")
local RockPart = ReplicatedStorage:WaitForChild("VFX"):WaitForChild("RockPart")

--Sound
local RockImpactPart = ReplicatedStorage:WaitForChild("VFX"):WaitForChild("Sounds"):WaitForChild("RockImpactPart")
local RockSmashPart = ReplicatedStorage:WaitForChild("VFX"):WaitForChild("Sounds"):WaitForChild("RockSmashPart")
local RockPillarPart = ReplicatedStorage:WaitForChild("VFX"):WaitForChild("Sounds"):WaitForChild("RockPillarPart")
local DashSound = ReplicatedStorage:WaitForChild("VFX"):WaitForChild("Sounds"):WaitForChild("DashSound")


local function RockImpact(position, direction, normal)

	local soundPart = RockImpactPart:Clone()

	soundPart.Position = position

	soundPart.Parent = workspace

	local sound = soundPart:WaitForChild("RockImpact")

	sound.PlaybackSpeed = math.random(95,105) / 100

	sound:Play()

	Debris:AddItem(soundPart, 3)


	direction = direction.Unit

	normal = normal.Unit

	for i = 1, 25 do

		local rockPart = RockPart:Clone()

		rockPart.Size = Vector3.new(math.random(3,6)/3, math.random(3,6)/3, math.random(3,6)/3)

		rockPart.Position = position + normal * 0.5
		rockPart.Parent = workspace

		local baseDir = -direction 

		local spread = Vector3.new(math.random(-10,10), math.random(-20,20), math.random(-10,10)) * 0.1

		local finalDirection = (baseDir + spread).Unit

		if finalDirection:Dot(normal) < 0 then

			finalDirection = finalDirection - normal * finalDirection:Dot(normal)

			finalDirection = finalDirection.Unit

		end

		local speed = math.random(30, 40)

		rockPart.AssemblyLinearVelocity = finalDirection * speed

		rockPart.AssemblyAngularVelocity = Vector3.new(math.random(-10,10), math.random(-10,10), math.random(-10,10))

		Debris:AddItem(rockPart, 1.5)
	end
end

function RockSmash(position)

	local soundPart = RockSmashPart:Clone()

	soundPart.Position = position
	soundPart.Parent = workspace

	local sound = soundPart:WaitForChild("RockSmash")

	sound.PlaybackSpeed = math.random(90,110) / 100

	sound:Play()

	Debris:AddItem(soundPart, 3)

	for i = 1, 15 do

		local rockPart = RockPart:Clone()

		rockPart.Size = Vector3.new(math.random(1,2)/3, math.random(1,2)/3, math.random(1,2)/3)

		rockPart.Position = position
		rockPart.Parent = workspace


		local finalDirection = Vector3.new(math.random(-5,5), math.random(10,60), math.random(-5,5)).Unit

		local speed = math.random(20, 50)

		rockPart.AssemblyLinearVelocity = finalDirection * speed

		rockPart.AssemblyAngularVelocity = Vector3.new(
			math.random(-15,15),
			math.random(-15,15),
			math.random(-15,15)
		)

		Debris:AddItem(rockPart, 1.5)
	end


end


local function CameraShake(position, maxDistance, strength, duration)

	local character = player.Character
	if not character then return end

	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then return end

	local distance = (root.Position - position).Magnitude

	if distance > maxDistance then
		return
	end


	local fallOff = 1 - (distance / maxDistance)

	local shakeStrength = strength * fallOff

	local startTime = workspace:GetServerTimeNow()

	local connection
	
	connection = RunService.RenderStepped:Connect(function()

		local elapsed = workspace:GetServerTimeNow() - startTime

		if elapsed >= duration then
			
			connection:Disconnect()
			
			return
				
		end

		local offset = Vector3.new((math.random() - 0.5) * 3, (math.random() - 0.5) * 3, (math.random() - 0.5) * 3) * shakeStrength

		camera.CFrame = camera.CFrame * CFrame.new(offset)
		
	end)
end


VFXEvent.OnClientEvent:Connect(function(effectName, position, direction, normal)

	if effectName == "RockImpact" then

		RockImpact(position, direction, normal)

	end

	if effectName == "RockSmash" then

		RockSmash(position)
		
		CameraShake(position, 70, 0.4, 0.9)

	end

	if effectName == "PillarSound" then

		local soundPart = RockPillarPart:Clone()

		soundPart.Position = position

		soundPart.Parent = workspace

		local sound = soundPart:WaitForChild("RockPillar")

		sound.PlaybackSpeed = math.random(90,110) / 100

		sound:Play()

		Debris:AddItem(soundPart, 3)


	end

	if effectName == "EarthESmash" then
		
		CameraShake(position, 50, 1, 0.1)

		local soundPart = RockPillarPart:Clone()

		soundPart.Position = position

		soundPart.Parent = workspace

		local sound = soundPart:WaitForChild("RockPillar")

		sound.PlaybackSpeed = math.random(90,110) / 100

		sound:Play()

		Debris:AddItem(soundPart, 3)

	end

	if effectName == "Dash" then

		local dashSound = DashSound:Clone()

		dashSound.Parent = workspace
		
		dashSound:Play()

		Debris:AddItem(dashSound, 1)
		

	end

end)
