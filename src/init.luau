local manifest = require("manifest")
local process = require("@lune/process")
local fs = require("@lune/fs")
local serde = require("@lune/serde")
local argparse = require("argparse")

print("Hello! C:")

print(argparse.process())
process.exit(0)

local manifestPath = manifest.find(process.cwd)
assert(manifestPath, `{manifest.fileName} not found`)

local content = fs.readFile(manifestPath)
local json = serde.decode("json", content)

local loadedManifest = manifest.coerce(json)
print(loadedManifest)
