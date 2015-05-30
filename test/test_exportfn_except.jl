include("prelude.jl")

py = bond!("Python", `python`; timeout=TIMEOUT)

# test exceptions in exported functions
gen_except() = throw("test")
exportfn(py, gen_except)
ex = @catch_except BondRemoteException rcall(py, "gen_except")
@test ex.msg == "test"
@test reval(py, "1") === 1

# test serialization errors in exported functions
gen_ser_except() = Base
exportfn(py, gen_ser_except)
ex = @catch_except BondSerializationException rcall(py, "gen_ser_except")
@test ex.remote == true
@test reval(py, "1") === 1
