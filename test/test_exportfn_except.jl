include("prelude.jl")

py = make_bond("Python", `python`; timeout=TIMEOUT)

# test exceptions in exported functions
gen_except() = throw("test")
exportfn(py, gen_except)
ex = @catch_except BondRemoteException bcall(py, "gen_except")
@test ex.msg == "test"
@test beval(py, "1") === 1
