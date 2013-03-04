--- This module defines functions that perform I/O on strings, instead of
-- files.
-- @module stringio

-- Our global environment.
local P = {}

-- Import section:
-- We declare everything this package needs from "outside" here.
local table = table
local getmetatable, setmetatable = getmetatable, setmetatable
local tonumber = tonumber
local type = type
local error = error
local ipairs = ipairs
local string = string
local select = select
local unpack = unpack

local print = print

-- No more external access after this point.
if string.sub(_VERSION, 5) == '5.2' then
    _ENV = P
else
    setfenv(1, P)
end


-- Metatable for a string writer.
local StringWriter = {}
StringWriter.__index = StringWriter

function StringWriter:__tostring()
    return self:value()
end

function StringWriter:close()
end

function StringWriter:seek()
end

function StringWriter:write(...)
    local args = {...}
    for i, v in ipairs(args) do
        table.insert(self.table, v)
    end
end

function StringWriter:writef(fmt, ...)
    return self:write(string.format(fmt, ...))
end

function StringWriter:value()
    return table.concat(self.table)
end


-- Metatable for a string reader.
local StringReader = {}
StringReader.__index = StringReader


function StringReader:seek(where, offset)
    local base

    where = where or 'cur'
    offset = offset or 0

    if where == 'set' then
        base = 1
    elseif where == 'cur' then
        base = self.offset
    elseif where == 'end' then
        base = #self.value
    end

    self.offset = base + offset
    return self.offset
end


function StringReader:_internal_read(format)
    local offset = self.offset
    local str = self.str
    local len = #str

    if offset > len then
        return nil
    end

    local ret
    if format == '*l' or format == '*L' then
        local i = str:find('\n', offset) or (len + 1)

        if format == '*l' then
            ret = str:sub(offset, i - 1)
        else
            ret = str:sub(offset, i)
        end

        self.offset = i + 1
    elseif format == '*a' then
        -- Read all.
        ret = str:sub(offset)
        self.offset = len + 1

    elseif format == '*n' then
        local _, digit_end, tmp

        -- Find all digits
        _, digit_end = str:find('%s*%d+', offset)

        -- See if there's a decimal section - e.g. ".1234"
        _, tmp = str:find('^%.%d+', digit_end + 1)
        if tmp then
            digit_end = tmp
        end

        -- Try finding an exponent.
        _, tmp = str:find('^[eE][%+%-]*%d+', digit_end + 1)
        if tmp then
            digit_end = tmp
        end

        ret = tonumber(str:sub(offset, digit_end))
        self.offset = digit_end + 1

    elseif type(format) == 'number' then
        -- Read the given number of bytes
        ret = str:sub(offset, offset + format - 1)
        self.offset = offset + format

    else
        error('bad read format', 2)
    end

    return ret
end


function StringReader:read(...)
    if select('#', ...) == 0 then
        return self:_internal_read('*l')
    else
        local ret = {}
        local formats = {...}

        for i, v in ipairs(formats) do
            ret[i] = self:_internal_read(v)
        end

        return unpack(ret)
    end
end




function create(initial)
    local t

    if initial then
        t = {table={initial}}
    else
        t = {table={}}
    end

    return setmetatable(t, StringWriter)
end


function open(value)
    return setmetatable({str=value, offset=1}, StringReader)
end

return P
