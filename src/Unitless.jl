"""

Module `Unitless` is to strip units from quantities.

"""
module Unitless

export
    baretype,
    convert_baretype

using Requires

"""
    Unitless.BareType

is the union of bare numeric types, that is `Real` or `Complex`.

"""
const BareType = Union{Real,Complex}

"""
    baretype(x) -> T <: Union{Real,Complex}

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
baretype(::Type{T}) where {T<:BareType} = T
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

This method may be extended with `T<:Unitless.BareType` and for `x` being of
non-standard numeric type.

"""
convert_baretype(::Type{T}, x::T) where {T<:BareType} = x
convert_baretype(::Type{T}, x) where {T<:BareType} = convert(T, x)
convert_baretype(::Type{T}, x) where {T} = convert_baretype(baretype(T), x)

function __init__()
    # Extend methods to `Unitful` quantities when this package is loaded.
    @require Unitful="1986cc42-f94f-5a68-af5c-568840ba703d" begin
        function baretype(::Type{<:Unitful.AbstractQuantity{T}}) where {T}
            return baretype(T)
        end
        function convert_baretype(::Type{T},
                                  x::Unitful.AbstractQuantity{T}) where {T<:BareType}
            return x
        end
        @inline function convert_baretype(::Type{T},
                                          x::Unitful.AbstractQuantity) where {T<:BareType}
            return convert(T, Unitful.ustrip(x))*Unitful.unit(x)
        end
    end
end

end # module Unitless
