local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")

local ElementStore = DataStoreService:GetDataStore("PlayerElement")

local SpawnRequest = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("SpawnRequest")
local SetElement = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("SetElement")
local spawnPointsFolder = workspace:WaitForChild("SpawnPoints")

local function GetRandomSpawn()

	local spawnPoints = spawnPointsFolder:GetChildren()

	return spawnPoints[math.random(1, #spawnPoints)]

end

local function SpawnPlayer(player)

	local character = player.Character or player.CharacterAdded:Wait()

	local spawnPoint = GetRandomSpawn()

	local _, size = character:GetBoundingBox()

	local height = size.Y

	character:PivotTo(spawnPoint.CFrame + Vector3.new(0, height / 2, 0))

end

SpawnRequest.OnServerEvent:Connect(function(player)

	SpawnPlayer(player)

end)

local function OnCharacterAdded(player, character)

	local humanoid = character:WaitForChild("Humanoid")

	SpawnRequest:FireClient(player, "ShowMenu")

	humanoid.JumpHeight = 10

	humanoid.WalkSpeed = 25

	humanoid.Died:Connect(function()

		-- stuff for death screen mabye?

	end)

end

Players.PlayerAdded:Connect(function(player)

	local success, savedElement = pcall(function()

		return ElementStore:GetAsync(player.UserId)

	end)

	if success and savedElement then

		player:SetAttribute("Element", savedElement)

	else

		player:SetAttribute("Element", "Earth")
		
	end

	player.CharacterAdded:Connect(function(character)

		OnCharacterAdded(player, character)

	end)

end)


SetElement.OnServerEvent:Connect(function(player, elementName)

	if elementName ~= "Fire" and elementName ~= "Water" and elementName ~= "Earth" then

		return

	end

	player:SetAttribute("Element", elementName)


end)

Players.PlayerRemoving:Connect(function(player)

	local element = player:GetAttribute("Element")

	pcall(function()
		
		ElementStore:SetAsync(player.UserId, element)
		
	end)

end)
