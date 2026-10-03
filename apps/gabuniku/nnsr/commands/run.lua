local run = {}

---@param pkg_name string?
---@param ... string?
---@return boolean
function run.run(pkg_name, ...)
  if pkg_name == nil then
    printError("nnsr run <package name>")
    printError("         ^^^^^^^^^^^^^^")
    printError("         | need package name")
    printError("         | USER/PKGNAME")
    return false
  end

  local args = { ... }

  -- set require path
  local cc_require = require("cc.require")

  local app_dir = "/apps/" .. pkg_name
  local manifest_path = fs.combine(app_dir, "manifest.json")
  local manifest_file = fs.open(manifest_path, "r")
  if manifest_file == nil then
    printError("can not open manifest file")
    return false
  end
  local manifest_raw = manifest_file.readAll()
  manifest_file.close()
  if manifest_raw == nil then
    printError("can not read manifest file")
    return false
  end
  local manifest = textutils.unserialiseJSON(manifest_raw)
  if type(manifest) ~= "table" then
    printError("minifest file is invalid format")
    return false
  end
  ---@cast manifest Manifest
  if manifest.schemaVersion > 1 then
    printError(
      string.format(
        'manifest version %02 is not supported. please do "nnsr sync gabuniku/nnsr"',
        manifest.schemaVersion
      )
    )
    return false
  end

  local entry_name = manifest.entry
  if entry_name == nil then
    entry_name = "main.lua"
  end

  local entry_path = fs.combine(app_dir, entry_name)

  local env = setmetatable({}, {
    __index = _ENV,
  })
  env.require, env.package = cc_require.make(env, app_dir)
  env.package.path = env.package.path .. ";/apps/?.lua" .. ";/apps/?/init.lua"

  local program, err = loadfile(entry_path, "t", env)

  if not program then
    printError(err)
    return false
  end

  local ok, runtime_err = pcall(program, table.unpack(args))

  if not ok then
    printError(runtime_err)
    return false
  end

  return true
end

function run.help()
  print("NAME")
  print("  nnsr run - run package")
  print("SYNOPSIS")
  print("  nnsr run [PKG] [ARGS]")
  print("DESCRIPTION")
  print("  Run script of package.")
  print("  ARGS are passed to the script.")
  print('  PKG style must be "USER/PKG_NAME"')
  print("EXAMPLE")
  print("  nnsr run hoge/fuga foo bar")
end

return run
