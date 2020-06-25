module ImageEdgeDetection

using ColorVectorSpace
using DataStructures
using ImageCore
using ImageFiltering
using MappedArrays
using Parameters: @with_kw # Same as Base.@kwdef but works on Julia 1.0
using UnPack
using StaticArrays

# TODO: port EdgeDetectionAPI to ImagesAPI
include("EdgeDetectionAPI/EdgeDetectionAPI.jl")
import .EdgeDetectionAPI: AbstractEdgeDetectionAlgorithm,
                          detect_edges, detect_edges!

 import .EdgeDetectionAPI: AbstractEdgeThinningAlgorithm,
                           thin_edges, thin_edges!
# TODO Relax this to all image color types
const GenericGrayImage = AbstractArray{<:Union{Number, AbstractGray}}

include("algorithms/canny.jl")
include("algorithms/nonmaxima_suppression.jl")


export
    # main types and functions
    Canny,
    NonmaximaSuppression,
    thin_edges,
    thin_edges!,
    detect_edges,
    detect_edges!

end # module
