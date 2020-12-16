"""
```
    Canny <: AbstractEdgeDetectionAlgorithm
    Canny(; spatial_scale = 1, high = Percentile(80), low = Percentile(20), thinning_algorithm = NonmaximaSuppression(threshold = low))

    detect_edges([T,] img, f::Canny)
    detect_edges!([out,] img, f::Canny)
    detect_subpixel_edges([T₁, T₂] img, f::Canny)
    detect_subpixel_edges!(out₁, out₂, img, f::Canny)
```

Returns a binary image depicting the edges of the input image.

# Details

TODO

# Options

Various options for the parameters of the `detect_edges` function and `Canny` type are described in more detail below.

# Choices for img

The `detect_edges` function can handle a variety of input types.
By default the type of the returned image matches the type of the
input image.

For colored images, the input is converted to grayscale.

# Choices for `spatial_scale` in `Canny`.

The `spatial_scale` determines the radius (σ) of the Gaussian filter. It must
be a positive real number.

# Choices for `high` and `low` in `Canny`.

The hysteresis thresholds `high` and `low` (`high` > `low`) can be specified as
positive numbers, or as `Percentiles`. If left unspecified, a default value of
`high = Percentile(80)` and `low = Percentile(20)` is assumed.

# Choices for `thinning_algorithm` in `Canny`.
You can specify an [`AbstractEdgeThinningAlgorithm`](@ref). By default, the
[`NonmaximaSuppression`](@ref) algorithm is used which suppresses non-maxima up
to pixel-level accuracy. For subpixel precision specify the
[`SubpixelNonmaximaSuppression`](@ref) algorithm.

# Example

```julia

using TestImages, FileIO, ImageView

img =  testimage("mandril_gray")
img_edges = detect_edges(img, Canny(spatial_scale = 1.4))

imshow(img)
imshow(img_edges)
```

# References
J. Canny, "A Computational Approach to Edge Detection," in IEEE Transactions on Pattern Analysis and Machine Intelligence, vol. PAMI-8, no. 6, pp. 679-698, Nov. 1986, doi: 10.1109/TPAMI.1986.4767851.

"""
@with_kw struct Canny{T₁ <: Union{Real,AbstractGray},
                      T₂ <: Union{Real,AbstractGray, Percentile},
                      T₃ <: Union{Real,AbstractGray, Percentile},
                      T₄ <: AbstractEdgeThinningAlgorithm} <: AbstractEdgeDetectionAlgorithm
    spatial_scale::T₁ = 1
    high::T₂ = Percentile(80)
    low::T₃ = Percentile(20)
    thinning_algorithm::T₄ = NonmaximaSuppression(threshold = low)
end

# Handles pixel-level precision.
function (f::Canny)(out::GenericGrayImage, img::GenericGrayImage)
    @unpack spatial_scale, high, low = f
    @unpack thinning_algorithm = f
    σ = spatial_scale

    # Smooth the image with a Gaussian filter of width σ, which specifies the
    # scale level of the edge detector.
    kernel =  KernelFactors.gaussian((σ,σ))
    imgf = imfilter(img, kernel, NA())

    # Calculate the gradient vector at each position of the filtered image.
    # The derivatives are taken with respect to the first and second dimension
    # (rows first, then columns).
    g₁, g₂ = imgradients(imgf, KernelFactors.scharr)
    # Gradient magnitude
    mag = hypot.(g₁, g₂)

    # In StatsBase quantiles are undefined in the presence of NaNs
    # hence we need to keep only valid magnitudes before we can determine
    # the percentiles.
    valid_indices = map(x-> !isnan(x), mag)
    valid_mag = view(mag, valid_indices)

    low_threshold =  typeof(low) <: Percentile ? StatsBase.percentile(vec(valid_mag), low.p) : low
    high_threshold =  typeof(high) <: Percentile ? StatsBase.percentile(vec(valid_mag), high.p) : high

    thinning_algorithm = @set thinning_algorithm.threshold = low_threshold

    # Isolate local maxima of gradient magnitude by “non-maximum suppression”
    # along the local gradient direction.
    nms = thin_edges(mag, g₁, g₂, thinning_algorithm)

    # Collect sets of connected edge pixels from the local maxima by applying
    # “hysteresis thresholding”. Edge pixels whose gradient magnitude is below
    # the low threshold are removed; edge pixels whose gradient magnitudes are
    # above (or equal to) the high threshold are retained, and edge pixels whose
    # gradient magnituded are between the low and high threshold are only
    # retained if they are connected to edge pixels whose gradient magnitudes
    # are above or equal to the high threshold.
    edges = zeros(Bool, axes(img))
    @inbounds for i in CartesianIndices(nms)
        if nms[i] >= high_threshold && edges[i] == 0
            trace_and_threshold!(edges, nms, i, low_threshold)
        end
    end
    out .= edges
end

# Handles subpixel precision.
function (f::Canny)(out₁::GenericGrayImage, out₂::AbstractArray{<:StaticVector}, img::GenericGrayImage)
    @unpack spatial_scale, high, low = f
    @unpack thinning_algorithm = f
    σ = spatial_scale

    # Smooth the image with a Gaussian filter of width σ, which specifies the
    # scale level of the edge detector.
    kernel = KernelFactors.gaussian((σ,σ))
    imgf = imfilter(img, kernel, NA())

    # Calculate the gradient vector at each position of the filtered image.
    # The derivatives are taken with respect to the first and second dimension
    # (rows first, then columns).
    g₁, g₂ = imgradients(imgf, KernelFactors.scharr)
    # Gradient magnitude
    mag = hypot.(g₁, g₂)

    # In StatsBase quantiles are undefined in the presence of NaNs
    # hence we need to keep only valid magnitudes before we can determine
    # the percentiles.
    valid_indices = map(x-> !isnan(x), mag)
    valid_mag = view(mag, valid_indices)

    low_threshold =  typeof(low) <: Percentile ? StatsBase.percentile(vec(valid_mag), low.p) : low
    high_threshold =  typeof(high) <: Percentile ? StatsBase.percentile(vec(valid_mag), high.p) : high

    thinning_algorithm = @set thinning_algorithm.threshold = low_threshold

    # Isolate local maxima of gradient magnitude by “non-maximum suppression”
    # along the local gradient direction.
    nms, subpixel_offsets = thin_subpixel_edges(mag, g₁, g₂, thinning_algorithm)

    # Collect sets of connected edge pixels from the local maxima by applying
    # “hysteresis thresholding”. Edge pixels whose gradient magnitude is below
    # the low threshold are removed; edge pixels whose gradient magnitudes are
    # above (or equal to) the high threshold are retained, and edge pixels whose
    # gradient magnituded are between the low and high threshold are only
    # retained if they are connected to edge pixels whose gradient magnitudes
    # are above or equal to the high threshold.
    edges = zeros(Bool, axes(img))
    @inbounds for i in CartesianIndices(nms)
        if nms[i] >= high_threshold && edges[i] == 0
            trace_and_threshold!(edges, nms, i, low_threshold)
        end
    end
    out₁ .= edges
    out₂ .= subpixel_offsets

    return out₁, out₂
end

function (f::Canny)(out::AbstractArray{<:Color3}, img::AbstractArray{<:Color3})
    T = eltype(img)
    out_temp = zeros(Gray{eltype(T)}, axes(out))
    # NB This will be refactored in future version once a proper color-based
    # edge detection algorithm is implemented. At the moment we just call the
    # default "grayscale" edge detection algorithm.
    out .= convert.(T, f(out_temp, Gray.(img)))
end

function (f::Canny)(out₁::AbstractArray{<:Color3}, out₂::AbstractArray{<:StaticVector}, img::AbstractArray{<:Color3})
    T = eltype(img)
    out_temp = zeros(Gray{eltype(T)}, axes(out₁))
    # NB This will be refactored in future version once a proper color-based
    # edge detection algorithm is implemented. At the moment we just call the
    # default "grayscale" edge detection algorithm.
    out_temp, offsets = f(out_temp, out₂, Gray.(img))

    out₁ .= convert.(T, out_temp)
    return out₁, offsets
end


(f::Canny)(out::GenericGrayImage, img::AbstractArray{<:Color3}) =
    f(out, of_eltype(Gray, img))

(f::Canny)(out₁::GenericGrayImage, out₂::AbstractArray{<:StaticVector}, img::AbstractArray{<:Color3}) =
    f(out₁, out₂, of_eltype(Gray, img))


"""
```
    trace_and_threshold!(out::AbstractArray,  mag::AbstractArray, i₀::CartesianIndex, low::Number)
```

 Marks all pixels of an edge that are 8-connected to i₀ and exhibit a gradient magnitude above `low`.

"""
function trace_and_threshold!(out::AbstractArray, mag::AbstractArray, i₀::CartesianIndex, low::Number)
    stack = Stack{CartesianIndex{2}}()
    push!(stack, i₀)
    # Trace all the pixels that are reachable from the current edge pixel.
    rows, cols = axes(out)
    while !isempty(stack)
        i = pop!(stack)

        # Mark the pixel as visited.
        out[i] = oneunit(eltype(out))
        rᵢ, cᵢ = i.I

        # Ensure we don't exceed the image bounds
        r₀ = (rᵢ > firstindex(rows)) ? rᵢ - 1 : firstindex(rows)
        r₁ = (rᵢ < lastindex(rows)) ? rᵢ + 1 : lastindex(rows)
        c₀ = (cᵢ > firstindex(cols)) ? cᵢ - 1 : firstindex(cols)
        c₁ = (cᵢ < lastindex(cols)) ? cᵢ + 1 : lastindex(cols)

        # Search the neighbourhood for any connected pixels which exceed
        # the minimum edge magnitude threshold `low`.
        @inbounds for r = r₀:r₁
            for c = c₀:c₁
                j = CartesianIndex(r,c)
                if out[j] == zero(eltype(out)) && mag[j] >= low
                    push!(stack, j)
                end
            end
        end
    end
end
