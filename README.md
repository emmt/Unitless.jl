# Unitless

[![License](http://img.shields.io/badge/license-MIT-brightgreen.svg?style=flat)](./LICENSE.md) [![Build Status](https://github.com/emmt/Unitless.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/emmt/Unitless.jl/actions/workflows/CI.yml?query=branch%3Amain) [![Build Status](https://ci.appveyor.com/api/projects/status/github/emmt/Unitless.jl?svg=true)](https://ci.appveyor.com/project/emmt/Unitless-jl) [![Coverage](https://codecov.io/gh/emmt/Unitless.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/emmt/Unitless.jl)

`Unitless` is a small [Julia](https://julialang.org/) package to deal with the
bare numeric type of values whatever their units. The intention is that
`Unitless` package automatically extends its exported methods when packages
such as [`Unitful`](https://github.com/PainterQubits/Unitful.jl) are loaded.

The `Unitless` package exports a few methods:

* `baretype(x)` yields the bare numeric type of `x` (a numeric value or type).
  If this method is not extended for a specific type, the fallback
  implementation yields `typeof(one(x))`.

* `baretype(args...)` yields the type resulting from promoting
  the bare numeric types of `args...`.

* `convert_baretype(T,x)` converts the bare numeric type of `x` to the bare
  numeric type of `T` while preserving the units of `x` if any.


## Examples

```julia
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


## Rationale

The following example shows how to use `baretype` to implement efficient
in-place multiplication of an array (whose element may have units) by a real
factor (which has no units):

```julia
function scale!(A::AbstractArray, α::Number)
    alpha = convert_baretype(eltype(A), α)
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
