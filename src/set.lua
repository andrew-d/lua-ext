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


function intersection(t, other)
    local ret = {}
    for k, v in pairs(t) do
        if other[k] then
            ret[k] = v
        end
    end

    return ret
end


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


function difference(t, other)
    local ret = {}
    for k, v in pairs(t) do
        if not other[k] then
            ret[k] = v
        end
    end

    return ret
end


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


function issubset(t, other)
    for k, v in pairs(t) do
        if not other[k] then
            return false
        end
    end

    return true
end


function isdisjoint(t, other)
    return tablex.isempty(intersection(t, other))
end


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
