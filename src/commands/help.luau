local _types = require("_types")
local process = require("@lune/process")
local stdio = require("@lune/stdio")
local fs = require("@lune/fs")

local function colored(color: stdio.Color, str: string)
	return stdio.color(color) .. str .. stdio.color("reset")
end

local function printHelp(name: string): ()
	local success, ret: _types.Command = pcall(require, `commands/{name}`)

	if not success then
		print(tostring(ret))
		return process.exit(1)
	end

	stdio.write(colored("blue", table.concat(ret.aliases, ", ")))

	if ret.help then
		stdio.write("\t" .. colored("yellow", ret.help) .. "\n")
	else
		stdio.write("\n")
	end
end

local run: _types.CommandHandler = function(args, flags)
	local topic = args[1]

	if topic then
		printHelp(topic)
		return
	end

	for _, name in fs.readDir("commands") do
		if name:match("^_") then
			continue
		end

		printHelp(name)
	end
end

local command: _types.Command = {
	aliases = {
		"help",
		"/?",
	},
	help = "Helps you (duh)",
	run = run,
}

return command
