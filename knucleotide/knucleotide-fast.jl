# The Computer Language Benchmarks Game
# https://salsa.debian.org/benchmarksgame-team/benchmarksgame/
#
# contributed by David Campbell
# based on the Go version
# modified by Jarrett Revels, Alex Arslan, Yichao Yu
#
# Bit-twiddle optimizations added by Kristoffer Carlsson

using Distributed
using Printf

const NucleotideLUT = zeros(UInt8, 256)
NucleotideLUT['A'%UInt8] = 0
NucleotideLUT['C'%UInt8] = 1
NucleotideLUT['G'%UInt8] = 2
NucleotideLUT['T'%UInt8] = 3
NucleotideLUT['a'%UInt8] = 0
NucleotideLUT['c'%UInt8] = 1
NucleotideLUT['g'%UInt8] = 2
NucleotideLUT['t'%UInt8] = 3

struct KNucleotides{L, T}
    i::T
end
Base.hash(kn::KNucleotides, h::UInt64) = hash(kn.i, h)
Base.isequal(kn1::KNucleotides, kn2::KNucleotides) = kn1.i == kn2.i
Base.show(io::IO, kn::KNucleotides) = print(io, '[', string(kn), ']')
function determine_inttype(l)
    l <= 4 && return UInt8
    l <= 8 && return UInt16
    l <= 16 && return UInt32
    l <= 32 && return UInt64
    error("invalid length")
end

function KNucleotides{L, T}(str::String) where {L, T}
    i = T(0)
    @inbounds for j in 1:L
        b = codeunit(str, j)
        i = (i << 2) | NucleotideLUT[b]
    end
    return KNucleotides{L, T}(i)
end

@inline function shift(kn::KNucleotides{L, T}, c::UInt8) where {L, T}
    i = kn.i
    i &= (~(3 << 2(L-1)) % T)
    KNucleotides{L, T}((i << T(2)) | @inbounds NucleotideLUT[c])
end

function Base.string(kn::KNucleotides{L}) where {L}
    sprint() do io
        for j in 1:L
            mask = 3 << (2(L-j))
            z = (kn.i & mask) >> 2(L-j)
            write(io,
                z == 0 ? 'A' :
                z == 1 ? 'C' :
                z == 2 ? 'G' :
                z == 3 ? 'T' :
                error())
        end
    end
end

function count_data(data::String, ::Type{KNucleotides{L, T}}) where {L, T}
    counts = Dict{KNucleotides{L, T}, Int}()
    kn = KNucleotides{L, T}(data)
    counts[kn] = 1
    @inbounds for offset = (L+1):sizeof(data)
        c = codeunit(data, offset)
        kn = shift(kn, c)
        token = Base.ht_keyindex2!(counts, kn)
        if token > 0
            counts.vals[token] += 1
        else
            Base._setindex!(counts, 1, kn, -token)
        end
    end
    return counts
end

function count_one(data::String, s::String)
    L = length(s)
    K = KNucleotides{L, determine_inttype(L)}
    d = count_data(data, K)
    return get(d, K(s), 0)
end

struct KNuc
    name::String
    count::Int
end

# sort down
function Base.isless(x::KNuc, y::KNuc)
    if x.count == y.count
        return x.name > y.name
    end
    x.count > y.count
end

function sorted_array(m)
    kn = Vector{KNuc}(undef, length(m))
    i = 1
    for (k, v) in m
        kn[i] = KNuc(string(k), v)
        i += 1
    end
    sort!(kn)
end

do_work(str::String, i::Int) = sorted_array(count_data(str, KNucleotides{i,determine_inttype(i)}))
do_work(str::String, i::String) = count_one(str, i)

function print_knucs(a::Array{KNuc, 1})
    sum = 0
    for kn in a
        sum += kn.count
    end
    for kn in a
        @printf("%s %.3f\n", kn.name, 100.0kn.count/sum)
    end
    println()
end

function perf_k_nucleotide(io = stdin)
    three = ">THREE "
    while true
        line = readline(io)
        if startswith(line, three)
            break
        end
    end
    data = read(io, String)
    str = filter(!isequal('\n'), data)

    vs = (1, 2, "GGT", "GGTA", "GGTATT", "GGTATTTTAATT", "GGTATTTTAATTTATAGT")
    results = Vector{Any}(undef, length(vs))
    for (i, v) in enumerate(vs)
        results[i] = do_work(w, str, v[2])
    end

    for (v, result) in zip(vs, results)
        if result isa Array
            print_knucs(result)
        end
        if result isa Int
            @printf("%d\t%s\n", result, v)
        end
    end
end

perf_k_nucleotide()
