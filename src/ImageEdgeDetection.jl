module ImageEdgeDetection

using ColorVectorSpace
using DataStructures
using ImageCore
using ImageCore.MappedArrays
using ImageFiltering
using Interpolations
using Parameters: @with_kw # Same as Base.@kwdef but works on Julia 1.0
using UnPack
using StaticArrays
using Setfield
using StatsBase

# TODO: port EdgeDetectionAPI to ImagesAPI
include("EdgeDetectionAPI/EdgeDetectionAPI.jl")
import .EdgeDetectionAPI: AbstractEdgeDetectionAlgorithm,
                          detect_edges, detect_edges!,
                          detect_subpixel_edges, detect_subpixel_edges!

import .EdgeDetectionAPI: AbstractEdgeThinningAlgorithm,
                          thin_edges, thin_edges!,
                          thin_subpixel_edges, thin_subpixel_edges!

# TODO Relax this to all image color types
const GenericGrayImage = AbstractArray{<:Union{Number, AbstractGray}}

"""
    Percentile(x)
Indicate that `x` should be interpreted as a [percentile](https://en.wikipedia.org/wiki/Percentile) rather than an absolute value. For example,
- `detect_edges(img, Canny(high = 80, low = 20))` uses absolute thresholds on the edge magnitudes
- `detect_edges(img, Canny(high = Percentile(80), low = Percentile(20)))` uses percentiles of the edge magnitude image as threshold
"""
struct Percentile{T} <: Real
    p::T
end


include("algorithms/nonmaxima_suppression.jl")
include("algorithms/subpixel_nonmaxima_suppression.jl")
include("algorithms/canny.jl")
include("algorithms/gradient_orientation.jl")

# Set the Canny algorithm as the default edge detection algorithm.
detect_edges(img::AbstractArray,
             args...; kwargs...) =
        detect_edges(img, Canny(thinning_algorithm = NonmaximaSuppression()), args...; kwargs...)

detect_subpixel_edges(img::AbstractArray, args...; kwargs...)  =
        detect_subpixel_edges(img, Canny(thinning_algorithm = SubpixelNonmaximaSuppression()), args...; kwargs...)

export
    # main types and functions
    Canny,
    NonmaximaSuppression,
    SubpixelNonmaximaSuppression,
    OrientationConvention,
    Percentile,
    thin_edges,
    thin_edges!,
    thin_subpixel_edges,
    thin_subpixel_edges!,
    detect_edges,
    detect_edges!,
    detect_subpixel_edges,
    detect_subpixel_edges!,
    detect_gradient_orientation,
    detect_gradient_orientation!

end # module
