local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remo = require(ReplicatedStorage.Packages.Remo)
local t = require(ReplicatedStorage.Packages.t)

type Remotes = Remo.Remotes<{
	attack: Remo.ClientToServer<string>,
}>

local charDirection = t.string
local remotes: Remotes = Remo.createRemotes({
	attack = Remo.remote(charDirection),
}, Remo.loggerMiddleware)

return remotes
