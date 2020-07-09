# JLFzf

# Example
```julia
julia> using JLFzf
julia> a = JLFzf.inter_fzf(["a", "b", "c"])
# interactive session happens here
"b"


julia> @show a
a = "b"
"b"
```

also try `JLFzf.inter_fzf(Fzf.read_repl_hist())`
