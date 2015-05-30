include("prelude.jl")

py = bond!("Python", `python`; timeout=TIMEOUT)

# test call without error
ret = rcall(py, "str", "Hello world!")
@test ret == "Hello world!"

# undefined function
@test_throws BondRemoteException rcall(py, "test_undefined")

# ensure the environment is still alive
ret = reval(py, "1")
@assert ret === 1
