local process = require("@lune/process")

--[=[
	Parses Windows switch-like CLI arguments:
	- Switches are flags that may have values, e.g.:
		- `/noValue`
		- `/valued:hello`
		- `/level:error
	- The rest is assumed to be a positional argument

	@return Parsed arguments
	@error Parsing error: invalid switch syntax
]=]
return function()
	local switches: { [string]: string } = {}
	local args: { string } = {}

	for _, arg in process.args do
		local switch, value = arg:match("/(%a%w*)(:?%w*)") -- i did it windows style cause i couldnt implement it unix style rn, too tired :sob:

		if switch then
			if value and #value == 1 then
				error(`malformed switch "{switch}": expected value following colon`)
			end

			if switches[switch] then
				error(`duplicate switch "{switch}"`)
			end

			switches[switch] = if value then value:sub(2) else ""

			continue
		end

		table.insert(args, arg)
	end

	return {
		args = args,
		switches = switches,
	}
end
