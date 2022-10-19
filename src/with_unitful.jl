# with_unitful.jl -
#
# Provide support for the `Unitful` package when loaded.
#

using .Unitful
using .Unitful: AbstractQuantity, unit, ustrip

# Extend `baretype` for unitful quantities.
@inline baretype(::Type{<:AbstractQuantity{T}}) where {T} = T

# Extend `_convert_baretype` for unitful quantities.
@inline _convert_baretype(::Type{T}, x::AbstractQuantity{T}) where {T} = x
@inline _convert_baretype(::Type{T}, x::AbstractQuantity) where {T} =
    convert(T, ustrip(x))*unit(x)
