local players = game:GetService("Players")
local replicatedStorage = game:WaitForChild("ReplicatedStorage")
local packages = replicatedStorage:WaitForChild("packages")
local modules = script.Parent:WaitForChild("modules")
local setup = require(replicatedStorage.shared.util.setup)
local upsideEngine = require(packages:WaitForChild("upsideEngine"))

local pluginSupportService = upsideEngine.GetService("PluginSupportService")
local sceneManager = upsideEngine.GetService("SceneManager")

-- Load global modules that are used across multiple scenes.
local globalModules = setup.getModulesByPath(modules:WaitForChild("globals"))
local playerGui = players.LocalPlayer:WaitForChild("PlayerGui")
local activeScene = nil

local sceneContainer = Instance.new("ScreenGui")
sceneContainer.Name = "SceneContainer"
sceneContainer.Parent = playerGui

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
	activeScene = scene

	setup.run(globalModules, "load", scene)
	setup.run(sceneModules, "load", scene)

	setup.run(globalModules, "start", scene)
	setup.run(sceneModules, "start", scene)
end

-- Listen for scene changes and reload modules accordingly.
sceneManager:On("SceneLoaded", function(scene)
	if activeScene then
		unloadModules(activeScene)
		scene:Disable()
		activeScene.Parent = nil
	end

	activeScene = scene
	scene.Parent = sceneContainer
	loadModules(scene)
end)

-- Load scenes from the plugin if they were created using it.
pluginSupportService:LoadPluginContent()
local myPluginScene = sceneManager:FindByName("MyScene")
myPluginScene:Enable()

-- Alternatively, create and enable a new scene programmatically.
local newScene = upsideEngine.new("Scene")
newScene:SetName("MyNewScene")
newScene:Enable()
