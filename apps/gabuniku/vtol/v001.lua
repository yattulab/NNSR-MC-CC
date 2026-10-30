---@package
---@class THI_V001
---@field joy InputDriver
---@field pedal InputDriver
---@field toggle_speed InputDriver
---@field toggle_alt InputDriver
---@field toggle_hover InputDriver
---@field knob_speed InputDriver
---@field knob_alt InputDriver
---@field knob_angle InputDriver
---@field throttle InputDriver
---@field speed_l OutputDriver
---@field speed_r OutputDriver
---@field angle_l OutputDriver
---@field angle_r OutputDriver

local args = { ... }

---@type InputDriver
local inputlib = require("gabuniku.auto-pilot-driver.input")
---@type OutputDriver
local outputlib = require("gabuniku.auto-pilot-driver.output")

---@type DriverConfig
local conf = require("configs.THI-QKSR")

---@type THI_V001
local vehicle = {
  joy = inputlib.new(conf.inputs.joy),
  pedal = inputlib.new(conf.inputs.pedal),
  toggle_speed = inputlib.new(conf.inputs.toggle_speed),
  toggle_alt = inputlib.new(conf.inputs.toggle_alt),
  toggle_hover = inputlib.new(conf.inputs.toggle_hover),
  knob_speed = inputlib.new(conf.inputs.knob_speed),
  knob_alt = inputlib.new(conf.inputs.knob_alt),
  knob_angle = inputlib.new(conf.inputs.knob_angle),
  throttle = inputlib.new(conf.inputs.throttle),

  speed_l = outputlib.new(conf.outputs.speed_l),
  speed_r = outputlib.new(conf.outputs.speed_r),
  angle_l = outputlib.new(conf.outputs.angle_l),
  angle_r = outputlib.new(conf.outputs.angle_r),
}

while true do
  local joy = vehicle.joy:read()
  local throttle = vehicle.throttle:read()
  local yaw = vehicle.pedal:read()

  local speed_l = throttle + (joy[1] * 0.2)
  local speed_r = throttle - (joy[1] * 0.2)
  local angle_l = joy[2] * 0.5 + (yaw[2] * 0.1)
  local angle_r = joy[2] * 0.5 + (yaw[1] * 0.1)

  vehicle.speed_l:write(speed_l)
  vehicle.speed_r:write(speed_r)
  vehicle.angle_l:write(angle_l)
  vehicle.angle_r:write(angle_r)

  sleep(0.05)
end
