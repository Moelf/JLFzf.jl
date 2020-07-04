# Fzf

# Example
```julia
julia> using Fzf
julia> a = Fzf.inter_fzf(["a", "b", "c"])
"b"


# interactive session here

julia> @show a
a = "b"
"b"
```

also try `Fzf.inter_fzf(Fzf.read_repl_hist())`
