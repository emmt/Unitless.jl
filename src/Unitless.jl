"""

Module `Unitless` is to strip units from quantities.

"""
module Unitless

export unitless

using Requires

"""
    unitless(x)

yields `x` converted to a basic numeric type.  Argument can be a value, a type,
an array, etc.  Copy is avoided as much as possible.

Examples:

    using Unitless
    unitless(π)                # yields π
    unitless(2.7)              # yields 2.7
    unitless(3//4)             # yields 3//4

    using Unitful
    unitless(u"3km/s")         # yields 3
    unitless(typeof(u"3km/s")) # yields Int
    unitless([u"3km/s"])       # yields [3]

""" unitless

# unitless for values
unitless(x::Complex{<:Real}) = x
unitless(x::Real) = x
unitless(x::T) where {T} = unsupported_type(T)

# unitless for types
unitless(::Type{Complex{T}}) where {T} = Complex{unitless(T)}
unitless(::Type{T}) where {T<:Real} = T
unitless(::Type{T}) where {T} = unsupported_type(T)

# unitless for arrays
unitless(A::AbstractArray) = _unitless(unitless(eltype(A)), A)
_unitless(::Type{T}, A::AbstractArray{T}) where {T} = A
function _unitless(::Type{T}, A::AbstractArray) where {T}
    B = similar(A, T)
    @inbounds @simd for i in eachindex(A, B)
        B[i] = unitless(A[i])
    end
    return B
end

@noinline unsupported_type(T) = error("unknown basic numeric type for `$T`")

function __init__()
    @require Unitful="1986cc42-f94f-5a68-af5c-568840ba703d" begin
        unitless(x::Unitful.Quantity) = unitless(x.val)
        unitless(::Type{<:Unitful.AbstractQuantity{T}}) where {T} = unitless(T)
    end
end

end # module Unitless
