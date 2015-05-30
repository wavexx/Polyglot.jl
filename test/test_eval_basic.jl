include("prelude.jl")

py = bond!("Python", `python`; timeout=TIMEOUT)

# test eval with a statement
ret = reval(py, "\"Hello world!\"")
@test ret == "Hello world!"

# test eval with a code block
reval(py, """def test_simple():
    return \"Hello world!\"
"""; block=true)

ret = reval(py, "test_simple()")
@test ret == "Hello world!"
