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


function call(func, ...)    return func(...)    end
function index(tbl, key)    return tbl[key]    end

function eq(x, y)           return x == y       end
function ne(x, y)           return x ~= y       end
function lt(x, y)           return x < y        end
function lte(x, y)          return x <= y       end
function gt(x, y)           return x > y        end
function gte(x, y)          return x >= y       end

function len(x)             return #x           end
function concat(x, y)       return x .. y       end

function add(x, y)          return x + y        end
function sub(x, y)          return x - y        end
function mul(x, y)          return x * y        end
function div(x, y)          return x / y        end
function pow(x, y)          return x ^ y        end
function mod(x, y)          return x % y        end
function neg(x)             return -x           end

function and_(x, y)         return x and y      end
function or_(x, y)          return x or y       end
function not_(x)            return not x        end

function nop(...)           return ...          end
function table(...)         return {...}        end


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


return P
