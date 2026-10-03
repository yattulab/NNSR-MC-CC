---@meta

---@class RepoSettings
---@field user string User Name of repository
---@field repo string Repository url
---@field branch string Repository branch

---@class Manifest
---@field schemaVersion integer
---@field id string
---@field name string
---@field description string?
---@field version string
---@field entry string?
---@field files string[]
---@field dependencies string[]?

---@alias SubCommands
---| "sync"    # sync package from repository
---| "list"    # show package installed
---| "run"     # run package (need define entry)
---| "help"    # show help
