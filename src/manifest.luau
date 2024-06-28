local serde = require("@lune/serde")
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

return manifest
