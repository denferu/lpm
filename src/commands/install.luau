local _types = require("_types")

local run: _types.CommandHandler = function(args, flags)
	print("ran")
end

local command: _types.Command = {
	aliases = {
		"install",
		"i",
	},
	help = "Installs all lpm manifest dependencies",
	run = run,
}

return command
