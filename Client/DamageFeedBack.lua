local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

local DamageFeedback = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("DamageFeedback")
local PlayerHighlight = ReplicatedStorage:WaitForChild("VFX"):WaitForChild("PlayerHighlight")
local DamageGUI = ReplicatedStorage:WaitForChild("VFX"):WaitForChild("DamageGUI")


local function HighlightCharacter(character)

	local highlight = PlayerHighlight:Clone()

	highlight.Parent = character

	Debris:AddItem(highlight, 0.4)
end


local function DisplayDamageNumber(character, damage)

	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then return end

	local gui = DamageGUI:Clone()
	
	gui.Adornee = root
	
	gui.Parent = workspace

	local text = gui:WaitForChild("DamageText")
	
	text.Text = tostring(damage)


	task.spawn(function()
		for i = 1, 20 do
			gui.StudsOffset += Vector3.new(0, 0.1, 0)
			
			text.TextTransparency += 0.05
			
			task.wait(0.02)
			
		end
		gui:Destroy()
	end)
end


DamageFeedback.OnClientEvent:Connect(function(character, damage)

	if not character then return end

	HighlightCharacter(character)
	
	DisplayDamageNumber(character, damage)

end)
