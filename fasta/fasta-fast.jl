# The Computer Language Benchmarks Game
# https://salsa.debian.org/benchmarksgame-team/benchmarksgame/
#
# contributed by Jarret Revels and Alex Arslan

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

function repeat_fasta(src, n)
    k = length(src)
    s = string(src, src, src[1:(n % k)])
    I = Iterators.cycle(src)
    col = 1
    count = 1
    c, state = iterate(I)
    print(c)
    while count < n
        col += 1
        c, state = iterate(I, state)
        print(c)
        if col == line_width
            println()
            col = 0
        end
        count += 1
    end
    println()
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

function random_fasta(symb, pr, n)
    cs = cumsum(pr)
    line = Vector{UInt8}(undef, line_width)
    k = n
    while k > 0
        m = min(k, line_width)
        resize!(line, m)
        for i = 1:m
            line[i] = symb[choose_char(cs)]
        end
        println(String(copy(line)))
        k -= line_width
    end
    return
end

function perf_fasta(n=25000000)
  println(">ONE Homo sapiens alu")
  repeat_fasta(alu, 2n)

  println(">TWO IUB ambiguity codes")
  random_fasta(iub1, iub2, 3n)
  println(">THREE Homo sapiens frequency")
  random_fasta(homosapiens1, homosapiens2, 5n)
end

n = parse(Int,ARGS[1])
perf_fasta(n)

