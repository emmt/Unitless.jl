module UnitlessUnitfulExt
if isdefined(Base, :get_extension)
    using Unitless, Unitful
else
    using ..Unitless, ..Unitful
end

# Extend bare_type, real_type, convert_bare_type, and convert_real_type.
for (f, g, S) in ((:(Unitless.bare_type), :(Unitless.convert_bare_type), :(Unitless.BareNumber)),
                  (:(Unitless.real_type), :(Unitless.convert_real_type), :Real))
    @eval begin
        $f(::Type{<:Unitful.AbstractQuantity{T}}) where {T} = $f(T)
        $g(::Type{T}, x::Unitful.AbstractQuantity{T}) where {T<:$S} = x
        @inline $g(::Type{T}, x::Unitful.AbstractQuantity) where {T<:$S} =
            $g(T, Unitful.ustrip(x))*Unitful.unit(x)
        $g(::Type{T}, ::Type{Unitful.Quantity{T,D,U}}) where {T<:$S,D,U} =
            Unitful.Quantity{T,D,U}
        @inline $g(::Type{T}, ::Type{Unitful.Quantity{R,D,U}}) where {T<:$S,R,D,U} =
            Unitful.Quantity{$g(T,R),D,U}
    end
end

# Extend unitless (only needed for values).
Unitless.unitless(x::Unitful.AbstractQuantity) = Unitful.ustrip(x)

end # module
