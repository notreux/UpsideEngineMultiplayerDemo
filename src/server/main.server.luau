local replicatedStorage = game:WaitForChild("ReplicatedStorage")
local setup = require(replicatedStorage.shared.util.setup)
local modules = setup.getModulesByPath(script.Parent:WaitForChild("modules"))

-- Unload all modules when required.
local function unloadModules()
	setup.run(modules, "unload")
end

-- Load and start all server-side modules.
local function loadModules()
	setup.run(modules, "load")
	setup.run(modules, "start")
end

-- Load modules
loadModules()

-- Ensure that modules are unloaded properly when the game is closing.
game:BindToClose(function()
	unloadModules()
end)
