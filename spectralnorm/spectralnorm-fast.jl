# The Computer Language Benchmarks Game
# https://salsa.debian.org/benchmarksgame-team/benchmarksgame/

# contributed by Jarret Revels
# based on the Javascript program

using Printf

A(i,j) = @fastmath 1.0 / ((i+j)*(i+j+1.0)/2.0+i+1.0)

@inline function Au!(w, u)
    n = length(u)
    @inbounds Threads.@threads for i = 1:n
        w[i] = 0
        z = 0.0
        @simd for j = 1:n
           z += A(i-1, j-1) * u[j]
        end
        w[i] = z
    end
end

@inline function Atu!(v, w)
    n = length(w)
    @inbounds  Threads.@threads for i = 1:n
        z = 0.0
        @simd for j = 1:n
           z += A(j-1,i-1) * w[j]
        end
        v[i] = z
    end
end

function perf_spectralnorm(n::Int=100)
    u = ones(Float64, n)
    v = zeros(Float64 ,n)
    w = zeros(Float64, n)
    vv = vBv = 0
    for i = 1:10
        Au!(w, u)
        Atu!(v, w)
        Au!(w, v)
        Atu!(u, w)
    end
    @inbounds @simd for i = 1:n
        vBv += u[i]*v[i]
        vv += v[i]*v[i]
    end
    return sqrt(vBv/vv)
end

n = parse(Int,ARGS[1])
@printf("%.9f\n", perf_spectralnorm(n))
