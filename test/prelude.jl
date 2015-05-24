using Base.Test
using Bond
using Compat

TIMEOUT = parse(Int, get(ENV, "BOND_TIMEOUT", "1"))
