include("prelude.jl")

# test capture itself
output = capture_stdout() do
    println("Hello world from Julia!")
end
@test output == "Hello world from Julia!\n"

# test STDOUT redirection
output = capture_stdout() do
    py = bond!("Python"; timeout=TIMEOUT)
    reval(py, "print \"Hello world from STDOUT!\""; block=true)
end
@test output == "Hello world from STDOUT!\n"

# test STDERR redirection
output = capture_stderr() do
    py = bond!("Python"; timeout=TIMEOUT)
    reval(py, "import sys;"; block=true)
    rcall(py, "sys.stderr.write", "Hello world from STDERR!\n")
end
@test output == "Hello world from STDERR!\n"
