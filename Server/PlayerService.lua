local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")

local DashRequest = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("DashRequest")
local AbilityEvent = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("AbilityEvent")
local VFXEvent = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("VFXEvent")
local Abilities = require(script.Parent:WaitForChild("Abilities"))

local AbilityModels = ServerStorage:WaitForChild("AbilityModels")

local playerData = {}

local maxDashes = 2
local rechargeTime = 4
local useCooldown = 1

local dashDistance = 40
local dashTime = 0.1

Players.PlayerAdded:connect(function(player)

	playerData[player] = {

		dashes = maxDashes,

		lastUse = 0,

		lastRecharge = workspace:GetServerTimeNow()
	}

	player:SetAttribute("Dashes", maxDashes)

end)

Players.PlayerRemoving:connect(function(player)

	playerData[player] = nil

end)

RunService.Heartbeat:Connect(function()

	for player, data in playerData do

		if data.dashes < maxDashes then

			local now = workspace:GetServerTimeNow()

			if now - data.lastRecharge >= rechargeTime then

				data.dashes += 1
				data.lastRecharge = now

				player:SetAttribute("Dashes", data.dashes)

				if data.dashes < maxDashes then

					player:SetAttribute("DashRechargeEnd", now + rechargeTime)

				else

					player:SetAttribute("DashRechargeEnd", nil)

				end

			end
		end
	end
end)


DashRequest.OnServerEvent:Connect(function(player)

	local data = playerData[player]
	if not data then return end

	local now = workspace:GetServerTimeNow()

	if now - data.lastUse < useCooldown then
		return
	end

	if data.dashes <= 0 then
		return
	end

	local character = player.Character
	if not character then return end

	local humanoid = character:FindFirstChild("Humanoid")

	local root = character:FindFirstChild("HumanoidRootPart")
	if not humanoid or not root then return end

	VFXEvent:FireClient(player, "Dash")

	local moveDirection = humanoid.MoveDirection

	local direction = moveDirection.Magnitude > 0 and moveDirection.Unit or root.CFrame.LookVector

	local dashSpeed = dashDistance / dashTime

	local startTime = workspace:GetServerTimeNow()

	local connection

	connection = RunService.Heartbeat:Connect(function(dt)

		local elapsed = workspace:GetServerTimeNow() - startTime

		if elapsed >= dashTime then

			connection:Disconnect()

			root.AssemblyLinearVelocity = Vector3.zero

			return
		end

		root.CFrame = root.CFrame + direction * dashSpeed * dt

	end)

	data.dashes -= 1

	data.lastUse = now

	if data.dashes == maxDashes - 1 then

		data.lastRecharge = now

	end

	player:SetAttribute("Dashes", data.dashes)

	player:SetAttribute("DashRechargeEnd", data.lastRecharge + rechargeTime)

end)



AbilityEvent.OnServerEvent:Connect(function(player, abilityKey, mousePos, clientCFrame)

	local character = player.Character
	local humanoid = character:FindFirstChild("Humanoid")
	if not character then return end
	
	if not humanoid or humanoid.Health <= 0 then
		return
	end

	local element = player:GetAttribute("Element")
	if not element then return end

	local elementAbilities = Abilities[element]
	if not elementAbilities then return end

	local AbilityFunction = elementAbilities[abilityKey]
	if not AbilityFunction then return end

	AbilityFunction(player, character, mousePos, clientCFrame)

end)


