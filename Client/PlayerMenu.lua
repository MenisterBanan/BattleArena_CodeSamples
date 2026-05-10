local ReplicatedStorage = game:GetService("ReplicatedStorage")


local player = game.Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")
local playerUI = PlayerGui:WaitForChild("PlayerUI")

local SpawnRequest = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("SpawnRequest")
local SetElement = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("SetElement")

local elementsUI = script.Parent:WaitForChild("ElementsUI")
local fireButton = elementsUI:WaitForChild("FireButton")
local waterButton = elementsUI:WaitForChild("WaterButton")
local earthButton = elementsUI:WaitForChild("EarthButton")
local CloseButton = elementsUI:WaitForChild("CloseButton")
local elementImage = elementsUI:WaitForChild("ElementImage")
local elementText = elementImage:WaitForChild("ElementText")

local tooltip = elementsUI:WaitForChild("AbilityTooltip")
local tooltipText = tooltip:WaitForChild("ToolTipText")

local QImage = elementsUI:WaitForChild("QAbilityImage")
local EImage = elementsUI:WaitForChild("EAbilityImage")
local RImage = elementsUI:WaitForChild("RAbilityImage")

local CameraPos = workspace:WaitForChild("MainMenuCameraPos")
local PlayButton = script.Parent:WaitForChild("PlayButton")
local ElementsButton = script.Parent:WaitForChild("ElementsButton")
local camera = workspace.CurrentCamera

elementsUI.Enabled = false

-- Main Menu
local function SetMenuCamera()
	
	camera.CameraType = Enum.CameraType.Scriptable
	
	camera.CFrame = CameraPos.CFrame
	
end

game:GetService("RunService").RenderStepped:Wait()

SetMenuCamera()

PlayButton.MouseButton1Click:Connect(function()
	
	playerUI.Enabled = true
	
	SpawnRequest:FireServer()
	
	script.Parent.Enabled = false
	
	workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
	
end)

SpawnRequest.OnClientEvent:Connect(function(action)
	
	if action == "ShowMenu" then
		
		script.Parent.Enabled = true
		
		playerUI.Enabled = false
		
		SetMenuCamera()
		
	end
	
end)
 

-- Images for UI elements
local elementData = {
	Fire = {
		
		Image = fireButton.Image,
		
		Color = Color3.fromRGB(255, 0, 0),
		
		Q = "rbxassetid://83869821268374",
		E = "rbxassetid://83869821268374",
		R = "rbxassetid://83869821268374"
		
	},
	Water = {
		
		Image = waterButton.Image,
		
		Color = Color3.fromRGB(0, 0, 255),
		
		Q = "rbxassetid://83869821268374",
		E = "rbxassetid://83869821268374",
		R = "rbxassetid://83869821268374"
		
	},
	Earth = {
		
		Image = earthButton.Image,
		
		Color = Color3.fromRGB(139, 69, 19),
		
		Q = "rbxassetid://126515768205172",
		E = "rbxassetid://116197840314269",
		R = "rbxassetid://106502185005008"
		
	}
}

local abilityDescriptions = {
	Fire = {
		
		Q = "Shoots a Fire projectile with High speed and small size that deals 40 damage",
		
		E = "Work in progress",
		
		R = "Work in progress"
	},

	Water = {
		Q = "Shoots a Water projectile with slow speed and big size that deals 40 damage",
		
		E = "Work in progress",
		
		R = "Work in progress"
	},

	Earth = {
		Q = "Shoots a rock projectile with moderate speed and size that deals 40 damage",
		
		E = "Form a protective shield around you that blocks damage then launch into the air and then SLAM into the ground dealing 50 damage to players AOE",
		
		R = "SMASH the ground and create a earth SHOCKWAVE that deals 60 damage to players AOE"
	}
}

local function UpdateElementUI(elementName)
	
	local data = elementData[elementName]
	
	elementImage.Image = data.Image
	
	elementText.Text = elementName
	
	elementText.TextColor3 = data.Color
	
	QImage.Image = data.Q
	
	EImage.Image = data.E
	
	RImage.Image = data.R
	
	
end

local function ShowTooltip(abilityKey, abilityImage)

	local element = player:GetAttribute("Element")

	local abilityDescription = abilityDescriptions[element][abilityKey]

	tooltipText.Text = abilityDescription
	
	tooltip.Visible = true
	
	local pos = abilityImage.AbsolutePosition
	
	local size = abilityImage.AbsoluteSize

	tooltip.Position = UDim2.fromOffset(pos.X - tooltip.AbsoluteSize.X/2 + size.X/2, pos.Y + size.Y + 5)
	
end

local function HideTooltip()
	
	tooltip.Visible = false
	
end

QImage.MouseEnter:Connect(function()
	
	ShowTooltip("Q", QImage)
	
end)

QImage.MouseLeave:Connect(HideTooltip)

EImage.MouseEnter:Connect(function()
	
	ShowTooltip("E", EImage)
	
end)

EImage.MouseLeave:Connect(HideTooltip)

RImage.MouseEnter:Connect(function()
	
	ShowTooltip("R", RImage)
	
end)

RImage.MouseLeave:Connect(HideTooltip)

CloseButton.MouseButton1Click:Connect(function()
	
	elementsUI.Enabled = false
	
	script.Parent.Enabled = true
	
end)

ElementsButton.MouseButton1Click:Connect(function()

	elementsUI.Enabled = true

	script.Parent.Enabled = false

	local element = player:GetAttribute("Element")

	UpdateElementUI(element)

end)

fireButton.MouseButton1Click:Connect(function()
	
	UpdateElementUI("Fire")
	
	SetElement:FireServer("Fire")
	
end)

waterButton.MouseButton1Click:Connect(function()
	
	UpdateElementUI("Water")
	
	SetElement:FireServer("Water")
	
end)

earthButton.MouseButton1Click:Connect(function()
	
	UpdateElementUI("Earth")
	
	SetElement:FireServer("Earth")
	
end)
