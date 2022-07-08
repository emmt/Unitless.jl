# Unitless [![Build Status](https://github.com/emmt/Unitless.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/emmt/Unitless.jl/actions/workflows/CI.yml?query=branch%3Amain) [![Build Status](https://ci.appveyor.com/api/projects/status/github/emmt/Unitless.jl?svg=true)](https://ci.appveyor.com/project/emmt/Unitless-jl) [![Coverage](https://codecov.io/gh/emmt/Unitless.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/emmt/Unitless.jl)

`Unitless` is a tiny [Julia](https://julialang.org/) package to strip units
from quantities.  The package provides a single method, `baretype`, which
yields the basic numerical type of its argument (a numerical value or type).


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
function scale!(A::AbstractArray, α::Real)
    alpha = convert(baretype(eltype(A)), α)
    @inbounds @simd for i in eachindex(A)
        A[i] *= alpha
    end
    return A
end
```

This seemingly very specific case was in fact the key point to allow for
packages such as [LazyAlgebra](https://github.com/emmt/LazyAlgebra.jl) or
[LinearInterpolators](https://github.com/emmt/LinearInterpolators.jl) to work
seamlessly on arrays whose entries have units.  The `Unitless` package was
created to share this need.


## Installation

The `Unitless` package can be installed as:

```julia
using Pkg
pkg"add https://github.com/emmt/Unitless.jl"
```

You may also consider using [my custom
registry](https://github.com/emmt/EmmtRegistry):

```julia
using Pkg
pkg"registry add General" # if no general registry has been installed yet
pkg"registry add https://github.com/emmt/EmmtRegistry" # if not yet added
pkg"add Unitless"
```
