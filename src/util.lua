--- Miscellaneous utility functions.
-- @module util

-- Our global environment.
local P = {}

-- Import section:
-- We declare everything this package needs from "outside" here.
local require = require
local pcall = pcall

-- No more external access after this point.
if platform.lua_version == '5.2' then
    _ENV = P
else
    setfenv(1, P)
end

-------------------------------------------------------------------------------
-- Requires a module, returning nil if it doesn't exist.
-- @param ... The argument(s) to pass to require
-- @return The module's table, or nil if it doesn't exist
function safe_require(...)
    local err, ret = pcall(require, ...)
    if err then
        return ret
    else
        return nil
    end
end


return P
