"""
```
    Canny <: AbstractEdgeDetectionAlgorithm
    Canny(; spatial_scale = 1, high = 0.2, low = 0.05)

    detect_edges([T,] img, f::Canny)
    detect_edges!([out,] img, f::Canny)
```

Returns a binary image depicting the edges of the input image.

# Details

TODO

# Example

```julia

using TestImages, FileIO, ImageView

img =  testimage("mandril_gray")
img_edges = detect_edges(img, Canny())

imshow(img)
imshow(img_edges)
```

# References
TODO.
"""
@with_kw struct Canny{T₁ <: Union{Real,AbstractGray},
                      T₂ <: Union{Real,AbstractGray},
                      T₃ <: Union{Real,AbstractGray}} <: AbstractEdgeDetectionAlgorithm
    spatial_scale::T₁ = 1 # radius of a Gaussain filter
    # relative to the maximum gradient magnitude
    high::T₂ = 0.05
    low::T₃ = 0.01
end

function (f::Canny)(out::GenericGrayImage, img::GenericGrayImage)
    @unpack spatial_scale, high, low = f
    σ = spatial_scale

    # Smooth the image with a Gaussian filter of width σ, which specifies the
    # scale level of the edge detector.
    kernel = KernelFactors.IIRGaussian((σ,σ))
    imgf = imfilter(img, kernel, NA())

    # Calculate the gradient vector at each position of the filtered image.
    # The derivatives are taken with respect to the first and second dimension.
    #gy, gx = imgradients(imgf, KernelFactors.scharr)
    #gy, gx = imgradients(imgf, KernelFactors.ando3)
    #gx, gy = imgradients(imgf, KernelFactors.sobel)
    #gx, gy = imgradients(imgf, KernelFactors.bickley)
    gy, gx = imgradients(imgf, KernelFactors.bickley)

    # Gradient magnitude
    mag = hypot.(gx, gy)

    #l = maximum(mag)
    #mag =  mag .* (100 / l)

    # Isolate local maxima of gradient magnitude by “non-maximum suppression”
    # along the local gradient direction.
    #nms = zeros(eltype(img), axes(img))
    nms = zeros(Float64, axes(img))
    suppress_non_maxima!(nms, mag, gx, gy, low)

    # Collect sets of connected edge pixels from the local maxima by applying
    # “hysteresis thresholding”.
    edges = zeros(eltype(img), axes(img))
    traced_edges = Vector{Vector{CartesianIndex{2}}}()
    for i in CartesianIndices(nms)
        if nms[i] >= high && edges[i] == 0
            trace = Vector{CartesianIndex}()
            trace_and_threshold!(edges, trace, nms, i, low)
            push!(traced_edges, trace)
        end
    end

    𝛉 = zeros(axes(out))
    for i in CartesianIndices(out)
        x = gx[i]
        y = gy[i]
        θ = atan(y,x)
        #θ = atan(y/x)
        𝛉[i] = θ
    end

    out .= edges

    return traced_edges

        # rows, cols = axes(img)
        # img_padded = padarray(img, Fill(0, (2,2)))
        # for r = first(rows):last(rows)
        #     for c = first(cols):last(cols)
        #         #i = CartesianIndex(r, c)
        #         dx = gx[r, c]
        #         dy = gy[r, c]
        #         𝐝 = SVector(dx, dy)
        #         sector = get_orientation_sector(𝐑, 𝐝)
        #         if is_local_maximum(mag, r, c, sector, low)
        #             # only keep local maxima
        #             nms[r,c] = mag[r,c]
        #         end
        #     end
        # end


    # Edge localization
    #=
        Isolate local maxima of gradient magnitude by “non-
        maximum suppression” along the local gradient direction.
    =#

    # Edge tracing and hysteresis thresholding
    #=
        Collect sets of connected edge pixels from the local maxima by applying “hysteresis thresholding”.
    =#

end

function (f::Canny)(out::AbstractArray{<:Color3}, img::AbstractArray{<:Color3})
    # TODO
end

(f::Canny)(out::GenericGrayImage, img::AbstractArray{<:Color3}) =
    f(out, of_eltype(Gray, img))


"""
    suppress_non_maxima!(nms::AbstractArray, mag::AbstractArray, gx::AbstractArray, gy::AbstractArray, low::Number)

    Isolates local maxima of gradient magnitude by “non-maximum suppression” along the local gradient direction.

"""
function suppress_non_maxima!(nms::AbstractArray, mag::AbstractArray, gx::AbstractArray, gy::AbstractArray, low::Number)
    # Used to rotate a 2D vector by π/8 degrees as part of the
    # get_orientation_sector routine to sidestep the need for
    # trigonometric operations.
    𝐑 = @SMatrix [cos(π/8) -sin(π/8) ;
                  sin(π/8)  cos(π/8)]
    #𝐑 = inv(𝐑)

    rows, cols = axes(mag)
    for r = (first(rows) + 1):(last(rows) - 1)
        for c = (first(cols) + 1):(last(cols) - 1)
            i = CartesianIndex(r, c)
            dx = gx[i]
            dy = gy[i]
            𝐝 = SVector(dx, dy) # TODO
            sector = get_orientation_sector(𝐑, 𝐝)
            if is_local_maximum(mag, i, sector, low)
                # only keep local maxima
                nms[r,c] = mag[r,c]
            end
        end
    end
    return nothing
end

"""
    get_orientation_sector(𝐑::AbstractArray, 𝐝₀::AbstractVector)

    Returns an orientation sector `s` (`s ∈ {0, 1, 2, 3}`) for the 2D
    vector `[dx, dy]`.

"""
function get_orientation_sector(𝐑::AbstractArray, 𝐝₀::AbstractVector)
    # Rotate 𝐝₀ by π/8 degrees
    𝐝₁ = 𝐑 * 𝐝₀
    dx, dy = 𝐝₁

    # Mirror to octants 0, ..., 3
    if dy < 0
        dx = -dx
        dy = -dy
    end

    sector = 0
    if (dx >= 0) && (dx >= dy)
        sector = 0
    elseif (dx >= 0) && (dx < dy)
        sector = 1
    elseif (dx < 0) && (-dx < dy)
        sector = 2
    elseif (dx < 0) && (-dx >= dy)
        sector = 3
    end
    return sector
end

"""
    is_local_maximum(mag::AbstractArray, r::Int, c::Int, sector::Int, low::Number)

Determines if the gradient magnitude `mag` is a local maximum at position
`[r,c]` in the direction `sector ∈ {0, 1, 2, 3}`.

"""
function is_local_maximum(mag::AbstractArray, i::CartesianIndex, sector::Int, low::Number)
    mc = mag[i]
    r, c = i.I
    if mc < low
        return false
    else
        if sector == 0
            ml = mag[r - 1, c]
            mr = mag[r + 1, c]
        elseif sector == 1
            ml = mag[r - 1, c - 1]
            mr = mag[r + 1, c + 1]
        elseif sector == 2
            ml = mag[r, c - 1]
            mr = mag[r, c + 1]
        else # sector == 3
            ml = mag[r - 1, c + 1]
            mr = mag[r + 1, c - 1]
        end
        return (ml <= mc) && (mc >= mr)
    end
end


"""
    trace_and_threshold!(out::AbstractArray, trace::Vector{CartesianIndex}, mag::AbstractArray, i₀::CartesianIndex, low::Number)

Recursively collects and marks all pixels of an edge that are 8-connected to i₀ and
exhibit a gradient magnitude above `low`.

"""
function trace_and_threshold!(out::AbstractArray, trace::Vector{CartesianIndex}, mag::AbstractArray, i₀::CartesianIndex, low::Number)
    stack = Stack{CartesianIndex{2}}()
    push!(stack, i₀)
   # Trace all the pixels that are reachable from the current edge pixel.
    rows, cols = axes(out)
    while !isempty(stack)
        i = pop!(stack)
        # Mark the pixel as visited.
        out[i] = 1.0
        # Add it to the list of edge pixels.
        push!(trace, i)
        rᵢ, cᵢ = i.I
        # Ensure we don't exceed the image bounds
        r₀ = (rᵢ > firstindex(rows)) ? rᵢ - 1 : firstindex(rows)
        r₁ = (rᵢ < lastindex(rows)) ? rᵢ + 1 : lastindex(rows)
        c₀ = (cᵢ > firstindex(cols)) ? cᵢ - 1 : firstindex(cols)
        c₁ = (cᵢ < lastindex(cols)) ? cᵢ + 1 : lastindex(cols)

        # Search the neighbourhood for any connected pixels which exceed
        # the minimum edge magnitude threshold `low`.
        for r = r₀:r₁
            for c = c₀:c₁
                j = CartesianIndex(r,c)
                if out[j] == 0 && mag[j] >= low
                    push!(stack, j)
                end
            end
        end
    end
end
