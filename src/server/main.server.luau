local replicatedStorage = game:WaitForChild("ReplicatedStorage")
local modules = script.Parent:WaitForChild("modules")
local setup = require(replicatedStorage.shared.util.setup)

-- Unload all modules when required.
local function unloadModules()
	setup.run(modules, "unload")
end

-- Load and start all server-side modules.
local function loadModules()
	setup.run(modules, "load")
	setup.run(modules, "start")
end

-- Load modules when the game has finished loading.
game.Loaded:Connect(function()
	loadModules()
end)

-- Ensure that modules are unloaded properly when the game is closing.
game:BindToClose(function()
	unloadModules()
end)
