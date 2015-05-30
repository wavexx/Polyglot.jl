include("prelude.jl")

# list drivers
drivers = Polyglot.list_drivers()
@test "Python" in drivers

# broken command
@test_throws BondException bond!("Python", `false`; timeout=TIMEOUT)

# default cmd/args
py = bond!("Python"; timeout=TIMEOUT)
ret = reval(py, "1")
@test ret == 1
close(py)

# default args only
py = bond!("Python", `python`; timeout=TIMEOUT)
ret = reval(py, "1")
@test ret == 1

# break the command without arguments
@test_throws BondException bond!("Python", `ssh localhost python`,
                                 timeout=TIMEOUT, def_args=false)

# check default arguments with custom cmd
py = bond!("Python", `ssh localhost python`, timeout=TIMEOUT)
ret = reval(py, "1")
@test ret == 1
