# User visible changes in `Unitless`

## Version 1.3.0

- Rename `Unitless.BareType` as `Unitless.BareNumber`.

## Version 1.2.0

- `baretype(args...)` with more than one argument yields the promoted bare type
  of `args...`.
- `promote_baretype(args...)` has been deprected in favor of
  `baretype(args...)`.
