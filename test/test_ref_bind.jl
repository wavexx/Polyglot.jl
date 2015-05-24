include("prelude.jl")

# ensure refs are bound to their bond
py1 = make_bond("Python", `python`; timeout=TIMEOUT)
py2 = make_bond("Python", `python`; timeout=TIMEOUT)

ref1 = bref(py1, "1")
ref2 = bref(py2, "1")

@test beval(py1, ref1) === 1
@test beval(py2, ref2) === 1
@test_throws BondException beval(py1, ref2)
