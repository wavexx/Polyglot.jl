include("prelude.jl")

# list drivers
drivers = Bond.list_drivers()
@test "Python" in drivers

# broken command
@test_throws BondException make_bond("Python", `false`; timeout=TIMEOUT)

# default cmd/args
py = make_bond("Python"; timeout=TIMEOUT)
ret = beval(py, "1")
@test ret == 1
close(py)

# default args only
py = make_bond("Python", `python`; timeout=TIMEOUT)
ret = beval(py, "1")
@test ret == 1

# break the command without arguments
@test_throws BondException make_bond("Python", `ssh localhost python`,
                                     timeout=TIMEOUT, def_args=false)

# check default arguments with custom cmd
py = make_bond("Python", `ssh localhost python`, timeout=TIMEOUT)
ret = beval(py, "1")
@test ret == 1
