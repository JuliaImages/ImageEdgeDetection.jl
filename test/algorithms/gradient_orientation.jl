@testset "detect_gradient_orientation" begin
    @info "Test: detect_gradient_orientation"

    @testset "Numerical" begin
        # Points on a compass in the sequence: E, NE, N, NW, W, SW, S, SE
        # expressed in raster coordinates (increasing rows, increasing columns)
        g₁ = [0, -1, -1, -1, 0, 1, 1, 1]
        g₂ = [1, 1, 0, -1, -1, -1, 0, 1]

        # Measuring from East in counter-clockwise manner in degrees.
        orientation_convention = OrientationConvention(in_radians = false,
                                                       is_clockwise = false,
                                                       compass_direction = 'E')
        out = detect_gradient_orientation(g₁, g₂, orientation_convention)
        @test all(out .== [0.0,  45.0,  90.0,  135.0,  180.0,  225.0,  270.0,  315.0])


        # Measuring from East in counter-clockwise manner in radians.
        orientation_convention = OrientationConvention(in_radians = true,
                                                       is_clockwise = false,
                                                       compass_direction = 'E')
        out = detect_gradient_orientation(g₁, g₂, orientation_convention)
        @test all(out .== deg2rad.([0.0,  45.0,  90.0,  135.0,  180.0,  225.0,  270.0,  315.0]))

        # Measuring from South in counter-clockwise manner in degrees.
        orientation_convention = OrientationConvention(in_radians = false,
                                                       is_clockwise = false,
                                                       compass_direction = 'S')
        out = detect_gradient_orientation(g₁, g₂, orientation_convention)
        @test all(out .== [90.0,  135.0,  180.0,  225.0,  270.0,  315.0,  0.0,  45.0])

        # Measuring from South in counter-clockwise manner in radians.
        orientation_convention = OrientationConvention(in_radians = true,
                                                       is_clockwise = false,
                                                       compass_direction = 'S')
        out = detect_gradient_orientation(g₁, g₂, orientation_convention)
        @test all(out .== deg2rad.([90.0,  135.0,  180.0,  225.0,  270.0,  315.0,  0.0,  45.0]))

        # Measuring from West in counter-clockwise manner in degrees.
        orientation_convention = OrientationConvention(in_radians = false,
                                                       is_clockwise = false,
                                                       compass_direction = 'W')
        out = detect_gradient_orientation(g₁, g₂, orientation_convention)
        @test all(out .== [180.0,  225.0,  270.0,  315.0,  360.0,  45.0,  90.0,  135.0])

        # Measuring from West in counter-clockwise manner in radians.
        orientation_convention = OrientationConvention(in_radians = true,
                                                       is_clockwise = false,
                                                       compass_direction = 'W')
        out = detect_gradient_orientation(g₁, g₂, orientation_convention)
        @test all(out .== deg2rad.([180.0,  225.0,  270.0,  315.0,  360.0,  45.0,  90.0,  135.0]))

        # Measuring from N in counter-clockwise manner degrees.
        orientation_convention = OrientationConvention(in_radians = false,
                                                       is_clockwise = false,
                                                       compass_direction = 'N')
        out = detect_gradient_orientation(g₁, g₂, orientation_convention)
        @test all(out .== [270.0,  315.0,  0.0,  45.0,  90.0,  135.0,  180.0,  225.0])

        # Measuring from N in counter-clockwise manner in radians.
        orientation_convention = OrientationConvention(in_radians = true,
                                                       is_clockwise = false,
                                                       compass_direction = 'N')
        out = detect_gradient_orientation(g₁, g₂, orientation_convention)
        @test all(out .== deg2rad.([270.0,  315.0,  0.0,  45.0,  90.0,  135.0,  180.0,  225.0]))

        # Measuring from East in clockwise manner.
        orientation_convention = OrientationConvention(in_radians = false,
                                                       is_clockwise = true,
                                                       compass_direction = 'E')
        out = detect_gradient_orientation(g₁, g₂, orientation_convention)
        @test all(out .== [0.0,  315.0,  270.0,  225.0,  180.0,  135.0,  90.0,  45.0])

        # Measuring from East in clockwise manner.
        orientation_convention = OrientationConvention(in_radians = true,
                                                       is_clockwise = true,
                                                       compass_direction = 'E')
        out = detect_gradient_orientation(g₁, g₂, orientation_convention)
        @test all(out .== deg2rad.([0.0,  315.0,  270.0,  225.0,  180.0,  135.0,  90.0,  45.0]))

        # Measuring from South in clockwise manner in degrees.
        orientation_convention = OrientationConvention(in_radians = false,
                                                       is_clockwise = true,
                                                       compass_direction = 'S')
        out = detect_gradient_orientation(g₁, g₂, orientation_convention)
        @test all(out .== [270.0,  225.0,  180.0,  135.0,  90.0,  45.0,  0.0,  315.0])

        # Measuring from South in clockwise manner in radians.
        orientation_convention = OrientationConvention(in_radians = true,
                                                       is_clockwise = true,
                                                       compass_direction = 'S')
        out = detect_gradient_orientation(g₁, g₂, orientation_convention)
        @test all(out .== deg2rad.([270.0,  225.0,  180.0,  135.0,  90.0,  45.0,  0.0,  315.0]))

        # Measuring from West in clockwise manner in degrees.
        orientation_convention = OrientationConvention(in_radians = false,
                                                       is_clockwise = true,
                                                       compass_direction = 'W')
        out = detect_gradient_orientation(g₁, g₂, orientation_convention)
        @test all(out .== [180.0,  135.0,  90.0,  45.0,  0.0,  315.0,  270.0,  225.0])

        # Measuring from West in clockwise manner in radians.
        orientation_convention = OrientationConvention(in_radians = true,
                                                       is_clockwise = true,
                                                       compass_direction = 'W')
        out = detect_gradient_orientation(g₁, g₂, orientation_convention)
        @test all(out .== deg2rad.([180.0,  135.0,  90.0,  45.0,  0.0,  315.0,  270.0,  225.0]))

        # Measuring from North in clockwise manner in degrees.
        orientation_convention = OrientationConvention(in_radians = false,
                                                       is_clockwise = true,
                                                       compass_direction = 'N')
        out = detect_gradient_orientation(g₁, g₂, orientation_convention)
        @test all(out .== [90.0,  45.0,  0.0,  315.0,  270.0,  225.0,  180.0,  135.0])

        # Measuring from North in clockwise manner in radians.
        orientation_convention = OrientationConvention(in_radians = true,
                                                       is_clockwise = true,
                                                       compass_direction = 'N')
        out = detect_gradient_orientation(g₁, g₂, orientation_convention)
        @test all(out .== deg2rad.([90.0,  45.0,  0.0,  315.0,  270.0,  225.0,  180.0,  135.0]))

        # Verify default setting.
        # Measuring from South in counter-clockwise manner in radians.
        out = detect_gradient_orientation(g₁, g₂)
        @test all(out .== deg2rad.([90.0,  135.0,  180.0,  225.0,  270.0,  315.0,  0.0,  45.0]))
    end

    @testset "Undefined Angles" begin
        # When the gradient magnitude is close to zero the gradient orientation
        # is undefined and we return a "sentinel" value of 360 degrees or
        # 2π.
        out₁ = detect_gradient_orientation([0.0], [0.0], OrientationConvention(in_radians = false))
        out₂ = detect_gradient_orientation([0.0], [0.0], OrientationConvention(in_radians = true))
        @test out₁ == [360]
        @test out₂ == [2π]

        detect_gradient_orientation!(out₂, [0.0], [0.0])
        @test out₂ == [2π]
    end

    @testset "Warning" begin
        convention = OrientationConvention(compass_direction = 'X')
        @test_logs (:warn, "Unrecognised compass_direction... using a default direction of south (S).")  detect_gradient_orientation([0.0], [0.0], convention)
    end

end
