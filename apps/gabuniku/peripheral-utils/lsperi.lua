local args = { ... }

local peri = peripheral.getNames()

print("NAME               Type")

for _, name in ipairs(peri) do
  local peri_type = peripheral.getType(name) or "nil"
  print(("%-18s %s"):format(name, peri_type))
end
