---@meta
---@alias OutputType
---| "redstone_relay"
---| "ccpe:transmission"
---| "ccpe:servo_bearing"
---| "ccpe:aero_bearing"

---@class RedstoneRelayConfig
---@field face string
---@field mode "digital" | "analog"

---@class TransmissionConfig
---@field mode "transmission" | "servo"
---@field servo_rpm number
---@field servo_max number

---@class BearingConfig
---@field max_angle number

---@class OutputContext
---@field type OutputType
---@field name string
---@field invert boolean?
---@field config RedstoneRelayConfig | TransmissionConfig | BearingConfig | nil
