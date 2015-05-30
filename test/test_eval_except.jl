include("prelude.jl")

py = bond!("Python", `python`; timeout=TIMEOUT)

# test eval without error
ret = reval(py, "\"Hello world!\"")
@test ret == "Hello world!"

# broken statement
@test_throws BondRemoteException reval(py, "\"")

# ensure the environment is still alive
ret = reval(py, "1")
@assert ret === 1
