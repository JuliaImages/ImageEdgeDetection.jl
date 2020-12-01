# usage example for package developer:
#
#     import EdgeDetectionAPI: AbstractEdgeDetectionAlgorithm,
#                             detect_edges, detect_edges!,
#                             detect_subpixel_edges, detect_subpixel_edges!

"""
    AbstractEdgeDetectionAlgorithm <: AbstractImageFilter

The root type for `ImageEdgeDetection` package.

Any concrete edge detection algorithm shall subtype it to support
[`detect_edges`](@ref), [`detect_edges!`](@ref), [`detect_subpixel_edges`](@ref)
and [`detect_subpixel_edges!`](@ref) APIs.

# Examples

All edge detection algorithms in ImageEdgeDetection are called in the
following pattern:

```julia
# first generate an algorithm instance
f = Canny()

# then pass the algorithm to `detect_edges`
img_edges = detect_edges(img, f)

# or use in-place version `detect_edges!`
img_edges = similar(img)
detect_edges!(img_edges, img, f)
```


For more examples, please check [`detect_edges`](@ref),
[`detect_edges!`](@ref) and concrete algorithms.

One can also detect edges to subpixel accuracy by specifying
`SubpixelNonmaximaSuppression` as the edge thinning algorithm and using
[`detect_subpixel_edges`](@ref) or [`detect_subpixel_edges!`](@ref). The
function returns an edge image as well as a accompanying matrix of length-2
vectors which, when added to the edge image coordinates, specify the location
of an edge to subpixel precision.

```julia
# first generate an algorithm instance
f = Canny(thinning_algorithm = SubpixelNonmaximaSuppression())

# then pass the algorithm to `detect_subpixel_edges`
img_edges, subpixel_offsets = detect_subpixel_edges(img, f)

# or use in-place version `detect_edges!`
img_edges = similar(img)
subpixel_offsets = zeros(SVector{2,Float64}, axes(img))
detect_edges!(img_edges, subpixel_offsets, img, f)
```

"""
abstract type AbstractEdgeDetectionAlgorithm <: AbstractImageFilter end

detect_edges!(out::Union{GenericGrayImage, AbstractArray{<:Color3}},
              img,
              f::AbstractEdgeDetectionAlgorithm,
              args...; kwargs...) =
        f(out, img, args...; kwargs...)

# TODO: Relax this to all color types
function detect_edges!(img::Union{GenericGrayImage, AbstractArray{<:Color3}},
                       f::AbstractEdgeDetectionAlgorithm,
                       args...; kwargs...)
    tmp = copy(img)
    f(img, tmp, args...; kwargs...)
    return img
end

function detect_edges(::Type{T},
                      img,
                      f::AbstractEdgeDetectionAlgorithm,
                      args...; kwargs...) where T
    out = similar(Array{T}, axes(img))
    detect_edges!(out, img, f, args...; kwargs...)
    return out
end

detect_edges(img::AbstractArray{T},
             f::AbstractEdgeDetectionAlgorithm,
             args...; kwargs...) where T <: Colorant =
        detect_edges(T, img, f, args...; kwargs...)

# Do not promote Number to Gray{<:Number}
detect_edges(img::AbstractArray{T},
             f::AbstractEdgeDetectionAlgorithm,
             args...; kwargs...) where T <: Number =
        detect_edges(T, img, f, args...; kwargs...)




# TODO Take care of this in a separate pull-request.
# Handle instance where the input is a sequence of images.
# detect_edges!(out_sequence::Vector{T},
#           img_sequence,
#           f::AbstractEdgeDetectionAlgorithm,
#           args...; kwargs...) where T <: Union{GenericGrayImage, AbstractArray{<:Color3}} =
#     f(out_sequence, img_sequence, args...; kwargs...)
#
# # TODO: Relax this to all color types
# function detect_edges!(img_sequence::Vector{T},
#                    f::AbstractEdgeDetectionAlgorithm,
#                    args...; kwargs...) where T <: Union{GenericGrayImage, AbstractArray{<:Color3}}
#     tmp = copy(img_sequence)
#     f(img_sequence, tmp, args...; kwargs...)
#     return img_sequence
# end
#
# function detect_edges(::Type{T},
#                   img_sequence::Vector{<:AbstractArray},
#                   f::AbstractEdgeDetectionAlgorithm,
#                   args...; kwargs...) where T
#     N  = length(img_sequence)
#     out_sequence = [similar(Array{T}, axes(img_sequence[n])) for n = 1:N]
#     detect_edges!(out_sequence, img_sequence, f, args...; kwargs...)
#     return out_sequence
# end

detect_edges(img_sequence::Vector{<:AbstractArray{T}},
             f::AbstractEdgeDetectionAlgorithm,
             args...; kwargs...) where T <: Colorant =
         detect_edges(T, img_sequence, f, args...; kwargs...)

# Do not promote Number to Gray{<:Number}
detect_edges(img_sequence::Vector{<:AbstractArray{T}},
             f::AbstractEdgeDetectionAlgorithm,
             args...; kwargs...) where T <: Number =
        detect_edges(T, img_sequence, f, args...; kwargs...)


######
detect_subpixel_edges!(out₁::Union{GenericGrayImage, AbstractArray{<:Color3}},
                       out₂::AbstractArray{<: StaticArray},
                       img,
                       f::AbstractEdgeDetectionAlgorithm,
                       args...; kwargs...) =
    f(out₁, out₂, img, args...; kwargs...)

# TODO: Relax this to all color types
function detect_subpixel_edges!(img::Union{GenericGrayImage, AbstractArray{<:Color3}},
                                f::AbstractEdgeDetectionAlgorithm,
                                args...; kwargs...)
    subpixel_offsets = zeros(SVector{2,Float64}, axes(img))
    tmp = copy(img)
    f(img, subpixel_offsets, tmp, args...; kwargs...)
    return img, subpixel_offsets
end

function detect_subpixel_edges(::Type{T},
                               img,
                               f::AbstractEdgeDetectionAlgorithm,
                               args...; kwargs...) where T
    out = similar(Array{T}, axes(img))
    subpixel_offsets = zeros(SVector{2,Float64}, axes(img))
    detect_subpixel_edges!(out, subpixel_offsets, img, f, args...; kwargs...)
    return out, subpixel_offsets
end

function detect_subpixel_edges(::Type{T₁}, ::Type{T₂},
                               img,
                               f::AbstractEdgeDetectionAlgorithm,
                               args...; kwargs...) where {T₁,T₂}
    out = similar(Array{T₁}, axes(img))
    subpixel_offsets = zeros(SVector{2,T₂}, axes(img))
    detect_subpixel_edges!(out, subpixel_offsets, img, f, args...; kwargs...)
    return out, subpixel_offsets
end

detect_subpixel_edges(img::AbstractArray{T},
                      f::AbstractEdgeDetectionAlgorithm,
                      args...; kwargs...) where T <: Colorant =
         detect_subpixel_edges(T, img, f, args...; kwargs...)

# Do not promote Number to Gray{<:Number}
detect_subpixel_edges(img::AbstractArray{T},
                 f::AbstractEdgeDetectionAlgorithm,
                 args...; kwargs...) where T <: Number =
        detect_subpixel_edges(T, img, f, args...; kwargs...)



# TODO Handle sequences properly in a separate pull-request.

# # Handle instance where the input is a sequence of images.
# detect_subpixel_edges!(out_sequence::Vector{T},
#           img_sequence,
#           f::AbstractEdgeDetectionAlgorithm,
#           args...; kwargs...) where T <: Union{GenericGrayImage, AbstractArray{<:Color3}} =
#     f(out_sequence, img_sequence, args...; kwargs...)
#
# # TODO: Relax this to all color types
# function detect_subpixel_edges!(img_sequence::Vector{T},
#                    f::AbstractEdgeDetectionAlgorithm,
#                    args...; kwargs...) where T <: Union{GenericGrayImage, AbstractArray{<:Color3}}
#     tmp = copy(img_sequence)
#     f(img_sequence, tmp, args...; kwargs...)
#     return img_sequence
# end

# function detect_subpixel_edges(::Type{T},
#                   img_sequence::Vector{<:AbstractArray},
#                   f::AbstractEdgeDetectionAlgorithm,
#                   args...; kwargs...) where T
#     N  = length(img_sequence)
#     out_sequence = [similar(Array{T}, axes(img_sequence[n])) for n = 1:N]
#     detect_subpixel_edges!(out_sequence, img_sequence, f, args...; kwargs...)
#     return out_sequence
# end
#
# detect_subpixel_edges(img_sequence::Vector{<:AbstractArray{T}},
#                  f::AbstractEdgeDetectionAlgorithm,
#                  args...; kwargs...) where T <: Colorant =
#          detect_subpixel_edges(T, img_sequence, f, args...; kwargs...)
#
# # Do not promote Number to Gray{<:Number}
# detect_subpixel_edges(img_sequence::Vector{<:AbstractArray{T}},
#                  f::AbstractEdgeDetectionAlgorithm,
#                  args...; kwargs...) where T <: Number =
#         detect_subpixel_edges(T, img_sequence, f, args...; kwargs...)

### Docstrings

"""
    detect_edges!([out,] img, f::AbstractEdgeDetectionAlgorithm, args...; kwargs...)

Detect edges of `img` using algorithm `f`;  if left unspecified, `f` is assumed
to be [`Canny`](@ref ImageEdgeDetection.Canny).

# Output

If `out` is specified, it will be changed in place. Otherwise `img` will be changed in place.

# Examples

Just simply pass an algorithm to `detect_edges!`:

```julia
img_edges = similar(img)
detect_edges!(img_edges, img, f)
```

For cases you just want to change `img` in place, you don't necessarily need to manually
allocate `img_edges`; just use the convenient method:

```julia
detect_edges!(img, f)
```

See also: [`detect_edges`](@ref)
"""
detect_edges!

"""
    out = detect_edges([T::Type,] img, f::AbstractEdgeDetectionAlgorithm, args...; kwargs...)

Detect edges of `img` using algorithm `f`;  if left unspecified, `f` is assumed
to be [`Canny`](@ref ImageEdgeDetection.Canny).

# Output

The return image `out` is an `Array{T}`. If `T` is not specified, then
it's inferred.

# Examples

Just simply pass the input image and algorithm to `detect_edges`

```julia
f = Canny(spatial_scale = 1.4)
img_edges = detect_edges(img, f)
```

This reads as "`detect_edges` of image `img` using algorithm `f`".

You can also explicitly specify the return type:

```julia
f = Canny(spatial_scale = 1.4)
img_edges_float32 = detect_edges(Gray{Float32}, img, f)
```

See also [`detect_edges!`](@ref) for in-place edge detection.
"""
detect_edges


"""
    detect_subpixel_edges!(out₁, out₂, img, f::AbstractEdgeDetectionAlgorithm, args...; kwargs...)

Detect edges of `img` to subpixel precision using algorithm `f`;  if left
unspecified, `f` is assumed to be [`Canny`](@ref ImageEdgeDetection.Canny).

# Output

The integer components of an edge correspond to non-zero row and column
entries in `out₁`. The accompanying subpixel offsets  are stored in a 2-D array
`out₂` as length-2 vectors. One can recover the  subpixel coordinates by adding
the subpixel offsets to the integer components.

# Examples

Just simply pass an algorithm to `detect_subpixel_edges!`:

```julia
f = Canny(spatial_scale = 1.4, thinning_algorithm = SubpixelNonmaximaSuppression())
img_edges = similar(img)
offsets = zeros(SVector{2,Float64}, axes(img))
detect_edges!(img_edges, offsets, img, f)
```

See also: [`detect_subpixel_edges`](@ref)
"""
detect_subpixel_edges!

"""
    out₁, out₂ = detect_subpixel_edges([T₁::Type, T₂::Type], img, f::AbstractEdgeDetectionAlgorithm, args...; kwargs...)

Detect edges of `img` to subpixel precision using algorithm `f`;  if left
unspecified, `f` is assumed to be [`Canny`](@ref ImageEdgeDetection.Canny).

# Output

The integer components of an edge correspond to non-zero row and column entries
in `out₁` which is an `Array{T₁}`. The accompanying subpixel offsets  are stored
in a 2-D array `out₂` as length-2 vectors (`Array{SVector{2, T₂}}`). One can
recover the  subpixel coordinates by adding the subpixel offsets to the integer
components.

# Examples

Just simply pass the input image and algorithm to `detect_subpixel_edges`

```julia
f = Canny(spatial_scale = 1.4, thinning_algorithm = SubpixelNonmaximaSuppression())
img_edges, offsets = detect_subpixel_edges(img, f)
```

This reads as "`detect_subpixel_edges` of image `img` using algorithm `f`".

You can also explicitly specify the return types:

```julia
f = Canny(spatial_scale = 1.4, thinning_algorithm = SubpixelNonmaximaSuppression())
img_edges, offsets = detect_subpixel_edges(Gray{Float32}, Float32, img, f)
```

See also [`detect_subpixel_edges!`](@ref) for in-place edge detection.
"""
detect_subpixel_edges
