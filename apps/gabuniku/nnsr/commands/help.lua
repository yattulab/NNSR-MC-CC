local help = {}

function help.help()
  print("package manager for nnsr-mc")
  print("Usage: nnsr [COMMAND] [ARGS]")
  print("")
  print("Commands:")
  print("  run   run program")
  print("  sync  download, update program code")
  print("  list  show downloaded programs")
  print("  help  print help")
  print("")
  print('See "nnsr help <command>" for more information')
end

function help.run(...)
  local args = { ... }
  if type(args) ~= "table" then
    help.help()
  else
    if args[1] == nil then
      help.help()
      return
    end

    local command = args[1]

    if command == "run" then
      require("commands.run").help()
    elseif command == "sync" then
      require("commands.sync").help()
    elseif command == "list" then
    elseif command == "help" then
      help.help()
    else
      printError("unknown command " .. command)
    end
  end
end

return help
