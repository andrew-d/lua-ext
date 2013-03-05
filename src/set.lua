--- Set implementation for Lua
-- @module set

-- Our global environment.
local P = {}

-- Import section:
-- We declare everything this package needs from "outside" here.
local pairs, ipairs = pairs, ipairs
local table = table
local error = error
local getmetatable, setmetatable = getmetatable, setmetatable
local tostring = tostring
local print = print

local tablex = require('tablex')

-- No more external access after this point.
if string.sub(_VERSION, 5) == '5.2' then
    _ENV = P
else
    setfenv(1, P)
end


-------------------------------------------------------------------------------
-- Compute the set intersection between two tables.
-- @param t A table
-- @param other Another table
-- @return A new table which contains the intersection between the two tables
function intersection(t, other)
    local ret = {}
    for k, v in pairs(t) do
        if other[k] then
            ret[k] = v
        end
    end

    return ret
end


-------------------------------------------------------------------------------
-- Compute the set union of two tables.
-- @param t A table
-- @param other Another table
-- @return A new table which contains the union of the two tables
function union(t, other)
    local ret = {}
    for k, v in pairs(t) do
        ret[k] = v
    end
    for k, v in pairs(other) do
        ret[k] = v
    end

    return ret
end


-------------------------------------------------------------------------------
-- Compute the (non-symmetric) difference of two tables.
-- @param t A table
-- @param other Another table
-- @return A new table which contains the difference between the two tables
function difference(t, other)
    local ret = {}
    for k, v in pairs(t) do
        if not other[k] then
            ret[k] = v
        end
    end

    return ret
end


-------------------------------------------------------------------------------
-- Compute the symmetric difference of two tables.
-- @param t A table
-- @param other Another table
-- @return A new table which contains the symmetric difference between the two
-- tables
function symmetric_difference(t, other)
    local ret = {}
    for k, v in pairs(t) do
        if not other[k] then
            ret[k] = v
        end
    end
    for k, v in pairs(other) do
        if not t[k] then
            ret[k] = v
        end
    end

    return ret
end


-------------------------------------------------------------------------------
-- Returns a boolean indicating whether the first table is a subset of the
-- second.
-- @param t A table
-- @param other Another table
-- @return A boolean value
function issubset(t, other)
    for k, v in pairs(t) do
        if not other[k] then
            return false
        end
    end

    return true
end


-------------------------------------------------------------------------------
-- Returns a boolean indicating whether the first table is disjoint with
-- respect to the second.
-- @param t A table
-- @param other Another table
-- @return A boolean value
function isdisjoint(t, other)
    return tablex.isempty(intersection(t, other))
end


-------------------------------------------------------------------------------
-- Returns a boolean indicating whether the first table is equal to the second.
-- @param t A table
-- @param other Another table
-- @return A boolean value
function equal(t, other)
    return issubset(t, other) and issubset(other, t)
end


local Set = {
    intersection         = intersection,
    union                = union,
    difference           = difference,
    symmetric_difference = symmetric_difference,
    values               = tablex.keys,
    issubset             = issubset,
    isempty              = tablex.isempty,
    isdisjoint           = isdisjoint,
    len                  = tablex.size,
    __eq                 = equal,
}


Set.__index = Set
Set.__add   = Set.union
Set.__mul   = Set.intersection
Set.__sub   = Set.difference
Set.__pow   = Set.symmetric_difference
Set.__lt    = Set.issubset
Set.__len   = tablex.size


function Set:__tostring()
    local ret = {}
    for k, v in pairs(self) do
        table.insert(ret, tostring(k))
    end
    return '[' .. table.concat(ret, ', ') .. ']'
end


-------------------------------------------------------------------------------
-- Create a new Set object that allows the set methods from this module to be
-- called directly on the set.  The set itself is a table, where the keys are
-- the values contained in the set, and the values are the boolean value
-- `true`.  The returned Set object will also have a `tostring()` method that
-- prints the values contained.
-- @param input An input value to initialize the set with.  If this is a Set
-- instance, then it will properly take the value of the set - otherwise, the
-- input is assumed to be a list-like table, and the values in this table are
-- added to the set.
function makeset(input)
    local set = {}
    if input then
        local mt = getmetatable(input)

        if mt == Set then
            for k, _ in pairs(input) do
                set[k] = true
            end
        else
            for _, v in ipairs(input) do
                set[v] = true
            end
        end
    end

    return setmetatable(set, Set)
end


return P
