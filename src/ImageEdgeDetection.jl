module ImageEdgeDetection

using ColorVectorSpace
using DataStructures
using ImageCore
using ImageFiltering
using Interpolations
using MappedArrays
using Parameters: @with_kw # Same as Base.@kwdef but works on Julia 1.0
using UnPack
using StaticArrays
using Setfield
using StatsBase

# TODO: port EdgeDetectionAPI to ImagesAPI
include("EdgeDetectionAPI/EdgeDetectionAPI.jl")
import .EdgeDetectionAPI: AbstractEdgeDetectionAlgorithm,
                          detect_edges, detect_edges!

 import .EdgeDetectionAPI: AbstractEdgeThinningAlgorithm,
                           thin_edges, thin_edges!
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
include("algorithms/canny.jl")

export
    # main types and functions
    Canny,
    NonmaximaSuppression,
    Percentile,
    thin_edges,
    thin_edges!,
    detect_edges,
    detect_edges!

end # module
