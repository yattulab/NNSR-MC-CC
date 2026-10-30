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
local vehicle_id = sublevel.getName()
print(vehicle_id)
local ss = require("ccpe.sensor_system")
---@type InputDriver
local inputlib = require("gabuniku.auto-pilot-driver.input")
---@type OutputDriver
local outputlib = require("gabuniku.auto-pilot-driver.output")
---@type LPFController
local lpflib = require("gabuniku.auto-pilot-control.lpf")

---@type DriverConfig
local conf = require("configs." .. vehicle_id)

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

local function getHoverRPM()
  local pos = ss.getBodyPosition()
  local pressure = ss.getPressureFromAltitude(pos.y)
  local gravity = ss.getPhysicsChainGravityForce()
  return ss.getPropellerRPM(gravity, pressure, 0, 0)
end

local function control()
  local desk = ss.getPeripheral(conf.inputs.throttle.config.channel)
  local throttle_module = desk.getModule(conf.inputs.throttle.config.id)
  throttle_module.setFreeMode(true)

  desk = ss.getPeripheral(conf.monitor.channel)
  local screen = desk.getModule("monitor").getModule(6)
  screen.clear()
  screen.setTextScale(0.5, 1.0)
  screen.write("ID : " .. vehicle_id)

  -- FMC
  ss.initPropeller(2, 17)

  local prev_toggle_hover = vehicle.toggle_hover:read()

  while true do
    local joy = vehicle.joy:read()
    local throttle = vehicle.throttle:read()
    local yaw = vehicle.pedal:read()
    local hover_angle = vehicle.knob_angle:read()
    local hover_enable = vehicle.toggle_hover:read()

    local speed_l = 0.0
    local speed_r = 0.0
    local angle_l = 0.0
    local angle_r = 0.0

    if (hover_enable ~= prev_toggle_hover) and hover_enable > 0 then
      local rpm = getHoverRPM()
      throttle_module.setAxis(rpm / 256.0)
    end
    prev_toggle_hover = hover_enable

    if hover_enable > 0 then
      -- hover
      speed_l = throttle + (joy[1] * 0.2)
      speed_r = throttle - (joy[1] * 0.2)
      angle_l = joy[2] * 0.5 + (yaw[2] * 0.3)
      angle_r = joy[2] * 0.5 + (yaw[1] * 0.3)
    else
      -- flight
      speed_l = throttle + (yaw[2] * 0.25)
      speed_r = throttle + (yaw[1] * 0.25)
      angle_l = hover_angle - (joy[1] * 0.25) + (joy[2] * 0.25)
      angle_r = hover_angle + (joy[1] * 0.25) + (joy[2] * 0.25)
    end

    -- update screen

    parallel.waitForAll(function()
      vehicle.speed_l:write(speed_l)
    end, function()
      vehicle.speed_r:write(speed_r)
    end, function()
      vehicle.angle_l:write(angle_l)
    end, function()
      vehicle.angle_r:write(angle_r)
    end)
    -- sleep(0.05)
  end
end

local function console()
  while true do
    sleep(1)
  end
end

parallel.waitForAll(control, console)
