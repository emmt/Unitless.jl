# Unitless

[![License](http://img.shields.io/badge/license-MIT-brightgreen.svg?style=flat)](./LICENSE.md) [![Build Status](https://github.com/emmt/Unitless.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/emmt/Unitless.jl/actions/workflows/CI.yml?query=branch%3Amain) [![Build Status](https://ci.appveyor.com/api/projects/status/github/emmt/Unitless.jl?svg=true)](https://ci.appveyor.com/project/emmt/Unitless-jl) [![Coverage](https://codecov.io/gh/emmt/Unitless.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/emmt/Unitless.jl)

`Unitless` is a small [Julia](https://julialang.org/) package to facilitate
coding with numbers whether they have units or not. The package provides
methods to strip units from numbers or numeric types, convert the numeric type
of quantities (not their units), determine appropriate numeric type to carry
computations mixing numbers with different types and/or units. These methods
make it easy to write code that works consistently for numbers with any units
(including none). The intention is that the `Unitless` package automatically
extends its exported methods when packages such as
[`Unitful`](https://github.com/PainterQubits/Unitful.jl) are loaded.

The `Unitless` package exports a few methods:

* `unitless(x)` yields `x` without its units, if any. `x` can be a number or a
  numeric type. In the latter case, `unitless` behaves like `bare_type`
  described below.

* `bare_type(x)` yields the bare numeric type of `x` (a numeric value or type).
  If this method is not extended for a specific type, the fallback
  implementation yields `typeof(one(x))`. With more than one argument,
  `bare_type(args...)` yields the type resulting from promoting the bare
  numeric types of `args...`. With no argument, `bare_type()` yields
  `Unitless.BareNumber` the union of bare numeric types that may be returned by
  this method.

* `real_type(x)` yields the bare real type of `x` (a numeric value or type). If
  this method is not extended for a specific type, the fallback implementation
  yields `typeof(one(real(x))`. With more than one argument,
  `real_type(args...)` yields the type resulting from promoting the bare real
  types of `args...`. With no argument, `real_type()` yields `Real` the
  super-type of types that may be returned by this method.

* `floating_point_type(args...)` yields a floating-point type appropriate to
  represent the bare real type of `args...`. With no argument,
  `floating_point_type()` yields `AbstractFloat` the super-type of types that
  may be returned by this method. You may consider
  `floating_point_type(args...)` as an equivalent to
  to`float(real_type(args...))`.

* `convert_bare_type(T,x)` converts the bare numeric type of `x` to the bare
  numeric type of `T` while preserving the units of `x` if any. Argument `x`
  may be a number or a numeric type, while argument `T` must be a numeric type.
  If `x` is one of `missing`, `nothing`, `undef`, or the type of one of these
  singletons, `x` is returned.

* `convert_real_type(T,x)` converts the bare real type of `x` to the bare real
  type of `T` while preserving the units of `x` if any. Argument `x` may be a
  number or a numeric type, while argument `T` must be a numeric type. If `x`
  is one of `missing`, `nothing`, `undef`, or the type of one of these
  singletons, `x` is returned.

* `convert_floating_point_type(T,x)` converts the bare real type of `x` to the
  suitable floating-point type for type `T` while preserving the units of `x`
  if any. Argument `x` may be a number or a numeric type, while argument `T`
  must be a numeric type. If `x` is one of `missing`, `nothing`, `undef`, or
  the type of one of these singletons, `x` is returned. You may consider
  `convert_floating_point_type(T,x)` as an equivalent to
  to `convert_real_type(float(real_type(T)),x)`.

The only difference between `bare_type` and `real_type` is how they treat
complex numbers. The former preserves the complex kind of its argument while
the latter always returns a real type. You may assume that `real_type(x) =
real(bare_type(x))`. Conversely, `convert_bare_type(T,x)` yields a complex
result if `T` is complex and a real result if `T` is real whatever `x`, while
`convert_real_type(T,x)` yields a complex result if `x` is complex and a real
result if `x` is real, only the real part of `T` matters for
`convert_real_type(T,x)`. See examples below.


## Examples

The following examples illustrate the result of the methods provided by
`Unitful`, first with bare numbers and bare numeric types, then with
quantities:

```julia
julia> using Unitless

julia> map(unitless, (2.1, Float64, true, ComplexF32))
(2.1, Float64, true, ComplexF32)

julia> map(bare_type, (1, 3.14f0, true, 1//3, π, 1.0 - 2.0im))
(Int64, Float32, Bool, Rational{Int64}, Irrational{:π}, Complex{Float64})

julia> map(real_type, (1, 3.14f0, true, 1//3, π, 1.0 - 2.0im))
(Int64, Float32, Bool, Rational{Int64}, Irrational{:π}, Float64)

julia> map(x -> convert_bare_type(Float32, x), (2, 1 - 0im, 1//2, Bool, Complex{Float64}))
(2.0f0, 1.0f0, 0.5f0, Float32, Float32)

julia> map(x -> convert_real_type(Float32, x), (2, 1 - 0im, 1//2, Bool, Complex{Float64}))
(2.0f0, 1.0f0 + 0.0f0im, 0.5f0, Float32, ComplexF32)

julia> using Unitful

julia> map(unitless, (u"2.1GHz", typeof(u"2.1GHz")))
(2.1, Float64)

julia> map(bare_type, (u"3.2km/s", u"5GHz", typeof((0+1im)*u"Hz")))
(Float64, Int64, Complex{Int64})

julia> map(real_type, (u"3.2km/s", u"5GHz", typeof((0+1im)*u"Hz")))
(Float64, Int64, Int64)
```


## Rationale

The following example shows a first attempt to use `bare_type` to implement
efficient in-place multiplication of an array (whose element may have units) by
a real factor (which must be unitless in this context):

```julia
function scale!(A::AbstractArray, α::Number)
    alpha = convert_bare_type(eltype(A), α)
    @inbounds @simd for i in eachindex(A)
        A[i] *= alpha
    end
    return A
end
```

An improvement is to realize that when `α` is a real while the entries of `A`
are complexes, it is more efficient to multiply the entries of `A` by a
real-valued multiplier rather than by a complex one. Implementing this is as
simple as replacing `convert_bare_type` by `convert_real_type` to only convert
the bare real type of the multiplier while preserving its complex/real kind:

```julia
function scale!(A::AbstractArray, α::Number)
    alpha = convert_real_type(eltype(A), α)
    @inbounds @simd for i in eachindex(A)
        A[i] *= alpha
    end
    return A
end
```

This latter version consistently and efficiently deals with `α` being real
while the entries of `A` are reals or complexes, and with `α` and the entries
of `A` being complexes. If `α` is a complex and the entries of `A` are reals,
the statement `A[i] *= alpha` will throw an `InexactConversion` if the
imaginary part of `α` is not zero. This check is probably optimized out of the
loop by Julia but, to handle this with guaranteed no loss of efficiency, the
code can be written as:

```julia
function scale!(A::AbstractArray, α::Union{Real,Complex})
    alpha = if α isa Complex && bare_type(eltype(A)) isa Real
        convert(real_type(eltype(A)), α)
    else
        convert_real_type(eltype(A), α)
    end
    @inbounds @simd for i in eachindex(A)
        A[i] *= alpha
    end
    return A
end
```

The restriction `α::Union{Real,Complex}` accounts for the fact that in-place
multiplication imposes a unitless multiplier. Since the test leading to the
expression used for `alpha` is based on the types of the arguments, the branch
is eliminated at compile time and the type of `alpha` is known by the compiler.
The `InexactConversion` exception may then only be thrown by the call to
`convert` in the first branch of the test.

This seemingly very specific case was in fact the key point to allow for
packages such as [LazyAlgebra](https://github.com/emmt/LazyAlgebra.jl) or
[LinearInterpolators](https://github.com/emmt/LinearInterpolators.jl) to work
seamlessly on arrays whose entries may have units. The `Unitless` package was
created to cover this need as transparently as possible.


## Installation

`Unitless` can be installed as any other official Julia packages. For example:

```julia
using Pkg
Pkg.add("Unitless")
```
