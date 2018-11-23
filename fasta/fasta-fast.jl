# The Computer Language Benchmarks Game
# https://salsa.debian.org/benchmarksgame-team/benchmarksgame/
#
# contributed by Jarret Revels and Alex Arslan

mutable struct PushVector{T, A<:AbstractVector{T}} <: AbstractVector{T}
    v::A
    l::Int
end

PushVector{T}() where {T} = PushVector(Vector{T}(undef, 0), 0)

Base.IndexStyle(::Type{PushVector{<:Any, A}}) where {A} = IndexStyle(A)
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

function Base.write(v::PushVector{UInt8}, s::String)
    for c in codeunits(s)
        push!(v, c)
    end
end
Base.write(v::PushVector{UInt8}, c::UInt8) = push!(v, c)

const line_width = 60

const alu = string(
   "GGCCGGGCGCGGTGGCTCACGCCTGTAATCCCAGCACTTTGG",
   "GAGGCCGAGGCGGGCGGATCACCTGAGGTCAGGAGTTCGAGA",
   "CCAGCCTGGCCAACATGGTGAAACCCCGTCTCTACTAAAAAT",
   "ACAAAAATTAGCCGGGCGTGGTGGCGCGCGCCTGTAATCCCA",
   "GCTACTCGGGAGGCTGAGGCAGGAGAATCGCTTGAACCCGGG",
   "AGGCGGAGGTTGCAGTGAGCCGAGATCGCGCCACTGCACTCC",
   "AGCCTGGGCGACAGAGCGAGACTCCGTCTCAAAAA")

const iub1 = b"acgtBDHKMNRSVWY"
const iub2 = [0.27, 0.12, 0.12, 0.27, 0.02,0.02, 0.02, 0.02, 0.02, 0.02,0.02, 0.02, 0.02, 0.02, 0.02]

const homosapiens1 = b"acgt"
const homosapiens2 = [0.3029549426680, 0.1979883004921,0.1975473066391, 0.3015094502008]

const IM   = Int32(139968)
const IA   = Int32(3877)
const IC   = Int32(29573)
const state = Ref(Int32(42))
gen_random() = (state[] = ((state[] * IA) + IC) % IM)

function repeat_fasta(io, src, n)
    k = length(src)
    s = string(src, src, src[1:(n % k)])
    I = Iterators.cycle(src)
    # I = Iterators.cycle(codeunits(src))
    col = 1
    count = 1
    c, state = iterate(I)
    write(io, c % UInt8)
    while count < n
        col += 1
        c, state = iterate(I, state)
        write(io, c % UInt8)
        if col == line_width
            write(io, '\n' % UInt8)
            col = 0
        end
        count += 1
    end
    write(io, '\n' % UInt8)
    return
end

function choose_char(cs)
    k = length(cs)
    r = gen_random() / IM
    r < cs[1] && return 1
    a = 1
    b = k
    while b > a + 1
        c = fld(a + b, 2)
        if r < cs[c]
            b = c
        else
            a = c
        end
    end
    return b
end

function random_fasta(io, symb, pr, n)
    cs = cumsum(pr)
    k = n
    while k > 0
        m = min(k, line_width)
        @inbounds for i = 1:m
            write(io, symb[choose_char(cs)])
        end
        write(io, '\n'%UInt8)
        k -= line_width
    end
    return
end

function perf_fasta(_n=25000000, _io = stdout)
  io = PushVector{UInt8}()
  write(io, ">ONE Homo sapiens alu\n")
  repeat_fasta(io, alu, 2n)

  write(io, ">TWO IUB ambiguity codes\n")
  random_fasta(io, iub1, iub2, 3n)
  write(io, ">THREE Homo sapiens frequency\n")
  random_fasta(io, homosapiens1, homosapiens2, 5n)
  z = resize!(io.v, length(io))
  write(_io, z)
end

n = parse(Int,ARGS[1])
perf_fasta(n)
