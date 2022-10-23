module UnitlessTests

using Unitless
using Unitful
using Test

# Minimal implementation of a custom numeric type.
struct MyNumber{T<:Unitless.BareNumber} <: Number
    val::T
end
Base.zero(::Type{MyNumber{T}}) where {T} = MyNumber{T}(zero(T))
Base.oneunit(::Type{MyNumber{T}}) where {T} = MyNumber{T}(one(T))
Base.one(::Type{MyNumber{T}}) where {T} = one(T)
Base.real(x::MyNumber{<:Real}) = x
Base.real(x::MyNumber{<:Complex}) = MyNumber(real(x.val))
Base.real(::Type{MyNumber{T}}) where {T<:Real} = MyNumber{T}
Base.real(::Type{MyNumber{Complex{T}}}) where {T<:Real} = MyNumber{T}
Unitless.unitless(x::MyNumber) = x.val

@testset "Basic types" begin
    # bare_type with no argument
    @test bare_type() === Unitless.BareNumber

    # bare_type for values
    @test bare_type(1.0) === Float64
    @test bare_type(Float32) === Float32
    @test bare_type(Complex(2,3)) === Complex{Int}
    @test bare_type(NaN) === typeof(NaN)
    @test bare_type(π) === typeof(π)
    @test bare_type(3//4) === typeof(3//4)
    @test_throws ErrorException bare_type("hello")

    # bare_type for types
    @test bare_type(Real) === Real
    @test bare_type(Integer) === Integer
    @test bare_type(Float32) === Float32
    @test bare_type(BigFloat) === BigFloat
    @test bare_type(Complex{Int}) === Complex{Int}
    @test bare_type(typeof(π)) === typeof(π)
    @test bare_type(typeof(3//4)) === typeof(3//4)
    @test_throws ErrorException bare_type(AbstractString)

    # bare_type with multiple arguments
    @test bare_type(1, 0f0) === Float32
    @test bare_type(Int, pi) === promote_type(Int, typeof(pi))
    @test bare_type(4, pi, 1.0) === promote_type(Int, typeof(pi), Float64)
    @test bare_type(Int, Int8, Float32) === promote_type(Int, Int8, Float32)
    @test bare_type(Int, Int8, Float32) === promote_type(Int, Int8, Float32)
    @test bare_type(Int, Int8, Int16, Float32) === promote_type(Int, Int8, Int16, Float32)

    # default implementation
    @test bare_type(MyNumber(1.2f0)) === Float32
    @test bare_type(MyNumber{Int16}) === Int16

    # convert_bare_type
    @test convert_bare_type(Int, -1) === -1
    @test convert_bare_type(Int, 2.0) === 2
    @test convert_bare_type(Float32, 2.0) === 2.0f0
    @test convert_bare_type(MyNumber{Int16}, 12.0) === Int16(12)
    @test_throws ErrorException convert_bare_type(Int, "oups!")

    # real_type with no argument
    @test real_type() === Real

    # real_type for values
    @test real_type(1.0) === Float64
    @test real_type(Float32) === Float32
    @test real_type(Complex(2,3)) === Int
    @test real_type(NaN) === typeof(NaN)
    @test real_type(π) === typeof(π)
    @test real_type(3//4) === typeof(3//4)
    @test_throws ErrorException real_type("hello")

    # real_type for types
    @test real_type(Real) === Real
    @test real_type(Integer) === Integer
    @test real_type(Float32) === Float32
    @test real_type(BigFloat) === BigFloat
    @test real_type(Complex{Int}) === Int
    @test real_type(typeof(π)) === typeof(π)
    @test real_type(typeof(3//4)) === typeof(3//4)
    @test_throws ErrorException real_type(AbstractString)

    # real_type with multiple arguments
    @test real_type(1, 0f0) === Float32
    @test real_type(Int, pi) === promote_type(Int, typeof(pi))
    @test real_type(4, pi, 1.0) === promote_type(Int, typeof(pi), Float64)
    @test real_type(Int, Int8, Float32) === promote_type(Int, Int8, Float32)
    @test real_type(Int, Int8, Float32) === promote_type(Int, Int8, Float32)
    @test real_type(Int, Int8, Complex{Int16}, Float32) === promote_type(Int, Int8, Int16, Float32)

    # default implementation
    @test real_type(MyNumber(1.2f0)) === Float32
    @test real_type(MyNumber{Complex{Int16}}) === Int16

    # convert_real_type
    @test convert_real_type(Int, -1) === -1
    @test convert_real_type(Int, 2.0) === 2
    @test convert_real_type(Complex{Float32}, 2.0) === 2.0f0
    @test convert_real_type(Complex{Int16}, 2 + 3im) === Complex{Int16}(2, 3)
    @test convert_real_type(Float32, 2.0 - 1.0im) === Complex{Float32}(2, -1)
    @test convert_real_type(MyNumber{Int16}, 12.0) === Int16(12)
    @test_throws ErrorException convert_real_type(Int, "oups!")

    # unitless
    @test unitless(Real) === bare_type(Real)
    @test unitless(Integer) === bare_type(Integer)
    @test unitless(Float32) === bare_type(Float32)
    @test unitless(BigFloat) === bare_type(BigFloat)
    @test unitless(Complex{Int}) === bare_type(Complex{Int})
    @test unitless(typeof(3//4)) === bare_type(typeof(3//4))
    @test unitless(typeof(π)) === bare_type(typeof(π))
    @test unitless(17.0) === 17.0
    @test unitless(17.0f0) === 17.0f0
    @test unitless(17) === 17
    @test unitless(Int16(17)) === Int16(17)
    @test unitless(true) === true
    @test unitless(false) === false
    @test unitless(3//4) === 3//4
    @test unitless(π) === π
    @test unitless(MyNumber(1.2f0)) === 1.2f0
    @test unitless(MyNumber{Int16}) === Int16
end

@testset "Unitful quantities" begin
    # bare_type for values
    @test bare_type(u"2.0m/s") === Float64
    @test bare_type(u"35GHz") === Int

    # bare_type for types
    @test bare_type(typeof(u"2.0m/s")) === Float64
    @test bare_type(typeof(u"35GHz")) === Int

    # bare_type with multiple arguments
    @test bare_type(u"2.0m/s", u"35GHz") === Float64
    @test bare_type(1, u"2.0f0m/s", u"35GHz") === Float32
    @test bare_type(1, u"2.0f0m/s", u"35GHz", Complex{Int8}(11)) === Complex{Float32}

    # convert_bare_type
    @test convert_bare_type(Float64, u"2.0m/s") === u"2.0m/s"
    @test convert_bare_type(Int, u"2.0m/s") === u"2m/s"
    @test convert_bare_type(Float32, u"35GHz") === u"35.0f0GHz"


    # real_type for values
    @test real_type(u"2.0m/s") === Float64
    @test real_type(u"35GHz") === Int

    # real_type for types
    @test real_type(typeof(u"2.0m/s")) === Float64
    @test real_type(typeof(u"35GHz")) === Int

    # real_type with multiple arguments
    @test real_type(u"2.0m/s", u"35GHz") === Float64
    @test real_type(1, u"2.0f0m/s", u"35GHz") === Float32
    @test real_type(1, u"2.0f0m/s", u"35GHz", Complex{Int8}(11)) === Float32

    # convert_real_type
    @test convert_real_type(Float64, u"2.0m/s") === u"2.0m/s"
    @test convert_real_type(Int, u"2.0m/s") === u"2m/s"
    @test convert_real_type(Float32, u"35GHz") === u"35.0f0GHz"

    # unitless
    @test unitless(u"17GHz") === 17
    @test unitless(typeof(u"2.0f0m/s")) === Float32
end

end # module UnitlessTests
