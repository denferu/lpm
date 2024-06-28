local fs = require("@lune/fs")
local paths = require("paths")

local aliases = {}

aliases.containers = {
	modules = "packages/_",
	aliases = "packages",
}

local function writeAliasModule(fileName: string, requires: string)
	local content = `return require({requires})\n`
	local file = paths.push(aliases.containers.aliases, fileName)

	fs.writeFile(file, content)
end

aliases.entryPoints = {
	paths.push("src", "init.luau"),
	"init.luau",
}

--[=[
	Writes an alias module to the aliases directory that
	re-exports `requires`.

	The entry point for `requires` is automatically determined,
	see possible entry points in `aliases.entryPoints`.

	This function makes aliases into the internal packages directory.

	@param alias The name of the alias module excluding .luau extension
	@param internalName The internal name of the require destination

	@error Entry point for `requires` not found
	@error IO error
]=]
function aliases.create(alias: string, internalName: string)
	local entryPoint: string?

	for _, partialPath in aliases.entryPoints do
		local full = paths.push(aliases.containers.modules, internalName, partialPath)

		if fs.isFile(full) then
			entryPoint = full
			break
		end
	end

	if not entryPoint then
		error(`entry point for "{internalName}" not found`)
	end

	local fileName = paths.withExtension(alias, "luau")

	local requires = paths.push(select(2, unpack(paths.split(entryPoint))))
	requires = requires:gsub("\\", "\\\\")
	requires = paths.withExtension(requires, "") -- since luau doesn't want extensions in requires

	writeAliasModule(fileName, `"{requires}"`)
end

return aliases
