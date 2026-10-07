---@class Driver
---@field peripheral ShipPeripheral
local Driver = {}
Driver.__index = Driver

---Driver
---@param peri ShipPeripheral
---@return Driver
function Driver.new(peri)
  ---@type Driver
  local obj = setmetatable({}, Driver)
  obj.peripheral = peri
  peripheral.call("ccpe:transmission_peripheral_0", "resetServo")
  return obj
end

---@param peri IOPeripheral
---@param value boolean
local function setOutput(peri, value)
  if peri.invert then
    value = not value
  end
  peripheral.call(peri.device, "setOutput", peri.side, value)
end

---@param peri IOPeripheral
---@param value number
local function setAnalogOutput(peri, value)
  if peri.invert then
    value = 15 - value
  end
  peripheral.call(peri.device, "setAnalogOutput", peri.side, value)
end

---@param throttle number
---@param rudder number
function Driver:drive(throttle, rudder)
  setAnalogOutput(self.peripheral.o_throttle, math.abs(throttle * 15))
  --local rs_steer = 15 * rudder
  --local steer_l = math.max(rs_steer, 0)
  --local steer_r = math.abs(math.min(rs_steer, 0))

  peripheral.call("ccpe:transmission_peripheral_0", "setServoAngle", rudder * 60)

  -- setAnalogOutput(self.peripheral.o_rudder_l, steer_l)
  -- setAnalogOutput(self.peripheral.o_rudder_r, steer_r)

  if throttle > 0 then
    setOutput(self.peripheral.o_shift_l, false)
    setOutput(self.peripheral.o_shift_r, true)
  else
    setOutput(self.peripheral.o_shift_l, true)
    setOutput(self.peripheral.o_shift_r, false)
  end
end

return Driver
