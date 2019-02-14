using PackageCompiler

benchmarks = [
    ("binarytrees"),
    ("fannkuchredux"),
    ("fasta"),
    ("knucleotide"),
    ("mandelbrot"),
    ("nbody"),
    ("pidigits"),
    ("regexredux"),
    ("revcomp"),
    ("spectralnorm"),
]

i = raw"C:\Users\sdani\.julia\dev\WinRPM\deps\usr\x86_64-w64-mingw32\sys-root\mingw\include"

for bench in benchmarks
  build_executable(
      joinpath(@__DIR__, "..", bench, "cmain.jl"), # Julia script containing a `julia_main` function, e.g. like `examples/hello.jl`
      builddir = joinpath(@__DIR__, bench), # that's where the compiled artifacts will end up [optional]
      cc_flags = ["-I$i"],
  )
end
