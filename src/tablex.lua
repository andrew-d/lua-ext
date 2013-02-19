--- A module that contains many helpful table extensions.
-- @module tablex

-- Our global environment.
local P = {}

-- Import section:
-- We declare everything this package needs from "outside" here.
local type = type
local pairs, ipairs = pairs, ipairs
local table = table
local error = error
local print = print

-- No more external access after this point.
if string.sub(_VERSION, 5) == '5.2' then
    _ENV = P
else
    setfenv(1, P)
end

-------------------------------------------------------------------------------
-- Performs a shallow-copy of the given table, optionally copying the input
-- table's metatable.
-- @param t The table to copy
-- @param copy_meta Whether or not to copy the input table's metatable.
-- Defaults to false.
-- @return A copy of t.
function copy(t, copy_meta)
    local ret = {}
    for k, v in pairs(t) do
        ret[k] = v
    end
    if copy_meta then
        setmetatable(ret, getmetatable(t))
    end
    return ret
end


-------------------------------------------------------------------------------
-- Performs a deep copy of the given table, recursively copying all keys and
-- values.  Will also update the new table's metatable to the original tables'.
-- @param t The table to copy
-- @return A deep copy of t.
function deepcopy(t)
    if type(t) ~= "table" then return t end

    local mt = getmetatable(t)
    local ret = {}
    for k, v in pairs(t) do
        if type(v) == "table" then
            v = deepcopy(v)
        end
        ret[k] = v
    end

    -- Note that we don't set this before we're done copying, as the original
    -- metatable might have __index / __newindex metamethods that interfere.
    setmetatable(ret, mt)
    return ret
end


-- Save old table.sort, in case we patch it.
local _sort = table.sort

-------------------------------------------------------------------------------
-- Sorts a table, and then returns the new table.  Useful for chaining.  Note
-- that this operation will sort the original table - i.e. it does not return
-- a copy of the table.
-- @param t The table to sort
-- @param func A comparator function
-- @return A sorted version of t
function sort(t, func)
    _sort(t, func)
    return t
end


-------------------------------------------------------------------------------
-- Returns whether or not the given table is empty (i.e. whether there are any
-- keys in the table with non-nil values).
-- @param t The table to check
-- @return A boolean value indicating whether the table is empty
function isempty(t)
    return not next(t)
end


-------------------------------------------------------------------------------
-- Get the size of the table (the number of keys with non-nil values in the
-- table).  Note that this is also alised as length() and count().
-- @param t The table to check
-- @return An integer that represents the size of the table
function size(t)
    local n = 0
    for _ in pairs(t) do
        n = n + 1
    end
    return n
end
length = size
count  = size


-------------------------------------------------------------------------------
-- Returns a list of the keys in a table.
-- @param t The table
-- @return The input table, cleared
function keys(t)
    local ret = {}
    for k, v in pairs(t) do
        table.insert(ret, k)
    end
    return ret
end


-------------------------------------------------------------------------------
-- Returns a list of the values in a table.
-- @param t The table
-- @return A list-like table representing the values found in t
function values(t)
    local ret = {}
    for k, v in pairs(t) do
        table.insert(ret, v)
    end
    return ret
end


-------------------------------------------------------------------------------
-- Clears the input table.
-- @param t The table to clear
-- @return The original table passed in, which is now empty
function clear(t)
    for k, v in pairs(t) do
        t[k] = nil
    end
    return t
end


-------------------------------------------------------------------------------
-- Copy one table into another, in-place.
-- @param t The table to copy into
-- @param u The table to copy from
-- @return The original table t
function update(t, u)
    for k, v in pairs(u) do
        t[k] = v
    end
    return ret
end


-------------------------------------------------------------------------------
-- Generate a table of all numbers in a range.
-- @param start The start index
-- @param fin   The number to end at
-- @param step  The step size, which can be negative (default: 1)
-- @return A list-like table of numbers
function range(start, fin, step)
    if start == fin then
        return {start}
    elseif start > fin then
        return {}
    end

    local ret = {}
    local counter = 1
    step = step or 1

    for i = start,fin,step do
        ret[counter] = i
        counter = counter + 1
    end

    return ret
end


-------------------------------------------------------------------------------
-- Transpose the table, swapping keys and values.
-- @param t The table to transpose
-- @return A copy of the table, with the keys and values transposes
function transpose(t)
    local ret = {}
    for k, v in pairs(t) do
        ret[v] = k
    end
    return ret
end



patch = nil
local excludes = {
    patch,
    range,
}
-------------------------------------------------------------------------------
-- Adds all the functions in this module to the 'table' table.  Note that we
-- exclude some functions that don't take a table as the first argument, such
-- as this function, the range() function, and so on.
patch = function()
    for key, val in pairs(P) do
        if val ~= patch then
            table[key] = val
        end
    end
end


return P
