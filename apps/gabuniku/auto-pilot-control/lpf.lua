---@class LPFController
---@field private alpha number
---@field private current number
local lpf = {}
lpf.__index = lpf

---@param alpha number
---@param init_val number?
function lpf.new(alpha, init_val)
  local self = setmetatable({}, lpf)
  self.alpha = alpha
  self.current = init_val or 0
  return self
end

---@param target number
---@return number
function lpf:lpf(target)
  self.current = self.current + (target - self.current) * self.alpha
  return self.current
end

return lpf
