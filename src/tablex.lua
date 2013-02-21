--- A module that contains many helpful table extensions.
-- @module tablex

-- Our global environment.
local P = {}

-- Import section:
-- We declare everything this package needs from "outside" here.
local type = type
local pairs, ipairs, next = pairs, ipairs, next
local table = table
local error = error
local print = print
local getmetatable, setmetatable = getmetatable, setmetatable

local tostring = tostring


-- No more external access after this point.
if string.sub(_VERSION, 5) == '5.2' then
    _ENV = P
else
    setfenv(1, P)
end


-- Helper function to copy metatables.
local function copymeta(src, dest, default)
    setmetatable(dest, getmetatable(src) or default)
    return dest
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
    step = step or 1

    if start == fin then
        return {start}
    end

    local ret = {}
    local counter = 1

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


-------------------------------------------------------------------------------
-- Compare two tables using a given comparison function.
-- @param t The table to compare
-- @param t2 The table to compare against
-- @param cmp The comparison function.  Should return a truthy value of two
-- table values are equal.
-- @return A boolean indicating whether the two tables are equal.
function compare(t, t2, cmp)
    for k, v in pairs(t) do
        if not cmp(v, t2[k]) then return false end
    end
    for k, v in pairs(t2) do
        if not cmp(v, t[k]) then return false end
    end
    return true
end


-------------------------------------------------------------------------------
-- Compare two list-like tables using a given comparison function.
-- @param t The list-like table to compare
-- @param t2 The list-like table to compare against
-- @param cmp The comparison function.  Should return a truthy value of two
-- table values are equal.
-- @return A boolean indicating whether the two tables are equal.
function comparei(t, t2, cmp)
    if #t ~= #t2 then return false end

    for i, v in ipairs(t) do
        if not cmp(v, t2[i]) then
            return false
        end
    end

    return true
end


-------------------------------------------------------------------------------
-- Compare two list-like tables using a given comparison function, without
-- caring about element order.
-- @param t The list-like table to compare
-- @param t2 The list-like table to compare against
-- @param cmp The comparison function.  Should return a truthy value of two
-- table values are equal.
-- @return A boolean indicating whether the two tables are equal.
function compare_unordered(t, t2, cmp)
    if #t ~= #t2 then return false end

    local seen = {}
    for i, v in ipairs(t) do
        local found = nil

        -- We search through all elements in the table that we haven't already
        -- "seen".
        for j, v2 in ipairs(t2) do
            if not seen[j] then
                if cmp(v, v2) then
                    found = j
                    break
                end
            end
        end

        if not found then
            return false
        end

        -- We mark the index in the second array as 'seen', so we don't match
        -- it again.
        seen[found] = true
    end

    return true
end


-------------------------------------------------------------------------------
-- Returns the index of the first value in a list-like table.
-- @param t The list-like table to search
-- @param val The value to search for
-- @param start The starting index to search at.  Negative indexes are taken
-- from the end of the list (defaults to 1).
-- @return An integer index if found, or nil otherwise
function find(t, val, start)
    start = start or 1

    if start < 0 then
        start = #t + start + 1
    end

    for i = start, #t do
        if t[i] == val then
            return i
        end
    end

    return nil
end


-------------------------------------------------------------------------------
-- Returns the index of the last value in a list-like table.
-- @param t The list-like table to search
-- @param val The value to search for
-- @param start The starting index to search at.  Negative indexes are taken
-- from the end of the list (defaults to 1).
-- @return An integer index if found, or nil otherwise
function rfind(t, val, start)
    start = start or 1

    if start < 0 then
        start = #t + start + 1
    end

    for i = #t, start, -1 do
        if t[i] == val then
            return i
        end
    end

    return nil
end


-------------------------------------------------------------------------------
-- Apply a function to all values of a table, returning a table of the results.
-- This function will copy the metatable of the input table to the output.
-- @param t The table
-- @param func A function that takes 1 or more arguments
-- @param ... Any additional arguments to pass to the function
-- @return A table containing the results of applying func(t[value], ...) for
-- all values in t.
function map(t, func, ...)
    local ret = {}
    for k, v in pairs(t) do
        ret[k] = func(v, ...)
    end
    return copymeta(t, ret)
end


-------------------------------------------------------------------------------
-- Apply a function to all values in a list-like table, returning a list-like
-- table of the results.
-- @param t The list-like table
-- @param func A function that takes 1 or more arguments
-- @param ... Any additional arguments to pass to the function
-- @return A list-like table containing the results of applying
-- func(t[value], ...) for all values in t.
function mapi(t, func, ...)
    local ret = {}
    for k, v in ipairs(t) do
        ret[k] = func(v, ...) or false
    end
    return copymeta(t, ret)
end


-------------------------------------------------------------------------------
-- Apply a function to all values of a table, modifying the table in-place.
-- @param t The table
-- @param func A function that takes 1 or more arguments
-- @param ... Any additional arguments to pass to the function
-- @return The original table, t
function transform(t, func, ...)
    for k, v in pairs(t) do
        t[k] = func(v, ...)
    end
    return t
end


-------------------------------------------------------------------------------
-- Apply a function that takes two arguments to all elements in a list-like
-- table, from left to right.  This reduces the sequence to a single value.
-- If the 'initial' parameter is given, then it will also act as the default
-- value if the sequence is empty.  Otherwise, if the sequence is empty and
-- no initial value is given, this function will return nil.
-- @param t The table
-- @param func A function that takes two arguments and returns a single value
-- @param initial (optional) The initial value to use.  If present, this is
-- placed "before" the other elements in the sequence
-- @return The result of the reduce operation.
function reduce(t, func, initial)
    if #t == 0 then return initial end

    -- Perform the reduce
    local start, ret

    if initial then
        ret = initial
        start = 1
    else
        ret = t[1]
        start = 2
    end

    for i = start,#t do
        ret = func(ret, t[i])
    end

    return ret
end


-- We need to exclude certain things from being patched (mainly, the patch
-- function itself).
patch = nil
local excludes = {
    ['patch'] = true,
    ['range'] = true,
}

-------------------------------------------------------------------------------
-- Adds all the functions in this module to the 'table' table.  Note that we
-- exclude some functions that don't take a table as the first argument, such
-- as this function, the range() function, and so on.
-- @param mod If given, the module to patch these functions into.  Defaults to
-- the table module.
patch = function(mod)
    mod = mod or table
    for key, val in pairs(P) do
        if not excludes[key] then
            mod[key] = val
        end
    end
end


return P
