# We assume all drivers are tested in the reference Python implementation.
# As such, we only test one driver (Python) in order to cover the current host.

dir = dirname(@__FILE__)
tests = 0
fails = 0

for f in readdir(dir)
    m = match(r"^test_(.*)\.jl$", f)
    fp = joinpath(dir, f)
    if m === nothing || !isfile(fp)
        continue
    end

    tests = tests + 1
    name = m.captures[1]
    print("$name ... ")
    try
        evalfile(fp)
        println("OK")
    catch e
        fails = fails + 1
        println("FAIL: $e")
    end
end

exit(fails != 0)
