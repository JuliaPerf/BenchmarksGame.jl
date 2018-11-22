# The Computer Language Benchmarks Game
# https://salsa.debian.org/benchmarksgame-team/benchmarksgame/

# based on Oleg Mazurov's Java Implementation and Jeremy Zerfas' C implementation
# transliterated by Hamza Yusuf Çakır

global const preferred_num_blocks = 12

struct Fannkuch
    n::Int64
    blocksz::Int64
    maxflips::Vector{Int32}
    chksums::Vector{Int32}

    function Fannkuch(n, nthreads)
        nfact = factorial(n)

        blocksz = nfact ÷ (nfact < preferred_num_blocks ? 1 : preferred_num_blocks)
        maxflips = zeros(Int32,nthreads)
        chksums = zeros(Int32, nthreads)

        new(n, blocksz, maxflips, chksums)
    end
end

struct Perm
    p::Vector{Int8}
    pp::Vector{Int8}
    count::Vector{Int8}

    function Perm(n)
        p = zeros(Int8, n)
        pp = zeros(Int8, n)
        count = zeros(Int8, n)

        new(p, pp, count)
    end
end

Base.@propagate_inbounds function first_permutation(perm::Perm, idx)
    p = perm.p
    pp = perm.pp

    for i = 2:length(p)
        p[i] = i - 1
    end

    for i = length(p):-1:2
        ifact = factorial(i-1)
        d = idx ÷ ifact
        perm.count[i] = d
        idx = idx % ifact

        for j = 1:i
            pp[j] = p[j]
        end

        for j = 1:i
            p[j] = j+d <= i ? pp[j+d] : pp[j+d-i]
        end
    end
end

Base.@propagate_inbounds function next_permutation(perm::Perm)
    p = perm.p
    count = perm.count

    first = p[2]
    p[2]  = p[1]
    p[1]  = first

    i = 2
    while (count[i] + 1) >= i
        count[i] = 0
        i += 1

        next = p[1] = p[2]

        for j = 1:i-1
            p[j] = p[j+1]
        end

        p[i] = first
        first = next
    end
    count[i] += 1
end

Base.@propagate_inbounds @inline function count_flips(perm::Perm)
    p = perm.p
    pp = perm.pp

    flips = 1
    first = p[1] + 1
    if p[first] != 0

        copyto!(pp, 2, p, 2, length(p) - 1)

        while true
            flips += 1

            new_first = pp[first]
            pp[first] = first - 1

            if first > 3
                lo = 2; hi = first-1

                # see the note in Jeremy Zerfas' C implementation
                for k = 1:15
                    t = pp[lo]
                    pp[lo] = pp[hi]
                    pp[hi] = t

                    !((lo + 3) <= hi) && break
                    lo += 1
                    hi -= 1
                end
            end

            first = new_first + 1
            pp[first] == 0 && break
        end
    end

    return flips
end

Base.@propagate_inbounds function run_task(f::Fannkuch, perm::Perm, idxmin, idxmax)

    maxflips = 1
    chksum = 0

    let
        i = idxmin
        while true
            if perm.p[1] != 0
                flips = count_flips(perm)
                maxflips = max(maxflips, flips)
                chksum += iseven(i) ? flips : -flips
            end
            if i == idxmax
                break
            end
            i += 1
            next_permutation(perm)
        end
    end
    id = Threads.threadid()
    f.maxflips[id] = max(f.maxflips[id], maxflips)
    f.chksums[id] += chksum
end

function runf(f::Fannkuch)
    factn = factorial(f.n)

    Threads.@threads for idxmin=0:f.blocksz:factn-1
        perm = Perm(f.n)
        first_permutation(perm, idxmin)
        idxmax = idxmin + f.blocksz - 1
        @inbounds run_task(f, perm, idxmin, idxmax)
    end
end

function fannkuchredux(n)
    f = Fannkuch(n,Threads.nthreads())

    runf(f)

    # reduce results
    chk = sum(f.chksums)
    res = maximum(f.maxflips)

    println(chk, "\nPfannkuchen(", n, ") = ", res)
end

n = parse(Int, ARGS[1])
@time fannkuchredux(n)
