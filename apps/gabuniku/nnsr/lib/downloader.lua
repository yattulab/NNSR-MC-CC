---@class Downloader
---@field repo RepoSettings
---@field pkg_id string
---@field use_cdn boolean
local Downloader = {}
Downloader.__index = Downloader

---@param repo RepoSettings
---@param pkg_id string
---@param use_cdn boolean?
---@return Downloader
function Downloader.new(repo, pkg_id, use_cdn)
  ---@type Downloader
  local self = setmetatable({}, Downloader)
  self.repo = repo
  self.pkg_id = pkg_id
  if use_cdn then
    self.use_cdn = true
  else
    self.use_cdn = false
  end
  return self
end

---@param path string
---@param pkg_id string?
---@return string url
function Downloader:repo_path_to_url(path, pkg_id)
  local pkg_id = pkg_id or self.pkg_id
  local url_base
  -- use cdn
  if self.use_cdn then
    url_base = "https://cdn.jsdelivr.net/gh/%s/%s@%s/apps/%s/%s"
  else
    -- use github
    url_base = "https://raw.githubusercontent.com/%s/%s/%s/apps/%s/%s"
  end

  local repo = self.repo

  return string.format(url_base, repo.user, repo.repo, repo.branch, pkg_id, path)
end

---@param url string
---@param text boolean?
---@return string | nil data
---@return string | nil error message
function Downloader.download(url, text)
  local is_text = text and true or false
  local response, err = http.get(url, nil, is_text)
  if response == nil then
    return nil, err
  end

  local content = response.readAll()
  response.close()
  if content == nil then
    return nil, err
  end
  return content, nil
end

---@param path string
---@param pkg_id string?
---@return number | nil length
function Downloader:download_file(path, pkg_id)
  local url = self:repo_path_to_url(path, pkg_id)
  local data, err = self.download(url)
  if data then
    local pkg_id = pkg_id or self.pkg_id
    local path = fs.combine("/apps", pkg_id, path)
    local handle, ferr = fs.open(path, "wb")
    if handle == nil then
      printError("failed open " .. ferr)
      return nil
    end
    handle.write(data)
    handle.close()
    return #data
  else
    printError("failed download " .. path)
    printError(err)
    return nil
  end
end

return Downloader
