--- PlayerOne - Add retro gaming charm to your coding experience with 8-bit sound effects
--- Main module that provides the plugin interface
---@module 'player-one'

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
local M = {}

M = Config.setup()

return M
