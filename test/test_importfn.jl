include("prelude.jl")

py = bond!("Python", `python`; timeout=TIMEOUT)

# test importfn with a function without arguments
reval(py, """def test_simple():
    return \"Hello world!\"
"""; block=true)

fn = importfn(py, "test_simple")
ret = fn()
@test ret == "Hello world!"

# try with arguments
fn = importfn(py, "str")
ret = fn("Hello world!")
@test ret == "Hello world!"

# empty return value
reval(py, """def test_empty():
    pass
"""; block=true)

@test rcall(py, "test_empty") === nothing
@test importfn(py, "test_empty")() === nothing
