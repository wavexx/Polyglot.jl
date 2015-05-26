include("prelude.jl")

py = make_bond("Python", `python`; timeout=TIMEOUT)

# test ref with call
beval(py, """def test_call(arg, *args):
    return arg
"""; block=true)

# the second (ignored) argument enforces XCALL
ret = bcall(py, "test_call", 1, bref(py, "None"))
@test ret === 1
ret = bcall(py, "test_call", [1], bref(py, "None"))
@test ret == [1]
ret = bcall(py, "test_call", bref(py, "1 + 1"))
@test ret === 2
