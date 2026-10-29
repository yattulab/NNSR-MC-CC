---@class OutputDriver
---@field context OutputContext
local output_driver = {}
output_driver.__index = output_driver

---@param context OutputContext
---@return OutputDriver
function output_driver.new(context)
  local self = setmetatable({}, output_driver)

  if context.type == "ccpe:transmission" then
    -- init servo mode
    peripheral.call(context.name, "setServoMode", context.config.mode == "servo")
    peripheral.call(context.name, "setServoSpeed", context.config.servo_rpm)
  elseif context.type == "ccpe:servo_bearing" or context.type == "ccpe:aero_bearing" then
    peripheral.call(context.name, "assemble")
  end
  self.context = context
  return self
end

---@param value number
function output_driver:write(value)
  local driver_type = self.context.type
  local ctx = self.context
  -- clap [-1,1]
  value = math.max(-1, math.min(1, value))
  if driver_type == "redstone_relay" then
    ---@type RedstoneRelayConfig
    local config = ctx.config
    if ctx.invert then
      value = 1.0 - value
    end
    if ctx.config.mode == "analog" then
      peripheral.call(ctx.name, "setAnalogOutput", value)
    else
      peripheral.call(ctx.name, "setOutput", (value > 0))
    end
  elseif driver_type == "ccpe:transmission" then
    ---@type TransmissionConfig
    local config = ctx.config
    if ctx.invert then
      value = -value
    end
    if config.mode == "transmission" then
      value = value * 256
      peripheral.call(ctx.name, "setTargetSpeed", value)
    else
      value = value * config.servo_max
      peripheral.call(ctx.name, "setServoAngle", value)
    end
  elseif driver_type == "ccpe:servo_bearing" or driver_type == "ccpe:aero_bearing" then
    ---@type BearingConfig
    local config = ctx.config
    if ctx.invert then
      value = -value
    end
    value = value * config.max_angle
    peripheral.call(ctx.name, "setTargetAngle", value)
  end
end

return output_driver
