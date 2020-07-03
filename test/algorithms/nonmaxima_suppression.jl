@testset "nonmaxima supression" begin
    @info "Test: NonmaximaSuppression"

    @testset "API" begin
        img = Gray{N0f8}.(load("algorithms/References/circle.png"))
        nms_ref = Gray{N0f8}.(load("algorithms/References/circle_nms.png"))

        f = NonmaximaSuppression()

        g₁, g₂ = imgradients(img, KernelFactors.scharr)
        mag = hypot.(g₁, g₂)

        nms = zeros(eltype(mag), axes(mag))

        f(nms, mag, g₁, g₂)

        for i in CartesianIndices(nms_ref)
            nms_ref[i] == 0.0 ? (@test nms[i] == 0) : (@test nms[i] == mag[i])
        end
    end
end
