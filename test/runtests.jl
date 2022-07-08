module UnitlessTests

using Unitless
using Unitful
using Test

@testset "Basic types" begin
    # baretype for values
    @test baretype(1.0) === Float64
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
end

@testset "Unitful quantities" begin
    # baretype for values
    @test baretype(u"2.0m/s") === Float64
    @test baretype(u"35GHz") === Int

    # baretype for types
    @test baretype(typeof(u"2.0m/s")) === Float64
    @test baretype(typeof(u"35GHz")) === Int
end

end # module UnitlessTests
