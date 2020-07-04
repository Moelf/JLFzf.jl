# Fzf

# Example
```julia
julia> using Fzf
julia> a = Fzf.inter_fzf(["a", "b", "c"])
# interactive session happens here
"b"


julia> @show a
a = "b"
"b"
```

also try `Fzf.inter_fzf(Fzf.read_repl_hist())`
