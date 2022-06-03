module UnitlessTests

using Unitless
using Unitful
using Test

identical(a::AbstractArray, b::AbstractArray) = false
identical(a::AbstractArray{T,N}, b::AbstractArray{T,N}) where {T,N} = (a == b)

@testset "Basic types" begin
    # unitless for values
    @test unitless(1.0) === 1.0
    @test unitless(Complex(2,3)) === Complex(2,3)
    @test unitless(NaN) === NaN
    @test unitless(π) === π
    @test unitless(3//4) === 3//4
    @test_throws ErrorException unitless("hello")

    # unitless for types
    @test unitless(Real) === Real
    @test unitless(Integer) === Integer
    @test unitless(Float32) === Float32
    @test unitless(BigFloat) === BigFloat
    @test unitless(Complex{Int}) === Complex{Int}
    @test unitless(typeof(π)) === typeof(π)
    @test unitless(typeof(3//4)) === typeof(3//4)
    @test_throws ErrorException unitless(AbstractString)

    # unitless for arrays
    @test let A = [1.0];           unitless(A) === A; end
    @test let A = [π];             unitless(A) === A; end
    @test let A = [3//4];          unitless(A) === A; end
    @test let A = [one(BigFloat)]; unitless(A) === A; end
    @test let A = Real[2];         unitless(A) === A; end
    @test_throws ErrorException unitless(["hello"])
end

@testset "Unitful quantities" begin
    # unitless for values
    @test unitless(u"2.0m/s") === 2.0
    @test unitless(u"35GHz") === 35
    #@test unitless(Complex(u"2s",u"3s")) === Complex(2,3)

    # unitless for types
    @test unitless(typeof(u"2.0m/s")) === Float64
    @test unitless(typeof(u"35GHz")) === Int

    # unitless for arrays
    @test let A = unitless([u"2.0m"]); identical(A, [2.0]); end
end

end # module UnitlessTests
