local M = {}

M.ui = {
	enter = { frequency = 440.0, duration = 100, amplitude = 0.2 },
	select = { frequency = 660.0, duration = 100, amplitude = 0.2 },
	back = { frequency = 330.0, duration = 100, amplitude = 0.2 },
	error = { frequency = 220.0, duration = 200, amplitude = 0.3 },
	success = { frequency = 880.0, duration = 100, amplitude = 0.2 },
	notification = { frequency = 550.0, duration = 150, amplitude = 0.2 },
}

return M
