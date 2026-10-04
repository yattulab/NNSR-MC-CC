local args = { ... }

local setup_path = "/apps/gabuniku/peripheral-utils/startup.lua"
local deploy_path = "/startup/peripheral-utils/startup.lua"

print("setup peripheral-utils")
fs.makeDir("/startup/peripheral-utils")

if fs.exists(deploy_path) then
  fs.delete(deploy_path)
end
fs.copy(setup_path, deploy_path)

print("done.")
