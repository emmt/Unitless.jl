module UnitlessTests

using Unitless
using Unitful
using Test

struct MyNumber{T<:Number} <: Number
    val::T
end

Base.zero(::Type{MyNumber{T}}) where {T} = MyNumber{T}(zero(T))
Base.oneunit(::Type{MyNumber{T}}) where {T} = MyNumber{T}(one(T))
Base.one(::Type{MyNumber{T}}) where {T} = one(T)

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

    # convert_bare_type
    @test convert_bare_type(Float64, u"2.0m/s") === u"2.0m/s"
    @test convert_bare_type(Int, u"2.0m/s") === u"2m/s"
    @test convert_bare_type(Float32, u"35GHz") === u"35.0f0GHz"
end

end # module UnitlessTests
