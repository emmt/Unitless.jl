# User visible changes in `Unitless`

## Version 2.0.0

Breaking changes compared to version 1:
- Rename `baretype` as `bare_type`.

New features:
- `bare_type()` with no arguments yields `Unitless.BareNumber`.
- `real_type` and `convert_real_type` which work like `bare_type` and
  `convert_bare_type` except for complex numbers or numeric types for which the
  bare real type backing the storage of the real and imaginary parts is
  considered.
- `unitless(x)` yields `x` without its units if any. `x` may be a number or a
  numeric type.

## Version 1.3.0

- Rename `Unitless.BareType` as `Unitless.BareNumber`.

## Version 1.2.0

- `baretype(args...)` with more than one argument yields the promoted bare type
  of `args...`.
- `promote_baretype(args...)` has been deprected in favor of
  `baretype(args...)`.
