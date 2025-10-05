local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local replicatedStorage = game:WaitForChild("ReplicatedStorage")
local modules = script.Parent:WaitForChild("modules")

local upsideEngine = require(ReplicatedStorage.Packages.UpsideEngine)
local setup = require(replicatedStorage.shared.util.setup)
local sceneManager = upsideEngine.GetService("SceneManager")

-- Load global modules that are used across multiple scenes.
local globalModules = setup.getModulesByPath(modules:WaitForChild("globals"))
local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

local activeScene = nil
local sceneContainer = Instance.new("ScreenGui")
sceneContainer.Name = "SceneContainer"
sceneContainer.Parent = playerGui
sceneContainer.IgnoreGuiInset = true

-- Unload modules from the current scene.
local function unloadModules(scene)
	local path = modules:WaitForChild(scene.Name)
	local sceneModules = setup.getModulesByPath(path)

	setup.run(globalModules, "unload")
	setup.run(sceneModules, "unload")
end

-- Load and start modules for the new scene.
local function loadModules(scene)
	local path = modules:WaitForChild(scene.Name)
	local sceneModules = setup.getModulesByPath(path)

	setup.run(globalModules, "load", scene)
	setup.run(sceneModules, "load", scene)

	setup.run(globalModules, "start", scene)
	setup.run(sceneModules, "start", scene)
end

-- Listen for scene changes and reload modules accordingly.
sceneManager:On("SceneLoaded", function(scene)
	if activeScene then
		unloadModules(activeScene)
		activeScene:Disable()
		activeScene.Instance.Parent = nil
	end

	activeScene = scene
	scene.Instance.Parent = sceneContainer
	loadModules(scene)
end)

local myPluginScene = nil
while not myPluginScene do
	myPluginScene = sceneManager:FindByName("game")
	task.wait()
end

myPluginScene:Enable()

return {}
