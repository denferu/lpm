--[=[
	### Command Line Interface Parser **(CLIP)**

	Inspired by the Rust based [clap library](https://docs.rs/clap/latest/clap/).
]=]
local clip = {}

type Token = "string" | "specialCharacters" | "whitespace"

local symbols = '!?&%.,-_;*^¨`´"@#£¤${[]}=<>|½§'

local function toTokenKind(char: string): Token
	if char:match("^%s+$") then
		return "whitespace"
	elseif symbols:find(char) then
		return "specialCharacters"
	else
		return "string"
	end
end

function clip.tokenize(input: string)
	local tokens: { { str: string, kind: Token } } = {}

	for index, character in input:split("") do
		local kind: Token = toTokenKind(character)
		local last = tokens[#tokens]

		if last and kind == last.kind then
			last.str ..= character
			continue
		end

		table.insert(tokens, {
			kind = kind,
			str = character,
		})
	end

	return tokens
end

return clip
