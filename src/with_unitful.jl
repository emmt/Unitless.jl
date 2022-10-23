# with_unitful.jl -
#
# Provide support for the `Unitful` package when loaded.
#

using .Unitful
using .Unitful: AbstractQuantity, unit, ustrip

# Extend `baretype` for unitful quantities.
baretype(::Type{<:AbstractQuantity{T}}) where {T} = baretype(T)

# Extend `_convert_baretype` for unitful quantities.
convert_baretype(::Type{T}, x::AbstractQuantity{T}) where {T<:BareType} = x
@inline convert_baretype(::Type{T}, x::AbstractQuantity) where {T<:BareType} =
    convert(T, ustrip(x))*unit(x)
