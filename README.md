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

* `convert_bare_type(T,x)` converts the bare numeric type of `x` to the bare
  numeric type of `T` while preserving the units of `x` if any.

* `convert_real_type(T,x)` converts the bare real type of `x` to the bare real
  type of `T` while preserving the units of `x` if any.

* `unitless(x)` yields `x` without its units, if any. `x` can be a number or a
  numeric type. In the latter case, `unitless` behaves like `bare_type`.


## Examples

```julia
julia> using Unitless

julia> bare_type(1)
Int64

julia> bare_type(-3.14f0)
Float32

julia> bare_type(π)
Irrational{:π}

julia> bare_type(sqrt(π))
Float64

julia> bare_type(1 + 0im)
Complex{Int64}

julia> using Unitful

julia> bare_type(u"3km/s")
Int64

julia> bare_type(u"3.2km/s")
Float64

julia> bare_type(typeof(u"2.1GHz"))
Float64

julia> unitless(typeof(u"2.1GHz"))
Float64

julia> unitless(u"2.1GHz")
2.1
```


## Rationale

The following example shows how to use `bare_type` to implement efficient
in-place multiplication of an array (whose element may have units) by a real
factor (which has no units):

```julia
function scale!(A::AbstractArray, α::Number)
    alpha = convert_bare_type(eltype(A), α)
    @inbounds @simd for i in eachindex(A)
        A[i] *= alpha
    end
    return A
end
```

This seemingly very specific case was in fact the key point to allow for
packages such as [LazyAlgebra](https://github.com/emmt/LazyAlgebra.jl) or
[LinearInterpolators](https://github.com/emmt/LinearInterpolators.jl) to work
seamlessly on arrays whose entries may have units. The `Unitless` package was
created to cover this need.


## Installation

`Unitless` can be installed as any other official Julia packages. For example:

```julia
using Pkg
pkg"add Unitless"
```
