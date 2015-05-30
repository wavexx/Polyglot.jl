include("prelude.jl")

py = bond!("Python", `python`; timeout=TIMEOUT)

# test ref with call
reval(py, """def test_call(arg, *args):
    return arg
"""; block=true)

# the second (ignored) argument enforces XCALL
ret = rcall(py, "test_call", 1, rref(py, "None"))
@test ret === 1
ret = rcall(py, "test_call", [1], rref(py, "None"))
@test ret == [1]
ret = rcall(py, "test_call", rref(py, "1 + 1"))
@test ret === 2
