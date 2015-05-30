include("prelude.jl")

# ensure refs are bound to their bond
py1 = bond!("Python", `python`; timeout=TIMEOUT)
py2 = bond!("Python", `python`; timeout=TIMEOUT)

ref1 = rref(py1, "1")
ref2 = rref(py2, "1")

@test reval(py1, ref1) === 1
@test reval(py2, ref2) === 1
@test_throws BondException reval(py1, ref2)
