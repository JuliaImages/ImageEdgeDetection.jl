# AbstractGray and Color3 tests should be generated seperately
function generate_test_types(number_types::AbstractArray{<:DataType}, color_types::AbstractArray{<:UnionAll})
    test_types = map(Iterators.product(number_types, color_types)) do T
        try
            T[2]{T[1]}
        catch err
            !isa(err, TypeError) && rethrow(err)
        end
    end
    test_types = filter(x->x != false, test_types)
    if isempty(filter(x->x<:Color3, test_types))
        test_types = [number_types..., test_types...]
    end
    test_types
end

function edge_detection_equality(ratio = 0.005)
    # Compare edge maps as binary masks. Reference images load as N0f8 with
    # values exactly in {0, 1}, but the actual may carry floating-point noise
    # from upstream colorspace conversions (e.g. Lab(0,0,0) → Gray(4.38e-10),
    # Lab(100,0,0) → Gray(0.9999999)) — so bit-exact comparison spuriously
    # marks every pixel as different. A small `ratio` also absorbs the handful
    # of near-threshold pixels that flip between edge/non-edge across library
    # versions (e.g. Lab→Gray rounding shifting a few NMS pixels).
    is_edge(v) = float(real(v)) > 0.5

    function (ref, x)
        if size(ref) != size(x)
            @warn "test fails because size(ref) != size(x)"
            return false
        end

        count = sum(is_edge.(ref) .!= is_edge.(x))
        max_count = ceil(Int, length(ref)*ratio)
        rst = count <= max_count
        if !rst
            @warn "$count pixels are incorrectly categorized as edges/non-edges, at most $max_count are allowed."
        end
        return rst
    end
end
