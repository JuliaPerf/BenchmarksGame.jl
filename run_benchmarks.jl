using DeepDiffs
using TimerOutputs

verify = "verify" in ARGS

struct Benchmark
    name::String
    benchmark::Union{Number, String}
    verify::Union{Number, String}
end

const BENCHMARKS = [
    Benchmark("binarytrees", 21, 10),
    Benchmark("fannkuchredux", 12, 7),
    Benchmark("fasta", 25000000, 1000),
    #Benchmark("knucleotide", 25000000, "knucleotide-input.txt"),
    Benchmark("mandelbrot", 16000, 200),
    Benchmark("nbody", 50000000, 1000),
    Benchmark("pidigits", 10000, 27),
    Benchmark("regexredux", 5000000, "regexredux-input.txt"),
#    Benchmark("revcomp", 25000000, "revcomp-input.txt"),
    Benchmark("spectralnorm", 5500, 100),
]

verify && println("VERIFYING!")
error = false
TimerOutputs.reset_timer!()
for benchmark in BENCHMARKS
    dir = benchmark.name
    _arg = verify ? benchmark.verify : benchmark.benchmark
    println("Running $dir")
    bdir = joinpath(@__DIR__, dir)
    arg, input = _arg isa String ? ("", "$(joinpath(bdir, _arg))") : (string(_arg), "")
    @timeit dir begin
        for file in readdir(bdir)
            endswith(file, ".jl") || continue
            println("    $file:")
            if !isempty(input)
                cmd = pipeline(`$(Base.julia_cmd()) $(joinpath(bdir, file)) `; stdin=input)
            else
                cmd = `$(Base.julia_cmd()) $(joinpath(bdir, file)) $(arg)`
            end
            if verify
                bench_output = read(cmd, String)
                correct_output = read(joinpath(bdir, string(dir, "-output.txt")), String)
                if bench_output != correct_output
                    println(deepdiff(bench_output, correct_output))
                    error = true
                end
            else
                @timeit file run(cmd)
            end
        end
    end
end
TimerOutputs.print_timer(; compact=true, allocations=false)

if error
    error("Some verification failed")
end