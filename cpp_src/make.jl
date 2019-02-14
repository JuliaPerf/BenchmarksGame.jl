cd(@__DIR__)
include("make_flags.jl")
for cmd in make_cmds
  try
    run(`g++ $cmd`)
    @info "success"
  catch e
    @warn "failed command" exception = e
  end
end


benchmarks = [
    ("binarytrees", 21),
    ("fannkuchredux", 12),
    ("fasta", 25000000),
    ("knucleotide", "knucleotide-input.txt"),
    ("mandelbrot", 16000),
    ("nbody", 50000000),
    ("pidigits", 10000),
    ("regexredux", "regexredux-input.txt"),
    ("revcomp", "revcomp-input.txt"),
    ("spectralnorm", 5500),
]

dir = joinpath(@__DIR__, "..")

map(benchmarks) do (bench, arg)
  cmd = if arg == -1
  	`./$bench`
  else
    `./$bench $arg`
  end
  @elapsed read(cmd, String)
end

map(benchmarks) do (bench, arg)
  println(bench)
  root = joinpath(dir, bench)
  jl = joinpath(root, string(bench, "-fast.jl"))
  if !isfile(jl)
    jl = replace(jl, "-fast" => "")
  end
  @assert isfile(jl)
  args = [:stdout => "result.bin"]
  argcmd = ``
  cmd = if arg isa String
    push!(args, :stdin => joinpath(dir, bench, arg))
  else
    argcmd = `$arg`
  end
  jltime = withenv("JULIA_NUM_THREADS" => 16) do
     @elapsed run(pipeline(`julia -O3 $jl $argcmd`; args...))
  end
  ctime = @elapsed run(pipeline(`./$bench $argcmd`; args...))
  (jltime, ctime)
end

function create_cmain(dir, bench, arg)
  root = joinpath(dir, bench)
  jl = joinpath(root, string(bench, "-fast.jl"))
  if !isfile(jl)
    jl = replace(jl, "-fast" => "")
  end
  src = read(jl, String)
  str = split(read(jl, String), "\n", keepempty = false)
  lastend = str[findlast(x-> occursin(x, "end"), str)]
  start = lastend.offset + lastend.ncodeunits
  main = src[(start + 1):end]
  rest = src[1:start]
  open(joinpath(root, "cmain.jl"), "w") do io
    println(io, rest)
    println(io, """
    Base.@ccallable function julia_main(ARGS::Vector{String})::Cint
    """)
    for line in split(main, "\n", keepempty = false)
      println(io, "    ", line)
    end
    println(io, """
        return 0
    end
    """)
    if arg isa Integer
      println(io, "julia_main([\"$arg\"])")
    end
  end
end
for (bench, arg) in benchmarks
  create_cmain(dir, bench, arg)
end
