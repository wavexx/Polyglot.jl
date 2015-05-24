include("prelude.jl")

py = make_bond("Python", `python`; timeout=TIMEOUT)

# test importfn with a function without arguments
beval(py, """def test_simple():
    return \"Hello world!\"
"""; stm=false)

fn = importfn(py, "test_simple")
ret = fn()
@test ret == "Hello world!"

# try with arguments
fn = importfn(py, "str")
ret = fn("Hello world!")
@test ret == "Hello world!"
