#=
The Computer Language Benchmarks Game
 https://salsa.debian.org/benchmarksgame-team/benchmarksgame/
 direct transliteration of the swift#3 program by Ralph Ganszky and Daniel Muellenborn:
 https://benchmarksgame-team.pages.debian.net/benchmarksgame/program/mandelbrot-swift-3.html
 modified for Julia 1.0 by Simon Danisch
=#
const zerov8 = ntuple(x-> 0f0, 8)

@inline function step_mandel(Zr,Zi,Tr,Ti,cr,ci)
    Zi = 2f0 .* Zr .* Zi .+ ci
    Zr = Tr .- Ti .+ cr
    Tr = Zr .* Zr
    Ti = Zi .* Zi
    return Zr,Zi,Tr,Ti
end

# Calculate mandelbrot set for one Vec8 into one byte
Base.@propagate_inbounds function mand8(cr, ci)
    Zr = zerov8
    Zi = zerov8
    Tr = zerov8
    Ti = zerov8
    t = zerov8
    i = 0

    while i<50
        for _ in 1:5
            Zr,Zi,Tr,Ti = step_mandel(Zr,Zi,Tr,Ti,cr,ci)
            i += 1
        end
        t = Tr .+ Ti
        all(x-> x > 4f0, t) && (return 0x00)
    end
    byte = 0xff
    t[1] <= 4.0 || (byte &= 0b01111111)
    t[2] <= 4.0 || (byte &= 0b10111111)
    t[3] <= 4.0 || (byte &= 0b11011111)
    t[4] <= 4.0 || (byte &= 0b11101111)
    t[5] <= 4.0 || (byte &= 0b11110111)
    t[6] <= 4.0 || (byte &= 0b11111011)
    t[7] <= 4.0 || (byte &= 0b11111101)
    t[8] <= 4.0 || (byte &= 0b11111110)
    return byte
end

function mandel_inner(rows, ci, y, N, xvals)
    @simd for x in 1:8:N
        @inbounds begin
            cr = ntuple(i-> xvals[x + (i - 1)], 8)
            rows[((y-1)*N÷8+(x-1)÷8) + 1] = mand8(cr, ci)
        end
    end
end

function mandelbrot(n = 200, io = stdout)
    inv_ = 2.0 / n
    N = n
    xvals = zeros(Float32, n)
    yvals = zeros(Float32, n)
    Threads.@threads for i in 0:(N-1)
        @inbounds xvals[i + 1] = i * inv_ - 1.5
        @inbounds yvals[i + 1] = i * inv_ - 1.0
    end
    rows = zeros(UInt8, n*N÷8)
    Threads.@threads for y in 1:N
        @inbounds ci = yvals[y]
        mandel_inner(rows, ci, y, N, xvals)
    end
    write(io, "P4\n$n $n\n")
    write(io, rows)
end
Base.@ccallable function julia_main(ARGS::Vector{String})::Cint

    mandelbrot(parse(Int, ARGS[1]), stdout)
    return 0
end

mandelbrot(160, IOBuffer())
