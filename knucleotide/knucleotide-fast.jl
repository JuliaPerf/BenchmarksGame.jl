# The Computer Language Benchmarks Game
# https://salsa.debian.org/benchmarksgame-team/benchmarksgame/
#
# contributed by David Campbell
# based on the Go version
# modified by Jarret Revels, Alex Arslan, Yichao Yu
#
# Bit-twiddle optimizations added by Kristoffer Carlsson

using Printf

struct KNucleotides
    i::UInt64
end
Base.hash(kn::KNucleotides, h::UInt64) = hash(kn.i, h)
Base.isequal(kn1::KNucleotides, kn2::KNucleotides) = kn1.i == kn2.i
KNucleotides() = KNucleotides(0)
Base.show(io::IO, kn::KNucleotides) = print(io, '[', string(kn), ']')

const NucleotideLUT = zeros(UInt8, 256)
NucleotideLUT['A'%UInt8] = 0
NucleotideLUT['C'%UInt8] = 1
NucleotideLUT['G'%UInt8] = 2
NucleotideLUT['T'%UInt8] = 3

length_bit(l) = (UInt64(1) << 2l)

# Should be called after the nucelotides are added!
set_length(kn::KNucleotides, l::Integer) = KNucleotides(kn.i | length_bit(l))
add_nucleotide(kn::KNucleotides, c::UInt8) = KNucleotides(@inbounds (kn.i << 2) | NucleotideLUT[c])
Base.length(kn::KNucleotides) = (64 - leading_zeros(kn.i) - 1) ÷ 2
function KNucleotides(str::String, n=length(str), offset=0)
    # @assert isascii(str) && n <= 29
    kn = KNucleotides()
    @inbounds for i in 1:n
        kn = add_nucleotide(kn, codeunit(str, i + offset))
    end
    kn = set_length(kn, n)
    return kn
end

function Base.string(kn::KNucleotides)
    l = length(kn)
    i = kn.i - length_bit(l)
    sprint() do io
        for j in 1:l
            iiii = i
            mask = 3 << (2(l-j))
            z = (i & mask) >> 2(l-j)
            write(io,
                z == 0 ? 'A' :
                z == 1 ? 'C' :
                z == 2 ? 'G' :
                z == 3 ? 'T' :
                error())
        end
    end
end

function count_data(data::String, n::Int)
    counts = Dict{KNucleotides, Int}()
    top = length(data) - n
    @inbounds for offset = 0:top
        kn = KNucleotides(data, n, offset)
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
    k = KNucleotides(s)
    d = count_data(data, length(s))
    return haskey(d, k) ? d[k] : 0
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

do_work(str::String, i::Int) = sorted_array(count_data(str, i))
do_work(str::String, i::String) = count_one(str, i)

function perf_k_nucleotide(io = stdin)
    three = ">THREE "
    while true
        line = readline(io)
        if startswith(line, three)
            break
        end
    end
    data = read(io, String)
    str = uppercase(data)
    str = filter(!isequal('\n'), str)

    vs = [1, 2, "GGT", "GGTA", "GGTATT", "GGTATTTTAATT", "GGTATTTTAATTTATAGT"]
    results = Vector{Any}(undef, length(vs))
    Threads.@threads for i in 1:length(vs)
        results[i] = do_work(str, vs[i])
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
