include("prelude.jl")

py = make_bond("Python", `python`; timeout=TIMEOUT)

# test exportfn with a simple function without arguments
local_fn_noarg() = 1
exportfn(py, local_fn_noarg)
@test bcall(py, "local_fn_noarg") === 1

# test exportfn with a simple function with arguments
local_fn_add1(x) = x + 1
exportfn(py, local_fn_add1)
@test bcall(py, "local_fn_add1", 1) === 2

# explicit name
exportfn(py, local_fn_noarg, "fn_noarg")
@test bcall(py, "fn_noarg") === 1
