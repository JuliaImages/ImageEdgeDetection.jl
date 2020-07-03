using ImageEdgeDetection
using Test, TestImages
using ImageDraw
using FileIO
using ImageIO
using ImageFiltering
using ImageCore
using ReferenceTests

include("testutils.jl")

@testset "ImageEdgeDetection.jl" begin
    include("util.jl")

    include("algorithms/canny.jl")
    include("algorithms/nonmaxima_suppression.jl")
end

nothing
