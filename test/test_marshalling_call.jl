include("prelude.jl")

py = make_bond("Python", `python`; timeout=TIMEOUT)

# test types over call
beval(py, """def test_id(arg):
    return arg
"""; stm=false)

beval(py, """def test_id2(arg1, arg2):
    return arg1, arg2
"""; stm=false)

for value in [nothing; true; false; 0; 1; "String"; 0.0; 1.;
              []; ["String"]; @compat Dict("a"=>"b")]
    # single value
    @test bcall(py, "test_id", value) == value

    # tuples are upgraded to arrays
    @test bcall(py, "test_id2", value, value) == [value, value]
end
