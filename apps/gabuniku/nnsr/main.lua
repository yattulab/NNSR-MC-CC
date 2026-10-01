local args = { ... }

---@type SubCommands
local command = args[1]

if command == "run" then
  require("commands.run").run(table.unpack(args, 2))
elseif command == "sync" then
  --require("commands.pull").run(table.unpack(args, 2))
elseif command == "list" then
  --require("commands.list").run(table.unpack(args, 2))
elseif command == "help" then
  --require("commands.help").run(table.unpack(args, 2))
else
  print("usage: nnsr <run|sync|help>")
end
