local Log = {}

local function push(level, message)
  print(string.format("[Perimeter][%s] %s", level, tostring(message)))
end

function Log.info(msg)
  push("INFO", msg)
end

function Log.warn(msg)
  push("WARN", msg)
end

function Log.error(msg)
  push("ERROR", msg)
end

return Log
