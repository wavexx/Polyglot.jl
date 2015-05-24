include("prelude.jl")

py = make_bond("Python", `python`; timeout=TIMEOUT)

# test eval without error
ret = beval(py, "\"Hello world!\"")
@test ret == "Hello world!"

# broken statement
@test_throws BondRemoteException beval(py, "\"")

# ensure the environment is still alive
ret = beval(py, "1")
@assert ret === 1
