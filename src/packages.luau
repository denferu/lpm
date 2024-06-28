local packages = {}

export type Dependency = {
	owner: string,
	name: string,
	version: string?,
}

--[=[
	@error Dependency isn't parseable
]=]
function packages.parseDependency(dependency: string): Dependency
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

return packages
