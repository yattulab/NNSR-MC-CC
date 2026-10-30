--- test model for single
---@type DriverConfig
local config = {
  monitor = {
    channel = 2,
    id = 6,
  },
  inputs = {
    joy = {
      type = "ccpe:joystick",
      name = "joy",
      config = {
        channel = 0,
        id = "joystick_2",
      },
    },
    pedal = {
      type = "ccpe:pedal",
      name = "pedal",
      config = {
        channel = 2,
        id = "pedal",
      },
    },
    toggle_speed = {
      name = "toggle_speed",
      type = "ccpe:knob",
      config = {
        channel = 2,
        id = 5,
        is_desk = true,
      },
    },
    toggle_alt = {
      name = "toggle_alt",
      type = "ccpe:switch",
      config = {
        channel = 2,
        id = 4,
        is_desk = true,
      },
    },
    toggle_hover = {
      name = "toggle_hover",
      type = "ccpe:switch",
      config = {
        channel = 2,
        id = 3,
        is_desk = true,
      },
    },
    knob_speed = {
      name = "knob_speed",
      type = "ccpe:knob",
      config = {
        channel = 2,
        id = 1,
        is_desk = true,
      },
    },
    knob_alt = {
      name = "knob_alt",
      type = "ccpe:knob",
      config = {
        channel = 2,
        id = 2,
        is_desk = true,
      },
    },
    knob_angle = {
      name = "knob_angle",
      type = "ccpe:knob",
      config = {
        channel = 2,
        id = 0,
        is_desk = true,
      },
    },
    throttle = {
      name = "throttle",
      type = "ccpe:throttle",
      config = {
        channel = 1,
        id = "throttle",
      },
    },
  },
  outputs = {
    speed_l = {
      name = "ccpe:transmission_peripheral_16",
      type = "ccpe:transmission",
      config = {
        mode = "transmission",
      },
    },
    speed_r = {
      name = "ccpe:transmission_peripheral_18",
      type = "ccpe:transmission",
      config = {
        mode = "transmission",
      },
    },
    angle_l = {
      name = "ccpe:transmission_peripheral_15",
      type = "ccpe:transmission",
      invert = true,
      config = {
        mode = "servo",
        servo_max = 90,
        servo_rpm = 16,
      },
    },
    angle_r = {
      name = "ccpe:transmission_peripheral_17",
      type = "ccpe:transmission",
      config = {
        mode = "servo",
        servo_max = 90,
        servo_rpm = 16,
      },
    },
  },
}

return config
