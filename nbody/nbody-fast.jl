# The Computer Language Benchmarks Game
# https://salsa.debian.org/benchmarksgame-team/benchmarksgame/

# contributed by Jarret Revels and Alex Arslan
# based on the Java version

module NBody

using Printf
using LinearAlgebra

# Utilities
@inline combinations(x, y::Tuple{}) = ()
@inline combinations(x, y::Tuple) = ((x, y[1]), combinations(x, Base.tail(y))...)
@inline unordered_pairs(x, y) = ((x, y),)
@inline unordered_pairs(x, y, tail...) = (combinations(x, (y, tail...))..., unordered_pairs(y, tail...)...)

@inline _mapreduce(f, op, head) = f(head)
@inline _mapreduce(f, op, head, tail...) = op(f(head), _mapreduce(f, op, tail...))

@inline _foreach(f, head) = (f(head); nothing)
@inline _foreach(f, head, tail...) = (f(head); _foreach(f, tail...); nothing)

# Constants
const solar_mass = 4π^2
const days_per_year = 365.24

struct Vec3
    x::NTuple{3, Float64}
end
@inline Vec3(x, y, z) = Vec3((x,y,z))
@inline Base.:/(v::Vec3, n::Number) = @inbounds return Vec3(1/n .* v.x)
@inline Base.:*(v::Vec3, n::Number) = @inbounds return Vec3(n .* v.x)
@inline Base.:-(v1::Vec3, v2::Vec3) = @inbounds return Vec3(v1.x .- v2.x)
@inline Base.:+(v1::Vec3, v2::Vec3) = @inbounds return Vec3(v1.x .+ v2.x)
@inline squarednorm(v1::Vec3) = @inbounds return sum(v1.x .* v1.x)
@inline Base.muladd(x::Vec3, y::Number, z::Vec3) = @inbounds return Vec3(muladd.(x.x, y, z.x))

# A heavenly body in the system
mutable struct Body{mass}
    pos::Vec3
    vel::Vec3
end

@inline mass(::Body{m}) where {m} = m
@inline momentum(body::Body) = body.vel * mass(body)
@inline kinetic_energy(body::Body) = (mass(body) / 2) * squarednorm(body.vel)

@inline function potential_energy(bi::Body, bj::Body)
    sqdistance = squarednorm(bi.pos - bj.pos)
    -(mass(bi) * mass(bj)) / sqrt(sqdistance)
end

@inline potential_energy(bodies::Tuple{<:Body, <:Body}) = potential_energy(bodies...)

@inline function init_sun!(bodies)
    p = _mapreduce(momentum, +, bodies...)
    @inbounds bodies[1].vel -= p / solar_mass
    nothing
end

@inline function advance(bodies, dt::Number)
    _foreach(unordered_pairs(bodies...)...) do (bi, bj)
        Base.@_inline_meta
        delta = bi.pos - bj.pos
        dsq = squarednorm(delta)
        distance = sqrt(dsq)
        mag = 1 / (dsq * distance)
        bi.vel = muladd(delta, -(mass(bj) * dt) * mag, bi.vel)
        bj.vel = muladd(delta,  (mass(bi) * dt) * mag, bj.vel)
        nothing
    end
    _foreach(bodies...) do b
        Base.@_inline_meta
        b.pos = muladd(b.vel, dt, b.pos)
    end
    return nothing
end

@inline function energy(bodies)
    kinetic = _mapreduce(kinetic_energy, +, bodies...)
    potential = _mapreduce(potential_energy, +, unordered_pairs(bodies...)...)
    return kinetic + potential
end

function perf_nbody(N::Int=1000)
    jupiter = Body{9.54791938424326609e-04 * solar_mass}(          # mass
                   Vec3(4.84143144246472090e+00,                   # pos[1] = x
                         -1.16032004402742839e+00,                 # pos[2] = y
                         -1.03622044471123109e-01),                # pos[3] = z
                   Vec3(1.66007664274403694e-03 * days_per_year,   # v[1] = vx
                        7.69901118419740425e-03 * days_per_year,   # v[2] = vy
                        -6.90460016972063023e-05 * days_per_year), # v[3] = vz
                   )

    saturn = Body{2.85885980666130812e-04 * solar_mass}(
                  Vec3(8.34336671824457987e+00,
                       4.12479856412430479e+00,
                      -4.03523417114321381e-01),
                  Vec3(-2.76742510726862411e-03 * days_per_year,
                       4.99852801234917238e-03 * days_per_year,
                       2.30417297573763929e-05 * days_per_year),
                  )

    uranus = Body{4.36624404335156298e-05 * solar_mass}(
                  Vec3(1.28943695621391310e+01,
                    -1.51111514016986312e+01,
                    -2.23307578892655734e-01),
                  Vec3(2.96460137564761618e-03 * days_per_year,
                       2.37847173959480950e-03 * days_per_year,
                       -2.96589568540237556e-05 * days_per_year),
                  )

    neptune = Body{5.15138902046611451e-05 * solar_mass}(
                   Vec3(1.53796971148509165e+01,
                        -2.59193146099879641e+01,
                        1.79258772950371181e-01),
                   Vec3(2.68067772490389322e-03 * days_per_year,
                        1.62824170038242295e-03 * days_per_year,
                       -9.51592254519715870e-05 * days_per_year),
                   )

    sun = Body{solar_mass}(Vec3(0.0, 0.0, 0.0), Vec3(0.0, 0.0, 0.0))

    bodies = (sun, jupiter, saturn, uranus, neptune)

    init_sun!(bodies)
    @printf("%.9f\n", energy(bodies))
    for i in Base.OneTo(N)
        advance(bodies, 0.01)
    end
    @printf("%.9f\n", energy(bodies))
    return nothing
end

end # module

n = parse(Int, ARGS[1])
NBody.perf_nbody(n)
