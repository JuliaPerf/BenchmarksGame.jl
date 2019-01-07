# The Computer Language Benchmarks Game
# https://salsa.debian.org/benchmarksgame-team/benchmarksgame/

# based on an OCaml program
# *reset*

using Printf

abstract type BTree end

mutable struct Empty <: BTree
end

mutable struct Node <: BTree
    left::BTree
    right::BTree
end

function make(d)
    if d == 0
        Node(Empty(), Empty())
    else
        Node(make(d-1), make(d-1))
    end
end

check(t::Empty) = 0
check(t::Node) = 1 + check(t.left) + check(t.right)

function loop_depths(d, min_depth, max_depth)
    for i = 0:div(max_depth - d, 2)
        niter = 1 << (max_depth - d + min_depth)
        c = 0
        for j = 1:niter
            c += check(make(d))
        end
        @printf("%i\t trees of depth %i\t check: %i\n", niter, d, c)
        d += 2
    end
end

function perf_binary_trees(N::Int=10)
    min_depth = 4
    max_depth = N
    stretch_depth = max_depth + 1

    # create and check stretch tree
    let c = check(make(stretch_depth))
        @printf("stretch tree of depth %i\t check: %i\n", stretch_depth, c)
    end

    long_lived_tree = make(max_depth)

    loop_depths(min_depth, min_depth, max_depth)
    @printf("long lived tree of depth %i\t check: %i\n", max_depth, check(long_lived_tree))

end

n = parse(Int,ARGS[1])
perf_binary_trees(n)
