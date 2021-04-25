using DataStructures
using Base.Meta

import Base.ImmutableDict

# @auto_hash_equals struct EClass
#     id::Int64
# end

struct ENode{T}
    head::Any
    args::Vector{Int64}
    metadata::Any
    hash::Ref{UInt} # hash cache
    ENode{T}(h, a, m) where {T} = new{T}(h, a, m, Ref{UInt}(0))
end

function ENode(e, c_ids::AbstractVector{Int64})
    # @assert length(getargs(e)) == length(c_ids)
    # static_args = MVector{length(c_ids), Int64}(c_ids...)
    m = getmetadata(e)
    ENode{typeof(e)}(gethead(e), c_ids, m)
end

ENode(e) = ENode(e, Int64[])

ENode(a::ENode) =
    error("constructor of ENode called on enode. This should never happen")



function Base.:(==)(a::ENode, b::ENode)
    # isequal(a.metadata, b.metadata) && 
    isequal(a.args, b.args) && 
    isequal(a.head, b.head)
end

# This optimization comes from SymbolicUtils
# The hash of an enode is cached to avoid recomputing it.
# Shaves off a lot of time in accessing dictionaries with ENodes as keys.
function Base.hash(t::ENode{T}, salt::UInt) where {T}
    !iszero(salt) && return hash(hash(t, zero(UInt)), salt)
    h = t.hash[]
    !iszero(h) && return h
    h′ = hash(t.args,  hash(t.metadata, hash(t.head, hash(T, salt))))
    t.hash[] = h′
    return h′
end

TermInterface.arity(n::ENode) = length(n.args)
TermInterface.getmetadata(n::ENode) = n.metadata
# TermInterface.metadatatype(n::ENode{T,M}) where {T,M} = M

termtype(x::ENode{T}) where T = T

function Base.show(io::IO, x::ENode)
    print(io, "(", x.head)
    n = arity(x)
    if n == 0
        print(io, ")")
        return
    else
        print(io, " ")
    end
    for i ∈ 1:n
        if i < n
            print(io, x.args[i], " ")
        else
            print(io, x.args[i], ")")
        end
    end
end
