include("prelude.jl")

py1 = make_bond("Python", `python`; timeout=TIMEOUT)
py2 = make_bond("Python", `python`; timeout=TIMEOUT)

beval(py1, """def fun1():
    return 42
"""; block=true)

@test bcall(py1, "fun1") === 42

# proxy with implicit name
proxyfn(py1, "fun1", py2)
@test bcall(py2, "fun1") === 42

# proxy with explicit name
proxyfn(py1, "fun1", py2, "fun2")
@test bcall(py2, "fun2") === 42
