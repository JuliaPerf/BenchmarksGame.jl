#=
The Computer Language Benchmarks Game
 https://salsa.debian.org/benchmarksgame-team/benchmarksgame/
 direct transliteration of the swift#3 program by Ralph Ganszky and Daniel Muellenborn:
 https://benchmarksgame-team.pages.debian.net/benchmarksgame/program/mandelbrot-swift-3.html
 modified for Julia 1.0 by Simon Danisch
=#
const zerov8 = ntuple(x-> 0f0, 8)

# Calculate mandelbrot set for one Vec8 into one byte
Base.@propagate_inbounds function mand8(cr, ci)
    Zr = zerov8
    Zi = zerov8
    Tr = zerov8
    Ti = zerov8
    t = zerov8
    for i in 0:49
        Zi = 2f0 .* Zr .* Zi .+ ci
        Zr = Tr .- Ti .+ cr
        Tr = Zr .* Zr
        Ti = Zi .* Zi
        t = Tr .+ Ti
        all(x-> x > 4f0, t) && break
    end
    byte = UInt8(0)
    t[1] <= 4f0 && (byte |= 0x80)
    t[2] <= 4f0 && (byte |= 0x40)
    t[3] <= 4f0 && (byte |= 0x20)
    t[4] <= 4f0 && (byte |= 0x10)
    t[5] <= 4f0 && (byte |= 0x08)
    t[6] <= 4f0 && (byte |= 0x04)
    t[7] <= 4f0 && (byte |= 0x02)
    t[8] <= 4f0 && (byte |= 0x01)
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

function mandelbrot(n = 200)
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
    write(stdout, "P4\n$n $n\n")
    write(stdout, rows)
end

mandelbrot(parse(Int, ARGS[1]))
