include("prelude.jl")

py = bond!("Python", `python`; timeout=TIMEOUT)

# test types over call
reval(py, """def test_id(arg):
    return arg
"""; block=true)

reval(py, """def test_id2(arg1, arg2):
    return arg1, arg2
"""; block=true)

for value in [nothing; true; false; 0; 1; "String"; 0.0; 1.;
              []; ["String"]; Dict("a"=>"b")]
    # single value
    @test rcall(py, "test_id", value) == value

    # tuples are upgraded to arrays
    @test rcall(py, "test_id2", value, value) == [value; value]
end
