---@meta
--- OUTPUT
---@alias OutputType
---| "redstone_relay"
---| "analog_transmission"
---| "ccpe:transmission"
---| "ccpe:servo_bearing"
---| "ccpe:aero_bearing"

---@class RedstoneRelayConfig
---@field face string
---@field mode "digital" | "analog"

---@class TransmissionConfig
---@field mode "transmission" | "servo"
---@field servo_rpm number?
---@field servo_max number?

---@class BearingConfig
---@field max_angle number

---@class OutputContext
---@field type OutputType
---@field name string
---@field invert boolean?
---@field config RedstoneRelayConfig | TransmissionConfig | BearingConfig | nil

--- INPUT
---@alias InputType
---| "redstone_relay"
---| "throttle_lever"
---| "steering_wheel"
---| "ccpe:joystick"
---| "ccpe:throttle"
---| "ccpe:pedal"
---| "ccpe:button"
---| "ccpe:switch"
---| "ccpe:knob"

---@alias CCPEDeskModuleType
---| "pedal"
---| "joystick"
---| "joystick_2"
---| "joystick_3"
---| "throttle"
---| "throttle_2"
---| "monitor_2"

---@class CCPEModulesConfig
---@field channel number
---@field id number | CCPEDeskModuleType
---@field is_desk boolean?

---@class InputContext
---@field type InputType
---@field name string
---@field invert boolean?
---@field config RedstoneRelayConfig | CCPEModulesConfig | nil

---@class DriverConfig
---@field inputs table<string, InputContext>
---@field outputs table<string, OutputContext>
