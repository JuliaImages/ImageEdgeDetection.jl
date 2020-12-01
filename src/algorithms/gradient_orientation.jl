"""
```
    OrientationConvention(; compass_direction::AbstractChar = 'S', is_clockwise::Bool = false, in_radians = true, tol = sqrt(eps(Float64)))
```
Specifies the coordinate system context for `detect_gradient_orientation` which
determines the meaning of the angles (the gradient orientations).

# Details

You can specify how you want the gradient orientation to be reported.  By
default, the orientation is measured counter-clockwise from the south direction.
This is because in a Raster coordinate system, the first spatial dimension
increases as one goes down the image (i.e. it points south), and the second
spatial dimension increases as one moves to the right of the image (i.e. it
points east).

If you wish to interpret the orientation in a canonical Cartesian coordinate
convention you would specify east as the reference compass direction
(`compass_direction = 'E'`) and a counter-clockwise direction (`clockwise =
false`).

If `in_radians = true` the valid angles are reported in the range of `[0...2π)`,
otherwise they are reported in the range `[0...360)`. The values `2π` and `360`
are used as sentinels to designate undefined angles (because the gradient
magnitude was too close to zero). By default, an angle is undefined if `(abs(g₁)
< tol && abs(g₂) < tol)` where `g₁` and `g₂` denote the gradient in the first
and second spatial dimensions, and `tol = sqrt(eps(Float64))`.

# Example

```julia

using TestImages, FileIO, ImageView, ImageEdgeDetection, ImageFiltering

img =  testimage("mandril_gray")

# Gradient in the first and second spatial dimension
g₁, g₂ = imgradients(img, KernelFactors.scharr)

# Interpret the angles with respect to a canonical Cartesian coordinate system
# where the angles are measured counter-clockwise from the positive x-axis.

orientation_convention = OrientationConvention(in_radians = true,
                                               is_clockwise = false,
                                               compass_direction = 'E')
angles = detect_gradient_orientation(g₁, g₂, orientation_convention)

```
"""
@with_kw struct OrientationConvention{ T <: AbstractChar}
    # 'N', 'S', 'E ', 'W' for (north, south, east, west)
    compass_direction::T = 'S'
    is_clockwise::Bool = false
    in_radians::Bool = true
    tol = sqrt(eps(eltype(Float64)))
end


"""
    detect_gradient_orientation(g₁::AbstractArray, g₂::AbstractArray, orientation_convention::OrientationConvention, args...; kwargs...)

Given the gradient in the first (`g₁`) and second (`g₂`) spatial dimensions,
returns the gradient orientation, where the orientation is interpreted according
to a supplied [`OrientationConvention`](@ref
ImageEdgeDetection.OrientationConvention).

# Details

You can specify how you want the gradient orientation to be reported by
supplying an [`OrientationConvention`](@ref
ImageEdgeDetection.OrientationConvention). If left unspecified the orientation
is measured counter-clockwise from the south direction. This is because in a
Raster coordinate system, the first spatial dimension increases as one goes down
the image (i.e. it points south), and the second spatial dimension increases as
one moves to the right of the image (i.e. it points east).

If you wish to interpret the orientation in a canonical Cartesian coordinate
convention you would specify east as the reference compass direction
(`compass_direction = 'E'`) and a counter-clockwise direction (`clockwise =
false`).

# Output

Returns a two-dimensional array of angles. If `in_radians = true` the valid
angles are reported in the range of `[0...2π)`, otherwise they are reported in
the range `[0...360)`. The values `2π` and `360` are used as sentinels to
designate undefined angles (because the gradient magnitude was too close to
zero). By default, an angle is undefined if `(abs(g₁) < tol && abs(g₂) < tol)`
where `g₁` and `g₂` denote the gradient in the first and second spatial
dimensions, and `tol = sqrt(eps(Float64))` (as defined in
[`OrientationConvention`](@ref ImageEdgeDetection.OrientationConvention)).


See also: [`detect_gradient_orientation!`](@ref)
"""
function detect_gradient_orientation(g₁::AbstractArray, g₂::AbstractArray, orientation_convention::OrientationConvention)
    out = zeros(axes(g₁))
    detect_gradient_orientation!(out, g₁, g₂, orientation_convention)
    return out
end

function detect_gradient_orientation(g₁::AbstractArray, g₂::AbstractArray)
    out = zeros(axes(g₁))
    detect_gradient_orientation!(out, g₁, g₂, OrientationConvention())
    return out
end

"""
    detect_gradient_orientation(out::AbstractArray, g₁::AbstractArray, g₂::AbstractArray, orientation_convention::OrientationConvention, args...; kwargs...)

Given the gradient in the first (`g₁`) and second (`g₂`) spatial dimensions,
returns the gradient orientation in `out`, where the orientation is interpreted
according to a supplied [`OrientationConvention`](@ref
ImageEdgeDetection.OrientationConvention).

# Details

You can specify how you want the gradient orientation to be reported by
supplying an [`OrientationConvention`](@ref
ImageEdgeDetection.OrientationConvention). If left unspecified the orientation
is measured counter-clockwise in radians from the south direction. This is
because in a Raster coordinate system, the first spatial dimension increases as
one goes down the image (i.e. it points south), and the second spatial dimension
increases as one moves to the right of the image (i.e. it points east).

If you wish to interpret the orientation in a canonical Cartesian coordinate
convention you would specify east as the reference compass direction
(`compass_direction = 'E'`) and a counter-clockwise direction (`clockwise =
false`).

# Output

Returns a two-dimensional array of angles. If `in_radians = true` genuine angles are
reported in the range of `[0...2π)`, otherwise they are reported in the range
`[0...360)`. The values `2π` and `360` are used as sentinels to designate
undefined angles (because the gradient magnitude was too close to zero).
By default, an angle is undefined if `(abs(g₁) < tol && abs(g₂) < tol)` where
`g₁` and `g₂` denote the gradient in the first and second spatial dimensions,
and `tol = sqrt(eps(eltype(out)))` (as defined in [`OrientationConvention`](@ref
ImageEdgeDetection.OrientationConvention)).

See also: [`detect_gradient_orientation`](@ref)
"""
function detect_gradient_orientation!(out::AbstractArray, g₁::AbstractArray, g₂::AbstractArray, orientation_convention::OrientationConvention)
    @unpack compass_direction, is_clockwise, in_radians = orientation_convention
    tol = sqrt(eps(eltype(out)))

    # Determine from which compass direction we intend to measure the angle.
    if compass_direction == 'S' || compass_direction == 's'
        offset = π/2
    elseif compass_direction == 'E' || compass_direction == 'e'
        offset = 0.0
    elseif compass_direction == 'N' || compass_direction == 'n'
        offset = -π/2
    elseif compass_direction == 'W' || compass_direction == 'w'
        offset = π
    else
        @warn("Unrecognised compass_direction... using a default direction of south (S).")
        offset = π/2
    end


    if !is_clockwise && !in_radians
        @inbounds for i in CartesianIndices(g₁)
            out[i] = rad2deg(zero_to_2PI(valid_angle(g₁[i], g₂[i], offset, tol)))
        end
    elseif !is_clockwise && in_radians
        @inbounds for i in CartesianIndices(g₁)
            out[i] = zero_to_2PI(valid_angle(g₁[i], g₂[i], offset, tol))
        end
    elseif is_clockwise && !in_radians
        @inbounds for i in CartesianIndices(g₁)
            out[i] = rad2deg(zero_to_2PI(clockwise_valid_angle(g₁[i], g₂[i], offset, tol)))
        end
    elseif is_clockwise && in_radians
        @inbounds for i in CartesianIndices(g₁)
            out[i] = zero_to_2PI(clockwise_valid_angle(g₁[i], g₂[i], offset, tol))
        end
    end
    return nothing
end

function detect_gradient_orientation!(out::AbstractArray, g₁::AbstractArray, g₂::AbstractArray)
    detect_gradient_orientation!(out, g₁, g₂, OrientationConvention())
    return out
end

# When the angle is undefined because g₁ and g₂ are almost zero, we return
# a "dummy" value of 2π.
function valid_angle(g₁, g₂, offset, tol)
    # The expression for the angle when changing coordinate system from Raster
    # to Cartesian coordinates is atan(-g₁, g₂). The offset is used to indicate
    # against which compass direction we will measure angles.
    is_angle_undefined = (abs(g₁) < tol && abs(g₂) < tol)
    return  is_angle_undefined ? 2π : atan(-g₁, g₂) + offset
end

# When the angle is undefined because g₁ and g₂ are almost zero, we return
# a "dummy" value of 2π.
function clockwise_valid_angle(g₁, g₂, offset, tol)
    # The expression for the angle when changing coordinate system from Raster
    # to Cartesian coordinates is atan(-g₁, g₂). The offset is used to indicate
    # against which compass direction we will measure angles.
    is_angle_undefined = (abs(g₁) < tol && abs(g₂) < tol)
    return  is_angle_undefined ? 2π : clockwise(atan(-g₁, g₂) + offset)
end

function zero_to_2PI(θ)
   return (θ >= 0 ? θ : (2*π + θ))
end

function clockwise(x)
   return mod(-x, 2π)
end
