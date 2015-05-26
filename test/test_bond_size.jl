include("prelude.jl")

py = make_bond("Python", `python`; timeout=TIMEOUT)

# ensure that the pipe/TTY is opened properly and buffers are bound to
# available memory size
for size in [2^i for i=9:16]
    buf = repeat("x", size)
    ret = bcall(py, "str", buf)
    @test ret == buf
end
