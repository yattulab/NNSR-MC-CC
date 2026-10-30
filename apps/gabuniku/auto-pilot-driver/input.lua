local pe = require("ccpe.pe")
local ss = require("ccpe.sensor_system")

---@class InputDriver
---@field context InputContext
---@field private module table
local input_driver = {}
input_driver.__index = input_driver

---@param config CCPEModulesConfig
local function getMonitorModule(config)
  local monitor
  if config.is_desk then
    local desk = ss.getPeripheral(config.channel)
    monitor = desk.getModule("monitor")
  else
    monitor = pe.getPeripheral(config.channel)
  end
  return monitor.getModule(config.id)
end
---@param config CCPEModulesConfig
local function getDeskModule(config)
  local desk = ss.getPeripheral(config.channel)
  return desk.getModule(config.id)
end

---@param context InputContext
---@return InputDriver
function input_driver.new(context)
  local self = setmetatable({}, input_driver)
  self.context = context
  local typ = context.type
  if typ == "ccpe:joystick" or typ == "ccpe:throttle" or typ == "ccpe:pedal" then
    self.module = getDeskModule(context.config)
  elseif typ == "ccpe:button" or typ == "ccpe:knob" or typ == "ccpe:switch" then
    self.module = getMonitorModule(context.config)
  end
  return self
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
    local x = self.module.getAxisXSigned()
    local y = self.module.getAxisYSigned()
    --- [x,y]
    value = { x, y }
  elseif driver_type == "ccpe:throttle" then
    value = self.module.getAxis()
  elseif driver_type == "ccpe:pedal" then
    local l = self.module.getLeftPedal()
    local r = self.module.getRightPedal()
    --- [l,r]
    value = { l, r }
  elseif driver_type == "ccpe:button" then
    value = self.module.isPressed() and 1 or 0
  elseif driver_type == "ccpe:switch" then
    value = self.module.getToggleState() and 1 or 0
  elseif driver_type == "ccpe:knob" then
    value = self.module.getRelativePercent()
  end
  return value
end

return input_driver
