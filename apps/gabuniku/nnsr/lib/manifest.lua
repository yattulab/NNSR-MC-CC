local manifest = {}

local SUPPORT_VERTION = 1

local path = require("path")

---@param obj table
---@return Manifest | nil
---@return string | nil
function manifest.try_from(obj)
  -- type validating

  if type(obj.schemaVersion) ~= "number" then
    return nil, "schemaVersion must be number"
  end

  if type(obj.name) ~= "string" then
    return nil, "name must be string"
  end

  if type(obj.version) ~= "string" then
    return nil, "version must be string"
  end

  if type(obj.description) ~= "string" and obj.description ~= nil then
    return nil, "description must be string or nil"
  end

  if type(obj.entry) ~= "string" and obj.entry ~= nil then
    return nil, "entry must be string or nil"
  end

  if type(obj.files) ~= "table" then
    return nil, "files must be table"
  end

  for i, file in ipairs(obj.files) do
    if type(file) ~= "string" then
      return nil, string.format("files[%d] must be string", i)
    end
  end

  if type(obj.dependencies) ~= "table" then
    return nil, "dependencies must be table"
  end

  if obj.dependencies ~= nil then
    for i, dependence in ipairs(obj.dependencies) do
      if type(dependence) ~= "string" then
        return nil, string.format("dependencies[%d] must be string", i)
      end
    end
  end

  ---@type Manifest
  local manifest_type = obj

  -- semantic validating

  if manifest_type.schemaVersion > SUPPORT_VERTION then
    return nil,
      string.format(
        "manifest version %d is not supported (support until %d)",
        manifest_type.schemaVersion,
        SUPPORT_VERTION
      )
  end
  return manifest_type, nil
end

---@param str  string
---@return Manifest | nil
---@return string | nil
function manifest.try_from_str(str)
  local raw, err = textutils.unserialiseJSON(str)

  if raw == nil then
    return nil, err
  end

  if type(raw) ~= "table" then
    return nil, "manifest must be table"
  end

  return manifest.try_from(raw)
end

---@param path_ string
---@return Manifest | nil
---@return string | nil
function manifest.try_from_path(path_)
  local file, err = path.open(path_, "r")
  if file == nil then
    return nil, err
  end
  local str = file.readAll()
  file.close()
  if str == nil then
    return nil, "can not read file"
  end
  return manifest.try_from_str(str)
end

return manifest
