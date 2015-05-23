using Bond
using Base.Test

TIMEOUT = parse(Int, get(ENV, "BOND_TIMEOUT", "1"))

py = make_bond("Python"; timeout=TIMEOUT)
ret = beval(py, "1")
@assert ret == 1
#close(py) # TODO: needs Expect 0.1.2
