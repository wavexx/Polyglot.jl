include("prelude.jl")

py = make_bond("Python", `python`; timeout=TIMEOUT)

# test eval with a statement
ret = beval(py, "\"Hello world!\"")
@test ret == "Hello world!"

# test eval with a code block
beval(py, """def test_simple():
    return \"Hello world!\"
"""; stm=false)

ret = beval(py, "test_simple()")
@test ret == "Hello world!"
