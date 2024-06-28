local process = require("@lune/process")

local paths = {}

paths.separator = if process.os == "windows" then "\\" else "/"

function paths.format(path: string)
	return path:gsub("[\\/]", paths.separator):gsub("^%s+", ""):gsub("%s+$", "")
end

function paths.split(path: string)
	return paths.format(path):split(paths.separator)
end

--[=[
	@param path Path to add to
	@param ... All the segments in order to add onto the end of `path`
]=]
function paths.push(path: string, ...: string)
	local segments = paths.split(path)

	for _, segment in { ... } do
		table.insert(segments, segment)
	end

	return table.concat(segments, paths.separator)
end

function paths.pop(path: string)
	local segments = paths.split(path)
	table.remove(segments, #segments)

	return table.concat(segments, paths.separator)
end

function paths.withExtension(path: string, extension: string)
	return path:gsub("%.%w+$", "") .. `.{extension}`
end

return paths
