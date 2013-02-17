--- A module for benchmarking arbitrary Lua code.
-- @module benchmark

-- Our global environment.
local P = {}

-- Import section:
-- We declare everything this package needs from "outside" here.
local os = os
local util = require('util')

-- No more external access after this point.
if string.sub(_VERSION, 5) == '5.2' then
    _ENV = P
else
    setfenv(1, P)
end


-------------------------------------------------------------------------------
-- Benchmark a function with given arguments.
-- @param f The function to call
-- @param ... Any arguments to pass to the function f
-- @return The time the function took, in seconds
function benchmark(f, ...)
    local start = os.clock()
    f(...)
    return os.clock() - start
end


-------------------------------------------------------------------------------
-- Benchmark a function, running it a given number of times.
-- @param num The number of times to run the function
-- @param f The function to call
-- @param ... Any arguments to pass to the function f
-- @return The average time taken
-- @return The total time taken
function benchmark_n(num, f, ...)
    local total = 0

    for i = 1,num do
        local start = os.clock()
        f(...)
        total = total + (os.clock() - start)
    end

    return total / num, total
end


return P
