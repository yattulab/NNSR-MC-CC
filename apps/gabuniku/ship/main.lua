local args = { ... }

local steering = peripheral.wrap("steering_wheel_0")
print(steering)

---@type ccTweaked.peripheral.RedstoneRelay
local top_lever = peripheral.wrap("top")

---@type ccTweaked.peripheral.RedstoneRelay
local throttle_in = peripheral.wrap("redstone_relay_9")

---@type ccTweaked.peripheral.RedstoneRelay
local rudder_l = peripheral.wrap("redstone_relay_6")

---@type ccTweaked.peripheral.RedstoneRelay
local rudder_r = peripheral.wrap("redstone_relay_7")

---@type ccTweaked.peripheral.RedstoneRelay
local throttle = peripheral.wrap("redstone_relay_10")

---@type ccTweaked.peripheral.RedstoneRelay
local shift_l = peripheral.wrap("redstone_relay_4")

---@type ccTweaked.peripheral.RedstoneRelay
local shift_r = peripheral.wrap("redstone_relay_5")

while true do
  local steer_in = steering.getNormalizedAngle()
  local rs_steer = 15 * steer_in
  local steer_l = math.max(rs_steer, 0)
  local steer_r = math.abs(math.min(rs_steer, 0))

  local throttle_val = throttle_in.getAnalogInput("top")
  local invert = throttle_in.getInput("right")

  print(("%d, %s, %s"):format(throttle_val, invert))

  rudder_l.setAnalogOutput("right", steer_l)
  rudder_r.setAnalogOutput("left", steer_r)

  throttle.setAnalogOutput("bottom", 15 - throttle_val)

  shift_l.setOutput("right", invert)
  shift_r.setOutput("left", not invert)

  sleep(0.05)
end
