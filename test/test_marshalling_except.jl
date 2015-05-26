include("prelude.jl")

py = make_bond("Python", `python`; timeout=TIMEOUT)

# test local serialization error
beval(py, """def test_id(arg):
    return arg
"""; stm=false)

ex = @catch_except BondSerializationException bcall(py, "test_id", STDIN)
@test ex.remote === false
@test beval(py, "1") === 1

# test remote serialization error
beval(py, """def test_rmt():
    return lambda x: x
"""; stm=false)

ex = @catch_except BondSerializationException bcall(py, "test_rmt")
@test ex.remote === true
@test beval(py, "1") === 1
