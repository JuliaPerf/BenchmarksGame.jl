"""
Usage: build_julia relative/path/to/file.jl
Result: compiles an executable under the name build/file
"""

using Libdl
global gcc = "gcc"
gccworks = try
    success(`$gcc -v`)
catch
    error("GCC wasn't found. Please make sure that gcc is on the path and run again")
end
using Libdl
threadingOn() = ccall(:jl_threading_enabled, Cint, ()) != 0

shell_escape(str) = "'$(replace(str, "'" => "'\''"))'"
libDir() = dirname(abspath(Libdl.dlpath("libjulia")))
private_libDir() = abspath(Sys.BINDIR, Base.PRIVATE_LIBDIR)

includeDir() = abspath(Sys.BINDIR, Base.INCLUDEDIR, "julia")

function ldflags()
    fl = "-L$(shell_escape(libDir()))"
    if Sys.iswindows()
        fl = fl * " -Wl,--stack,8388608"
    elseif Sys.islinux()
        fl = fl * " -Wl,--export-dynamic"
    end
    return fl
end

function ldlibs()
    libname = "julia"
    if Sys.isunix()
        return "-Wl,-rpath,$(shell_escape(libDir())) -Wl,-rpath,$(shell_escape(private_libDir())) -l$libname"
    else
        return "-l$libname -lopenlibm"
    end
end

function cflags()
    return sprint() do io
        print(io, "-std=gnu99")
        include = shell_escape(includeDir())
        print(io, " -I", include)
        print(io, " -DJULIA_ENABLE_THREADING=1")
        if Sys.isunix()
            print(io, " -fPIC")
        end
    end
end

function allflags()
    return "$(cflags()) $(ldflags()) $(ldlibs())"
end

function julia_flags(optimize, debug, cc_flags)
    flags = Base.shell_split(allflags())
    bitness_flag = Sys.ARCH == :aarch64 ? `` : Int == Int32 ? "-m32" : "-m64"
    flags = `$flags $bitness_flag`
    optimize == nothing || (flags = `$flags -O$optimize`)
    debug == 2 && (flags = `$flags -g`)
    cc_flags == nothing || isempty(cc_flags) || (flags = `$flags $cc_flags`)
    flags
end
path = ARGS[1]

command = """
Base.reinit_stdio()
_bindir = ccall(:jl_get_julia_bindir, Any, ())::String
@eval(Sys, BINDIR = \$(_bindir))
@eval(Sys, STDLIB = joinpath(\$_bindir, "..", "share", "julia", "stdlib", string('v', (VERSION.major), '.', VERSION.minor)))
Base.init_load_path()
Base.init_depot_path()
using REPL
Base.REPL_MODULE_REF[] = REPL
include("$path")
"""
function default_sysimg_path(debug = false)
    ext = "sys"
    if Sys.isunix()
        dirname(Libdl.dlpath(ext))
    else
        normpath(Sys.BINDIR, "..", "lib", "julia")
    end
end
function build_shared(s_file, o_file)
    # Prevent compiler from stripping all symbols from the shared lib.
    if Sys.isapple()
        o_file = `-Wl,-all_load $o_file`
    else
        o_file = `-Wl,--whole-archive $o_file -Wl,--no-whole-archive`
    end
    command = `gcc -shared -DJULIAC_PROGRAM_LIBNAME=\"$s_file\" -o $s_file $o_file $(julia_flags("3", false, ""))`
    if Sys.isapple()
        command = `$command -Wl,-install_name,@rpath/$s_file`
    elseif Sys.iswindows()
        command = `$command -Wl,--export-all-symbols`
    end
    run(command)
end
function build_exec(e_file, cprog, s_file)
    command = `gcc -DJULIAC_PROGRAM_LIBNAME=\"$s_file\" -o $e_file $cprog $s_file $(julia_flags("3", false, ""))`
    if Sys.isapple()
        command = `$command -Wl,-rpath,@executable_path`
    else
        command = `$command -Wl,-rpath,\$ORIGIN`
    end
    run(command)
end
sys_so = joinpath(default_sysimg_path(false), "sys.so")
isdir("build") || mkdir("build")
syso = abspath(joinpath("build", "sys.so"))
sysa = abspath(joinpath("build", "sys.a"))
run(`julia -C native --output-o $sysa -J $sys_so -O3 -e "$command"`)
build_shared(syso, sysa)
exe_name = splitext(basename(path))[1]
build_exec(joinpath("build", exe_name), "program.c", syso)
