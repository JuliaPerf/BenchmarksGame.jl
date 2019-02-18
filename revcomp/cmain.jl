# The Computer Language Benchmarks Game
# https://salsa.debian.org/benchmarksgame-team/benchmarksgame/
#
# contributed by David Campbell
# modified by Jarrett Revels, Kristoffer Carlsson, Alex Arslan

mutable struct PushVector{T, A<:AbstractVector{T}} <: AbstractVector{T}
    v::A
    l::Int
end

PushVector{T}() where {T} = PushVector(Vector{T}(undef, 60), 0)

Base.IndexStyle(::Type{<:PushVector}) = IndexLinear()
Base.length(v::PushVector) = v.l
Base.size(v::PushVector) = (v.l,)
@inline function Base.getindex(v::PushVector, i)
    @boundscheck checkbounds(v, i)
    @inbounds v.v[i]
end

function Base.push!(v::PushVector, i)
    v.l += 1
    if v.l > length(v.v)
        resize!(v.v, v.l * 2)
    end
    v.v[v.l] = i
    return v
end

function Base.resize!(v::PushVector, l::Integer)
    # Only support shrinking for now, since that is all we need
    @assert l <= v.l
    v.l = l
end

const _revcompdata = Dict(
   'A'=> 'T', 'a'=> 'T',
   'C'=> 'G', 'c'=> 'G',
   'G'=> 'C', 'g'=> 'C',
   'T'=> 'A', 't'=> 'A',
   'U'=> 'A', 'u'=> 'A',
   'M'=> 'K', 'm'=> 'K',
   'R'=> 'Y', 'r'=> 'Y',
   'W'=> 'W', 'w'=> 'W',
   'S'=> 'S', 's'=> 'S',
   'Y'=> 'R', 'y'=> 'R',
   'K'=> 'M', 'k'=> 'M',
   'V'=> 'B', 'v'=> 'B',
   'H'=> 'D', 'h'=> 'D',
   'D'=> 'H', 'd'=> 'H',
   'B'=> 'V', 'b'=> 'V',
   'N'=> 'N', 'n'=> 'N',
)

const revcompdata = zeros(UInt8, 256)
for (k, v) in _revcompdata
    revcompdata[k%UInt8] = v%UInt8
end

function print_buff(outio, bb)
    b = resize!(bb.v, length(bb))
    l = length(b)
    length(b) == 0 && return

    br = reverse!(b)
    for i = 1:60:l
        if i+59 > l
            write(outio, @view br[i:end])
        else
            write(outio, @view br[i:i+59])
        end
        write(outio, '\n')
    end
end

function perf_revcomp(io=stdin, outio = stdout)
    buff = PushVector{UInt8}()
    while true
        line = codeunits(readline(io))
        if isempty(line)
            print_buff(outio, buff)
            return
        elseif first(line) == UInt8('>')
            print_buff(outio, buff)
            resize!(buff, 0)
            write(outio, line)
            write(outio, '\n')
        else
            l = length(line)
            @inbounds for c in line
                push!(buff, revcompdata[c%Int])
            end
        end
    end
end
Base.@ccallable function julia_main(ARGS::Vector{String})::Cint
    perf_revcomp()
    return 0
end

open(joinpath(@__DIR__, "revcomp-input.txt")) do io
    perf_revcomp(io, IOBuffer())
end
