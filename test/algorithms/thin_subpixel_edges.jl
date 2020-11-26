@testset "thin_subpixel_edges" begin
    @info "Test: thin_subpixel_edges"

    @testset "API" begin
        img_ref = Gray{N0f8}.(testimage("lake_gray.tif"))
        img = copy(img_ref)

        f = SubpixelNonmaximaSuppression()
        g₁, g₂ = imgradients(img, KernelFactors.scharr)
        mag = hypot.(g₁, g₂)

        g₁_cpy = copy(g₁)
        g₂_cpy = copy(g₂)
        mag_cpy = copy(mag)

        thinned_edges₀ = zeros(eltype(mag), axes(mag))
        offsets₀ = zeros(SVector{2,Float64}, axes(mag))
        thin_subpixel_edges!(thinned_edges₀, offsets₀, mag, g₁, g₂, f)
        thinned_edges₁, offsets₁ = thin_subpixel_edges(mag, g₁, g₂, f)

        @test mag == mag_cpy # mag unchanged
        @test g₁ == g₁_cpy # g₁ unchanged
        @test g₂ == g₂_cpy # g₂ unchanged

        @test all(map(x-> .!all(isnan.(x)), offsets₀))
        @test all(map(x-> .!all(isnan.(x)), offsets₁))

        @test all(offsets₀ .== offsets₁)
        @test thinned_edges₀ == thinned_edges₁
        @test eltype(thinned_edges₀) == eltype(mag)
        @test eltype(thinned_edges₁) == eltype(mag)

        for T in [Float16, Float32, Float64]
            thinned_edges₂ = zeros(T, axes(mag))
            offsets₂ = zeros(SVector{2,T}, axes(mag))
            thin_subpixel_edges!(thinned_edges₂, offsets₂, mag, g₁, g₂, f)
            @test eltype(thinned_edges₂) == T
            @test eltype(offsets₂) == SVector{2,T}

            thinned_edges₃, offsets₃ = thin_subpixel_edges(T, SVector{2, T}, mag, g₁, g₂, f)
            @test eltype(thinned_edges₃) == T
            @test eltype(offsets₃) == SVector{2, T}
        end
    end

    @testset "Numerical" begin
        img = Gray{N0f8}.(load("algorithms/References/circle.png"))
        nms_ref = Gray{N0f8}.(load("algorithms/References/circle_nms.png"))

        f = SubpixelNonmaximaSuppression()

        g₁, g₂ = imgradients(img, KernelFactors.scharr)
        mag = hypot.(g₁, g₂)

        thinned_edges₀, subpixel_offsets₀ = thin_subpixel_edges(mag, g₁, g₂, f)

        for i in CartesianIndices(nms_ref)
            nms_ref[i] == 0.0 ? (@test thinned_edges₀[i] == 0) : (@test thinned_edges₀[i] == mag[i])
            thinned_edges₀[i] == 0.0 ? (@test subpixel_offsets₀[i] == SVector(0.0, 0.0)) : (@test subpixel_offsets₀[i] != SVector(0.0, 0.0))
        end
    end
end
