@testset "thin_edges" begin
    @info "Test: thin_edges"

    @testset "API" begin
        img_ref = Gray{N0f8}.(testimage("lake_gray.tif"))
        img = copy(img_ref)

        f = NonmaximaSuppression()
        g₁, g₂ = imgradients(img, KernelFactors.scharr)
        mag = hypot.(g₁, g₂)

        g₁_cpy = copy(g₁)
        g₂_cpy = copy(g₂)
        mag_cpy = copy(mag)

        thinned_edges₀ = zeros(eltype(mag), axes(mag))
        thin_edges!(thinned_edges₀, mag, g₁, g₂, f)
        thinned_edges₁ = thin_edges(mag, g₁, g₂, f)

        @test mag == mag_cpy # mag unchanged
        @test g₁ == g₁_cpy # g₁ unchanged
        @test g₂ == g₂_cpy # g₂ unchanged

        @test thinned_edges₀ == thinned_edges₁
        @test eltype(thinned_edges₀) == eltype(mag)
        @test eltype(thinned_edges₁) == eltype(mag)

        thin_edges!(mag, g₁, g₂, f)
        @test mag != mag_cpy
        @test thinned_edges₀ == mag

        mag = copy(mag_cpy)
        for T in generate_test_types([Float16, Float32, Float64], [Gray])
            thinned_edges₂ = zeros(T, axes(mag))
            thin_edges!(thinned_edges₂, mag, g₁, g₂, f)
            @test eltype(thinned_edges₂) == T
            @test eltype(thin_edges(T, mag, g₁, g₂, f)) == T
        end
    end

    @testset "Numerical" begin
        img = Gray{N0f8}.(load("algorithms/References/circle.png"))
        nms_ref = Gray{N0f8}.(load("algorithms/References/circle_nms.png"))

        f = NonmaximaSuppression()

        g₁, g₂ = imgradients(img, KernelFactors.scharr)
        mag = hypot.(g₁, g₂)

        thinned_edges₀ = zeros(eltype(mag), axes(mag))
        thin_edges!(thinned_edges₀, mag, g₁, g₂, f)

        thinned_edges₁ = thin_edges(mag, g₁, g₂, f)

        for i in CartesianIndices(nms_ref)
            nms_ref[i] == 0.0 ? (@test thinned_edges₀[i] == 0) : (@test thinned_edges₀[i] == mag[i])
            nms_ref[i] == 0.0 ? (@test thinned_edges₁[i] == 0) : (@test thinned_edges₁[i] == mag[i])
        end
    end
end
