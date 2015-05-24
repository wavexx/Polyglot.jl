include("prelude.jl")

py = make_bond("Python", `python`; timeout=TIMEOUT)

# test call without error
ret = bcall(py, "str", "Hello world!")
@test ret == "Hello world!"

# undefined function
@test_throws BondRemoteException bcall(py, "test_undefined")

# ensure the environment is still alive
ret = beval(py, "1")
@assert ret === 1
