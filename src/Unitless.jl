"""

Module `Unitless` is to facilitate coding with numbers whether they have units
or not.

"""
module Unitless

export
    bare_type,
    convert_bare_type,
    convert_floating_point_type,
    convert_real_type,
    floating_point_type,
    real_type,
    unitless

if !isdefined(Base, :get_extension)
    using Requires
end

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
called with no arguments.

"""
bare_type() = BareNumber
bare_type(x::T) where {T} = bare_type(T)
bare_type(::Type{T}) where {T<:BareNumber} = T
bare_type(::Type{T}) where {T<:Number} = typeof(one(T))
@noinline bare_type(::Type{T}) where {T} =
    error("unknown bare numeric type for `", T, "`")

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
called with no arguments.

"""
real_type() = Real
real_type(x::T) where {T} = real_type(T)
real_type(::Type{T}) where {T<:Real} = T
real_type(::Type{Complex{T}}) where {T<:Real} = T
real_type(::Type{T}) where {T<:Number} = typeof(one(real(T)))
@noinline real_type(::Type{T}) where {T} = error("unknown bare real type for `", T, "`")

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

converts `x` so that its bare numeric type is that of `T`. Argument `x` may be
a number or a numeric type, while argument `T` must be a numeric type. If `x`
is one of `missing`, `nothing`, `undef`, or the type of one of these
singletons, `x` is returned.

This method may be extended with `T<:Unitless.BareNumber` and for `x` of
non-standard numeric type.

"""
convert_bare_type(::Type{T}, x) where {T<:Number} = convert_bare_type(bare_type(T), x)

# NOTE: All other specializations of `convert_bare_type(T,x)` are for `T<:BareNumber`.
convert_bare_type(::Type{T}, x::T) where {T<:BareNumber} = x
convert_bare_type(::Type{T}, x::BareNumber) where {T<:BareNumber} = convert(T, x)
@noinline convert_bare_type(::Type{T}, x) where {T<:BareNumber} = error(
   "unsupported conversion of bare numeric type of object of type `",
    typeof(x), "` to `", T, "`")

convert_bare_type(::Type{T}, ::Type{<:BareNumber}) where {T<:BareNumber} = T
@noinline convert_bare_type(::Type{T}, ::Type{S}) where {T<:BareNumber,S} = error(
    "unsupported conversion of bare numeric type of type `", S, "` to `", T, "`")

"""
    convert_real_type(T, x)

converts `x` so that its bare real type is that of `T`. Argument `x` may be a
number or a numeric type, while argument `T` must be a numeric type. If `x` is
one of `missing`, `nothing`, `undef`, or the type of one of these singletons,
`x` is returned.

This method may be extended with `T<:Real` and for `x` of non-standard numeric
type.

"""
convert_real_type(::Type{T}, x) where {T<:Number} = convert_real_type(real_type(T), x)

# NOTE: All other specializations of `convert_real_type(T,x)` are for `T<:Real`.
convert_real_type(::Type{T}, x::T) where {T<:Real} = x
convert_real_type(::Type{T}, x::Complex{T}) where {T<:Real} = x
convert_real_type(::Type{T}, x::Real) where {T<:Real} = convert(T, x)
convert_real_type(::Type{T}, x::Complex) where {T<:Real} = convert(Complex{T}, x)
@noinline convert_real_type(::Type{T}, x) where {T<:Real} = error(
    "unsupported conversion of bare real type of object of type `",
    typeof(x), "` to `", T, "`")

convert_real_type(::Type{T}, ::Type{<:Real}) where {T<:Real} = T
convert_real_type(::Type{T}, ::Type{<:Complex}) where {T<:Real} = Complex{T}
@noinline convert_real_type(::Type{T}, ::Type{S}) where {T<:Real,S} = error(
    "unsupported conversion of bare real type of type `", S, "` to `", T, "`")

# Special values/types.
const Special = Union{Missing,Nothing,typeof(undef)}
for (func, type) in ((:convert_bare_type, :BareNumber),
                     (:convert_real_type, :Real))
    @eval begin
        $func(::Type{<:$type}, x::Special) = x
        $func(::Type{<:$type}, ::Type{T}) where {T<:Special} = T
    end
end

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
when called with no arguments.

"""
floating_point_type() = AbstractFloat
@inline floating_point_type(args...) = float(real_type(args...))

"""
    convert_floating_point_type(T, x)

converts `x` so that its bare real type is the floating-point type of `T`.
Argument `x` may be a number or a numeric type, while argument `T` must be a
numeric type. If `x` is one of `missing`, `nothing`, `undef`, or the type of
one of these singletons, `x` is returned.

This method may be extended with `T<:AbstractFloat` and for `x` of non-standard
numeric type.

"""
convert_floating_point_type(::Type{T}, x) where {T<:Number} =
    convert_real_type(floating_point_type(T), x)

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
    @static if !isdefined(Base, :get_extension)
        # Extend methods to `Unitful` quantities when this package is loaded.
        @require Unitful = "1986cc42-f94f-5a68-af5c-568840ba703d" include(
            "../ext/UnitlessUnitfulExt.jl")
    end
end

end # module Unitless
