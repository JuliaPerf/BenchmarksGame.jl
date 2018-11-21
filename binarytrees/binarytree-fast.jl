# The Computer Language Benchmarks Game
# https://salsa.debian.org/benchmarksgame-team/benchmarksgame/

# contributed by Simon Danisch
# based on the [C++ implementation](https://benchmarksgame-team.pages.debian.net/benchmarksgame/program/binarytrees-gpp-9.html)

using Printf
struct Node
    left::Int
    right::Int
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
function check(pool, node::Int)
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
    @sprintf("%i\t trees of depth %i\t check: %i\n", niter, d, c)
end
function loop_depths(io, d, min_depth, max_depth)
    output = ntuple(x-> String[], Threads.nthreads())
    Threads.@threads for d in min_depth:2:max_depth
        pool = Node[]
        push!(output[Threads.threadid()], threads_inner(pool, d, min_depth, max_depth))
    end
    foreach(s->foreach(x->print(io, x), s), output)
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

    loop_depths(io, min_depth, min_depth, max_depth)
    @printf(io, "long lived tree of depth %i\t check: %i\n", max_depth, check(pool, long_lived_tree))
end
n = parse(Int, ARGS[1])
perf_binary_trees(stdout, n)
