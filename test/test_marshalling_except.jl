include("prelude.jl")

py = bond!("Python", `python`; timeout=TIMEOUT)

# test local serialization error
reval(py, """def test_id(arg):
    return arg
"""; block=true)

# NOTE: JSON.json is currently too lax[1], allowing unknown/unhandled types to
# slip though (functions/IO/etc). We test the serialization using a Module
# type, which is explicitly handled as a failure.
# [1] https://github.com/JuliaLang/JSON.jl/issues/108
ex = @catch_except BondSerializationException rcall(py, "test_id", Base)
@test ex.remote === false
@test reval(py, "1") === 1

# test remote serialization error
reval(py, """def test_rmt():
    return lambda x: x
"""; block=true)

ex = @catch_except BondSerializationException rcall(py, "test_rmt")
@test ex.remote === true
@test reval(py, "1") === 1
