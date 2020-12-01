@testset "canny" begin
    @info "Test: Canny"

    @testset "API" begin
        img_gray = Gray{N0f8}.(load("algorithms/References/circle.png"))
        img = copy(img_gray)

        # Detect edges
        f = Canny()
        edges_img_1 = detect_edges(img, f)
        @test img == img_gray # img unchanged
        @test eltype(edges_img_1) == Gray{N0f8}

        edges_img_2 = detect_edges(Gray{Bool}, img, f)
        @test img == img_gray # img unchanged
        @test eltype(edges_img_2) == Gray{Bool}

        edges_img_3 = similar(img, Bool)
        detect_edges!(edges_img_3, img, f)
        @test img == img_gray # img unchanged
        @test eltype(edges_img_3) == Bool

        edges_img_4 = copy(img_gray)
        detect_edges!(edges_img_4, f)
        @test eltype(edges_img_4) == Gray{N0f8}

        @test edges_img_1 == edges_img_2
        @test edges_img_1 == edges_img_3
        @test edges_img_1 == edges_img_4

        for T in generate_test_types([Float32, N0f8, Bool], [Gray])
            @test eltype(detect_edges(T, img, f)) == T
        end

        # Detect subpixel edges
        img_gray = Gray{N0f8}.(load("algorithms/References/circle.png"))
        img = copy(img_gray)
        f = Canny(thinning_algorithm = SubpixelNonmaximaSuppression())
        edges_img_1, offsets_1 = detect_subpixel_edges(img, f)
        @test img == img_gray # img unchanged
        @test eltype(edges_img_1) == Gray{N0f8}
        @test eltype(offsets_1) == SVector{2, Float64}

        edges_img_2, offsets_2 = detect_subpixel_edges(Gray{Bool}, img, f)
        @test img == img_gray # img unchanged
        @test eltype(edges_img_2) == Gray{Bool}
        @test eltype(offsets_2) == SVector{2, Float64}

        edges_img_3, offsets_3 = detect_subpixel_edges(Gray{Bool}, Float32, img, f)
        @test img == img_gray # img unchanged
        @test eltype(edges_img_3) == Gray{Bool}
        @test eltype(offsets_3) == SVector{2, Float32}

        edges_img_4 = similar(img, Bool)
        offsets_4 = similar(offsets_3)
        detect_subpixel_edges!(edges_img_4, offsets_4, img, f)
        @test img == img_gray # img unchanged
        @test eltype(edges_img_4) == Bool
        @test offsets_4  == offsets_3
        @test eltype(offsets_4) == SVector{2, Float32}

        edges_img_5 = copy(img_gray)
        offsets_5 = similar(offsets_1)
        detect_subpixel_edges!(edges_img_5, offsets_5, img, f)
        @test eltype(edges_img_5) == Gray{N0f8}
        @test eltype(offsets_5) == SVector{2, Float64}

        @test edges_img_1 == edges_img_2
        @test edges_img_1 == edges_img_3
        @test edges_img_1 == edges_img_4
        @test edges_img_1 == edges_img_5

        @test offsets_1  == offsets_2
        @test offsets_1  ≈ offsets_3
        @test offsets_1  ≈ offsets_4
        @test offsets_1  == offsets_5
    end

    @testset "Offset Arrays" begin
        img_gray = Gray{N0f8}.(load("algorithms/References/circle.png"))
        img_gray_offset = OffsetArray(img_gray, -24:25, -24:25)

        f = Canny()
        edges_img_1 = detect_edges(img_gray_offset, f)
        @test eltype(edges_img_1) == Gray{N0f8}
        @test axes(edges_img_1) == axes(img_gray_offset)

        g = Canny(thinning_algorithm = SubpixelNonmaximaSuppression())
        edges_img_2, offsets = detect_subpixel_edges(img_gray_offset, g)

        @test edges_img_1 == edges_img_2
        @test axes(edges_img_2) == axes(img_gray_offset)
        @test axes(offsets) == axes(img_gray_offset)
    end



    @testset "Keywords" begin
        img_gray = Gray{N0f8}.(load("algorithms/References/circle.png"))
        img = copy(img_gray)
        low = [0.000009765625, Percentile(20)]
        high = [0.01953125, Percentile(80)]
        spatial_scale = [1.0, 1.4]
        # Detect edges
        for i = 1:2
            f = Canny(spatial_scale = spatial_scale[i], low = low[i], high = high[i])
            @test_reference "References/circle_edge.png" Gray.(detect_edges(img, f)) by=edge_detection_equality()
            @test_reference "References/circle_edge.png" Gray.(detect_edges(img * 0.1, f)) by=edge_detection_equality() # Working with small magnitudes
        end

        # Detect subpixel edges
        for i = 1:2
            g = Canny(spatial_scale = spatial_scale[i], low = low[i], high = high[i], thinning_algorithm = SubpixelNonmaximaSuppression())
            out1, offsets1 = detect_subpixel_edges(img, g)
            out2, offsets2 = detect_subpixel_edges(img, g)
            @test_reference "References/circle_edge.png" Gray.(out1) by=edge_detection_equality()
            @test_reference "References/circle_edge.png" Gray.(out2) by=edge_detection_equality() # Working with small magnitudes
        end
    end

    @testset "Types" begin
        # Gray
        img_gray = Gray{N0f8}.(load("algorithms/References/circle.png"))
        f = Canny()
        g = Canny(thinning_algorithm = SubpixelNonmaximaSuppression())

        type_list = generate_test_types([Float32, N0f8], [Gray])
        for T in type_list
            img = T.(img_gray)
            out1 = Gray.(detect_edges(img, f))
            out2, offsets2 = detect_subpixel_edges(img, g)
            @test_reference "References/circle_edge.png" out1 by=edge_detection_equality()
            @test_reference "References/circle_edge.png" Gray.(out2) by=edge_detection_equality()
        end

        # Color3
        img_color = RGB{Float64}.(load("algorithms/References/circle.png"))
        f = Canny()
        g = Canny(thinning_algorithm = SubpixelNonmaximaSuppression())

        type_list = generate_test_types([Float32, N0f8], [RGB, Lab])
        for T in type_list
            img = T.(img_color)
            out1 = Gray.(detect_edges(img, f))
            out2, offsets2 = detect_subpixel_edges(img, g)
            @test_reference "References/circle_edge.png" out1 by=edge_detection_equality()
            @test_reference "References/circle_edge.png" Gray.(out2) by=edge_detection_equality()
        end
    end

    @testset "Default Values" begin
        img = Gray{N0f8}.(load("algorithms/References/circle.png"))
        out, offsets = detect_subpixel_edges(img)
        @test_reference "References/circle_edge.png" Gray.(detect_edges(img)) by=edge_detection_equality()
        @test_reference "References/circle_edge.png" Gray.(out) by=edge_detection_equality()
    end

    @testset "Numerical" begin
        # Check that the image only has ones or zeros.
        img = Gray{N0f8}.(load("algorithms/References/circle.png"))
        f = Canny()
        img₀₁ = detect_edges(img, f)
        non_zeros = findall(x -> x != 0.0 && x != 1.0, img₀₁)
        @test length(non_zeros) == 0
    end

    @testset "Subpixel Accuracy on Circle Image" begin
        # Equation of circle (x-a)^2 + (y - b)^2 = r^2 and corresponding image.
        a = 25
        b = 25
        r = 20
        img = Gray{N0f8}.(load("algorithms/References/circle.png"))
        algo = Canny(spatial_scale = 1.4, thinning_algorithm = SubpixelNonmaximaSuppression())
        nms, offsets = detect_subpixel_edges(img, algo)

        # Verify that the subpixel coordinates more accurately satisfy the
        # circle equation.
        total₁ = 0.0
        total₂ = 0.0
        N = sum(nms)
        for i in CartesianIndices(nms)
            y,x = i.I
            δy, δx = offsets[i]
            y′ = y + δy
            x′ = x + δx
            if nms[i] == 1
                # Degree to which pixel coordinates fail to satisfy circle
                # equation.
                val₁ = abs((x-a)^2 + (y - b)^2 - r^2)
                total₁ = total₁ + val₁

                # Degree to which subpixel coordinates fail to satisfy circle
                # equation.
                val₂ = abs((x′-a)^2 + (y′ - b)^2 - r^2)
                total₂ = total₂ + val₂
            end
        end
        # The subpixel coordinates yield a better fit.
        @test total₂ <  total₁
        @test total₂ / N < 6.72
    end

    @testset "Subpixel Accuracy on Synthetic Image" begin
        # Test image for which we want to detect edges.
        img  = [0.5  0.5   0.7  0.6  0.6
                0.5  0.5   0.7  0.6  0.6
                0.5  0.5   0.7  0.6  0.6
                0.5  0.5   0.7  0.6  0.6
                0.5  0.5   0.7  0.6  0.6]

        thinning_algorithm = SubpixelNonmaximaSuppression()

        # Calculate the gradient vector at each position of the filtered image.
        # The derivatives are taken with respect to the first and second
        # dimension (rows first, then columns).
        g₁, g₂ = imgradients(img, KernelFactors.scharr)
        # Gradient magnitude
        mag = hypot.(g₁, g₂)
        # Isolate local maxima of gradient magnitude by “non-maximum
        # suppression” along the local gradient direction and store location of
        # edge to subpixel precision.
        nms, offsets = thin_subpixel_edges(mag, g₁, g₂, thinning_algorithm)

        # This is the expected result for the non-maxima suppression.
        target_nms = [0.0  0.1   0.0  0.05  0.0
                      0.0  0.1   0.0  0.05  0.0
                      0.0  0.1   0.0  0.05  0.0
                      0.0  0.1   0.0  0.05  0.0
                      0.0  0.1   0.0  0.05  0.0]

        for i in CartesianIndices(target_nms)
            @test nms[i] ≈ target_nms[i]
        end

        # Verify the correctness of the subpixel refinement.
        for r = 1:5
            @test all(offsets[r, 1] .≈ SVector(0.0, 0.0))
            @test all(offsets[r, 2] .≈ SVector(0.0, 0.16666666666666666))
            @test all(offsets[r, 3] .≈ SVector(0.0, 0.0))
            @test all(offsets[r, 4] .≈ SVector(0.0, -0.5))
            @test all(offsets[r, 5] .≈ SVector(0.0, 0.0))
        end

        # Verify correctness on a 90 degree rotated variant of the synthetic
        # image
        img = img'
        # Calculate the gradient vector at each position of the filtered image.
        # The derivatives are taken with respect to the first and second
        # dimension (rows first, then columns).
        g₁, g₂ = imgradients(img, KernelFactors.scharr)
        # Gradient magnitude
        mag = hypot.(g₁, g₂)
        # Isolate local maxima of gradient magnitude by “non-maximum
        # suppression” along the local gradient direction and store location of
        # edge to subpixel precision.
        nms, offsets = thin_subpixel_edges(mag, g₁, g₂, thinning_algorithm)
        target_nms = target_nms'
        for i in CartesianIndices(target_nms)
            @test nms[i] ≈ target_nms[i]
        end
        for c = 1:5
            @test all(offsets[1, c] .≈ SVector(0.0, 0.0))
            @test all(offsets[2, c] .≈ SVector(0.16666666666666666, 0.0))
            @test all(offsets[3, c] .≈ SVector(0.0, 0.0))
            @test all(offsets[4, c] .≈ SVector(-0.5, 0.0))
            @test all(offsets[5, c] .≈ SVector(0.0, 0.0))
        end
    end

end
