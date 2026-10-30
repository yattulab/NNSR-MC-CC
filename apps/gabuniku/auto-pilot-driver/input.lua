local pe = require("ccpe.pe")
local ss = require("ccpe.sensor_system")

---@class InputDriver
---@field context InputContext
local input_driver = {}
input_driver.__index = input_driver

---@param context InputContext
---@return InputDriver
function input_driver.new(context)
  local self = setmetatable({}, input_driver)
  self.context = context
  return self
end

---@param config CCPEModulesConfig
local function getMonitorModule(config)
  monitor = pe.getPeripheral(config.channel)
  return monitor.getModule(config.id)
end
---@param config CCPEModulesConfig
local function getDeskModule(config)
  monitor = ss.getPeripheral(config.channel)
  return monitor.getModule(config.id)
end

---@return number | number[] normalized value [-1~1]
function input_driver:read()
  local driver_type = self.context.type
  local ctx = self.context
  local value = nil
  local config = ctx.config

  if driver_type == "redstone_relay" then
    if ctx.config.mode == "analog" then
      value = peripheral.call(ctx.name, "getAnalogInput", config.face)
    else
      value = peripheral.call(ctx.name, "getInput", config.face)
    end
    value = value / 15.0
  elseif driver_type == "throttle_lever" then
    value = peripheral.call(ctx.name, "getState") / 15.0
  elseif driver_type == "steering_wheel" then
    value = peripheral.call(ctx.name, "getNormalizedAngle")
  elseif driver_type == "ccpe:joystick" then
    local module = getDeskModule(config)
    local x = module.getAxisXSigned()
    local y = module.getAxisYSigned()
    --- [x,y]
    value = { x, y }
  elseif driver_type == "ccpe:throttle" then
    local module = getDeskModule(config)
    value = module.getAxis()
  elseif driver_type == "ccpe:pedal" then
    local module = getDeskModule(config)
    local l = module.getLeftPedal()
    local r = module.getRightPedal()
    --- [l,r]
    value = { l, r }
  elseif driver_type == "ccpe:button" then
    local module = getMonitorModule(config)
    value = module.isPressed()
  elseif driver_type == "ccpe:switch" then
    local module = getMonitorModule(config)
    value = module.getToggleState()
  elseif driver_type == "ccpe:knob" then
    local module = getMonitorModule(config)
    value = module.getRelativePercent()
  end
  return value
end

return input_driver
