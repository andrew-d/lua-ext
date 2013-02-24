--- A module that adds helpful extensions to the math library.
-- @module mathx

-- Our global environment.
local P = {}

-- Import section:
-- We declare everything this package needs from "outside" here.
local math = math

-- No more external access after this point.
if string.sub(_VERSION, 5) == '5.2' then
    _ENV = P
else
    setfenv(1, P)
end


local _floor = math.floor

-------------------------------------------------------------------------------
-- Extends the math.floor function to take a number of decimal places.
-- @param n The number to floor
-- @param p The number of decimal places
-- @return The number n, truncated to p decimal places
function floor(n, p)
    if p and p ~= 0 then
        local scale = 10 ^ p
        return _floor(n * scale) / scale
    else
        return _floor(n)
    end
end


-------------------------------------------------------------------------------
-- Round a number to a given number of decimal places.
-- @param n The number to round
-- @param p The number of decimal places
-- @return The number n, rounded to p decimal places
function round(n, p)
    local scale = 10 ^ (p or 0)
    return _floor(n * scale + 0.5) / scale
end


-------------------------------------------------------------------------------
-- Adds all the functions in this module to the 'math' table.  Note that we
-- exclude this function itself.
function patch()
    for key, val in pairs(P) do
        if val ~= patch then
            math[key] = val
        end
    end
end


return P
