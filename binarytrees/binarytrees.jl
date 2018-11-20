# The Computer Language Benchmarks Game
# https://salsa.debian.org/benchmarksgame-team/benchmarksgame/

# contributed by Jarret Revels and Alex Arslan
# based on an OCaml program
# *reset* 

using Distributed
using Printf

@everywhere abstract type BTree end

@everywhere struct Empty <: BTree
end

@everywhere struct Node <: BTree
    left::BTree
    right::BTree
end

@everywhere function make(d)
    if d == 0
        Node(Empty(), Empty())
    else
        Node(make(d-1), make(d-1))
    end
end

@everywhere check(t::Empty) = 0
@everywhere check(t::Node) = 1 + check(t.left) + check(t.right)

function loop_depths(min_depth, max_depth)
    out = @distributed vcat for d in min_depth:2:max_depth
        niter = 1 << (max_depth - d + min_depth)
        c = 0
        for j = 1:niter
            c += check(make(d)) 
        end
        @sprintf("%i\t trees of depth %i\t check: %i\n", niter, d, c)
    end
    for s in out
      print(s)
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

    loop_depths(min_depth, max_depth)
    @printf("long lived tree of depth %i\t check: %i\n", max_depth, check(long_lived_tree))

end

n = parse(Int,ARGS[1])
perf_binary_trees(n)

