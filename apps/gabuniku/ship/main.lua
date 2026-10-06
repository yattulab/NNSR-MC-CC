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

-- degree
local yaw_offset = 0

local Kp = 0.1
local Ki = 0.0
local Kd = 0.01
local pid_integral = 0.0
local pid_err = { 0, 0 }

local ap_state = {
  target_head = nil,
  target_speed = nil,
}

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

print("Ship Name : " .. sublevel.getName())

local function angleDiff(target, current)
  return (target - current + math.pi) % (2 * math.pi) - math.pi
end

local function getHeading()
  local _, yaw = sublevel.getLogicalPose().orientation:toEuler()

  return (math.deg(yaw) + yaw_offset) % 360
end

local function pid(target, dt)
  local p, i, d
  local err = angleDiff(target, getHeading())
  pid_err[0] = pid_err[1]
  pid_err[1] = err
  pid_integral = pid_integral + (pid_err[1] + pid_err[0]) / 2.0 * dt

  p = Kp * pid_err[1]
  i = Ki * pid_integral
  d = Kd * (pid_err[1] - pid_err[0]) / dt

  return p + i + d
end

local function control()
  local last = os.epoch("utc")
  while true do
    local now = os.epoch("utc")
    local dt = (now - last) / 1000
    last = now

    local ap_en = ap_lever.getInput(ship_conf.i_ap_enable.side)

    if steering.isHeld() then
      ap_en = false
    end
    local steer_in = 0
    local throttle = 0

    if ap_en then
      if ap_state.target_head then
        steer_in = pid(ap_state.target_head, dt)
      end
    else
      steer_in = steering.getNormalizedAngle()

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

      throttle = throttle_val / 15

      if invert then
        throttle = -throttle
      end
    end
    driver:drive(throttle, steer_in)

    sleep(0.05)
  end
end

local function consoleLoop()
  while true do
    write("> ")
    local line = read()

    local cmd, arg = line:match("^(%S+)%s*(.*)$")

    if cmd == "head" then
      ap_state.target_head = tonumber(arg)
    elseif cmd == "speed" then
      ap_state.target_speed = tonumber(arg)
    end
    --        elseif cmd == "ap" then
    --            state.ap = arg == "on"
    ---        end
  end
end

parallel.waitForAll(control, consoleLoop)
