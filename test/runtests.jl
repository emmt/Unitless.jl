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
    # baretype for values
    @test baretype(1.0) === Float64
    @test baretype(Float32) === Float32
    @test baretype(Complex(2,3)) === Complex{Int}
    @test baretype(NaN) === typeof(NaN)
    @test baretype(π) === typeof(π)
    @test baretype(3//4) === typeof(3//4)
    @test_throws ErrorException baretype("hello")

    # baretype for types
    @test baretype(Real) === Real
    @test baretype(Integer) === Integer
    @test baretype(Float32) === Float32
    @test baretype(BigFloat) === BigFloat
    @test baretype(Complex{Int}) === Complex{Int}
    @test baretype(typeof(π)) === typeof(π)
    @test baretype(typeof(3//4)) === typeof(3//4)
    @test_throws ErrorException baretype(AbstractString)

    # baretype with multiple arguments
    @test (@test_deprecated promote_baretype(1, 0f0)) === Float32
    @test baretype(1, 0f0) === Float32
    @test baretype(Int, pi) === promote_type(Int, typeof(pi))
    @test baretype(4, pi, 1.0) === promote_type(Int, typeof(pi), Float64)
    @test baretype(Int, Int8, Float32) === promote_type(Int, Int8, Float32)
    @test baretype(Int, Int8, Float32) === promote_type(Int, Int8, Float32)
    @test baretype(Int, Int8, Int16, Float32) === promote_type(Int, Int8, Int16, Float32)

    # default implementation
    @test baretype(MyNumber(1.2f0)) === Float32
    @test baretype(MyNumber{Int16}) === Int16

    # convert_baretype
    @test convert_baretype(Int, -1) === -1
    @test convert_baretype(Int, 2.0) === 2
    @test convert_baretype(Float32, 2.0) === 2.0f0
    @test convert_baretype(MyNumber{Int16}, 12.0) === Int16(12)
end

@testset "Unitful quantities" begin
    # baretype for values
    @test baretype(u"2.0m/s") === Float64
    @test baretype(u"35GHz") === Int

    # baretype for types
    @test baretype(typeof(u"2.0m/s")) === Float64
    @test baretype(typeof(u"35GHz")) === Int

    # baretype with multiple arguments
    @test baretype(u"2.0m/s", u"35GHz") === Float64
    @test baretype(1, u"2.0f0m/s", u"35GHz") === Float32

    # convert_baretype
    @test convert_baretype(Float64, u"2.0m/s") === u"2.0m/s"
    @test convert_baretype(Int, u"2.0m/s") === u"2m/s"
    @test convert_baretype(Float32, u"35GHz") === u"35.0f0GHz"
end

end # module UnitlessTests
