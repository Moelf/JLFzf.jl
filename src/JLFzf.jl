module JLFzf

import fzf_jll
using Pipe
import REPL

export inter_fzf, read_repl_hist

"""
    read_repl_hist()

Find corresponding history file, read it, split by history records
and return resulted `Vector{String}` in reverse order.
"""
function read_repl_hist()
    rx = r"(^|\n)# time:[^\n]*\n# mode:[^\n]*\n"m
    @pipe open(REPL.find_hist_file()) |>
    read |> String |>
    replace(_, r"\n$" => "") |>           # remove last new line
    replace(_, r"^\t"m => "") |>          # remove leading tabs
    split(_, rx, keepempty = false) |>    # split by history records
    reverse |> unique                     # keep unique entries
end

"""
    inter_fzf(in_str::String, args...)

Run interactive fzf and return selected result, by default `in_str` should use `\n`s as the delimiter,
return selected string.
Additional arguments `args` for `fzf` are allowed.
"""
function inter_fzf(in_str::String, args...)
    fzf_jll.fzf() do exe
        if length(args) == 0
            return read(pipeline(Cmd(`$exe`, ignorestatus = true), stdin = IOBuffer(in_str)), String) |> chomp
        else
            return read(pipeline(Cmd(`$exe $(args)`, ignorestatus = true), stdin = IOBuffer(in_str)), String) |> chomp
        end
    end
end

"""
    inter_fzf(ary::AbstractArray, args...)

Run interactive fzf with an array of inputs, return selected string.
Additional arguments `args` for `fzf` are allowed.
"""
function inter_fzf(ary::AbstractArray, args...)
    inter_fzf(join(ary, '\0'), args...)
end

end
