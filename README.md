# Unitless [![Build Status](https://github.com/emmt/Unitless.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/emmt/Unitless.jl/actions/workflows/CI.yml?query=branch%3Amain) [![Build Status](https://ci.appveyor.com/api/projects/status/github/emmt/Unitless.jl?svg=true)](https://ci.appveyor.com/project/emmt/Unitless-jl) [![Coverage](https://codecov.io/gh/emmt/Unitless.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/emmt/Unitless.jl)

`Unitless` is a small [Julia](https://julialang.org/) package to strip units
from quantities.  The package provides a single method, `unitless`, which
yields its argument (a value, a type, an array, etc.) converted to a basic
numeric type, avoiding copy as much as possible.  The package automatically
extends its methods when packages such as
[Unitful](https://github.com/PainterQubits/Unitful.jl) are loaded.  Other
packages are encouraged to create pull requests to this repository for their
own types to be taken into account.


## Usage

`unitless` is a no-op for arguments with basic numeric types.  For example:

```julia
using Unitless
unitless(π)                # yields π
unitless(2.7)              # yields 2.7
unitless(3//4)             # yields 3//4
unitless([1//3, 3//4])     # yields [1//3, 3//4]
unitless(Float32)          # yields Float32
```

`unitless` is able to strip units.  For example:

```julia
using Unitful
unitless(u"3km/s")         # yields 3
unitless(typeof(u"3km/s")) # yields Int
unitless([u"3km/s"])       # yields [3]
unitless(typeof([u"5GHz"]))# yields Array{Int,1}

```

As can be seen, stripping units from a quantity may not be a good idea
(`unitless(u"3km/s")` and `unitless(u"3m/s")` both yield `3`).  The real
interest is to apply `unitless` on types (not values).  For instance, the
following method can be used to efficiently multiply in-place an array (whose
element may have units) by a real factor (which has no units):

```julia
function scale!(A::AbstractArray, α::Real)
    alpha = convert(unitless(eltype(A)), α)
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

Since `Unitless` automatically extends the `unitless` method when packages such
as [Unitful](https://github.com/PainterQubits/Unitful.jl) are loaded, you can
use `unitless` without depending on such packages to write code that can
correctly deal with values that may have units.


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
