# JLFzf

To use Fzf if REPL, you don't have to use this pacakge if you're already a user of [OhMyREPL.jl](https://github.com/KristofferC/OhMyREPL.jl). Keep reading if you want to use Fzf for your own package or don't want to use `OhMyREPL` but still want Fzf search.

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

## Sample `startup.jl`
```
import REPL
import REPL.LineEdit
import JLFzf
const mykeys = Dict{Any,Any}(
    # primary history search: most recent first
    "^R" => function (mistate, o, c)
        line = JLFzf.inter_fzf(JLFzf.read_repl_hist(), 
        "--read0", 
        "--tiebreak=index",
        "--height=80%");
        JLFzf.insert_history_to_repl(mistate, line)
    end,
)
function customize_keys(repl)
    repl.interface = REPL.setup_interface(repl; extra_repl_keymap = mykeys)
end
atreplinit(customize_keys)
```

when in REPL, press `Ctril-R` to start a search, `mode` will be automatically switched upon
selecting search results (`Pkg>`, `Help>` etc.).
