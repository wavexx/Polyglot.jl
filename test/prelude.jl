using Base.Test
using Polyglot
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


function _capture_output(fun, fd, set_fd)
    old = fd
    rd, wr = set_fd()
    try
        fun()
    finally
        set_fd(old)
        close(wr)
    end
    readall(rd)
end

capture_stdout(fun) = _capture_output(fun, STDOUT, redirect_stdout)
capture_stderr(fun) = _capture_output(fun, STDERR, redirect_stderr)
