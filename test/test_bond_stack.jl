include("prelude.jl")
using Expect

function bond_stack_depth(bond::Polyglot.BondProc)
    depth = 0
    while true
        try
            reval(bond, "1")
        catch e
            isa(e, BondTerminatedException) || rethrow(e)
            break
        end
        println(bond.proc, "RETURN")
        depth += 1
    end
    depth
end

# initial depth
py = bond!("Python", `python`; timeout=TIMEOUT)
@test bond_stack_depth(py) == 1

# depth after remote serialization error
py = bond!("Python", `python`; timeout=TIMEOUT)
@test_throws BondSerializationException reval(py, "lambda x: x")
@test reval(py, "1") === 1
@test bond_stack_depth(py) == 1

# depth after exception in exported function
py = bond!("Python", `python`; timeout=TIMEOUT)
local_except() = raise("test")
exportfn(py, local_except)
@test_throws BondRemoteException rcall(py, "local_except")
@test reval(py, "1") === 1
@test bond_stack_depth(py) == 1

# depth after serialization error in exported function
py = bond!("Python", `python`; timeout=TIMEOUT)
local_ser_except() = Base
exportfn(py, local_ser_except)
@test_throws BondSerializationException rcall(py, "local_ser_except")
@test reval(py, "1") === 1
@test bond_stack_depth(py) == 1
