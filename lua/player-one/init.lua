--- PlayerOne - Add retro gaming charm to your coding experience with 8-bit sound effects
--- Main module that provides the plugin interface
---@module 'player-one'

-- TODO: add checkhealth #11
local Config = require("player-one.config")

---@class PlayerOne
---@field setup fun(options?: PlayerOne.Config): PlayerOne
---@field play fun(sound: PlayerOne.SoundParams)
---@field play_async fun(sound: PlayerOne.SoundParams)
---@field append fun(sound: PlayerOne.SoundParams)
---@field stop fun()
---@field load_theme fun(theme: string|PlayerOne.Theme)
---@field enable fun()
---@field disable fun()
---@field toggle fun()
---@field reload_binary fun(): boolean
local M = {}

setmetatable(M, {
	__index = Config,
})

return M
