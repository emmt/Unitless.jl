"""

Module `Unitless` is to strip units from quantities.

"""
module Unitless

export
    baretype,
    convert_baretype

using Requires

"""
    baretype(x)

yields the bare numeric type of `x` which can be a numeric value or type (that
is an instance or a sub-type of `Number`). This method is useful to strip units
from quantities.

Examples:

```jldoctest
julia> using Unitless

julia> baretype(1)
Int64

julia> baretype(-3.14f0)
Float32

julia> baretype(π)
Irrational{:π}

julia> baretype(sqrt(π))
Float64

julia> baretype(1 + 0im)
Complex{Int64}

julia> using Unitful

julia> baretype(u"3km/s")
Int64

julia> baretype(u"3.2km/s")
Float64

julia> baretype(typeof(u"2.1GHz"))
Float64
```

"""
baretype(x::T) where {T} = baretype(T)
baretype(::Type{T}) where {T<:Real} = T
baretype(::Type{T}) where {T<:Complex} = T
baretype(::Type{T}) where {T<:Number} = typeof(one(T))

# Catch errors.
@noinline baretype(T::Type) = error("unknown bare numeric type for `$T`")

"""
    baretype(args...)

yields the promoted bare numeric type of `args...`.

"""
baretype(a, b) = promote_type(baretype(a), baretype(b))
baretype(a, b, c) = promote_type(baretype(a), baretype(b), baretype(c))
@inline baretype(a, b, c...) =
    promote_type(baretype(a), baretype(b), map(baretype, c)...)

@deprecate promote_baretype(args...) baretype(args...)

"""
    convert_baretype(T, x)

converts `x` so that its bare numeric type is the same as that of type `T`.

"""
convert_baretype(::Type{T}, x) where {T} = _convert_baretype(baretype(T), x)

# Private method `_convert_baretype` is called by `convert_baretype` with a
# first argument that is guaranteed to be a bare numeric type.
_convert_baretype(::Type{T}, x::T) where {T} = x
_convert_baretype(::Type{T}, x) where {T} = convert(T, x)

function __init__()
    @require Unitful="1986cc42-f94f-5a68-af5c-568840ba703d" include("with_unitful.jl")
end

end # module Unitless
