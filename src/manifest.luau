local fs = require("@lune/fs")
local paths = require("paths")

local manifest = {}

manifest.fileName = "lpm.json"

--[=[
	@param searchRoot Path to start search from
]=]
function manifest.find(searchRoot: string): string?
	local possiblePaths = {
		paths.push(searchRoot, manifest.fileName),
	}

	local foundPath: string?

	for _, path in possiblePaths do
		if not fs.isFile(path) then
			continue
		end

		foundPath = path
		break
	end

	return foundPath
end

export type Manifest = {
	dependencies: { string },
}

--[=[
	Parses `manifest` into a `Manifest` if possible.

	@error Manifest wasn't parseable
	@error Invalid manifest
]=]
function manifest.coerce(manifest: { [unknown]: unknown })
	assert(typeof(manifest) == "table", 'Expected provided "manifest" to be a table')
	assert(typeof(manifest.dependencies) == "table", 'Expected manifest to contain a list "dependencies"')

	for key, value in manifest.dependencies :: any do
		if typeof(key) ~= "string" then
			error(`Invalid manifest["dependencies"] key "{key}"`)
		end

		if typeof(value) ~= "string" then
			error(`Invalid manifest["dependencies"][{key}] value type, expected string`)
		end
	end

	local expectedKeys = {
		"dependencies",
	}

	for _, key in expectedKeys do
		if typeof(manifest[key]) == "nil" then
			error(`Expected manifest key "{key}" to exist`)
		end
	end

	for key, _ in manifest do
		if typeof(key) == "string" and not table.find(expectedKeys, key) then
			error(`Unexpected manifest key "{key}"`)
		end
	end

	return manifest :: Manifest
end

return manifest
