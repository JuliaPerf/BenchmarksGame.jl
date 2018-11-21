using DeepDiffs
using TimerOutputs

verify = "verify" in ARGS
num_threads = 8

struct Benchmark
    name::String
    benchmark::Union{Number, String}
    verify::Union{Number, String}
end

const BENCHMARKS = [
    Benchmark("binarytrees", 21, 10),
    Benchmark("fannkuchredux", 12, 7),
    Benchmark("fasta", 25000000, 1000),
    Benchmark("knucleotide", 25000000, "knucleotide-input.txt"),
    Benchmark("mandelbrot", 16000, 200),
    Benchmark("nbody", 50000000, 1000),
    Benchmark("pidigits", 10000, 27),
    Benchmark("regexredux", 5000000, "regexredux-input.txt"),
    # Benchmark("revcomp", 25000000, "revcomp-input.txt"),
    Benchmark("spectralnorm", 5500, 100),
]

verify && println("VERIFYING!")
error = false
result_file = "result.bin"
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
            withenv("JULIA_NUM_THREADS" => num_threads) do
                if !isempty(input)
                    cmd = pipeline(`$(Base.julia_cmd()) $(joinpath(bdir, file)) `; stdin=input, stdout = result_file)
                else
                    cmd = pipeline(`$(Base.julia_cmd()) $(joinpath(bdir, file)) $(arg)`; stdout = result_file)
                end
                @timeit file run(cmd)
            end
            if verify
                bench_output = read(result_file, String)
                correct_output = read(joinpath(bdir, string(dir, "-output.txt")), String)
                if bench_output != correct_output
                    println(deepdiff(correct_output, bench_output))
                    error = true
                end
            end
        end
    end
end
TimerOutputs.print_timer(; compact=true, allocations=false)

if error
    error("Some verification failed")
end
