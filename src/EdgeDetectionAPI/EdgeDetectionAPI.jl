# This is a temporary module to validate `AbstractImageFilter` idea
# proposed in https://github.com/JuliaImages/ImagesAPI.jl/pull/3
module EdgeDetectionAPI

using ImageCore # ColorTypes is sufficient
using StaticArrays

# TODO Relax this to all image color types
const GenericGrayImage = AbstractArray{<:Union{Number, AbstractGray}}

"""
    AbstractImageAlgorithm

The root of image algorithms type system
"""
abstract type AbstractImageAlgorithm end

"""
    AbstractImageFilter <: AbstractImageAlgorithm

Filters are image algorithms whose input and output are both images
"""
abstract type AbstractImageFilter <: AbstractImageAlgorithm end

include("edge_detection.jl")
include("edge_thinning.jl")

# we do not export any symbols since we don't require
# package developers to implement all the APIs

end  # module EdgeDetectionAPI
