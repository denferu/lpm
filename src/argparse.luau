local process = require("@lune/process")

local argparse = {}

--[=[
	@return Parsed arguments
	@error Parsing error
]=]
function argparse.process()
	local args: { string } = {}

	local flags = {
		["foo"] = "",
	}

	local current: string?

	for _, arg in process.args do
		if not current and arg:match("^%-") then
			local dashes, name = arg:match("(%-%-?)(%a%w*)")

			if #dashes == 1 and #name > 1 then
				warn(`invalid length flag "{name}" for dash count, treating as positional`)
				table.insert(args, arg)

				continue
			end

			current = arg
			continue
		elseif not current then
			table.insert(args, arg)
		elseif current and flags[current] then
			flags[current] = arg
			current = nil
		else
			error(`unexpected arg "{arg}"`)
		end
	end

	return {
		args = args,
		flags = flags,
	}
end

return argparse
