"""

Module `Unitless` is to facilitate coding with numbers whether they have units
or not.

"""
module Unitless

export
    bare_type,
    convert_bare_type,
    convert_real_type,
    floating_point_type,
    real_type,
    unitless

using Requires

"""
    Unitless.BareNumber

is the union of bare numeric types, that is `Real` or `Complex`.

"""
const BareNumber = Union{Real,Complex}

"""
    bare_type(x) -> T <: Union{Real,Complex}

yields the bare numeric type `T` backing the storage of `x` which may be a
number or a numeric type. If `x` has units, they are discarded. Hence `T` is
always a unitless real or complex type.

Examples:

```jldoctest
julia> map(bare_type, (1, 3.14f0, π, 1 + 0im))
(Int64, Float32, Irrational{:π}, Complex{Int64})

julia> using Unitful

julia> map(bare_type, (u"3km/s", u"3.2km/s", typeof(u"2.1GHz")))
(Int64, Float64, Float64)
```

---
    bare_type(args...) -> T <: Union{Real,Complex}

yields the promoted bare numeric type of `args...`.

---
    bare_type() -> Unitless.BareNumber

yields the union of bare numeric types that may be returned by `bare_type` when
called with at least one argument.

"""
bare_type() = BareNumber
bare_type(x::T) where {T} = bare_type(T)
bare_type(::Type{T}) where {T<:BareNumber} = T
bare_type(::Type{T}) where {T<:Number} = typeof(one(T))
bare_type(T::Type) = error(
    # NOTE: split string to avoid inlining
    "unknown bare numeric type for `", T, "`")

"""
    real_type(x) -> T <: Real

yields the bare numeric type `T` backing the storage of `x` which may be a
number of a numeric type. If `x` is complex, `T` is the bare numeric type of
the real and imaginary parts of `x`. If `x` has units, they are discarded.
Hence `T` is always a unitless real type.

Examples:

```jldoctest
julia> using Unitless

julia> map(real_type, (-3.14f0, 1 + 0im, Complex{Int8}))
(Float32, Int64, Int8)

julia> using Unitful

julia> real_type(u"3km/s")
Int64
```

---
    bare_type(args...)

yields the promoted bare real type of `args...`.

---
    real_type() -> Real

yields the supertype of the types that may be returned by `real_type` when
called with at least one argument.

"""
real_type() = Real
real_type(x::T) where {T} = real_type(T)
real_type(::Type{T}) where {T<:Real} = T
real_type(::Type{Complex{T}}) where {T<:Real} = T
real_type(::Type{T}) where {T<:Number} = typeof(one(real(T)))
real_type(T::Type) = error(
    # NOTE: split string to avoid inlining
    "unknown bare real type for `", T, "`")

# Multiple arguments.
for f in (:bare_type, :real_type)
    @eval begin
        $f(a, b) = promote_type($f(a), $f(b))
        $f(a, b, c) = promote_type($f(a), $f(b), $f(c))
        @inline $f(a, b, c...) = promote_type($f(a), $f(b), map($f, c)...)
    end
end

"""
    convert_bare_type(T, x)

converts `x` so that its bare numeric type is the same as that of type `T`.

This method may be extended with `T<:Unitless.BareNumber` and for `x` of
non-standard numeric type.

"""
convert_bare_type(::Type{T}, x::T) where {T<:BareNumber} = x
convert_bare_type(::Type{T}, x::BareNumber) where {T<:BareNumber} = convert(T, x)

convert_bare_type(::Type{T}, x) where {T<:Number} = convert_bare_type(bare_type(T), x)
convert_bare_type(::Type{T}, x) where {T<:BareNumber} = error(
    # NOTE: split string to avoid inlining
    "unsupported conversion of bare numeric type of object of type `",
    typeof(x), "` to `", T, "`")

"""
    convert_real_type(T, x)

converts `x` so that its bare real type is the same as that of type `T`.

This method may be extended with `T<:Real` and for `x` of non-standard numeric
type.

"""
convert_real_type(::Type{T}, x::T) where {T<:Real} = x
convert_real_type(::Type{T}, x::T) where {T<:Complex} = x
convert_real_type(::Type{T}, x::Complex{T}) where {T<:Real} = x

convert_real_type(::Type{T}, x::Real) where {T<:Real} = convert(T, x)
convert_real_type(::Type{T}, x::Complex) where {T<:Real} = convert(Complex{T}, x)

convert_real_type(::Type{T}, x) where {T<:Number} = convert_real_type(real_type(T), x)
convert_real_type(::Type{T}, x) where {T<:Real} = error(
    # NOTE: split string to avoid inlining
    "unsupported conversion of bare real type of object of type `",
    typeof(x), "` to `", T, "`")

"""
    floating_point_type(args...) -> T <: AbstractFloat

yields an appropriate floating-point type to represent the promoted numeric
type used by arguments `args...` for storing their value(s). Any units of the
arguments are ignored and the returned type is always unitless.

For numerical computations, a typical usage is:

    T = floating_point_type(x, y, ...)
    xp = convert_real_type(T, x)
    yp = convert_real_type(T, y)
    ...

to have numbers `x`, `y`, etc. converted to an appropriate common
floating-point type while preserving their units if any.

Also see [`real_type`](@ref) and [`convert_real_type`](@ref).

---
    floating_point_type() -> AbstractFloat

yields the supertype of the types that may be returned by `floating_point_type`
when called with at least one argument.

"""
floating_point_type() = AbstractFloat
@inline floating_point_type(args...) = float(real_type(args...))

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
        # Extend bare_type, real_type, convert_bare_type, and
        # convert_real_type.
        for (f, g, S) in ((:bare_type, :convert_bare_type, :BareNumber),
                          (:real_type, :convert_real_type, :Real))
            @eval begin
                $f(::Type{<:Unitful.AbstractQuantity{T}}) where {T} = $f(T)
                $g(::Type{T}, x::Unitful.AbstractQuantity{T}) where {T<:$S} = x
                @inline $g(::Type{T}, x::Unitful.AbstractQuantity) where {T<:$S} =
                    $g(T, Unitful.ustrip(x))*Unitful.unit(x)
            end
        end

        # Extend unitless (only needed for values).
        unitless(x::Unitful.AbstractQuantity) = Unitful.ustrip(x)
    end
end

end # module Unitless
