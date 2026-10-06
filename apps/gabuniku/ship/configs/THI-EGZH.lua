---@type ShipPeripheral
local input_peripherals = {
  i_steering = {
    device = "steering_wheel_0",
    invert = true,
  },
  i_throttle = {
    device = "redstone_relay_9",
    side = "top",
  },
  i_invert = {
    device = "redstone_relay_9",
    side = "right",
    invert = false,
  },
  i_ap_enable = {
    device = "top",
    side = "right",
  },
  -- i_turn_enable = {},
  -- i_turn_dir = {},
  o_throttle = {
    device = "redstone_relay_10",
    side = "bottom",
    invert = true,
  },
  o_rudder_l = {
    device = "redstone_relay_6",
    side = "right",
  },
  o_rudder_r = {
    device = "redstone_relay_7",
    side = "left",
  },
  o_shift_l = {
    device = "redstone_relay_4",
    side = "right",
  },
  o_shift_r = {
    device = "redstone_relay_5",
    side = "left",
  },
}

return input_peripherals
