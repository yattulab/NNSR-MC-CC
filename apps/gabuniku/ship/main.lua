---@class IOPeripheral
---@field device string
---@field side string?
---@field invert boolean?

---@class ShipPeripheral
---@field i_steering IOPeripheral
---@field i_throttle IOPeripheral
---@field o_rudder_l IOPeripheral
---@field o_rudder_r IOPeripheral
---@field o_shift_l IOPeripheral
---@field o_shift_r IOPeripheral
---@field o_throttle IOPeripheral
---@field i_invert IOPeripheral
---@field i_turn_dir IOPeripheral
---@field i_turn_enable IOPeripheral
---@field i_ap_enable IOPeripheral

local args = { ... }

---@type ShipPeripheral
local ship_conf = require("configs/THI-EGZH")

---@type Driver
local driverlib = require("driver")

local driver = driverlib.new(ship_conf)

local steering = peripheral.wrap(ship_conf.i_steering.device)

---@type ccTweaked.peripheral.RedstoneRelay
local ap_lever = peripheral.wrap(ship_conf.i_ap_enable.device)

---@type ccTweaked.peripheral.RedstoneRelay
local throttle_in = peripheral.wrap(ship_conf.i_throttle.device)

while true do
  local steer_in = steering.getNormalizedAngle()

  if ship_conf.i_steering.invert then
    steer_in = -steer_in
  end

  local throttle_val = throttle_in.getAnalogInput(ship_conf.i_throttle.side)

  if ship_conf.i_throttle.invert then
    throttle_val = 15 - throttle_val
  end

  local invert = throttle_in.getInput(ship_conf.i_invert.side)
  if ship_conf.i_invert.invert then
    invert = not invert
  end

  local throttle = throttle_val / 15

  if invert then
    throttle = -throttle
  end

  driver:drive(throttle, steer_in)

  sleep(0.05)
end
