local list = {}

local manifestlib = require("lib/manifest")

function list.run()
  local manifest_paths = fs.find("/apps/*/*/manifest.json")
  for i, path in ipairs(manifest_paths) do
    local manifest = manifestlib.try_from_path(path)
    if manifest then
      ---@cast manifest Manifest
      print(("%s | %s"):format(manifest.id, manifest.version))
    end
  end
end

function list.help()
  print("NAME")
  print("  nnsr list - show package list")
  print("SYNOPSIS")
  print("  nnsr list")
  print("DESCRIPTION")
  print("  show list of package.")
  print("EXAMPLE")
  print("  nnsr list")
end

return list
