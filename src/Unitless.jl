"""

Module `Unitless` is to facilitate coding with numbers whether they have units
or not.

"""
module Unitless

export
    bare_type,
    convert_bare_type,
    unitless

using Requires

"""
    Unitless.BareNumber

is the union of bare numeric types, that is `Real` or `Complex`.

"""
const BareNumber = Union{Real,Complex}

"""
    bare_type() -> Unitless.BareNumber

yields the union of bare numeric types in the `Unitless` package.

"""
bare_type() = BareNumber

"""
    bare_type(x) -> T <: Union{Real,Complex}

yields the bare numeric type backing the storage of `x`. `x` may be a type, a
value, or an object. If `x` has units, they are discarded; hence `T` is always
a unitless real or complex type.

Examples:

```jldoctest
julia> using Unitless

julia> bare_type(1)
Int64

julia> bare_type(-3.14f0)
Float32

julia> bare_type(π)
Irrational{:π}

julia> bare_type(sqrt(π))
Float64

julia> bare_type(1 + 0im)
Complex{Int64}

julia> using Unitful

julia> bare_type(u"3km/s")
Int64

julia> bare_type(u"3.2km/s")
Float64

julia> bare_type(typeof(u"2.1GHz"))
Float64
```

"""
bare_type(x::T) where {T} = bare_type(T)
bare_type(::Type{T}) where {T<:BareNumber} = T
bare_type(::Type{T}) where {T<:Number} = typeof(one(T))

# Catch errors.
@noinline bare_type(T::Type) = error("unknown bare numeric type for `$T`")

"""
    bare_type(args...)

yields the promoted bare numeric type of `args...`.

"""
bare_type(a, b) = promote_type(bare_type(a), bare_type(b))
bare_type(a, b, c) = promote_type(bare_type(a), bare_type(b), bare_type(c))
@inline bare_type(a, b, c...) =
    promote_type(bare_type(a), bare_type(b), map(bare_type, c)...)

"""
    convert_bare_type(T, x)

converts `x` so that its bare numeric type is the same as that of type `T`.

This method may be extended with `T<:Unitless.BareNumber` and for `x` being of
non-standard numeric type.

"""
convert_bare_type(::Type{T}, x::T) where {T<:BareNumber} = x
convert_bare_type(::Type{T}, x) where {T<:BareNumber} = convert(T, x)
convert_bare_type(::Type{T}, x) where {T} = convert_bare_type(bare_type(T), x)

"""
    unitless(x)

yields `x` without its units if any. `x` may be a number or a numeric type. In
the latter case, `unitless` behaves like `bare_type`.

Compared to `ustrip` from the `Unitful` package, argument can be a numeric type
and, of course, `unitless` only requires the lightweight `Unitless` package to
be loaded.

"""
unitless(T::Type) = bare_type(T)
unitless(x::BareNumber) = x

function __init__()
    # Extend methods to `Unitful` quantities when this package is loaded.
    @require Unitful="1986cc42-f94f-5a68-af5c-568840ba703d" begin
        # Extend bare_type.
        bare_type(::Type{<:Unitful.AbstractQuantity{T}}) where {T} = bare_type(T)

        # Extend convert_bare_type.
        convert_bare_type(::Type{T}, x::Unitful.AbstractQuantity{T}) where {T<:BareNumber} = x
        @inline convert_bare_type(::Type{T}, x::Unitful.AbstractQuantity) where {T<:BareNumber} =
            convert(T, Unitful.ustrip(x))*Unitful.unit(x)

        # Extend unitless (only needed for values).
        unitless(x::Unitful.AbstractQuantity) = Unitful.ustrip(x)
    end
end

end # module Unitless
