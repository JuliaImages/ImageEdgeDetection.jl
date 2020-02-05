# usage example for package developer:
#
#     import EdgeDetectionAPI: AbstractEdgeThinningAlgorithm,
#                             thin_edges, thin_edges!

"""
    AbstractEdgeThinningAlgorithm <: AbstractImageFilter

The root type for `ImageEdgeDetection` package.

Any concrete edge thinning algorithm shall subtype it to support
[`thin_edges`](@ref) and [`thin_edges!`](@ref) APIs.

# Examples

All edge thinning algorithms in ImageEdgeDetection are called in the
following pattern:

```julia
# first generate an algorithm instance
f = NonmaximaSuppression()

# then pass the algorithm to `thin_edges`
img_edges = thin_edges(img, f)

# or use in-place version `thin_edges!`
img_edges = similar(img)
thin_edges!(img_edges, img, f)
```


For more examples, please check [`thin_edges`](@ref),
[`thin_edges!`](@ref) and concrete algorithms.
"""
abstract type AbstractEdgeThinningAlgorithm <: AbstractImageFilter end

thin_edges!(out::Union{GenericGrayImage, AbstractArray{<:Color3}},
          img,
          f::AbstractEdgeThinningAlgorithm,
          args...; kwargs...) =
    f(out, img, args...; kwargs...)

# TODO: Relax this to all color types
function thin_edges!(img::Union{GenericGrayImage, AbstractArray{<:Color3}},
                   f::AbstractEdgeThinningAlgorithm,
                   args...; kwargs...)
    tmp = copy(img)
    f(img, tmp, args...; kwargs...)
    return img
end

function thin_edges(::Type{T},
                  img,
                  f::AbstractEdgeThinningAlgorithm,
                  args...; kwargs...) where T
    out = similar(Array{T}, axes(img))
    thin_edges!(out, img, f, args...; kwargs...)
    return out
end

thin_edges(img::AbstractArray{T},
                 f::AbstractEdgeThinningAlgorithm,
                 args...; kwargs...) where T <: Colorant =
         thin_edges(T, img, f, args...; kwargs...)

# Do not promote Number to Gray{<:Number}
thin_edges(img::AbstractArray{T},
                 f::AbstractEdgeThinningAlgorithm,
                 args...; kwargs...) where T <: Number =
        thin_edges(T, img, f, args...; kwargs...)


# Handle instance where the input is a sequence of images.
thin_edges!(out_sequence::Vector{T},
          img_sequence,
          f::AbstractEdgeThinningAlgorithm,
          args...; kwargs...) where T <: Union{GenericGrayImage, AbstractArray{<:Color3}} =
    f(out_sequence, img_sequence, args...; kwargs...)

# TODO: Relax this to all color types
function thin_edges!(img_sequence::Vector{T},
                   f::AbstractEdgeThinningAlgorithm,
                   args...; kwargs...) where T <: Union{GenericGrayImage, AbstractArray{<:Color3}}
    tmp = copy(img_sequence)
    f(img_sequence, tmp, args...; kwargs...)
    return img_sequence
end

function thin_edges(::Type{T},
                  img_sequence::Vector{<:AbstractArray},
                  f::AbstractEdgeThinningAlgorithm,
                  args...; kwargs...) where T
    N  = length(img_sequence)
    out_sequence = [similar(Array{T}, axes(img_sequence[n])) for n = 1:N]
    thin_edges!(out_sequence, img_sequence, f, args...; kwargs...)
    return out_sequence
end

thin_edges(img_sequence::Vector{<:AbstractArray{T}},
                 f::AbstractEdgeThinningAlgorithm,
                 args...; kwargs...) where T <: Colorant =
         thin_edges(T, img_sequence, f, args...; kwargs...)

# Do not promote Number to Gray{<:Number}
thin_edges(img_sequence::Vector{<:AbstractArray{T}},
                 f::AbstractEdgeThinningAlgorithm,
                 args...; kwargs...) where T <: Number =
        thin_edges(T, img_sequence, f, args...; kwargs...)

### Docstrings

"""
    thin_edges!([out,] img, f::AbstractEdgeThinningAlgorithm, args...; kwargs...)

Detect edges of `img` using algorithm `f`.

# Output

If `out` is specified, it will be changed in place. Otherwise `img` will be changed in place.

# Examples

Just simply pass an algorithm to `thin_edges!`:

```julia
img_edges = similar(img)
thin_edges!(img_edges, img, f)
```

For cases you just want to change `img` in place, you don't necessarily need to manually
allocate `img_edges`; just use the convenient method:

```julia
thin_edges!(img, f)
```

See also: [`thin_edges`](@ref)
"""
thin_edges!

"""
    thin_edges([T::Type,] img, f::AbstractEdgeThinningAlgorithm, args...; kwargs...)

Detect edges of `img` using algorithm `f`.

# Output

The return image `img_edges` is an `Array{T}`.

If `T` is not specified, then it's inferred.
# Examples

Just simply pass the input image and algorithm to `thin_edges`

```julia
img_edges = thin_edges(img, f)
```

This reads as "`thin_edges` of image `img` using algorithm `f`".

You can also explicitly specify the return type:

```julia
img_edges_float32 = thin_edges(Gray{Float32}, img, f)
```

See also [`thin_edges!`](@ref) for in-place edge thinning.
"""
thin_edges
