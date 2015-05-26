include("prelude.jl")

# test capture itself
output = capture_stdout() do
    println("Hello world from Julia!")
end
@test output == "Hello world from Julia!\n"

# test STDOUT redirection
output = capture_stdout() do
    py = make_bond("Python"; timeout=TIMEOUT)
    beval(py, "print \"Hello world from STDOUT!\""; block=true)
end
@test output == "Hello world from STDOUT!\n"

# test STDERR redirection
output = capture_stderr() do
    py = make_bond("Python"; timeout=TIMEOUT)
    beval(py, "import sys;"; block=true)
    bcall(py, "sys.stderr.write", "Hello world from STDERR!\n")
end
@test output == "Hello world from STDERR!\n"
