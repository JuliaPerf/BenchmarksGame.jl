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
