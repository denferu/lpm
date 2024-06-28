local tempFile = require("tempFile")
local net = require("@lune/net")
local process = require("@lune/process")
local fs = require("@lune/fs")
local stdio = require("@lune/stdio")
local paths = require("paths")
local aliases = require("aliases")

local packages = {}

export type Package = {
	owner: string,
	name: string,
	version: string?,
}

--[=[
	@error Dependency isn't parseable
]=]
function packages.parseDependency(dependency: string): Package
	local owner, name, version = dependency:match("(%a%w+)/(%a%+w)(@?%w*)")

	if not owner or not name then
		error("couldn't parse owner or name")
	end

	if version and #version == 1 then
		error('invalid version specifier only includes "@"')
	end

	if version then
		version = version:sub(2)
	end

	return {
		owner = owner,
		name = name,
		version = version,
	}
end

type DownloadOptions = {
	repository: {
		owner: string,
		name: string,
		ref: string?,
	},
	githubApiToken: string?,
}

--[=[
	@error Network request error
	@error IO error while extracting package
]=]
function packages.download(package: Package, githubApiToken: string?): string
	local ref = package.version or "main"
	local url = `https://api.github.com/repos/{package.owner}/{package.name}/zipball/{ref}`

	print("Downloading", url)

	local response = net.request({
		url = url,
		headers = {
			["Accept"] = "application/vnd.github+json",
			["Authorization"] = if githubApiToken then `Bearer {githubApiToken}` else nil :: any,
			["X-GitHub-Api-Version"] = "2022-11-28",
		},
	})

	if not response.ok then
		warn("couldn't request", url .. ":", response.statusCode, response.statusMessage)
		error(`{response.statusCode} {response.statusMessage}`)
	end

	local disposition = tostring(response.headers["content-disposition"])
	local subfolderName = disposition:match("attachment; filename=([%w%-]+)")

	if not subfolderName then
		error("Invalid HTTP response: no content-disposition header match for subfolder name")
	end

	local extractedPath = tempFile.with(function(path: string): string
		if not pcall(fs.writeFile, path, response.body) then
			return error("Couldn't write temporary zip file")
		end

		local parentPathSegments = path:split("\\")
		table.remove(parentPathSegments, #parentPathSegments)

		local parentPath = table.concat(parentPathSegments, "\\")

		local result = process.spawn("tar", { "-xf", path, "*.luau" }, { cwd = parentPath })

		if not result.ok then
			error(result.stderr)
		end

		return `{parentPath}\\{subfolderName}`
	end)

	return extractedPath
end

packages.container = "packages"

local function createMissingDirectories()
	if not fs.isDir(packages.container) then
		assert(not fs.isFile(packages.container), "invalid packages container: it's a file.")
		fs.writeDir(packages.container)
	end

	local internal = paths.push(aliases.containers.modules)

	if not fs.isDir(internal) then
		assert(not fs.isFile(internal), "invalid internal packages container: it's a file.")
		fs.writeDir(internal)
	end
end

--[=[
	@param path The path to install as a package
	@param asName The name to install the package as
	@param interactive When true and an action has to be taken, stdio is prompted for confirmation

	@return Path that the package was moved to

	@error `packages.download` errors
	@error User denied deleting duplicate package `asName`
	@error `interactive` is disabled and there exists a duåplicate package `asName`
	@error IO error
]=]
function packages.installPath(method: "copy" | "move", path: string, asName: string, interactive: boolean)
	createMissingDirectories()

	local out = paths.push(aliases.containers.modules, asName)

	if fs.isFile(out) or fs.isDir(out) then
		if not interactive or not stdio.prompt("confirm", `{out} already exists, delete?`) then
			error("User denied deletion")
		end

		local success, err: any = pcall(fs.removeFile, out)

		if not success then
			success, err = pcall(fs.removeDir, out)
		end

		if not success then
			error(`couldn't delete \"{out}\": "{err}"`)
		end
	end

	local success: boolean, result: any

	if method == "copy" then
		success, result = pcall(fs.move, path, out)
	elseif method == "move" then
		success, result = pcall(fs.copy, path, out)
	else
		error(`unhandled install method "{method}"`)
	end

	if not success then
		error(`install failure: {result or "unknown error"}`)
	end

	return out
end

return packages
