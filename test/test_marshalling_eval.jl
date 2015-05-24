include("prelude.jl")

py = make_bond("Python", `python`; timeout=TIMEOUT)

# test types over eval
ret = beval(py, "None")
@test ret === nothing

ret = beval(py, "True")
@test ret === true

ret = beval(py, "False")
@test ret === false

ret = beval(py, "0")
@test ret === 0

ret = beval(py, "1")
@test ret === 1

ret = beval(py, "\"String\"")
@test ret == "String"

ret = beval(py, "0.0")
@test ret === 0.0

ret = beval(py, "1.0")
@test ret === 1.0

ret = beval(py, "[]")
@test ret == []

ret = beval(py, "[\"String\"]")
@test ret == ["String"]

ret = beval(py, "{\"a\": \"b\"}")
@test ret == @compat Dict("a"=>"b")
