module JLFzf

import fzf_jll
import REPL
import REPL.LineEdit

export inter_fzf, read_repl_hist, insert_history_to_repl

"""
    read_repl_hist()

Find corresponding history file, read it, split by history records
and return resulted `Vector{String}` in reverse order.
"""
function read_repl_hist()
    rx = r"(^|\n)# time:[^\n]*\n"m
    # markers for history modes, used by `insert_history_to_repl()`
    rxj = r"^# mode: julia\n"m => ""
    rxh = r"^# mode: help\n"m => "?\n"
    rxp = r"^# mode: pkg\n"m => "]\n"
    rxs = r"^# mode: shell\n"m => ";\n"
    str = open(io -> read(io, String), REPL.find_hist_file())
    str = replace(str, r"\n$" => "")  # remove last new line
    str = replace(str, r"^\t"m => "")  # remove leading tabs
    str = replace(str, rxj)
    str = replace(str, rxh)
    str = replace(str, rxp)
    str = replace(str, rxs)
    str = split(str, rx, keepempty=false)
    unique(reverse(str))
end

"""
    inter_fzf(in_str::String, args...)

Run interactive fzf and return selected result, by default `in_str` should use `\n`s as the delimiter,
return selected string.
Additional arguments `args` for `fzf` are allowed.
"""
function inter_fzf(in_str::String, args...)
    cmd = length(args) == 0 ? fzf_jll.fzf() : `$(fzf_jll.fzf()) $(args)`
    pipe = pipeline(ignorestatus(cmd), stdin=IOBuffer(in_str))
    readchomp(pipe)
end

"""
    inter_fzf(ary::AbstractArray, args...)

Run interactive fzf with an array of inputs, return selected string.
Additional arguments `args` for `fzf` are allowed.
"""
function inter_fzf(ary::AbstractArray, args...)
    inter_fzf(join(ary, '\n'), args...)
end

function edit_insert_and_state_transition(mistate, line, mode)
    LineEdit.edit_insert(mistate, line)
    iobuffer = LineEdit.buffer(mistate)
    LineEdit.transition(mistate, Base.active_repl.interface.modes[mode]) do
        prompt_state = LineEdit.state(mistate, Base.active_repl.interface.modes[mode])
        prompt_state.input_buffer = copy(iobuffer)
    end
    nothing
end

"""
    insert_history_to_repl(mistate, line)

Paste found by `fzf` history `line` into REPL `mistate`.
"""
function insert_history_to_repl(mistate, line)
    rxh = r"^\?\n"
    rxp = r"^\]\n"
    rxs = r"^;\n"
    LineEdit.edit_clear(mistate)
    if occursin(rxh, line)
        edit_insert_and_state_transition(mistate, replace(line, rxh => ""), 3)
    elseif occursin(rxp, line)
        edit_insert_and_state_transition(mistate, replace(line, rxp => ""), 6)
    elseif occursin(rxs, line)
        edit_insert_and_state_transition(mistate, replace(line, rxs => ""), 2)
    else
        LineEdit.edit_insert(mistate, line)
    end
    LineEdit.refresh_line(mistate)
end

end
