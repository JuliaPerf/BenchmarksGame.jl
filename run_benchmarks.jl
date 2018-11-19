verify = "verify" in ARGS

struct Benchmark
    name::String
    benchmark::Union{Number, String}
    verify::Union{Number, String}
end

const BENCHMARKS = [
   #Benchmark("binarytrees", 21, 10),
  #  Benchmark("fannkuchredux", 12, 7),
   # Benchmark("fasta", 25000000, 1000),
   # Benchmark("knucleotide", 25000000, "knucleotide-input.txt"),
  #  Benchmark("mandelbrot", 16000, 200),
   # Benchmark("nbody", 50000000, 1000),
  #  Benchmark("pidigits", 10000, 27),
 #   Benchmark("regexredux", 5000000, "regexredux-input.txt"),
 #   Benchmark("revcomp", "0 < revcomp-input.txt"),
    Benchmark("spectralnorm", 5500, 100),
]

verify && println("VERIFYING!")
for benchmark in BENCHMARKS
    dir = benchmark.name
    _arg = verify ? benchmark.verify : benchmark.benchmark
    arg = _arg isa String ? "0 < $(_arg)" : string(_arg)
    println("Running $dir")
    bdir = joinpath(@__DIR__, dir)
    for file in readdir(bdir)
        endswith(file, ".jl") || continue
        println("    $file:")
        cmd = `$(Base.julia_cmd()) $(joinpath(bdir, file)) $(arg)`
        if verify
            bench_output = read(cmd, String)
            correct_output = read(joinpath(bdir, string(dir, "-output.txt")), String)
            if bench_output != correct_output
                @show bench_output
                @show correct_output
                error()
            end
        else
            time = @elapsed run(cmd)
            println("Time: $time")
        end
    end
end