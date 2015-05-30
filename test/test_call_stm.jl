include("prelude.jl")

py = bond!("Python", `python`; timeout=TIMEOUT)

# test call with a statement
ret = rcall(py, "lambda x: x", "Hello world!")
@test ret == "Hello world!"
