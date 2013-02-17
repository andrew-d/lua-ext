-- Our global environment.
local P = {}

-- Import section:
-- We declare everything this package needs from "outside" here.
local math = math
local type = type
local pairs, ipairs = pairs, ipairs
local string = string
local error = error

-- No more external access after this point.
if string.sub(_VERSION, 5) == '5.2' then
    _ENV = P
else
    setfenv(1, P)
end


-------------------------------------------------------------------------------
-- Escape a string so it can be used as a pattern.
-- @param s The string to escape
-- @return A string with any special characters escaped, such that it can be
-- used as a pattern
function escape_pattern(s)
    -- Prepend all non-alphanumeric characters with a percent sign.
    return (string.gsub(s, "(%W)", "%%%1"))
end


-------------------------------------------------------------------------------
-- Checks if a string contains only alphabetic characters.
-- @param s The string to check
-- @return true or false
function isalpha(s)
    return string.find(s, '^%a+$') == 1
end


-------------------------------------------------------------------------------
-- Checks if a string contains only digits.
-- @param s The string to check
-- @return true or false
function isdigit(s)
    return string.find(s, '^%d+$') == 1
end


-------------------------------------------------------------------------------
-- Checks if a string contains only alphanumeric characters.
-- @param s The string to check
-- @return true or false
function isalnum(s)
    return string.find(s, '^%w+$') == 1
end


-------------------------------------------------------------------------------
-- Checks if a string contains only spaces.
-- @param s The string to check
-- @return true or false
function isspace(s)
    return string.find(s, '^%s+$') == 1
end


-------------------------------------------------------------------------------
-- Checks if a string contains only lower-case characters.
-- @param s The string to check
-- @return true or false
function islower(s)
    return string.find(s, '^[%l%s]+$') == 1
end


-------------------------------------------------------------------------------
-- Checks if a string contains only upper-case characters.
-- @param s The string to check
-- @return true or false
function isupper(s)
    return string.find(s, '^[%u%s]+$') == 1
end


-------------------------------------------------------------------------------
-- Returns a copy of the string
-- @param s The string
-- @return A copy of the input string
function copy(s)
    return s .. ''
end
dup = copy


-------------------------------------------------------------------------------
-- Return the single character at the given index.
-- @param s The string
-- @param i The index
-- @return A string of length 1 if successful, otherwise an empty string
function at(s, i)
    return string.sub(s, i, i)
end


-------------------------------------------------------------------------------
-- Shortens a string to a given length, adding dots if necessary.
-- @param s The string to shorten
-- @param len The maximum length to show
-- @param show_tail Boolean indicating whether to show the start or end of the
-- string (defaults to false, indicating show the start)
-- @return A string of maximum length len
function shorten(s, len, show_tail)
    if #s > len then
        -- Handle the case where the length is less than the number of dots we
        -- would add (3).
        if len < 3 then
            return string.rep('.', len)
        end

        if show_tail then
            local start_idx = #s - len + 1 + 3
            return '...' .. s:sub(start_idx)
        else
            return s:sub(1, len - 3) .. '...'
        end
    end
    return s
end


-------------------------------------------------------------------------------
-- Capitalize the first word in a string.
-- @param s The string to capitalize
-- @return The string, with the first letter capitalized
function capitalize(s)
    return string.sub(s, 1, 1):upper() .. string.sub(s, 2)
end


-------------------------------------------------------------------------------
-- Strip any final newline from a string
-- @param s The string to chomp
-- @return The string, with any final newline characters removed
function chomp(s, separator)
    if separator ~= nil then
        return (string.gsub(s, escape_pattern(separator) .. '$', ''))
    else
        -- First remove '\n', then '\r', so we don't clobber 'foo\n\r'.
        return (string.gsub(string.gsub(s, '\n$', ''), '\r$', ''))
    end
end


-------------------------------------------------------------------------------
-- Remove the final character from the string.  If the string ends with a
-- newline pair (\r\n), then both characters are removed.
-- @param s The string to chop
-- @return The string, with the final character (or newline pair) removed
function chop(s)
    if string.sub(s, #s - 1) == '\r\n' then
        return string.sub(s, 1, #s - 2)
    else
        return string.sub(s, 1, #s - 1)
    end
end


-------------------------------------------------------------------------------
-- Remove all characters given from the string.
-- @param s The string to delete from
-- @param substr Either a list-like table of strings or single string to remove
-- @return The string with all input strings removed
function delete(s, substr)
    -- For each substring given, we remove it.
    if type(substr) ~= 'table' then
        return (string.gsub(s, escape_pattern(substr), ''))
    end

    for i, val in ipairs(substr) do
        s = string.gsub(s, escape_pattern(val), '')
    end

    return s
end


-------------------------------------------------------------------------------
-- Remove leading characters from a string, as given by the chars pattern.
-- @param s The string to strip
-- @param chars The pattern used to look for leading characters (default: %s+)
-- @return A string with leading characters matching the pattern removed
function lstrip(s, chars)
    chars = chars or '%s+'
    return (string.gsub(s, '^' .. chars, ''))
end


-------------------------------------------------------------------------------
-- Remove trailing characters from a string, as given by the chars pattern.
-- @param s The string to strip
-- @param chars The pattern used to look for trailing characters (default: %s+)
-- @return A string with trailing characters matching the pattern removed
function rstrip(s, chars)
    chars = chars or '%s+'
    return (string.gsub(s, chars .. '$', ''))
end

-------------------------------------------------------------------------------
-- Remove leading and trailing characters from a string, as given by the chars
-- pattern.
-- @param s The string to strip
-- @param chars The pattern used to look for leading and trailing characters
-- (default: %s+)
-- @return A string with leading and trailing characters matching the pattern
-- removed
function strip(s, chars)
    chars = chars or '%s+'
    return lstrip(rstrip(s, chars), chars)
end


-- Find the last occurence of a substring in a string.
-- The general idea is that we repeatedly search for the substring, keeping
-- track of the last match.  When we don't find any more, we return the last
-- match.
local function _find_last(s, sub, first, last)
    local start, fin = string.find(s, sub, first, true)
    local last_start

    while start do
        last_start = start
        start, fin = string.find(s, sub, fin + 1, true)
        if last and start > last then
            break
        end
    end

    return last_start
end


-------------------------------------------------------------------------------
-- Finds the index of the first instance of sub in s
-- @param s The string to search
-- @param sub The string to search for
-- @param first The start index
-- @return The index of the first instance, or nil if not found
function lfind(s, sub, first)
    local r = string.find(s, sub, first, true)
    if r then
        return r
    else
        return nil
    end
end


-------------------------------------------------------------------------------
-- Finds the index of the last instance of sub in s
-- @param s The string to search
-- @param sub The string to search for
-- @param first The start index
-- @param last  The last index
-- @return The index of the last instance, or nil if not found
function rfind(s, sub, first, last)
    local r = _find_last(s, sub, first, last)
    if r then
        return r
    else
        return nil
    end
end


-------------------------------------------------------------------------------
-- Replaces all instances of substring old replaced by new.
-- @param s The string to search
-- @param old The substring to search for
-- @param new The substring to replace with
-- @param count (optional) If given, this function will only perform this
-- number of replacements.
-- @return The new string
function replace(s, old, new, count)
    -- We escape old, escape percents in new, and then gsub.
    return (string.gsub(s, escape_pattern(old), new:gsub('%%', '%%%%'), n))
end


-------------------------------------------------------------------------------
-- Returns true if s ends with the specified suffix, false otherwise.
-- @param s The string to check
-- @param suffix A string or list-like table of suffixes to check
-- @param start (optional) The index to start checking at.  Defaults to 1
-- @param fin (optional) The index to stop checking at.  Defaults to #s
-- @return true or false
function endswith(s, suffix, start, fin)
    start = start or 1
    fin = fin or #s

    -- TODO: Check for things that aren't tables or strings
    if type(suffix) ~= 'table' then
        suffix = {suffix}
    end

    -- Extract the chunk of string we're to check.
    local check = string.sub(s, start, fin)

    -- For each suffix in the table, we check if the string ends there.
    for i, suff in ipairs(suffix) do
        if string.match(check, escape_pattern(suff) .. '$') then
            return true
        end
    end

    return false
end

-------------------------------------------------------------------------------
-- Returns true if s starts with the specified suffix, false otherwise.
-- @param s The string to check
-- @param suffix A string or list-like table of suffixes to check
-- @param start (optional) The index to start checking at.  Defaults to 1
-- @param fin (optional) The index to stop checking at.  Defaults to #s
-- @return true or false
function startswith(s, suffix, start, fin)
    start = start or 1
    fin = fin or #s

    -- TODO: Check for things that aren't tables or strings
    if type(suffix) ~= 'table' then
        suffix = {suffix}
    end

    -- Extract the chunk of string we're to check.
    local check = string.sub(s, start, fin)

    -- For each suffix in the table, we check if the string ends there.
    for i, suff in ipairs(suffix) do
        if string.match(check, '^' .. escape_pattern(suff)) then
            return true
        end
    end

    return false
end

-------------------------------------------------------------------------------
-- Returns the number of occurences of the substring substr in the string given
-- by s[start:fin].
-- @param s The string to check
-- @param substr The substring to search for
-- @param start The index at which to start searching (defaults to 1)
-- @param fin The index at which to finish searching (defaults to #s)
-- @return A number indicating the number of times the substring was found
function count(s, substr, start, fin)
    if start ~= nil and fin ~= nil then
        s = string.sub(s, start, fin)
    elseif start ~= nil then
        s = string.sub(s, start)
    end

    local count = 0
    for w in string.gmatch(s, escape_pattern(substr)) do
        count = count + 1
    end

    return count
end


-- Helper function for partition/rpartition, below.
local function _partition(s, sep, func)
    -- Use the function to find the match.
    local start, fin = func(s, sep)
    if not start or start == -1 then
        return s, '', ''
    else
        if not fin then
            fin = start
        end

        return string.sub(s, 1, start - 1),
               string.sub(s, start, fin),
               string.sub(s, fin + 1)
    end
end


-------------------------------------------------------------------------------
-- Search the string s for a pattern, and returns the part before it, the
-- match, and the part after it.  If not found, returns the input string and
-- two empty strings.
-- @param s The string to partition
-- @param sep The separator to partition by
-- @return The part before the separator, or the full string if no match
-- @return The separator, or a blank string if not found
-- @return The part after the separator, or a blank string if not found
function partition(s, sep)
    if #sep == 0 then
        error("bad argument #2 to 'partition' (expected non-empty string)")
    end

    return _partition(s, sep, lfind)
end


-------------------------------------------------------------------------------
-- Search the string s for a pattern, starting from the end, and return the
-- part before it, the match, and the part after it.  If not found, returns the
-- input string and two empty strings.
-- @param s The string to partition
-- @param sep The separator to partition by
-- @return The part before the separator, or the full string if no match
-- @return The separator, or a blank string if not found
-- @return The part after the separator, or a blank string if not found
function rpartition(s, sep)
    if #sep == 0 then
        error("bad argument #2 to 'rpartition' (expected non-empty string)")
    end

    return _partition(s, sep, rfind)
end


-- Helper function for rjust/ljust, below
local function get_padding(s, i, padstr)
    if #s >= i then
        return ''
    end

    local rep_length = math.ceil((i - #s) / #padstr)
    local padding = string.rep(padstr, rep_length)
    return string.sub(padding, 1, i - #s)
end


-------------------------------------------------------------------------------
-- Left-justifies the string to the given width.
-- @param s The string to left-justify
-- @param i The width to justify to
-- @param padstr The padding string to use (defaults to ' ')
-- @return The newly justified string
function ljust(s, i, padstr)
    if padstr == nil then
        padstr = ' '
    end

    return s .. get_padding(s, i, padstr)
end


-------------------------------------------------------------------------------
-- Right-justifies the string to the given width.
-- @param s The string to right-justify
-- @param i The width to justify to
-- @param padstr The padding string to use (defaults to ' ')
-- @return The newly justified string
function rjust(s, i, padstr)
    if padstr == nil then
        padstr = ' '
    end

    return get_padding(s, i, padstr) .. s
end


-------------------------------------------------------------------------------
-- Pad a string with zeros on the left, to fill a field of the specified
-- width.  The string is never truncated.
-- @param s The string to pad
-- @param width The width to pad to
function zfill(s, width)
    if #s >= width then
        return s
    end

    return string.rep('0', width - #s) .. s
end


-- TODO:
--  join
--  expandtabs
--  splitlines
--  split
--  center
--  lines?  (iterator over lines, instead of list)
--  title
--  translate?


-------------------------------------------------------------------------------
-- Adds all the functions in this module to the 'string' table, so they can be
-- used directly on strings.
function patch()
    for key, val in pairs(P) do
        string[key] = val
    end
end


return P
