include("prelude.jl")

py = make_bond("Python", `python`; timeout=TIMEOUT)

# test ref with a statement
ret = beval(py, bref(py, "1"))
@test ret === 1

# test ref with a code block
code = bref(py, """def test_simple():
    return \"Hello world!\"
""")
beval(py, code; stm=false)
ret = beval(py, "test_simple()")
@test ret == "Hello world!"

# check environment
ret = beval(py, "1")
@test ret === 1
