# The Computer Language Benchmarks Game
# https://salsa.debian.org/benchmarksgame-team/benchmarksgame/

# based on Oleg Mazurov's Java Implementation
# transliterated by Hamza Yusuf Çakır

global const nchunks = 150

struct Fannkuch
    n::Int64
    chunksz::Int32
    ntasks::Int32
    maxflips::Vector{Int32}
    chksums::Vector{Int32}
    taskId::Threads.Atomic{Int}

    function Fannkuch(n)
        nfact = factorial(n)

        chunksz = (nfact + nchunks - 1) ÷ nchunks
        ntasks = (nfact + chunksz - 1) ÷ chunksz

        maxflips = Vector{Int32}(undef, ntasks)
        chksums = Vector{Int32}(undef, ntasks)

        taskId = Threads.Atomic{Int}(0)

        new(n, chunksz, ntasks, maxflips, chksums, taskId)
    end
end

struct Perm
    p::Vector{Int32}
    pp::Vector{Int32}
    count::Vector{Int32}

    function Perm(n)
        p = zeros(Int32, n)
        pp = zeros(Int32, n)
        count = zeros(Int32, n)

        new(p, pp, count)
    end
end

Base.@propagate_inbounds function first_permutation(perm::Perm, idx)
    p = perm.p
    pp = perm.pp

    for i = Int32(1):Int32(length(p))
        p[i] = i - 1
    end

    for i = Int32(length(p)):Int32(-1):Int32(2)
        ifact = factorial(i-1)
        d = idx ÷ ifact
        perm.count[i] = d
        idx = idx % ifact

        for j = Int32(1):i
            pp[j] = p[j]
        end

        for j = Int32(1):i
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
    while (count[i] += 1) > i - 1
        count[i] = 0
        i += 1

        next = p[1] = p[2]

        for j = 1:i-1
            p[j] = p[j+1]
        end

        p[i] = first
        first = next
    end
end

Base.@propagate_inbounds function count_flips(perm::Perm)
    p = perm.p
    pp = perm.pp

    flips = 1
    first = p[1]

    if p[first + 1] != 0
        pp .= p

        while true # do..while(pp[first+1] != 0)
            flips += 1

            lo = 1; hi = first - 1
            while lo < hi
                t = pp[lo+1]
                pp[lo+1] = pp[hi+1]
                pp[hi+1] = t
                lo += 1
                hi -= 1
            end

            t = pp[first+1]
            pp[first+1] = first
            first = t

            (pp[first+1] == 0) && break
        end
    end

    return flips
end

Base.@propagate_inbounds function run_task(f::Fannkuch, perm::Perm, task)
    idxmin = task * f.chunksz
    idxmax = min(factorial(f.n), idxmin + f.chunksz)

    first_permutation(perm, idxmin)

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

            i += 1
            if i == idxmax
                break
            end

            next_permutation(perm)
        end
    end

    f.maxflips[task+1] = maxflips
    f.chksums[task+1] = chksum
end

function runf(f::Fannkuch)
    perm = Perm(f.n)

    taskId = f.taskId # atomic
    while (task = Threads.atomic_add!(taskId, 1)) < f.ntasks
        @inbounds run_task(f, perm, task)
    end
end

function fannkuchredux(n::Int)
    f = Fannkuch(n)

    Threads.@threads for i = 1:Threads.nthreads()
        runf(f)
    end

    chk = sum(f.chksums)
    res = maximum(f.maxflips)

    return (chk, res)
end

n = parse(Int, ARGS[1])
chk, res = fannkuchredux(n)
println(chk, "\nPfannkuchen(", n, ") = ", res)
