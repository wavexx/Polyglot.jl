include("prelude.jl")

py1 = bond!("Python", `python`; timeout=TIMEOUT)
py2 = bond!("Python", `python`; timeout=TIMEOUT)

reval(py1, """def fun1():
    return 42
"""; block=true)

@test rcall(py1, "fun1") === 42

# proxy with implicit name
proxyfn(py1, "fun1", py2)
@test rcall(py2, "fun1") === 42

# proxy with explicit name
proxyfn(py1, "fun1", py2, "fun2")
@test rcall(py2, "fun2") === 42
