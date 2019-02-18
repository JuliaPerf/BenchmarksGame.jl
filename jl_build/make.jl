using PackageCompiler
using Libdl

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
if Sys.iswindows()
    using WinRPM
    push!(cc_flags, "-I" * joinpath(WinRPM.installdir, "usr", "$(Sys.ARCH)-w64-mingw32", "sys-root", "mingw", "include"))
end

# Concat all cmains into one shared image (speeds up compilation a lot)!
open(joinpath(@__DIR__, "image.jl"), "w") do io
    for bench in benchmarks
        input = joinpath(@__DIR__, "..", bench, string(bench, "-input.txt"))
        isfile(input) && cp(input, joinpath(@__DIR__, string(bench, "-input.txt")))
        jlfile = joinpath(@__DIR__, "..", bench, "cmain.jl")
        println(io, "module ", titlecase(bench))
        print(io, replace(read(jlfile, String), "julia_main" => string(bench, "_main")))
        println(io, "export ", string(bench, "_main"))
        println(io, "end\nusing .", titlecase(bench))
        println(io)
    end
end
# build the image/shared library
build_shared_lib(
    joinpath(@__DIR__, "image.jl"), "bench_image", # Julia script containing a `julia_main` function, e.g. like `examples/hello.jl`
    builddir = joinpath(@__DIR__, "image"), # that's where the compiled artifacts will end up [optional]
)

# Create an executable for each benchmark, linking into the image

mkpath(joinpath(@__DIR__, "cdriver"))
for bench in benchmarks
    cprog = joinpath(@__DIR__, "cdriver", "program.c")
    cfile = joinpath(@__DIR__, "cdriver", string(bench, ".c"))
    open(cfile, "w") do io
        print(io, replace(read(cprog, String), "julia_main" => string(bench, "_main")))
    end
    PackageCompiler.build_exec(
        bench, cfile,
        escape_string(joinpath(@__DIR__, "image", "bench_image.$(Libdl.dlext)")),
        joinpath(@__DIR__, "image"),
        true, "3", false, PackageCompiler.system_compiler, cc_flags
    )
end
