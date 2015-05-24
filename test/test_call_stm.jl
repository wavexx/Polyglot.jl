include("prelude.jl")

py = make_bond("Python", `python`; timeout=TIMEOUT)

# test call with a statement
ret = bcall(py, "lambda x: x", "Hello world!")
@test ret == "Hello world!"
