using Base.Test
using Bond
using Compat

TIMEOUT = parse(Int, get(ENV, "BOND_TIMEOUT", "1"))

macro catch_except(extype, expr)
    quote
        ret = nothing
        try
            $expr
        catch e
            ret = e
        end
        if isa(ret, $extype)
            ret
        else
            qexpr = $(Expr(:quote, expr))
            extype = $extype
            error("$qexpr did not throw an exception of type $extype")
        end
    end
end
