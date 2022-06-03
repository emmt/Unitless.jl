# Unitless [![Build Status](https://github.com/emmt/Unitless.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/emmt/Unitless.jl/actions/workflows/CI.yml?query=branch%3Amain) [![Build Status](https://ci.appveyor.com/api/projects/status/github/emmt/Unitless.jl?svg=true)](https://ci.appveyor.com/project/emmt/Unitless-jl) [![Coverage](https://codecov.io/gh/emmt/Unitless.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/emmt/Unitless.jl)

`Unitless` is a small [Julia](https://julialang.org/) package to strip units
from quantities.  The package provides a single method, `unitless`, which
yields its argument (a value, a type, an array, etc.) converted to a basic
numeric type, avoiding copy as much as possible.  The package automatically
extends its methods when packages such as
[Unitful](https://github.com/PainterQubits/Unitful.jl) are loaded.  Other
packages are encouraged to create pull requests to this repository for their
own types to be taken into account.

Examples:

```julia
using Unitless
unitless(π)                # yields π
unitless(2.7)              # yields 2.7
unitless(3//4)             # yields 3//4

using Unitful
unitless(u"3km/s")         # yields 3
unitless(typeof(u"3km/s")) # yields Int
unitless([u"3km/s"])       # yields [3]
```


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
