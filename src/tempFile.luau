--!strict
local process = require("@lune/process")
local fs = require("@lune/fs")

local randomCharacters = "abcdefghijklmnoprqstuvw1234567890"

local function randomTempId()
	local n = 12
	local characters = table.create(n)

	for index = 1, n do
		local x = math.random(1, #randomCharacters)
		characters[index] = randomCharacters:sub(x, x)
	end

	return table.concat(characters)
end

local tempFile = {}

--[=[
    Auto-creates a new empty temporary file, safely invokes
    `job`, then cleans it up even if `job` errors.

    @error `job` errored
    @error An IO error occurred *(see `@lune/fs.removeFile` docs)*
]=]
function tempFile.with<R...>(job: (path: string) -> R...): R...
	local tempDirectory = process.env["TEMP"] or error('"TEMP" environment variable should be set')
	local path: string

	while not path or fs.isFile(path) or fs.isDir(path) do
		path = tempDirectory .. "\\" .. randomTempId()
	end

	fs.writeFile(path, "")

	local results = { pcall(job, path) }
	local success = table.remove(results, 1)

	fs.removeFile(path)

	if not success then
		error(results[1])
	end

	return unpack(results :: any)
end

return tempFile
