--- A module that contains operator functions.
-- @module operator

-- Our global environment.
local P = {}

-- Import section:
-- We declare everything this package needs from "outside" here.

-- No more external access after this point.
if string.sub(_VERSION, 5) == '5.2' then
    _ENV = P
else
    setfenv(1, P)
end


--- Call a function with some arguments.
function call(func, ...)    return func(...)    end
--- Return the given key from a table.
function index(tbl, key)    return tbl[key]    end

--- Return the result of `x == y`
function eq(x, y)           return x == y       end
--- Return the result of `x ~= y`
function ne(x, y)           return x ~= y       end
--- Return the result of `x < y`
function lt(x, y)           return x < y        end
--- Return the result of `x <= y`
function lte(x, y)          return x <= y       end
--- Return the result of `x > y`
function gt(x, y)           return x > y        end
--- Return the result of `x >= y`
function gte(x, y)          return x >= y       end

--- Return the length of x
-- @param x
function len(x)             return #x           end
--- Return x concatenated with y
function concat(x, y)       return x .. y       end

--- Return `x + y`
function add(x, y)          return x + y        end
--- Return `x - y`
function sub(x, y)          return x - y        end
--- Return `x * y`
function mul(x, y)          return x * y        end
--- Return `x / y`
function div(x, y)          return x / y        end
--- Return `x ^ y`
function pow(x, y)          return x ^ y        end
--- Return `x % y`
function mod(x, y)          return x % y        end
--- Return `-x`
-- @param x
function neg(x)             return -x           end

--- Return the result of x and y
function and_(x, y)         return x and y      end
--- Return the result of `x or y`
function or_(x, y)          return x or y       end
--- Return `not x`
-- @param x
function not_(x)            return not x        end

--- No-op function.  Returns exactly what is passed in.
-- @param ...
function nop(...)           return ...          end
--- Table function - constructs a table from the input arguments.
-- @param ...
function table(...)         return {...}        end


-------------------------------------------------------------------------------
-- This table contains all of the lua operator functions, keyed by a sensible
-- string representation.  See the code for more details.
-- @table optable
-- @field num The number of operations
optable = {
    ["()"]=call,
    ["[]"]=index,

    ["+"]=add,
    ["-"]=sub,
    ["*"]=mul,
    ["/"]=div,
    ["^"]=pow,
    ["%"]=mod,

    ["<"]=lt,
    ["<="]=lte,
    [">"]=gt,
    [">="]=gte,
    ["=="]=eq,
    ["~="]=neq,

    ["#"]=len,
    [".."]=concat,
    ["and"]=and_,
    ["or"]=or_,
    ["not"]=not_,

    ["{}"]=table,
    [""]=nop,
}

optable.num = 21


return P
