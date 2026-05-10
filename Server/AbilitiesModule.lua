local Abilities = {}
local ServerStorage = game:GetService("ServerStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AbilityEvent = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("AbilityEvent")
local VFXEvent = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("VFXEvent")
local DamageFeedback = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("DamageFeedback")

local AbilityModels = ServerStorage:WaitForChild("AbilityModels")
local RockAbilityModel = AbilityModels:WaitForChild("QRockAbility")
local FireBallAbilityModel = AbilityModels:WaitForChild("QFireBall")
local WaterBallAbilityModel = AbilityModels:WaitForChild("QWaterBall")

local RockAbilityModel = AbilityModels:WaitForChild("QRockAbility")
local RockShieldModel = AbilityModels:WaitForChild("RockShieldAbility")
local DebugPart = ServerStorage:WaitForChild("DebugBox"):WaitForChild("DebugPart")


-- Q Ability Cooldown
local EarthQCooldown = 2
local FireQCooldown = 2
local WaterQCooldown = 2

-- E Ability Cooldown
local EarthECooldown = 9

-- R Ability Cooldown
local EarthRCooldown = 15


-- Q Ability Stats
local ElementQData = {

	Earth = {
		Model = RockAbilityModel,
		Speed = 120,
		Lifetime = 3,
		Damage = 40,
		HitRadius = 4,
		EnvironmentHitRadius = 0.5
	},

	Fire = {
		Model = FireBallAbilityModel,
		Speed = 140,
		Lifetime = 2.5,
		Damage = 40,
		HitRadius = 3,
		EnvironmentHitRadius = 0.3
	},

	Water = {
		Model = WaterBallAbilityModel,
		Speed = 90,
		Lifetime = 3.5,
		Damage = 40,
		HitRadius = 5,
		EnvironmentHitRadius = 1
	}
}

-- Earth E Ability Stats
local EarthEDamage = 50
local EarthERadius = 10


-- Earth R Ability Stats
local EarthRDamage = 60

-- Visuals (Earth E)
local SpikeCount = 40
local SpikeRiseHeight = 2
local SpikeSpawnDepth = -4
local SpikeRiseTime = 0.2
local SpikeFadeTime = 0.3


local cooldowns = {}


Abilities.Earth = {}

-- Helper Functions
local function RemoveMovement(humanoid, root, character)

	humanoid.WalkSpeed = 0
	humanoid.JumpHeight = 0
	humanoid.AutoRotate = false
	root.Anchored = true
	humanoid.PlatformStand = true

end

local function RestoreMovement(humanoid, root, oldWalkSpeed, oldJumpPower, character)

	root.Anchored = false
	humanoid.PlatformStand = false
	humanoid.WalkSpeed = oldWalkSpeed
	humanoid.JumpHeight = oldJumpPower
	humanoid.AutoRotate = true

end

local function SpawnSpikes(position)

	local spikesFolder = ServerStorage:WaitForChild("SpikesVisual")

	for i = 1, SpikeCount do

		local spike = spikesFolder:GetChildren()[math.random(1, #spikesFolder:GetChildren())]:Clone()

		spike.Parent = workspace

		local angle = math.random() * math.pi * 2

		local radius = math.sqrt(math.random()) * EarthERadius

		local offset = Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)

		local groundPos = position + offset

		local rayParams = RaycastParams.new()
		rayParams.FilterType = Enum.RaycastFilterType.Exclude

		local result = workspace:Raycast(groundPos + Vector3.new(0, 10, 0), Vector3.new(0, -20, 0), rayParams)

		if not result then
			continue 
		end

		groundPos = result.Position

		local startPos = groundPos - Vector3.new(0, SpikeSpawnDepth, 0)

		local endPos = groundPos + Vector3.new(0, SpikeRiseHeight, 0)

		local randomRotation = CFrame.Angles(0, math.rad(math.random(0,360)), 0)

		spike:PivotTo(CFrame.new(startPos) * randomRotation)

		local riseTween = TweenService:Create(spike, TweenInfo.new(SpikeRiseTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				CFrame = CFrame.new(endPos) * randomRotation}
		)

		riseTween:Play()

		task.delay(0.5, function()

			local fadeTween = TweenService:Create(spike, TweenInfo.new(0.5),
				{
					Transparency = 1
				}
			)

			fadeTween:Play()

		end)

	end
end

local function QAbilityProjectile(player, character, mousePos, abilityData, clientCFrame)

	local ownerHumanoid = character:WaitForChild("Humanoid")
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then return end

	local clientPosition = clientCFrame.Position

	local direction = (mousePos - clientPosition).Unit

	local projectile = abilityData.Model:Clone()

	projectile.Parent = workspace

	--local debugHitbox = DebugPart:Clone()
	--debugHitbox.Size = Vector3.new(abilityData.HitRadius * 2, abilityData.HitRadius * 2, abilityData.HitRadius * 2)
	--debugHitbox.Parent = workspace

	local position = clientPosition + direction * 3

	projectile:PivotTo(CFrame.new(position))

	local startTime = workspace:GetServerTimeNow()

	local lastPosition = projectile.PrimaryPart.Position

	local hitPlayers = {}

	local connection

	connection = RunService.Heartbeat:Connect(function(dt)

		if workspace:GetServerTimeNow() - startTime > abilityData.Lifetime then

			connection:Disconnect()

			projectile:Destroy()

			--debugHitbox:Destroy()

			return

		end

		local nextPosition = lastPosition + direction * abilityData.Speed * dt


		local playerHits = workspace:GetPartBoundsInRadius(projectile.HitBox.Position, abilityData.HitRadius)

		for _, part in playerHits do

			local targetHumanoid = part.Parent:FindFirstChild("Humanoid")
			if not targetHumanoid or targetHumanoid == ownerHumanoid or targetHumanoid:GetAttribute("Immune") then continue end

			if not hitPlayers[targetHumanoid] then

				hitPlayers[targetHumanoid] = true

				targetHumanoid:TakeDamage(abilityData.Damage)

				DamageFeedback:FireClient(player, targetHumanoid.Parent, abilityData.Damage)
			end
		end

		local environmentHits = workspace:GetPartBoundsInRadius(projectile.HitBox.Position, abilityData.EnvironmentHitRadius)

		for _, part in environmentHits do

			if part:IsDescendantOf(character) then continue end
			if part:IsDescendantOf(projectile) then continue end

			local humanoid = part.Parent:FindFirstChild("Humanoid")

			if not humanoid then

				local rayParams = RaycastParams.new()
				rayParams.FilterDescendantsInstances = {character, projectile}
				rayParams.FilterType = Enum.RaycastFilterType.Exclude

				local rayDirection = nextPosition - lastPosition

				local result = workspace:Raycast(lastPosition, rayDirection, rayParams)

				local impactPosition = nextPosition

				local impactNormal = Vector3.new(0, 1, 0)

				if result then

					impactPosition = result.Position

					impactNormal = result.Normal

				end
				
				if player:GetAttribute("Element") == "Earth" then

					VFXEvent:FireAllClients("RockImpact", impactPosition, direction, impactNormal)
					
				end


				connection:Disconnect()

				projectile:Destroy()

				--debugHitbox:Destroy()

				return
			end
		end

		--debugHitbox.Position = nextPosition

		-- fix no spin on round?
		local rotation = CFrame.Angles(20 * dt, 20 * dt, 20 * dt)

		local currentCFrame = projectile:GetPivot()

		local newCFrame = CFrame.new(nextPosition) * (currentCFrame - currentCFrame.Position) * rotation

		projectile:PivotTo(newCFrame)

		lastPosition = nextPosition

	end)
end

local function SpawnRing(player, character, centerPos, radius, plateCount, riseHeight, riseSpeed, hitPlayers)

	local ownerHumanoid = character:FindFirstChild("Humanoid")

	local RockPlates = AbilityModels:WaitForChild("RockPlates")

	VFXEvent:FireAllClients("PillarSound", centerPos)

	for i = 1, plateCount do

		local RockPlate = RockPlates:GetChildren()[math.random(1, #RockPlates:GetChildren())]:Clone()

		local angle = (i / plateCount) * (2 * math.pi)

		local offset = Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)

		local origin = centerPos + offset + Vector3.new(0, 10, 0)



		--local debugHitbox = DebugPart:Clone()
		--debugHitbox.Shape = Enum.PartType.Block
		--debugHitbox.Parent = workspace
		--debugHitbox.Size = Vector3.new(5, 32, 5)


		local rayParams = RaycastParams.new()

		rayParams.FilterType = Enum.RaycastFilterType.Exclude

		local result = workspace:Raycast(origin, Vector3.new(0, -25, 0), rayParams)

		if result then

			local hitPos = result.Position
			
			local rockPlate = RockPlate:Clone()

			rockPlate.Parent = workspace

			local startPos = hitPos - Vector3.new(0, 15, 0)

			local heightOffset = math.random(-2, 2)

			local targetY = startPos.Y + riseHeight + heightOffset

			task.spawn(function()

				local current = startPos

				-- Up
				while (current.Y < targetY) do

					current += Vector3.new(0, riseSpeed * task.wait(), 0)

					rockPlate:PivotTo(CFrame.new(current))


					--debugHitbox:PivotTo(plate:GetPivot())


					local hits = workspace:GetPartBoundsInBox(rockPlate:GetPivot(), Vector3.new(5, 30, 5))

					for _, part in hits do

						local targetHumanoid = part.Parent:FindFirstChild("Humanoid")
						if not targetHumanoid or targetHumanoid == ownerHumanoid or targetHumanoid:GetAttribute("Immune") then continue end

						if not hitPlayers[targetHumanoid] then 

							hitPlayers[targetHumanoid] = true

							targetHumanoid:TakeDamage(EarthRDamage)

							DamageFeedback:FireClient(player, targetHumanoid.Parent, EarthRDamage)

							print("Hit player", targetHumanoid.Name)

						end
					end

				end

				task.wait(0.2)

				-- Down
				while (current.Y > startPos.Y) do

					current -= Vector3.new(0, (riseSpeed + 40) * task.wait(), 0)

					rockPlate:PivotTo(CFrame.new(current))


					--debugHitbox:PivotTo(plate:GetPivot())


				end

				rockPlate:Destroy()

			end)

		end
	end
end

local function GetGroundPosition(character)
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then return nil end

	local rayParams = RaycastParams.new()

	rayParams.FilterDescendantsInstances = {character}

	rayParams.FilterType = Enum.RaycastFilterType.Exclude

	local result = workspace:Raycast(root.Position, Vector3.new(0, -1000, 0), rayParams)

	return result.Position

end

local function SlamToGround(character, duration)

	local humanoid = character:FindFirstChild("Humanoid")
	local root = character:FindFirstChild("HumanoidRootPart")
	if not humanoid or not root then return end

	local groundPos = GetGroundPosition(character)

	local startPos = root.Position

	local endPos = Vector3.new(startPos.X, groundPos.Y + root.Size.Y, startPos.Z)

	local elapsed = 0

	while elapsed < duration do

		local dt = RunService.Heartbeat:Wait()

		elapsed += dt

		local alpha = math.clamp(elapsed / duration, 0, 1)

		alpha = alpha ^ 4

		local newPos = startPos:Lerp(endPos, alpha)

		local rot = root.CFrame - root.CFrame.Position

		root.CFrame = CFrame.new(newPos) * rot

	end

end

local function IsInAir(character)

	local humanoid = character:FindFirstChild("Humanoid")

	if not humanoid then return false end

	return humanoid.FloorMaterial == Enum.Material.Air

end


--=========================================================================================================

-- Ability Functions
function Abilities.Earth.Q(player, character, mousePos, clientCFrame)

	local ownerHumanoid = character:FindFirstChild("Humanoid")
	local root = character:FindFirstChild("HumanoidRootPart")

	local now = workspace:GetServerTimeNow()

	if cooldowns[player] and cooldowns[player]["Q"] then
		if now - cooldowns[player]["Q"] < EarthQCooldown then
			return
		end
	end

	cooldowns[player] = cooldowns[player] or {}

	cooldowns[player]["Q"] = now

	player:SetAttribute("QCooldownEnd", workspace:GetServerTimeNow() + EarthQCooldown)

	QAbilityProjectile(player, character, mousePos, ElementQData.Earth, clientCFrame)

end

function Abilities.Earth.E(player, character, mousePos, clientCFrame)


	local ownerHumanoid = character:FindFirstChild("Humanoid")
	local root = character:FindFirstChild("HumanoidRootPart")
	local foot = character:FindFirstChild("LeftFoot")
	if not ownerHumanoid or not root or not foot then return end

	local now = workspace:GetServerTimeNow()

	if cooldowns[player] and cooldowns[player]["E"] then
		if now - cooldowns[player]["E"] < EarthECooldown then
			return
		end
	end

	if clientCFrame then
		root.CFrame = clientCFrame
	end

	cooldowns[player] = cooldowns[player] or {}

	cooldowns[player]["E"] = now

	AbilityEvent:FireClient(player, "LockInput")

	AbilityEvent:FireClient(player, "InAnimation")

	player:SetAttribute("ECooldownEnd", workspace:GetServerTimeNow() + EarthECooldown)

	ownerHumanoid:SetAttribute("Immune", true)

	local oldWalkSpeed = ownerHumanoid.WalkSpeed
	local oldJumpPower = ownerHumanoid.JumpHeight

	RemoveMovement(ownerHumanoid, root, character)

	local shield = RockShieldModel:Clone()

	shield.Parent = workspace

	local connection

	connection = RunService.Heartbeat:Connect(function()

		shield:PivotTo(CFrame.new(foot.Position))

	end)

	-- Shield Animation
	for _, part in shield:GetDescendants() do

		if part:IsA("BasePart") then

			part.Transparency = 1

			local originalCFrame = part.CFrame

			local randomOffset = Vector3.new(math.random(-5, 5), math.random(-5, 5), math.random(-5, 5))

			part.CFrame = part.CFrame + randomOffset

			local tween = TweenService:Create(part, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					CFrame = originalCFrame,

					Transparency = 0
				}
			)

			tween:Play()
		end

	end


	task.wait(0.5)

	-- Shield and Player Movement

	local startPos = root.Position

	local upPos = startPos + Vector3.new(0, 20, 0)

	local t = 0

	while t < 1 do

		local dt = RunService.Heartbeat:Wait()

		t += dt * 3

		local pos = startPos:Lerp(upPos, math.clamp(t, 0, 1))

		local rot = root.CFrame - root.CFrame.Position 

		root.CFrame = CFrame.new(pos) * rot

	end


	while true do

		local dt = RunService.Heartbeat:Wait()

		local currentPos = foot.Position

		local rayParams = RaycastParams.new()
		rayParams.FilterDescendantsInstances = {character}
		rayParams.FilterType = Enum.RaycastFilterType.Exclude

		local result = workspace:Raycast(currentPos, Vector3.new(0, -10, 0), rayParams)

		if result then

			local finalPos = Vector3.new(root.Position.X, result.Position.Y + root.Size.Y, root.Position.Z)

			local rotation = root.CFrame - root.CFrame.Position

			root.CFrame = CFrame.new(finalPos) * rotation

			break
		end

		local nextPos = root.Position - Vector3.new(0, 200 * dt, 0)

		local rotation = root.CFrame - root.CFrame.Position

		root.CFrame = CFrame.new(nextPos) * rotation

	end
	
	VFXEvent:FireAllClients("EarthESmash", root.Position)
	
	-- Spike animation
	SpawnSpikes(root.Position)

	--local debugHitbox = DebugPart:Clone()
	--debugHitbox.Size = Vector3.new(EarthERadius * 2, EarthERadius * 2, EarthERadius * 2)
	--debugHitbox.CFrame = CFrame.new(root.Position)
	--debugHitbox.Parent = workspace

	-- Damage dealing
	local hitPlayers = {}

	local hits = workspace:GetPartBoundsInRadius(root.Position, EarthERadius)

	for _, part in hits do

		local targetHumanoid = part.Parent:FindFirstChild("Humanoid")
		if not targetHumanoid or targetHumanoid == ownerHumanoid or targetHumanoid:GetAttribute("Immune") then continue end

		if not hitPlayers[targetHumanoid] then 

			hitPlayers[targetHumanoid] = true

			targetHumanoid:TakeDamage(EarthEDamage)

			DamageFeedback:FireClient(player, targetHumanoid.Parent, EarthEDamage)

			print("Hit player", targetHumanoid.Name)

		end
	end

	--Shield Destroy Animation + attack animation

	task.wait(.5)

	for _, part in shield:GetDescendants() do
		if part:IsA("BasePart") then

			local fadeTween = TweenService:Create(part, TweenInfo.new(0.5),
				{
					Transparency = 1
				}
			)

			fadeTween:Play()
		end
	end

	task.wait(0.5)

	-- cleanup

	shield:Destroy()
	connection:Disconnect()

	RestoreMovement(ownerHumanoid, root, oldWalkSpeed, oldJumpPower, character)

	ownerHumanoid:SetAttribute("Immune", false)

	AbilityEvent:FireClient(player, "UnlockInput")

	AbilityEvent:FireClient(player, "NotInAnimation")

end

function Abilities.Earth.R(player, character, mousePos, clientCFrame)

	local ownerHumanoid = character:FindFirstChild("Humanoid")
	local root = character:FindFirstChild("HumanoidRootPart")
	local foot = character:FindFirstChild("LeftFoot")
	if not ownerHumanoid or not root or not foot then return end

	local now = workspace:GetServerTimeNow()

	if cooldowns[player] and cooldowns[player]["R"] then
		if now - cooldowns[player]["R"] < EarthRCooldown then
			return
		end
	end

	if clientCFrame then
		root.CFrame = clientCFrame
	end

	cooldowns[player] = cooldowns[player] or {}

	cooldowns[player]["R"] = now

	AbilityEvent:FireClient(player, "LockInput")

	AbilityEvent:FireClient(player, "InAnimation")

	AbilityEvent:FireClient(player, "EarthRAnimation")

	AbilityEvent:FireClient(player, "LockMovement")

	player:SetAttribute("RCooldownEnd", workspace:GetServerTimeNow() + EarthRCooldown)


	local animSyncTimer = 0.37

	if IsInAir(character) then

		SlamToGround(character, animSyncTimer)

	else

		task.wait(animSyncTimer)

	end

	VFXEvent:FireAllClients("RockSmash", root.Position-Vector3.new(0, 3, 0))

	local center = root.Position

	local rings = 5
	local platesPerRing = 4
	local ringSpacing = 4
	local riseHeight = 2
	local riseSpeed = 40

	local hitPlayers = {}

	for i = 1, rings do

		local radius =  3 + i * ringSpacing

		SpawnRing(player, character, center, radius, platesPerRing + i * 4, riseHeight + i * 2.5, riseSpeed, hitPlayers)

		task.wait(0.1)
	end

	AbilityEvent:FireClient(player, "UnlockMovement")

	AbilityEvent:FireClient(player, "UnlockInput")

	AbilityEvent:FireClient(player, "NotInAnimation")

	print("Earth R")

end



Abilities.Fire = {}

function Abilities.Fire.Q(player, character, mousePos)

	local now = workspace:GetServerTimeNow()

	if cooldowns[player] and cooldowns[player]["Q"] then
		if now - cooldowns[player]["Q"] < FireQCooldown then
			return
		end
	end

	cooldowns[player] = cooldowns[player] or {}

	cooldowns[player]["Q"] = now

	player:SetAttribute("QCooldownEnd", workspace:GetServerTimeNow() + FireQCooldown)

	QAbilityProjectile(player, character, mousePos, ElementQData.Fire)

end

function Abilities.Fire.E(player, character, mousePos)

	print("Fire E")

end

function Abilities.Fire.R(player, character, mousePos)

	print("Fire R")

end


Abilities.Water = {}

function Abilities.Water.Q(player, character, mousePos)

	local now = workspace:GetServerTimeNow()

	if cooldowns[player] and cooldowns[player]["Q"] then
		if now - cooldowns[player]["Q"] < WaterQCooldown then
			return
		end
	end

	cooldowns[player] = cooldowns[player] or {}

	cooldowns[player]["Q"] = now

	player:SetAttribute("QCooldownEnd", workspace:GetServerTimeNow() + WaterQCooldown)

	QAbilityProjectile(player, character, mousePos, ElementQData.Water)

end

function Abilities.Water.E(player, character, mousePos)

	print("Water E")

end

function Abilities.Water.R(player, character, mousePos)

	print("Water R")

end


return Abilities
