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

cc_flags = String[]
if iswindows()
    using WinRPM
    WinRPM.installdir
    push!(cc_flags, joinpath(WinRPM.installdir, "usr", "$(Sys.ARCH)-w64-mingw32", "sys-root", "mingw", "include"))
end

for bench in benchmarks
  build_executable(
      joinpath(@__DIR__, "..", bench, "cmain.jl"), # Julia script containing a `julia_main` function, e.g. like `examples/hello.jl`
      builddir = joinpath(@__DIR__, bench), # that's where the compiled artifacts will end up [optional]
      cc_flags = cc_flags,
  )
end
