@testset "subpixel nonmaxima supression" begin
    @info "Test: SubpixelNonmaximaSuppression"

    @testset "Numerical" begin
        img = Gray{N0f8}.(load("algorithms/References/circle.png"))
        nms_ref = Gray{N0f8}.(load("algorithms/References/circle_nms.png"))

        f = SubpixelNonmaximaSuppression()

        g₁, g₂ = imgradients(img, KernelFactors.scharr)
        mag = hypot.(g₁, g₂)

        nms = zeros(eltype(mag), axes(mag))
        offsets = zeros(SVector{2,Float64}, axes(mag))

        f(nms, offsets, mag, g₁, g₂)

        for i in CartesianIndices(nms_ref)
            nms_ref[i] == 0.0 ? (@test nms[i] == 0) : (@test nms[i] == mag[i])
            nms[i] == 0.0 ? (@test offsets[i] == SVector(0.0, 0.0)) : (@test offsets[i] != SVector(0.0, 0.0))
        end
    end
end
