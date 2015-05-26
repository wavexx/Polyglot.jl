include("prelude.jl")

py = make_bond("Python", `python`; timeout=TIMEOUT)

# define a remote function
beval(py, """def remote_add1(x):
    return x + 1
"""; block=true)
remote_add1 = importfn(py, "remote_add1")

# define a local function that calls the remote
local_add2(x) = remote_add1(x + 1)
@test local_add2(0) === 2

# export it again
exportfn(py, local_add2, "ex_local_add2")
ex_local_add2 = importfn(py, "ex_local_add2")
@test ex_local_add2(0) === 2

# define a remote function that calls us recursively
beval(py, """def remote_add3(x):
    return ex_local_add2(x) + 1
""", block=true)
ex_remote_add3 = importfn(py, "remote_add3")
@test ex_remote_add3(0) === 3

# inception
local_add4(x) = ex_remote_add3(x + 1)
exportfn(py, local_add4, "ex_local_add4")
beval(py, """def remote_add5(x):
    return ex_local_add4(x) + 1
""", block=true)
ex_remote_add5 = importfn(py, "remote_add5")
@test ex_remote_add5(0) === 5
