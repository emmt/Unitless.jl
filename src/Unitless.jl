"""

Module `Unitless` is to strip units from quantities.

"""
module Unitless

export baretype

"""
    baretype(x)

yields the basic numeric type of `x` which can be a numeric value or a numeric
type.  This method is useful to strip units from quantities.

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
@noinline baretype(T::DataType) = error("unknown basic numeric type for `$T`")

end # module Unitless
