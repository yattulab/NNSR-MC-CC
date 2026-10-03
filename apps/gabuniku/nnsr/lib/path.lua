local path = {}

---@param path_ string
---@param mode ccTweaked.fs.openMode
---@return  ccTweaked.fs.BinaryReadHandle|ccTweaked.fs.BinaryWriteHandle|ccTweaked.fs.ReadHandle|ccTweaked.fs.WriteHandle| nil
---@return string | nil
function path.open(path_, mode)
  if not fs.exists(path_) then
    return nil, "no exists"
  end
  local handle = fs.open(path_, mode)
  if handle == nil then
    return nil, "can not open"
  end
  return handle, nil
end

return path
