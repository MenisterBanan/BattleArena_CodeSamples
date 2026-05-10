
local player = game.Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local hud = script.Parent

local PlayerGui = player:WaitForChild("PlayerGui")
local SpawnRequest = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("SpawnRequest")

local dashBarFill = hud.Dash:WaitForChild("BarBackGround"):WaitForChild("BarFill")
local dashCount = hud.Dash:WaitForChild("CountText")
local healthBar = script.Parent.HealthBarBackground.HealthBar
local healthText = script.Parent.HealthBarBackground.HealthText

local abilityIcons = {
	Earth = {
		Q = "rbxassetid://126515768205172",
		E = "rbxassetid://116197840314269",
		R = "rbxassetid://106502185005008"
	},

	Fire = {
		Q = "rbxassetid://83869821268374",
		E = "rbxassetid://83869821268374",
		R = "rbxassetid://83869821268374"
	},

	Water = {
		Q = "rbxassetid://83869821268374",
		E = "rbxassetid://83869821268374",
		R = "rbxassetid://83869821268374"
	}
}

hud.Enabled = false

local Q = hud.Q
local E = hud.E
local R = hud.R

local function UpdateHealth(humanoid)
	
	local health = humanoid.Health
	
	local maxHealth = humanoid.MaxHealth
	
	local percent = health / maxHealth
	
	healthBar.Size = UDim2.new(percent, 0, 1, 0)
	
	healthText.Text = math.floor(health) .. "/" .. maxHealth
	
end

local function UpdateUI()

	local element = player:GetAttribute("Element")

	local elementIcons = abilityIcons[element]

	Q.Icon.Image = elementIcons.Q
	
	E.Icon.Image = elementIcons.E
	
	R.Icon.Image = elementIcons.R
	
end


local function SetupCharacter(character)

	local humanoid = character:WaitForChild("Humanoid")
	
	UpdateHealth(humanoid)
	
	humanoid.HealthChanged:Connect(function()
		
		UpdateHealth(humanoid)
		
	end)
	
end


if player.Character then
	
	SetupCharacter(player.Character)
	
end

player.CharacterAdded:Connect(SetupCharacter)



local function UpdateAbility(frame, key)
	
	local now = workspace:GetServerTimeNow()
	
	local cooldownEnd = player:GetAttribute(key .. "CooldownEnd")

	if cooldownEnd and cooldownEnd > now then

		local remaining = cooldownEnd - now

		frame.CooldownOverlay.Visible = true
		
		frame.CooldownText.Visible = true
		
		frame.CooldownText.Text = string.format("%.1f", remaining)

	else
		
		frame.CooldownOverlay.Visible = false
		
		frame.CooldownText.Visible = false
		
	end
end

local function UpdateDash()

	local dashes = player:GetAttribute("Dashes")
	
	local rechargeEnd = player:GetAttribute("DashRechargeEnd")

	local now = workspace:GetServerTimeNow()

	dashCount.Text = tostring(dashes)

	if dashes >= 2 then

		dashBarFill.Size = UDim2.fromScale(1, 1)

	elseif rechargeEnd then

		local remaining = math.clamp(rechargeEnd - now, 0, 5)
		
		local progress = 1 - (remaining / 5)

		dashBarFill.Size = UDim2.fromScale(progress, 1)

	else

		dashBarFill.Size = UDim2.fromScale(0, 1)

	end
end

RunService.RenderStepped:Connect(function()
	
  UpdateAbility(Q, "Q")
  UpdateAbility(E, "E")
  UpdateAbility(R, "R")

  UpdateDash()
	
end)

UpdateUI()

player:GetAttributeChangedSignal("Element"):Connect(function()
	
	UpdateUI()
	
end)
