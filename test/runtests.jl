using ImageEdgeDetection

using FileIO
using ImageDraw
using ImageFiltering
using ImageCore
using OffsetArrays
using ReferenceTests
using StaticArrays
using Test
using TestImages

include("testutils.jl")

@testset "ImageEdgeDetection.jl" begin
    include("util.jl")

    include("algorithms/canny.jl")
    include("algorithms/thin_edges.jl")
    include("algorithms/thin_subpixel_edges.jl")
    include("algorithms/nonmaxima_suppression.jl")
    include("algorithms/subpixel_nonmaxima_suppression.jl")
end

nothing
