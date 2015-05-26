include("prelude.jl")
using Expect

function bond_stack_depth(bond::Bond.BondProc)
    depth = 0
    while true
        try
            beval(bond, "1")
        catch e
            isa(e, BondTerminatedException) || rethrow(e)
            break
        end
        sendline(bond.proc, "RETURN")
        depth += 1
    end
    depth
end

# initial depth
py = make_bond("Python", `python`; timeout=TIMEOUT)
@test bond_stack_depth(py) == 1

# depth after remote serialization error
py = make_bond("Python", `python`; timeout=TIMEOUT)
@test_throws BondSerializationException beval(py, "lambda x: x")
@test beval(py, "1") === 1
@test bond_stack_depth(py) == 1

# depth after exception in exported function
py = make_bond("Python", `python`; timeout=TIMEOUT)
local_except() = raise("test")
exportfn(py, local_except)
@test_throws BondRemoteException bcall(py, "local_except")
@test beval(py, "1") === 1
@test bond_stack_depth(py) == 1

# depth after serialization error in exported function
py = make_bond("Python", `python`; timeout=TIMEOUT)
local_ser_except() = Base
exportfn(py, local_ser_except)
@test_throws BondSerializationException bcall(py, "local_ser_except")
@test beval(py, "1") === 1
@test bond_stack_depth(py) == 1
