include("prelude.jl")

py = bond!("Python", `python`; timeout=TIMEOUT)

# test exportfn with a simple function without arguments
local_fn_noarg() = 1
exportfn(py, local_fn_noarg)
@test rcall(py, "local_fn_noarg") === 1

# test exportfn with a simple function with arguments
local_fn_add1(x) = x + 1
exportfn(py, local_fn_add1)
@test rcall(py, "local_fn_add1", 1) === 2

# explicit name
exportfn(py, local_fn_noarg, "fn_noarg")
@test rcall(py, "fn_noarg") === 1
