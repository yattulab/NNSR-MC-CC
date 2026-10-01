--[[
 setup.lua
 (c) 2026 gabuniku
 ]]
--

---@class RepoSettings
---@field user string User Name of repository
---@field repo string Repository url
---@field branch string Repository branch

---@class Manifest
---@field schemaVersion integer
---@field name string
---@field description string?
---@field version string
---@field entry string?
---@field files string[]
---@field dependencies string[]?

---@type RepoSettings
repo_settings = {
  user = "yattulab",
  repo = "NNSR-MC-CC",
  branch = "main",
}

nnsr_path = "apps/gabuniku/nnsr"

-- download from url
---@param url string
---@return string | nil
local function download(url)
  print("download : " .. url)
  local request = http.get(url)
  if request == nil then
    return nil
  end
  request.readAll()
end

---@param settings RepoSettings
---@param use_cdn? boolean if set true, use cdn (jsDeliver)
---@return boolean
local function download_nnsr_files(settings, use_cdn)
  local url_base
  -- use cdn
  if use_cdn then
    url_base = "https://cdn.jsdelivr.net/gh/%s/%s@%s/"
  else
    -- use github
    url_base = "https://raw.githubusercontent.com/%s/%s/%s/"
  end

  url_base = string.format(url_base, settings.user, settings.repo, settings.branch)

  -- check manifest
  print("check manifest...")
  local jsondata = download(url_base .. nnsr_path .. "/manifest.json")
  if jsondata == nil then
    print("failed download manifest.json")
    return false
  end

  local manifest, err = textutils.unserialiseJSON(jsondata)
  if manifest == nil then
    print("failed parse manifest : " .. err)
    return false
  end
  ---@cast manifest Manifest

  print("downloaded manifest.json")

  if manifest.schemaVersion ~= 1 then
    print(string.format("unsuported manifest version %d", manifest.schemaVersion))
    return false
  end

  print("name        : " .. manifest.name)
  print("version     : " .. manifest.version)
  print("source file(s)")

  if manifest.files then
    for _, files in ipairs(manifest.files) do
      print(files)
    end
  end

  local user_in = read(string.format("install nnsr ok (%2d files) ? (y/n)", #manifest.files))

  if user_in ~= "Y" and user_in ~= "y" then
    print("cancel by user")
    return false
  end

  return false
end

download_nnsr_files(repo_settings, false)

fs.makeDir("/startup")
local setup_file = fs.open("nnsr-setup.lua", "w")
if setup_file == nil then
  print("faild open /startup/nnsr-setup.lua")
  return
end
setup_file.writeLine("-- THIS FILE IS AUTO GENERATE BY SETUP SCRIPT")
setup_file.writeLine('shell.setAlias("nnsr", "/pkg/gabuniku/nnsr/main.lua")')
setup_file.close()
