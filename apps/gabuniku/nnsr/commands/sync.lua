local sync = {}

---@package
---@alias ResolveType
---| "pending"
---| "resolved"

---@type table<string,ResolveType>
local resolved_pkgs = {}

local manifestlib = require("lib.manifest")
local pathlib = require("lib.path")
local downloaderlib = require("lib.downloader")

function sync.download_manifest(repo, pkg_id, use_cdn)
  ---@type Downloader
  local downloader = downloaderlib.new(repo, pkg_id, use_cdn)

  print("get manifest")
  local mani_res, err = downloader:download_file("manifest.json")
  if mani_res == nil then
    return nil, err
  end
  print(string.format("download manifest.json (%d B)", mani_res))
  print("reading manifest")

  local manifest_path = fs.combine("/apps", pkg_id, "manifest.json")
  local manifest, err = manifestlib.try_from_path(manifest_path)
  return manifest, err
end

---resolved
---@param repo RepoSettings
---@param pkg_id string
---@param use_cdn boolean?
---@return boolean
function sync.resolve_pkg(repo, pkg_id, use_cdn)
  local base_path = fs.combine("/apps", pkg_id)
  local manifest_path = fs.combine(base_path, "manifest.json")
  local manifest
  local err
  if fs.exists(manifest_path) then
    manifest, err = manifestlib.try_from_path(manifest_path)
  else
    manifest, err = sync.download_manifest(repo, pkg_id, use_cdn)
  end
  if manifest == nil then
    printError("can not read manifest " .. err)
    return false
  end
  ---@cast manifest Manifest

  resolved_pkgs[pkg_id] = "pending"

  print(string.format("%s depend on %d package(s)", pkg_id, #manifest.dependencies))

  if #manifest.dependencies > 0 then
    print("resolve dependencies")
    for _, value in ipairs(manifest.dependencies) do
      if resolved_pkgs[value] == nil then
        if sync.resolve_pkg(repo, value, use_cdn) then
          print("resolved " .. value)
        else
          printError("resolve failed " .. value)
          return false
        end
      end
    end
  end

  print(string.format("get %d file(s)", #manifest.files))
  ---@type Downloader
  local downloader = downloaderlib.new(repo, pkg_id, use_cdn)
  for i, file in ipairs(manifest.files) do
    --[[
    if fs.exists(fs.combine(base_path, file)) then
      print(string.format("%2d cached %s", i, file))
    else
      local len, err = downloader:download_file(file)
      if len == nil then
        printError(err)
        return false
      end
      print(string.format("%2d get    %s (%d B)", i, file, len))
      ]]
    --

    local len, err = downloader:download_file(file)
    if len == nil then
      printError(err)
      return false
    end
    print(string.format("%2d get    %s (%d B)", i, file, len))
  end
  resolved_pkgs[pkg_id] = "resolved"
  return true
end

---sync
---@param pkg_id string?
---@param ... string[]?
---@return boolean
function sync.run(pkg_id, ...)
  if pkg_id == nil then
    printError("sync command need package name")
    return false
  end

  local use_cdn = true
  local args = { ... }
  if args ~= nil then
    for _, arg in ipairs(args) do
      if arg == "--no-cdn" then
        use_cdn = false
        print("do not use cdn")
      else
        printError("unknown argument : " .. arg)
        return false
      end
    end
  end

  local repo_raw, err = pathlib.open("/apps/gabuniku/nnsr/repository.json", "r")
  if repo_raw == nil then
    printError("repository.json | " .. err)
    return false
  end
  local repo, err = textutils.unserialiseJSON(repo_raw.readAll())
  repo_raw.close()
  if repo == nil then
    printError(err)
    return false
  end
  ---@cast repo RepoSettings
  return sync.resolve_pkg(repo, pkg_id, use_cdn)
end

function sync.help() end

return sync
