using Base.Test
using Bond

TIMEOUT = parse(Int, get(ENV, "BOND_TIMEOUT", "1"))
