local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UpsideEngine = require(ReplicatedStorage.Packages.UpsideEngine)
local packets = require(ReplicatedStorage.shared.packets)

-- imports
local exports = {}
function exports.load(scene: Scene)
	-- initialization code
	local networkingService = UpsideEngine.GetService("NetworkingService")
	local crossPlatformService = UpsideEngine.GetService("CrossPlatformService")

	local size = 256 * 1.3
	local character = UpsideEngine.new("Character")
	character.Instance.Position = UDim2.fromOffset(800, 400)
	character.Instance.Size = UDim2.fromOffset(size, size)
	character.Instance.ZIndex = 100
	character.Instance.ImageRectSize = Vector2.new(64, 64)
	character.SecondsPerFrame = 1 / 10
	character.Mass = 0
	character.WalkSpeed = 200
	character.Hitbox = {
		Vector3.new(0.4, 0.4),
		Vector3.new(0.6, 0.4),
		Vector3.new(0.6, 0.7),
		Vector3.new(0.4, 0.7),
	}

	character:SetScene(scene)
	character:SetSpriteSheet("idle_down", "rbxassetid://88928238314310", Vector2.new(4, 1))
	character:SetSpriteSheet("idle_up", "rbxassetid://95100588056676", Vector2.new(4, 1))
	character:SetSpriteSheet("idle_right", "rbxassetid://71261911169687", Vector2.new(4, 1))
	character:SetSpriteSheet("idle_left", "rbxassetid://77462626486631", Vector2.new(4, 1))

	character:SetSpriteSheet("down", "rbxassetid://72088943372389", Vector2.new(4, 1))
	character:SetSpriteSheet("up", "rbxassetid://115911888027275", Vector2.new(4, 1))
	character:SetSpriteSheet("right", "rbxassetid://76714492246422", Vector2.new(4, 1))
	character:SetSpriteSheet("left", "rbxassetid://121774338997444", Vector2.new(4, 1))

	character:SetSpriteSheet("attack_down", "rbxassetid://137512613035558", Vector2.new(4, 1))
	character:SetSpriteSheet("attack_up", "rbxassetid://136983856571004", Vector2.new(4, 1))
	character:SetSpriteSheet("attack_right", "rbxassetid://101513639148728", Vector2.new(4, 1))
	character:SetSpriteSheet("attack_left", "rbxassetid://139944524052888", Vector2.new(4, 1))

	character:Play("idle_down")

	crossPlatformService.SideView = false
	crossPlatformService:SetPlayerCharacter(character)
	scene.Camera:SetSubject(character)

	local player = Players.LocalPlayer
	local mouse = player:GetMouse()
	local attacking = false

	exports.replicationCn = networkingService:ReplicateOnChange(character)
	exports.attackCn = mouse.Button1Down:Connect(function()
		if attacking then
			return
		end

		local spriteSheetName = character.Active.Name
		local direction = spriteSheetName:match("(%a+)$")

		if direction ~= "" then
			attacking = true
			character:Play("attack_" .. direction)
			task.wait(0.2)
			packets.attack:fire(direction)
			task.wait(0.2)
			character:Play("idle_" .. direction)
			attacking = false
		end
	end)
end

function exports.start(scene: Scene)
	-- code to run once everything is ready
end

function exports.unload(scene: Scene)
	-- code to run before the scene is unloaded
	exports.attackCn:Disconnect()
	exports.replicationCn:Disconnect()
end

return exports
