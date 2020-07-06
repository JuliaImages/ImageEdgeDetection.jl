# usage example for package developer:
#
#     import EdgeDetectionAPI: AbstractEdgeDetectionAlgorithm,
#                             detect_edges, detect_edges!

"""
    AbstractEdgeDetectionAlgorithm <: AbstractImageFilter

The root type for `ImageEdgeDetection` package.

Any concrete edge detection algorithm shall subtype it to support
[`detect_edges`](@ref) and [`detect_edges!`](@ref) APIs.

# Examples

All edge detection algorithms in ImageEdgeDetection are called in the
following pattern:

```julia
# first generate an algorithm instance
f = Canny()

# then pass the algorithm to `detect_edges`
img_edges, list_edges = detect_edges(img, f)

# or use in-place version `detect_edges!`
img_edges = similar(img)
list_edges = detect_edges!(img_edges, img, f)
```


For more examples, please check [`detect_edges`](@ref),
[`detect_edges!`](@ref) and concrete algorithms.
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


# Handle instance where the input is a sequence of images.
detect_edges!(out_sequence::Vector{T},
          img_sequence,
          f::AbstractEdgeDetectionAlgorithm,
          args...; kwargs...) where T <: Union{GenericGrayImage, AbstractArray{<:Color3}} =
    f(out_sequence, img_sequence, args...; kwargs...)

# TODO: Relax this to all color types
function detect_edges!(img_sequence::Vector{T},
                   f::AbstractEdgeDetectionAlgorithm,
                   args...; kwargs...) where T <: Union{GenericGrayImage, AbstractArray{<:Color3}}
    tmp = copy(img_sequence)
    f(img_sequence, tmp, args...; kwargs...)
    return img_sequence
end

function detect_edges(::Type{T},
                  img_sequence::Vector{<:AbstractArray},
                  f::AbstractEdgeDetectionAlgorithm,
                  args...; kwargs...) where T
    N  = length(img_sequence)
    out_sequence = [similar(Array{T}, axes(img_sequence[n])) for n = 1:N]
    detect_edges!(out_sequence, img_sequence, f, args...; kwargs...)
    return out_sequence
end

detect_edges(img_sequence::Vector{<:AbstractArray{T}},
                 f::AbstractEdgeDetectionAlgorithm,
                 args...; kwargs...) where T <: Colorant =
         detect_edges(T, img_sequence, f, args...; kwargs...)

# Do not promote Number to Gray{<:Number}
detect_edges(img_sequence::Vector{<:AbstractArray{T}},
                 f::AbstractEdgeDetectionAlgorithm,
                 args...; kwargs...) where T <: Number =
        detect_edges(T, img_sequence, f, args...; kwargs...)

### Docstrings

"""
    detect_edges!([out,] img, f::AbstractEdgeDetectionAlgorithm, args...; kwargs...)

Detect edges of `img` using algorithm `f`.

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
    detect_edges([T::Type,] img, f::AbstractEdgeDetectionAlgorithm, args...; kwargs...)

Detect edges of `img` using algorithm `f`.

# Output

The return image `img_edges` is an `Array{T}`.

If `T` is not specified, then it's inferred.
# Examples

Just simply pass the input image and algorithm to `detect_edges`

```julia
img_edges = detect_edges(img, f)
```

This reads as "`detect_edges` of image `img` using algorithm `f`".

You can also explicitly specify the return type:

```julia
img_edges_float32 = detect_edges(Gray{Float32}, img, f)
```

See also [`detect_edges!`](@ref) for in-place edge detection.
"""
detect_edges
