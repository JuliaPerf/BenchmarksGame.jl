# The Computer Language Benchmarks Game
# https://salsa.debian.org/benchmarksgame-team/benchmarksgame/

# based on Mario Pernici Python's program

print_line(ns, i) = println(rpad(string(ns), 10), '\t', ':', i)

function pidigits(N::Int)
    i = k = ns = 0
    k1 = 1
    n,a,d,t,u = map(BigInt,(1,0,1,0,0))

    while true
        k += 1
        t = n << 1
        n *= k
        a += t
        k1 += 2
        a *= k1
        d *= k1

        if a >= n
            t,u = divrem(n*3 +a, d)
            u += n
            if d > u
                if i >= N
                    print_line(ns, i)
                    return ns
                end
                ns = ns*10 + t
                i += 1
                if mod(i,10) == 0
                    print_line(ns, i)
                    ns = 0
                end
                a -= d*t
                a *= 10
                n *= 10

            end
        end
    end
end

n = parse(Int,ARGS[1])
pidigits(n)
