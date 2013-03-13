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
local math = math
local unpack = unpack

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


-- Default equality comparison function
local function _default_cmp(x, y)
    return x == y
end

-------------------------------------------------------------------------------
-- Compare two tables using a given comparison function.
-- @param t The table to compare
-- @param t2 The table to compare against
-- @param cmp The comparison function.  Should return a truthy value of two
-- table values are equal.
-- @return A boolean indicating whether the two tables are equal.
function compare(t, t2, cmp)
    cmp = cmp or _default_cmp
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

    cmp = cmp or _default_cmp
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
    cmp = cmp or _default_cmp

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

        -- We mark the index in the second list as 'seen', so we don't match
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
-- This is the same as the map() function, except it operates in-place.
-- @see map
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
-- Apply a function to any number of list-like tables, returning a list-like
-- table containing the results.  Note that this function will only map up to
-- the minimum length of all input tables.
-- @param func A function that takes a number of arguments equal to the number
-- of tables that were passed in.
-- @param ... Any number of tables passed.
-- @return A table containing the results of applying func(t1[i],  t2[i], ...)
-- for all i.
function mapn(func, ...)
    local ret = {}
    local lists = {...}
    local len = math.huge

    for i = 1,#lists do
        len = math.min(len, #(lists[i]))
    end

    for i = 1,len do
        local args = {}

        for j = 1,#lists do
            table.insert(args, lists[j][i])
        end

        table.insert(ret, func(unpack(args)))
    end

    return ret
end


-------------------------------------------------------------------------------
-- Apply a function that takes two arguments to all elements in a list-like
-- table, from left to right.  This reduces the sequence to a single value.
-- If the 'initial' parameter is given, then it will also act as the default
-- value if the sequence is empty.  Otherwise, if the sequence is empty and
-- no initial value is given, this function will return nil.
-- Note: this function is aliased as "foldl".
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
foldl = reduce


-------------------------------------------------------------------------------
-- Return a list-like table of list-like tables, such that each sub-table
-- contains the i-th element from the two input values.  For example,
-- zip({1,2,3}, {4,5,6}) == {{1,4}, {2,5}, {3,6}}
-- @param t The first table
-- @param t2 The second table
-- @return The zipped table, as above.
function zip(t, t2)
    local ret = {}
    local cnt = math.min(#t, #t2)

    for i = 1,cnt do
        ret[i] = {t[i], t2[i]}
    end

    return ret
end


-------------------------------------------------------------------------------
-- Return a list-like table of list-like tables, such that each sub-table
-- contains the i-th element from the each of the input values.  For example,
-- zip({1,2,3}, {4,5,6}) == {{1,4}, {2,5}, {3,6}}.  Note that this function is
-- less efficient on two values than zip().
-- @param t The first table
-- @param ... Any number of additional tables to zip.
-- @return The zipped table, as above.
function zipn(...)
    local ret = {}
    local args = {...}
    local len = math.huge

    -- Get max length of all input lists.
    for i = 1,#args do
        len = math.min(len, #(args[i]))
    end

    -- For all items in the lists...
    for i = 1,len do
        local item = {}

        for j = 1,#args do
            table.insert(item, args[j][i])
        end

        table.insert(ret, item)
    end

    return ret
end


-- Normalize given values of a slice (i.e. t[start:end] in python terms)
function normalize_slice(t, start, fin)
    local len = #t

    start = start or 1
    fin = fin or len

    if start < 0 then
        start = len + start + 1
    end

    if fin < 0 then
        fin = len + fin + 1
    end

    return start, fin
end


-------------------------------------------------------------------------------
-- Extract a range of values from a list-like table.
-- @param t A list-like table
-- @param start If given, the start index.  Defaults to 1, negative indexes are
-- from the end of the table.
-- @param fin If given, the end index.  Defaults to #t, negative indexes are
-- from the end of the table.
-- @return A list-like table with the contents of the specified slice.
function sub(t, start, fin)
    start, fin = normalize_slice(t, start, fin)

    local ret = {}
    for i = start,fin do
        table.insert(ret, t[i])
    end

    return ret
end


-------------------------------------------------------------------------------
-- This function deletes every key-value pair from the given table for which
-- the provided function returns true.
-- @param t The table to delete from
-- @param func A function that is passed the key and value, and should return
-- true if the pair is to be deleted, or false otherwise
-- @return The original table
function delete_if(t, func)
    for k, v in pairs(t) do
        if func(k, v) == true then
            t[k] = nil
        end
    end
    return t
end


-------------------------------------------------------------------------------
-- This function performs the same operation as delete_if, except it does not
-- modify the original table and instead returns a copy.
-- @see delete_if
-- @param t The table to delete from
-- @param func A function that is passed the key and value, and should return
-- true if the pair is to be deleted, or false otherwise
-- @return A new table that contains all values for which func(k, v) did not
-- return true.
function reject(t, func)
    local ret = {}
    for k, v in pairs(t) do
        if func(k, v) == false then
            ret[k] = v
        end
    end
    return ret
end


-------------------------------------------------------------------------------
-- This function deletes every key-value pair from the given table for which
-- the provided function returns a non-true value.  I.e. it keeps all items
-- for which the function returns true.
-- @param t The table to process
-- @param func A function that is passed the key and value, and should return
-- true if the pair is to be kept, or false otherwise
-- @return The original table
function keep_if(t, func)
    for k, v in pairs(t) do
        if func(k, v) ~= true then
            t[k] = nil
        end
    end
    return t
end


-------------------------------------------------------------------------------
-- This function performs the same operation as keep_if, except that it returns
-- a new table and does not modify the original.
-- @see keep_if
-- @param t The table to process
-- @param func A function that is passed the key and value, and should return
-- true if the pair is to be kept, or false otherwise
-- @return A new table that contains all values for which func(k, v) returned
-- true
function select(t, func)
    local ret = {}
    for k, v in pairs(t) do
        if func(k, v) == true then
            ret[k] = v
        end
    end
    return ret
end


local function value_identity(k, v)
    return v
end


-------------------------------------------------------------------------------
-- This function passes each key/value pair in the given table to func, and
-- will return true if the block ever returns a truthy value.  If func is not
-- given, then the implementation will default to function(k, v) return v end -
-- i.e. will test the truthiness of the values.
-- @param t The table to test
-- @param func A function that receives all key/value pairs
-- @return A boolean value which represents whether the given function ever
-- returned a truthy value.
function any(t, func)
    func = func or value_identity

    for k, v in pairs(t) do
        if func(k, v) then
            return true
        end
    end

    return false
end


-------------------------------------------------------------------------------
-- This function passes each key/value pair in the given table to func, and
-- will return true if the block returns a truthy value for all key/value
-- pairs.  If func is not given, then the implementation will default to
-- function(k, v) return v end - i.e. will test the truthiness of the values.
-- @param t The table to test
-- @param func A function that receives all key/value pairs
-- @return A boolean value which represents whether the given function returns
-- a truthy value for all k/v pairs.
function all(t, func)
    func = func or value_identity

    for k, v in pairs(t) do
        if not func(k, v) then
            return false
        end
    end

    return true
end


-------------------------------------------------------------------------------
-- This function wll pass every key/value pair in the table to the given
-- function, and will return the first pair for which the function returns a
-- non-falsy value.
-- @param t The table to search
-- @param func A function that will receive key/value pairs
-- @return The first k, v for which func(k, v) returns a non-falsy value, or
-- nil if no non-falsy value was returned
function detect(t, func)
    for k, v in pairs(t) do
        if func(k, v) then
            return k, v
        end
    end

    return nil
end


-------------------------------------------------------------------------------
-- Removes elements from the given list-like table up to, but not including,
-- the first element for which func(k, v) returns a falsy value.
-- @param t The table to process
-- @param func A function that receives key/value pairs, and returns a single
-- value
-- @return A new list-like table with all elements including and after the
-- first element for which func(k, v) returns a falsy value
function drop_while(t, func)
    local ret = {}
    local adding = false
    for k, v in ipairs(t) do
        if adding then
            table.insert(ret, v)
        else
            if not func(k, v) then
                adding = true
                table.insert(ret, v)
            end
        end
    end

    return ret
end


-------------------------------------------------------------------------------
-- Groups the given table by the return value of the given function.  The
-- returned table will have keys that are the results of func(i, v), and values
-- as a list-like table with the corresponding values.
-- @param t The table to group
-- @param func A function that takes an index/value pair and should return a
-- single value.
-- @return A table, with keys that are the results of func(i, v), and values
-- that are list-like tables containing all values.
function group_by(t, func)
    local ret = {}
    for i, v in ipairs(t) do
        local key = func(i, v)
        if ret[key] == nil then
            ret[key] = {}
        end

        table.insert(ret[key], v)
    end

    return ret
end


local function generic_compare(k1, v1, k2, v2)
    return v1 < v2
end


-------------------------------------------------------------------------------
-- This function will find the largest value in a table, comparing using the
-- given function.  If not given, a function that performs "v1 < v2" will be
-- used instead.
-- @param t The table to search
-- @param func The comparison function, receives (key1, val1, key2, val2), and
-- should return a boolean
-- @return max_key, max_val, which are the maximum values found in the input
-- table, or nil, nil if the table is empty
function max(t, func)
    if func == nil then
        func = generic_compare
    end

    local maxk, maxv
    for k, v in pairs(t) do
        if maxk == nil then
            maxk = k
            maxv = v
        else
            -- func(...) will return true if the current maximum values are
            -- less than the current values.  If so, we make these values the
            -- new max.
            if func(maxk, maxv, k, v) then
                maxk = k
                maxv = v
            end
        end
    end

    return maxk, maxv
end


-- TODO: min
-- TODO: one (returns true if func(k, v) returns true once for a table)
-- TODO: none (returns true if func(k, v) doesn't return true for a table)


-------------------------------------------------------------------------------
-- This function will pass each key/value pair in a table to a given function,
-- and then return two tables: one which contains the key/value pairs for which
-- the function returned true, and a table of the ones that returned false.
-- @param t The table to partition
-- @param func The partitioning function - called with func(k, v), and should
-- return a boolean
-- @return Two tables, which contain the {key, value} pairs for which the
-- function returned true and false
function partition(t, func)
    local trues, falses = {}, {}

    for k, v in pairs(t) do
        if func(k, v) then
            table.insert(trues, {k, v})
        else
            table.insert(falses, {k, v})
        end
    end

    return trues, falses
end


-------------------------------------------------------------------------------
-- This function will pass each index/value pair in a list-like table to a
-- given function, and then return two tables: one which contains the values
-- for which the function returned true, and a table of the ones that returned
-- false.
-- @param t The table to partition
-- @param func The partitioning function - called with func(i, v), and should
-- return a boolean
-- @return Two tables, which contain the values for which the function returned
-- true and false
function partitioni(t, func)
    local trues, falses = {}, {}

    for i, v in ipairs(t) do
        if func(i, v) then
            table.insert(trues, v)
        else
            table.insert(falses, v)
        end
    end

    return trues, falses
end

-------------------------------------------------------------------------------
-- Given a list-like table, will return a new list-like table that is flattened
-- by the given level.  That is to say, for every value that is a list-like
-- table, extract it's elements into the new list, to the recursive depth
-- specified.
-- @param t The list-like table to flatten
-- @param level The level to flatten to.  Use math.huge to represent "flatten
-- everything"
-- @return A new list-like table that has been flattened.
-- @todo Do we make this flatten a non list-like table too?
function flatten(t, level)
    level = level or 1
    if level == 0 then return t end

    local ret = {}
    for i, v in ipairs(t) do
        if type(v) ~= "table" then
            table.insert(ret, v)
        else
            local flattened = flatten(v, level - 1)
            for i, v in ipairs(flattened) do
                table.insert(ret, v)
            end
        end
    end

    return ret
end


-------------------------------------------------------------------------------
-- This function will randomly shuffle the given list-like table in-place, and
-- then return the table.
-- @param t The list-like table to shuffle
-- @return The input table, shuffled
function shuffle(t)
    local n = #t
    for i = 1,n-1 do
        local r = math.random(i, n)
        t[i], t[r] = t[r], t[i]
    end

    return t
end


-------------------------------------------------------------------------------
-- Adds all the functions in this module to the specified table.  Note that
-- we default to the 'table' table, and we exclude this function itself.
-- @param mod If given, the module to patch these functions into.  Defaults
-- to the table module.
function patch(mod)
    mod = mod or table
    for key, val in pairs(P) do
        if val ~= patch then
            mod[key] = val
        end
    end
end


-------------------------------------------------------------------------------
-- This table stores all functions that take a table as their first argument.
-- This is particularly useful if you want to set a metatable on a table so
-- that you can call functions like: tbl:copy(), as opposed to table.copy(tbl)
table_methods = {
    copy,
    deepcopy,
    sort,
    isempty,
    size,
    keys,
    values,
    clear,
    update,
    transpose,
    compare,
    comparei,
    compare_unordered,
    find,
    rfind,
    map,
    mapi,
    transform,
    reduce,
    zip,
    normalize_slice,
    sub,
    delete_if,
    reject,
    keep_if,
    select,
    any,
    all,
    detect,
    drop_while,
    group_by,
    max,
    partition,
    partitioni,
    flatten,
}


return P
