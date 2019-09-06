# Based on https://benchmarksgame-team.pages.debian.net/benchmarksgame/program/nbody-rust-7.html
# NB: rustc fully unrolls every outer for loop inside of advance
#
# We mimic this here with a very hacky macro. The first for loop is not
# yet inlined.
#
# The basic strategy matches Rust #7, based on gcc #4: use vectorized rsqrt
# to compute pairwise distances.
#
# We deviate by also skipping a single Newton step

module NBody

using StaticArrays, SIMD, Printf
using Base: llvmcall

const solar_mass = 4π^2
const days_per_year = 365.24
const NBODIES = 5
const NPAIRS = Int(NBODIES * (NBODIES - 1) / 2)
const PAIRS = Tuple((i,j) for i = 1:5, j = 1:5 if j > i)

struct Bodies
    x::MMatrix{NBODIES, 3, Float64}
    v::MMatrix{NBODIES, 3, Float64}
    m::NTuple{NBODIES, Float64}
end

macro const_unroll(for_loop)
    cond = for_loop.args[1]
    body = for_loop.args[2]

    conds = (cond.head == :block) ? cond.args : Any[cond]
    bind_syms = [cond.args[1] for cond = conds]
    const_bounds = collect(Iterators.product((eval(cond.args[2]) for cond = conds)...))
    bind_exprs = []
    for bind_vals = const_bounds
        binding_list = Any[]
        for (sym, val) = collect(Iterators.zip(bind_syms, bind_vals))
            push!(binding_list, Expr(:(=), esc(sym), esc(val)))
        end
        push!(bind_exprs, Expr(:let, Expr(:block, binding_list...), esc(body)))
    end

    return Expr(:block, bind_exprs...)
end

function init_bodies!(bodies)
  x, v = bodies.x, bodies.v
  # Sun
  x[1, :] = [0, 0, 0]
  v[1, :] = [0, 0, 0]

  # Jupiter
  x[2, :] = [
    4.84143144246472090e+00,
    -1.16032004402742839e+00,
    -1.03622044471123109e-01,
  ]
  v[2, :] = [
    1.66007664274403694e-03,
    7.69901118419740425e-03,
    -6.90460016972063023e-05,
  ] .* days_per_year

  # Saturn
  x[3, :] = [
    8.34336671824457987e+00,
    4.12479856412430479e+00,
    -4.03523417114321381e-01,
    ]
  v[3, :] = [
    -2.76742510726862411e-03,
    4.99852801234917238e-03,
    2.30417297573763929e-05,
  ] .* days_per_year

  # Uranus
  x[4, :] = [
    1.28943695621391310e+01,
    -1.51111514016986312e+01,
    -2.23307578892655734e-01,
  ]
  v[4, :] = [
    2.96460137564761618e-03,
    2.37847173959480950e-03,
    -2.96589568540237556e-05,
  ] .* days_per_year

  # Neptune
  x[5, :] = [
    1.53796971148509165e+01,
    -2.59193146099879641e+01,
    1.79258772950371181e-01,
  ]
  v[5, :] = [
    2.68067772490389322e-03,
    1.62824170038242295e-03,
    -9.51592254519715870e-05,
  ] * days_per_year
end

const __m128 = NTuple{4, VecElement{Float32}}
const __m128d = NTuple{2, VecElement{Float64}}
const v2d = Vec{2, Float64}

@inline function rsqrt_pd(v2::v2d)
    v2d(rsqrt_ccall(v2.elts))
end

@inline function rsqrt_pd_newton(v2::v2d)
    guess = rsqrt_pd(v2)
    # We only need one Newton step to achieve desired accuracy
    guess = guess * 1.5 - ((0.5 * v2) * guess) * (guess * guess)
    guess
end

rsqrt(f::__m128) = ccall(
  "llvm.x86.sse.rsqrt.ps",
  llvmcall, __m128, (__m128, ), f);
_mm_cvtpd_ps(f::__m128d) = ccall(
  "llvm.x86.sse2.cvtpd2ps",
  llvmcall, __m128, (__m128d, ), f);
_mm_cvtps_pd(f::__m128) = llvmcall(("", "
        %2 = shufflevector <4 x float> %0, <4 x float> undef, <2 x i32> <i32 0, i32 1>
        %3 = fpext <2 x float> %2 to <2 x double>
        ret <2 x double> %3"),
  __m128d,
  Tuple{__m128}, f)
@inline rsqrt_ccall(f::__m128d) = _mm_cvtps_pd(rsqrt(_mm_cvtpd_ps(f)))

@inline function advance(#x, v, m, dt, dx, dmag)
    x::MMatrix{NBODIES, 3, Float64, NBODIES * 3},
    v::MMatrix{NBODIES, 3, Float64, NBODIES * 3},
    m::NTuple{NBODIES, Float64},
    dt::Float64,
    dx::MMatrix{NPAIRS, 3, Float64, NPAIRS * 3},
    dmag::MVector{NPAIRS, Float64})

    dmag_v2d_ptr = Base.unsafe_convert(Ptr{v2d}, pointer_from_objref(dmag))
    dx_v2d_ptr = Base.unsafe_convert(Ptr{v2d}, pointer_from_objref(dx))

    # Unroll loop to calculate distances + store two at a time
    @inbounds for k1 = 1:2:length(PAIRS)
        k2 = k1 + 1
        k_v2d = k2 ÷ 2

        i1, j1 = PAIRS[k1]
        i2, j2 = PAIRS[k2]

        dx1 = v2d((x[i1, 1], x[i2, 1])) - v2d((x[j1, 1], x[j2, 1]))
        dx2 = v2d((x[i1, 2], x[i2, 2])) - v2d((x[j1, 2], x[j2, 2]))
        dx3 = v2d((x[i1, 3], x[i2, 3])) - v2d((x[j1, 3], x[j2, 3]))
        unsafe_store!(dx_v2d_ptr, dx1, k_v2d)
        unsafe_store!(dx_v2d_ptr, dx2, k_v2d + NPAIRS ÷ 2)
        unsafe_store!(dx_v2d_ptr, dx3, k_v2d + NPAIRS)

        dsq = dx1^2 + dx2^2 + dx3^2
        drsqrt = rsqrt_pd_newton(dsq)
        mag = dt * drsqrt / dsq
        unsafe_store!(dmag_v2d_ptr, mag, k_v2d)
    end

    @inbounds begin
      k = 1
      @const_unroll for (i, j) = PAIRS
          dmag_i = dmag[k] * m[i]
          dmag_j = dmag[k] * m[j]
          for d = 1:3
            dx_k = dx[k, d]
            v[i, d] -= dx_k * dmag_j
            v[j, d] += dx_k * dmag_i
          end
        k += 1
      end
    end

    @inbounds begin
      @const_unroll for i = 1:NBODIES
        @const_unroll for d = 1:3
          x[i, d] += dt * v[i, d]
        end
      end
    end
end

function energy(bodies)
  x, v, m = bodies.x, bodies.v, bodies.m
  e = 0.0
  for i = 1:NBODIES
    e += 0.5 * m[i] * sum(v[i, :].^2)
    for j = i + 1:NBODIES
      dx = x[i, :] - x[j, :]
      distance = sqrt(sum(dx .* dx))
      e -= (m[i] * m[j]) / distance
    end
  end
  return e
end

function init_sun!(bodies)
  px = [0.0, 0.0, 0.0]
  for i = 1:NBODIES
    px += bodies.v[i, :] * bodies.m[i]
  end
  bodies.v[1, :] = -px ./ solar_mass
end

function main(iterations::Int64)
  n = iterations

  x = zeros(MMatrix{NBODIES, 3, Float64, 15})
  v = zeros(MMatrix{NBODIES, 3, Float64, 15})
  m = NTuple{NBODIES, Float64}((
    1.0,
    9.54791938424326609e-04,
    2.85885980666130812e-04,
    4.36624404335156298e-05,
    5.15138902046611451e-05,
  ) .* solar_mass)
  bodies = Bodies(x, v, m)

  init_bodies!(bodies)
  init_sun!(bodies)
  @printf("%.9f\n", energy(bodies))

  # Buffers
  dx = zeros(MMatrix{NPAIRS, 3, Float64, 30})
  dmag = zeros(MVector{NPAIRS, Float64})
  for _ = 1:n
    advance(x, v, m, 0.01, dx, dmag)
  end

  @printf("%.9f\n", energy(bodies))
end

end

@time NBody.main(parse(Int64, ARGS[1]))
@time NBody.main(parse(Int64, ARGS[1]))

# > julia -O3 -C core2 -- nbody_unsafe_simd_unroll.jl 50000000
# -0.169075164
# -0.169060076
#   7.311025 seconds (9.49 M allocations: 460.274 MiB, 2.98% gc time)
# -0.169075164
# -0.169060076
#   3.609759 seconds (470 allocations: 11.891 KiB)

# using StaticArrays, InteractiveUtils
# nb = NBody
# code_native(nb.advance,
#   (MMatrix{nb.NBODIES, 3, Float64, nb.NBODIES * 3},
#   MMatrix{nb.NBODIES, 3, Float64, nb.NBODIES * 3},
#   NTuple{nb.NBODIES, Float64},
#   Float64,
#   MMatrix{nb.NPAIRS, 3, Float64, nb.NPAIRS * 3},
#   MVector{nb.NPAIRS, Float64}))
