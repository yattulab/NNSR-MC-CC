---@class PIDController
---@field kp number
---@field ki number
---@field kd number
---@field errors number[]
---@field integral number
---@field last_t number
local pid_controller = {}
pid_controller.__index = pid_controller

---@param kp number
---@param ki number
---@param kd number
function pid_controller.new(kp, ki, kd)
  local self = setmetatable({}, pid_controller)
  self.kp = kp
  self.ki = ki
  self.kd = kd
  self.errors = { 0, 0 }
  self.integral = 0
  self.last_t = os.epoch("utc")
  return self
end

---@param error number
---@param dt number?
function pid_controller:pid(error, dt)
  self.errors[1] = self.errors[2]
  self.errors[2] = error
  local now = os.epoch("utc")
  if dt == nil then
    dt = (now - self.last_t) / 1000
  end
  self.last_t = now

  self.integral = self.integral + ((self.errors[1] + self.errors[2]) / 2.0) * dt

  local p = error * self.kp
  local i = self.integral * self.ki
  local d = (self.errors[2] - self.errors[1]) / dt
  return p + i + d
end

return pid_controller
