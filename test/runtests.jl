using Bond
using Base.Test

TIMEOUT = parse(Int, get(ENV, "BOND_TIMEOUT", "1"))

# We assume all drivers are tested in the reference Python implementation.
# As such, we only test one driver (Python) in order to cover the current host.

# default cmd/args
py = make_bond("Python"; timeout=TIMEOUT)
ret = beval(py, "1")
@assert ret == 1
#close(py) # TODO: needs Expect 0.1.2

# default args only
py = make_bond("Python", `python`; timeout=TIMEOUT)
ret = beval(py, "1")
@assert ret == 1

# break the command without arguments
@test_throws make_bond("Python", `ssh localhost python`, timeout=TIMEOUT, def_args=false)

# check default arguments with custom cmd
py = make_bond("Python", `ssh localhost python`, timeout=TIMEOUT)
ret = beval(py, "1")
@assert ret == 1

# broken command
@test_throws make_bond("Python", `false`; timeout=TIMEOUT)
