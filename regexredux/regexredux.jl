# The Computer Language Benchmarks Game
# https://salsa.debian.org/benchmarksgame-team/benchmarksgame/
#
# contributed by Daniel Jones
# fixed by David Campbell
# modified by Jarrett Revels, Alex Arslan, Yichao Yu

using Printf

const variants = Regex.([
      "agggtaaa|tttaccct",
      "[cgt]gggtaaa|tttaccc[acg]",
      "a[act]ggtaaa|tttacc[agt]t",
      "ag[act]gtaaa|tttac[agt]ct",
      "agg[act]taaa|ttta[agt]cct",
      "aggg[acg]aaa|ttt[cgt]ccct",
      "agggt[cgt]aa|tt[acg]accct",
      "agggta[cgt]a|t[acg]taccct",
      "agggtaa[cgt]|[acg]ttaccct"
])

const subs = [
    (r"tHa[Nt]" => "<4>"),
    (r"aND|caN|Ha[DS]|WaS" => "<3>"),
    (r"a[NSt]|BY" => "<2>"),
    (r"<[^>]*>" => "|"),
    (r"\|[^|][^|]*\|" => "-")
]

function replace_fast!(out::IO, str::AbstractString, pat_repl::Pair)
    pattern, repl = pat_repl
    n = 1
    e = lastindex(str)
    i = a = firstindex(str)
    r = something(findnext(pattern,str,i), 0)
    j, k = first(r), last(r)
    while j != 0
        if i == a || i <= k
            Base.unsafe_write(out, pointer(str, i), UInt(j - i))
            Base._replace(out, repl, str, r, pattern)
        end
        if k < j
            i = j
            j > e && break
            k = nextind(str, j)
        else
            i = k = nextind(str, k)
        end
        r = something(findnext(pattern,str,k), 0)
        r == 0:-1 && break
        j, k = first(r), last(r)
        n += 1
    end
    write(out, SubString(str, i))
end

function inner(subs, res)
    for i in 2:length(subs)
        res = replace(res, subs[i])
    end
    res
end
function perf_regex_dna(io = stdin, output = stdout)
    N = Threads.nthreads()
    seq = read(io, String)
    l1 = length(seq)
    seq = replace(seq, r">.*\n|\n" => "")
    l2 = length(seq)
    res = Vector{Tuple{Int, Int}}(undef, N)
    Threads.@threads for i in 1:length(variants)
        k = 0; v = variants[i]
        for m in eachmatch(v, seq)
            k += 1
        end
        @inbounds res[Threads.threadid()] = (i, k)
    end
    nchunk = length(seq) ÷ N
    results = zeros(N)
    for id in 1:N
        chunk = SubString(seq, (id - 1) * nchunk + 1, min(id * nchunk, length(seq)))
        resio = IOBuffer(sizehint = nchunk)
        for sub in subs
            replace_fast!(resio, String(take!(resio)), sub)
        end
        results[id] += resio.size
    end

    println(output)
    println(output, l1 + 1)  # why + 1??
    println(output, l2)
    println(output, length(seq))
end

# perf_regex_dna()
cd(@__DIR__)
@time perf_regex_dna("../fasta.txt", IOBuffer());
x = IOBuffer()
