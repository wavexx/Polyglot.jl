include("prelude.jl")

py = make_bond("Python", `python`; timeout=TIMEOUT)

# test call with a simple function
beval(py, """def test_simple():
    return \"Hello world!\"
"""; stm=false)

ret = beval(py, "test_simple()")
@test ret == "Hello world!"

ret = bcall(py, "test_simple")
@test ret == "Hello world!"

# test call with a built-in
ret = bcall(py, "str", "Hello world!")
@test ret == "Hello world!"
