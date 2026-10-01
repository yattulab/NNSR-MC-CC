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

nnsr_path = "apps/gabuniku/nnsr/"

-- download from url
---@param url string
---@return string | nil
local function download(url)
  print("download : " .. url)
  local request = http.get(url)
  if request == nil then
    return nil
  end
  return request.readAll()
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
  local jsondata = download(url_base .. nnsr_path .. "manifest.json")
  if jsondata == nil then
    printError("failed download manifest.json")
    return false
  end

  local manifest, err = textutils.unserialiseJSON(jsondata)
  if manifest == nil then
    printError("failed parse manifest : " .. err)
    return false
  end
  ---@cast manifest Manifest

  print("downloaded manifest.json")

  if manifest.schemaVersion ~= 1 then
    printError(string.format("unsuported manifest version %d", manifest.schemaVersion))
    return false
  end

  print("name    : " .. manifest.name)
  print("version : " .. manifest.version)
  print("source file(s)")

  if manifest.files then
    for _, files in ipairs(manifest.files) do
      print("- " .. files)
    end
  end

  print(string.format("install nnsr ok (%2d files) ? (y/n)", #manifest.files))
  local user_in = read()

  if user_in ~= "Y" and user_in ~= "y" then
    print("cancel by user")
    return false
  end

  fs.makeDir("/apps/gabuniku/nnsr")

  print(string.format("download %d file(s)", #manifest.files))

  for i, file in ipairs(manifest.files) do
    print(string.format("[%2d / %2d] %s", i, #manifest.files, file))
    local code = download(url_base .. nnsr_path .. file)
    if code then
      local handle = fs.open("/" .. nnsr_path .. file, "w")
      if handle == nil then
        printError("faild create : /" .. nnsr_path .. file)
        return false
      end
      handle.write(code)
      handle.close()
    else
      printError("faild download : " .. file)
    end
  end

  return true
end

local result = download_nnsr_files(repo_settings, false)

if not result then
  printError("failed setup nnsr")
  return
end

-- setup startup script
print("setup startup script")
fs.makeDir("/startup")
local setup_file = fs.open("/startup/nnsr-setup.lua", "w")
if setup_file == nil then
  printError("faild open /startup/nnsr-setup.lua")
  return
end
setup_file.writeLine("-- THIS FILE IS AUTO GENERATE BY SETUP SCRIPT")
setup_file.writeLine('shell.setAlias("nnsr", "/apps/gabuniku/nnsr/main.lua")')
setup_file.close()

-- setup config
print("setup config")
local config = fs.open("/apps/gabuniku/nnsr/config.json", "w")
if config == nil then
  printError("failed create config")
  return
end

config.writeLine(textutils.serialiseJSON(repo_settings))

config.close()

shell.setAlias("nnsr", "/apps/gabuniku/nnsr/main.lua")

print("finish install nnsr")
print('please use "nnsr"or "nnsr help"')
