module JLFzf

import fzf_jll
using Pipe

export inter_fzf

function read_repl_hist()
    @pipe open("~/.julia/logs/repl_history.jl" |> expanduser) |> read |> String |> 
    replace(_, "\t" => "") |> #remove tabs
    split(_, "\n") |> #split by new lines
    filter(x->!occursin("#", x), _) |> #remove comments lines end
    unique |> reverse # keep unique entries
end

"""
inter_fzf(in_str::String)
run interactive fzf and return selected result, `in_str` should contain `\n`s,
return selected string
"""
function inter_fzf(in_str::String, args...)
    @show collect(args)
    fzf_jll.fzf() do exe
        if length(args) == 0
            return read(pipeline(`$exe`, stdin = IOBuffer(in_str)), String) |> chomp
        else
            return read(pipeline(`$exe $(join(args, " "))`, stdin = IOBuffer(in_str)), String) |> chomp
        end
    end
end

"""
inter_fzf(ary::AbstractArray)
run interactive fzf with an array of inputs, return selected string
"""
function inter_fzf(ary::AbstractArray, args...)
    inter_fzf(join(ary, "\n"), args...)
end

end
