-- Minimal TableSaverLoader stub to allow unit testing of persistence hooks.
local M = {}
local cache = {}

function M.Save(playerID, key, value)
  cache[playerID] = cache[playerID] or {}
  cache[playerID][key] = value
end

function M.Load(playerID, key)
  local bucket = cache[playerID]
  if bucket then
    return bucket[key]
  end
  return nil
end

return M
