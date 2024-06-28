-- local manifest = require("manifest")
local process = require("@lune/process")
local fs = require("@lune/fs")
-- local serde = require("@lune/serde")
local argparse = require("argparse")

local args = argparse()

print("Hello! C:")

local commandName = args.args[1]

if not commandName or not commandName:match("^%a%w*$") then
	print(`invalid command: "{commandName}"`)
	return process.exit(1)
end

local commandModule: typeof(require("commands/install"))?

for _, name in fs.readDir("commands") do
	if name:match("^_") then
		continue
	end

	local success, ret: any = pcall(require, `commands/{name}`)

	if not success then
		print(tostring(ret))
		return process.exit(1)
	end

	if not table.find(ret.aliases, commandName) then
		continue
	end

	commandModule = ret

	break
end

if not commandModule then
	print(`unrecognized command "{commandName}"`)
	return process.exit(1)
end

commandModule.run({ select(2, unpack(args.args)) }, args.switches)

-- local manifestPath = manifest.find(process.cwd)
-- assert(manifestPath, `{manifest.fileName} not found`)

-- local content = fs.readFile(manifestPath)
-- local json = serde.decode("json", content)

-- local loadedManifest = manifest.coerce(json)
-- print(loadedManifest)
