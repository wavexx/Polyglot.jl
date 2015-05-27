module Bond
export make_bond, beval, bcall, bref, importfn, exportfn, proxyfn
export BondException, BondTerminatedException, BondRemoteException, BondSerializationException

## Imports
using Base
import Base: close

using Expect
using JSON
using Compat


## Exceptions
type BondException <: Exception
    msg::ASCIIString
end

type BondTerminatedException <: Exception end

type BondRemoteException <: Exception
    msg::ASCIIString
    data
end

type BondSerializationException <: Exception
    msg::ASCIIString
    remote::Bool
end


## Bond
type BondProc
    proc::ExpectProc
    lang::String
    trans_except::Bool
    proto::Type
    bindings::Dict{String, Any}
    channels::Dict{String, Any}

    function BondProc(proc, lang, trans_except, proto)
        bindings = Dict()
        channels = @compat Dict("STDOUT"=>STDOUT, "STDERR"=>STDERR)
        new(proc, lang, trans_except, proto, bindings, channels)
    end
end


function _repl(bond::BondProc)
    while true
        expect!(bond.proc, "\n")
        ret = @compat split(bond.proc.before, " ", limit=2)
        cmd = ret[1]
        args = length(ret) > 1? _loads(bond.proto, ret[2]): []

        if cmd == "RETURN"
            return args
        elseif cmd == "OUTPUT"
            write(bond.channels[args[1]], args[2])
            continue
        elseif cmd == "EXCEPT"
            throw(BondRemoteException(string(args), args))
        elseif cmd == "ERROR"
            throw(BondSerializationException(string(args), true))
        elseif cmd == "BYE"
            throw(BondTerminatedException())
        elseif cmd == "CALL"
            ret = nothing
            code = nothing
            state = "RETURN"
            try
                ret = bond.bindings[args[1]](args[2]...)
            catch e
                state = "EXCEPT"
                ret = bond.trans_except? e: string(e)
            end
            try
                code = _dumps(bond.proto, ret)
            catch e
                state = "ERROR"
                code = _dumps(bond.proto, string(e))
            end
            _sendstate(bond, state, code)
            continue
        end

        break
    end

    throw(BondException("unknown interpreter state"))
end

close(bond::BondProc) = close(bond.proc)

function _sendstate(bond::BondProc, cmd::ASCIIString, code::String)
    sendline(bond.proc, string(cmd, " ", code))
end


## Refs
type BondRef
    bond::BondProc
    code::String
end

function bref(bond::BondProc, code::String)
    BondRef(bond, code)
end

_code(bond::BondProc, any) = any

function _code(bond::BondProc, ref::BondRef)
    if bond === ref.bond
        return ref.code
    else
        throw(BondException("cannot use a reference coming from a different bond"))
    end
end


## Serialization
function _dumps(proto, data)
    # TODO
    try
        JSON.json(data)
    catch e
        throw(BondSerializationException(string(e), false))
    end
end

function _loads(proto, data)
    # TODO
    JSON.parse(data)
end


## Main functions
function beval(bond::BondProc, code::String; block=false)
    _sendstate(bond, block? "EVAL_BLOCK": "EVAL", _dumps(bond.proto, code))
    _repl(bond)
end

function beval(bond::BondProc, code::BondRef; block=false)
    beval(bond, _code(bond, code); block=block)
end

function bcall(bond::BondProc, name::String, args...)
    if !any(x->isa(x, BondRef), args)
        _sendstate(bond, "CALL", _dumps(bond.proto, (name, args)))
    else
        args = [(@compat Int(isa(data, BondRef)), _code(bond, data)) for data in args]
        _sendstate(bond, "XCALL", _dumps(bond.proto, (name, args)))
    end
    _repl(bond)
end

function importfn(bond::BondProc, name::String)
    (args...)->bcall(bond, name, args...)
end

function exportfn(bond::BondProc, func::Function, name::String=string(func))
    _sendstate(bond, "EXPORT", _dumps(bond.proto, name))
    bond.bindings[name] = func
    _repl(bond)
end

function proxyfn(bond::BondProc, name::String, other_bond::BondProc, other_name::String=name)
    exportfn(other_bond, importfn(bond, name), other_name)
end

function interact(bond::BondProc)
    # TODO
    error("Unimplemented")
end


## Support functions
function _driver_path(path::String)
    root = dirname(@__FILE__())
    return joinpath(root, "drivers", path)
end

function query_driver(lang::String)
    JSON.parse(readall(_driver_path(joinpath(lang, "bond.json"))))
end

function list_drivers()
    drivers = String[]
    root = joinpath(dirname(@__FILE__()), "drivers")
    for file in readdir(root)
        data_path = joinpath(root, file, "bond.json")
        if isfile(data_path)
            push!(drivers, file)
        end
    end
    return drivers
end

function _load_stage(lang::String, data::Dict)
    path = data["file"]
    code = readall(_driver_path(joinpath(lang, path)))
    if haskey(data, "sub")
        code = replace(code, Regex(data["sub"][1]), unescape_string(data["sub"][2]))
    end
    return strip(code)
end


function make_bond(lang::String, cmd::Union(Cmd,Nothing)=nothing, args::Vector{String}=String[];
                   cwd::String=pwd(), env::Base.EnvHash=ENV, def_args=true,
                   trans_except::Union(Bool,Nothing)=nothing, timeout::Real=60, protocol::String="")
    protocol = "JSON" # TODO
    trans_except = false # TODO
    data = query_driver(lang)

    # find a suitable command
    proc = nothing
    if cmd !== nothing
        xargs = def_args? data["command"][1][2:end]: []
        cmd = `$(cmd.exec) $(xargs) $(args)`
        try
            proc = ExpectProc(cmd, timeout; env=env)
        catch e
            isa(e, Base.UVError) || rethrow(e)
            throw(BondException(string("cannot execute: ", Base.shell_escape(cmd))))
        end
    else
        for cmd_block in data["command"]
            xargs = def_args? cmd_block[2:end]: []
            cmd = `$(cmd_block[1]) $(xargs) $(args)`
            try
                proc = ExpectProc(cmd, timeout; env=env)
                break
            catch e
                isa(e, Base.UVError) || rethrow(e)
            end
        end
        if proc === nothing
            throw(BondException("no suitable interpreter found"))
        end
    end

    try
        # wait for a prompt if needed
        if haskey(data["init"], "wait")
            expect!(proc, Regex(data["init"]["wait"]))
        end

        # probe the interpreter
        sendline(proc, data["init"]["probe"])
        if expect!(proc, ["STAGE1\n", "STAGE1\r\n"]) == 2
            Expect.raw!(proc, true)
        end
    catch e
        throw(BondException(string("cannot get an interactive prompt using: ",
                                   Base.shell_escape(cmd))))
    end

    # inject base loader
    try
        stage1 = _load_stage(lang, data["init"]["stage1"])
        sendline(proc, stage1)
        if expect!(proc, ["STAGE2\n", "STAGE2\r\n"]) == 2
            throw(BondException("cannot switch terminal to raw mode"))
        end
    catch e
        throw(BondException(string("cannot initialize stage1: ", bond.proc.before)))
    end

    # load the second stage
    try
        stage2 = _load_stage(lang, data["init"]["stage2"])
        stage2 = @compat Dict("code"=>stage2, "start"=>[protocol, trans_except])
        sendline(proc, JSON.json(stage2))
        expect!(proc, ["READY\n"])
    catch e
        throw(BondException(string("cannot initialize stage2: ", bond.proc.before)))
    end

    proto = None # TODO
    return BondProc(proc, lang, trans_except, proto)
end

end
