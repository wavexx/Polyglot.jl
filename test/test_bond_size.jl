include("prelude.jl")

py = bond!("Python", `python`; timeout=TIMEOUT)

# ensure that the pipe/TTY is opened properly and buffers are bound to
# available memory size
for size in [2^i for i=9:16]
    buf = repeat("x", size)
    ret = rcall(py, "str", buf)
    @test ret == buf
end
