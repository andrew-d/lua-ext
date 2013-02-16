--- A module for determining information about the execution platform
-- @module platform

-- Our global environment.
local P = {}

-- Import section:
-- We declare everything this package needs from "outside" here.
local package = package
local string = string
local io = io
local os = os

-- No more external access after this point.
setfenv(1, P)


-- Use undocumented package.config to get directory and path separator.
local dirsep, pathsep = string.match(package.config, "^([^\n]+)\n([^\n]+)\n")


--- Platform-specific constants
const = {
    dirsep = dirsep,        -- The directory separator
    pathsep = pathsep,      -- The path separator
    extsep = '.',           -- The extension separator
}


local _is_windows = const.dirsep == '\\'

-------------------------------------------------------------------------------
-- Returns whether the current execution platform is Windows.
-- @return true if execution platform is Windows
function is_windows()
    return _is_windows
end


-------------------------------------------------------------------------------
-- Returns the current execution platform.
-- Values can include "windows", "darwin", "linux", or whatever the lower-case
-- version of `uname` returns.  "unknown" is returned if the output from
-- `uname` is empty (e.g. in case of an error).
-- @return A string indicating the current execution platform
function platform()
    if _is_windows then
        return 'windows'
    end

    -- Return the lower-cased output from `uname`.  The redirection means that
    -- if the command doesn't exist, we don't get a strange error.
    local uname = io.popen('uname 2>/dev/null'):read()
    if #uname > 0 then
        return uname:lower()
    end

    return 'unknown'
end



local _win_mapping = {
    ['AMD64'] = 'x64',
    ['IA64'] = 'ia64',
    ['x86'] = 'x86',
}

local _other_mapping = {
    ['i686'] = 'x86',
    ['i386'] = 'x86',
    ['x86_64'] = 'x64',
}


-------------------------------------------------------------------------------
-- Returns the current processor architecture.
-- The string returned will be one of 'x86', 'x64', 'ia64', 'unknown', or
-- whatever `uname -p` returns.
-- @returns A string indicating the processor architecture
function architecture()
    local arch

    if _is_windows then
        -- Try WOW64 first.
        arch = os.getenv('PROCESSOR_ARCHITEW6432')
        if arch == nil then
            arch = os.getenv('PROCESSOR_ARCHITECTURE')
        end

        return _win_mapping[arch] or 'unknown'
    end

    -- For now, we just try getting the information from uname.
    arch = io.popen('uname -a 2>/dev/null'):read()
    if arch ~= nil then
        if arch:find('x86_64') then
            return 'x64'
        elseif arch:find('i386') then
            return 'x86'
        end
    end

    -- Default to uname -p, mapped to common names if possible.
    arch = io.popen('uname -p 2>/dev/null'):read()
    if arch ~= nil then
        return _other_mapping[arch] or arch
    end
end


return P
