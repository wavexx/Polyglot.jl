include("prelude.jl")

py = bond!("Python", `python`; timeout=TIMEOUT)

# test call with a simple function
reval(py, """def test_simple():
    return \"Hello world!\"
"""; block=true)

ret = reval(py, "test_simple()")
@test ret == "Hello world!"

ret = rcall(py, "test_simple")
@test ret == "Hello world!"

# test call with a built-in
ret = rcall(py, "str", "Hello world!")
@test ret == "Hello world!"
