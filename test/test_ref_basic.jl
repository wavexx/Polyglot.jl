include("prelude.jl")

py = bond!("Python", `python`; timeout=TIMEOUT)

# test ref with a statement
ret = reval(py, rref(py, "1"))
@test ret === 1

# test ref with a code block
code = rref(py, """def test_simple():
    return \"Hello world!\"
""")
reval(py, code; block=true)
ret = reval(py, "test_simple()")
@test ret == "Hello world!"

# check environment
ret = reval(py, "1")
@test ret === 1
