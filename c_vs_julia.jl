cd(@__DIR__)
fasta_input = "fasta.txt"
fasta_gen = joinpath("fasta", "fasta.jl")
run(pipeline(`$(Base.julia_cmd()) $fasta_gen 25000000` ;stdout = fasta_input))

benchmarks = [
    ("binarytrees", 21),
    ("fannkuchredux", 12),
    ("fasta", 25000000),
    ("knucleotide", fasta_input),
    ("mandelbrot", 16000),
    ("nbody", 50000000),
    ("pidigits", 10000),
    ("regexredux", fasta_input),
    ("revcomp", fasta_input),
    ("spectralnorm", 5500),
]

timings = map(benchmarks) do (bench, arg)
  println(bench)
  isfile("result.bin") && rm("result.bin")
  args = [:stdout => "result.bin"]
  argcmd = ``
  cmd = if arg isa String
    @assert isfile(arg)
    push!(args, :stdin => arg)
  else
    argcmd = `$arg`
  end
  jltime = withenv("JULIA_NUM_THREADS" => 16) do
    exe = joinpath("jl_build", bench, "cmain")
     @elapsed run(pipeline(`$() $argcmd`; args...))
  end
  ctime = @elapsed run(pipeline(`./$bench $argcmd`; args...))
  (jltime, ctime)
end


run(pipeline(`./revcomp $argcmd`, stdin = fasta_gen))
