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
    end

    @testset "Types" begin
        # Gray
        img_gray = Gray{N0f8}.(load("algorithms/References/circle.png"))
        f = Canny()

        type_list = generate_test_types([Float32, N0f8], [Gray])
        for T in type_list
            img = T.(img_gray)
            @test_reference "References/circle_edge.png" Gray.(detect_edges(img, f)) by=edge_detection_equality()
        end

        # Color3
        img_color = RGB{Float64}.(load("algorithms/References/circle.png"))
        f = Canny()

        type_list = generate_test_types([Float32, N0f8], [RGB, Lab])
        for T in type_list
            img = T.(img_color)
            @test_reference "References/circle_edge.png" Gray.(detect_edges(img, f)) by=edge_detection_equality()
        end
    end

    @testset "Numerical" begin
        # Check that the image only has ones or zeros.
        img = Gray{N0f8}.(load("algorithms/References/circle.png"))
        f = Canny()
        img₀₁ = detect_edges(img, f)
        non_zeros = findall(x -> x != 0.0 && x != 1.0, img₀₁)
        @test length(non_zeros) == 0
    end

end
