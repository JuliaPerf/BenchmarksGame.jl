# The Computer Language Benchmarks Game
# https://salsa.debian.org/benchmarksgame-team/benchmarksgame/

# contributed by Simon Danisch
# based on the [C++ implementation](https://benchmarksgame-team.pages.debian.net/benchmarksgame/program/binarytrees-gpp-9.html)

using Printf
struct Node
    left::UInt32
    right::UInt32
end
function alloc!(pool, left, right)
    push!(pool, Node(left, right))
    return length(pool)
end
function make(pool, d)
    d == 0 && return 0
    alloc!(pool, make(pool, d - 1), make(pool, d - 1))
end
check(pool, t::Node) = 1 + check(pool, t.left) + check(pool, t.right)
function check(pool, node::Integer)
    node == 0 && return 1
    @inbounds return check(pool, pool[node])
end
function threads_inner(pool, d, min_depth, max_depth)
    niter = 1 << (max_depth - d + min_depth)
    c = 0
    for j = 1:niter
        c += check(pool, make(pool, d))
        empty!(pool)
    end
    return (niter, d, c)
end

function loop_depths(io, d, min_depth, max_depth, ::Val{N}) where N
    threadstore = ntuple(x-> NTuple{3, Int}[], N)
    Threads.@threads for d in min_depth:2:max_depth
        pool = Node[]
        push!(threadstore[Threads.threadid()], threads_inner(pool, d, min_depth, max_depth))
    end
    for results in threadstore, result in results
        @printf(io, "%i\t trees of depth %i\t check: %i\n", result...)
    end
end
function perf_binary_trees(io, N::Int=10)
    min_depth = 4
    max_depth = N
    stretch_depth = max_depth + 1
    pool = Node[]
    # create and check stretch tree
    c = check(pool, make(pool, stretch_depth))
    @printf(io, "stretch tree of depth %i\t check: %i\n", stretch_depth, c)

    long_lived_tree = make(pool, max_depth)

    loop_depths(io, min_depth, min_depth, max_depth, Val(Threads.nthreads()))
    @printf(io, "long lived tree of depth %i\t check: %i\n", max_depth, check(pool, long_lived_tree))
end

perf_binary_trees(stdout, parse(Int, ARGS[1]))
