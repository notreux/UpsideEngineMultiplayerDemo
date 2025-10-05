-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UpsideEngine = require(ReplicatedStorage.Packages.UpsideEngine)
local packets = require(ReplicatedStorage.shared.packets)

local DIRECTIONS = {
	up = Vector2.new(0, -1),
	down = Vector2.new(0, 1),
	left = Vector2.new(-1, 0),
	right = Vector2.new(1, 0),
}

local ATTACK_CONFIG = {
	FORCE_MULTIPLIER = 25000,
	RAYCAST_DISTANCE = 150,
	AUTHORITY_WAIT_TIME = 0.5,
	RAYCAST_FACTORS = { 0.35, 0.5, 0.65 },
}

local BALL_CONFIG = {
	IMAGE = "http://www.roblox.com/asset/?id=9302331788",
	SIZE = UDim2.fromOffset(50, 50),
	POSITION = UDim2.fromOffset(700, 400),
	Z_INDEX = 10,
	HITBOX_SCALE = 0.5,
	SHAPE = "Circle",
	MASS = 0,
	NAME = "Ball",
}

local exports = {}

local sceneManager, networkingService, crossPlatformService, authorityService
local scene
local characters = {} :: { [Player]: Character }

local function createBall()
	local ball = UpsideEngine.new("Character")
	ball.Instance.Image = BALL_CONFIG.IMAGE
	ball.Instance.Size = BALL_CONFIG.SIZE
	ball.Instance.Position = BALL_CONFIG.POSITION
	ball.Instance.ZIndex = BALL_CONFIG.Z_INDEX
	ball.HitboxScale = BALL_CONFIG.HITBOX_SCALE
	ball.Shape = BALL_CONFIG.SHAPE
	ball.Mass = BALL_CONFIG.MASS
	ball.Name = BALL_CONFIG.NAME
	ball:SetScene(scene)

	return ball
end

local function performAttackRaycast(character, direction, targetList)
	local isVertical = direction == "up" or direction == "down"

	for _, factor in ATTACK_CONFIG.RAYCAST_FACTORS do
		local absSize = character.Instance.AbsoluteSize
		local absPos = character.Instance.AbsolutePosition

		local size = Vector2.new(absSize.X * (isVertical and factor or 0.5), absSize.Y * (isVertical and 0.5 or factor))

		local from = absPos + size
		local to = from + (DIRECTIONS[direction] * ATTACK_CONFIG.RAYCAST_DISTANCE)

		local result = scene:Raycast({
			FilterType = "Whitelist",
			From = from,
			To = to,
			List = targetList,
		})

		if result and result.Object then
			return result.Object
		end
	end

	return nil
end

local function handleAttack(client, direction)
	local character = characters[client]
	if not character then
		return
	end

	local targetList = table.clone(characters)
	targetList[client] = nil

	local hitObject = performAttackRaycast(character, direction, targetList)
	if hitObject then
		local force = DIRECTIONS[direction] * ATTACK_CONFIG.FORCE_MULTIPLIER
		hitObject:ApplyForce(force)

		-- Temporarily set server authority
		authorityService:SetAuthority(hitObject, "Server")
		task.wait(ATTACK_CONFIG.AUTHORITY_WAIT_TIME)
		authorityService:SetAuthority(hitObject, "Client")
	end
end

local function handleReplicationRequest(request)
	local content = request.Content
	if content.ClassName == "Character" then
		local player = Players:GetPlayerByUserId(request.ClientId)
		local character = request:Accept()

		if not characters[player] then
			authorityService:SetAuthority(character, "Client")
			characters[player] = character
		end
	end
end

local function playerCleanup(player)
	characters[player] = nil
end

function exports.load()
	-- Initialize services
	sceneManager = UpsideEngine.GetService("SceneManager")
	networkingService = UpsideEngine.GetService("NetworkingService")
	crossPlatformService = UpsideEngine.GetService("CrossPlatformService")
	authorityService = UpsideEngine.GetService("AuthorityService")

	-- Initialize scene
	scene = sceneManager:FindByName("game")
	crossPlatformService.SideView = false

	-- Connect event handlers
	packets.attack:connect(handleAttack)
	networkingService:On("ReplicationRequest", handleReplicationRequest)
	Players.PlayerRemoving:Connect(playerCleanup)
end

function exports.start()
	-- code to run once everything is ready
	local ball = createBall()
	characters[0] = ball
end

function exports.unload()
	-- code to run before the server is closed
end

return exports
