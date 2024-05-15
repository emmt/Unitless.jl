"""

Module `Unitless` is to facilitate coding with numbers whether they have units
or not.

"""
module Unitless

export
    bare_type,
    convert_bare_type,
    convert_floating_point_type,
    convert_real_type,
    floating_point_type,
    real_type,
    unitless

# Import all types and functions that were documented but not necessarily exported.
import TypeUtils: BareNumber
import TypeUtils: bare_type
import TypeUtils: convert_bare_type
import TypeUtils: convert_floating_point_type
import TypeUtils: convert_real_type
import TypeUtils: floating_point_type
import TypeUtils: real_type
import TypeUtils: unitless

end # module Unitless
