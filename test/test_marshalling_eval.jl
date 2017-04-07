include("prelude.jl")

py = bond!("Python", `python`; timeout=TIMEOUT)

# test types over eval
ret = reval(py, "None")
@test ret === nothing

ret = reval(py, "True")
@test ret === true

ret = reval(py, "False")
@test ret === false

ret = reval(py, "0")
@test ret === 0

ret = reval(py, "1")
@test ret === 1

ret = reval(py, "\"String\"")
@test ret == "String"

ret = reval(py, "0.0")
@test ret === 0.0

ret = reval(py, "1.0")
@test ret === 1.0

ret = reval(py, "[]")
@test ret == []

ret = reval(py, "[\"String\"]")
@test ret == ["String"]

ret = reval(py, "{\"a\": \"b\"}")
@test ret == Dict("a"=>"b")
