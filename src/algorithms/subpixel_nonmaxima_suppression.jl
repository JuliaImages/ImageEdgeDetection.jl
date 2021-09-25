"""
```
    SubpixelNonmaximaSuppression <: AbstractEdgeThinningAlgorithm
    SubpixelNonmaximaSuppression(; threshold::Union{Number, Percentile} = Percentile(20))

    f = SubpixelNonmaximaSuppression()
    f(out₁::AbstractArray, out₂::Matrix{<:AbstractArray}, mag::AbstractArray, g₁::AbstractArray, g₂::AbstractArray, f::SubpixelNonmaximaSuppression)
```

Isolates local maxima of gradient magnitude `mag` along the local gradient
direction to subpixel precision.  The arguments `g₁` and `g₂` represent the
gradient in the first spatial dimension (y), and the second spatial dimension
(x), respectively.

The integer components of the local maxima correspond to non-zero row and column
entries `out₁`. The accompanying subpixel offsets  are stored in a 2-D array
`out₂` as length-2 vectors. One can recover the  subpixel coordinates by adding
the subpixel offsets to the integer components.


# Details

TODO

# Example

```julia

using TestImages, FileIO, ImageView, ImageEdgeDetection, ImageFiltering

img =  testimage("mandril_gray")

# Gradient in the first and second spatial dimension
g₁, g₂ = imgradients(img, KernelFactors.scharr)

# Gradient magnitude
mag = hypot.(g₁, g₂)

nms = zeros(eltype(mag), axes(mag))
subpixel_offsets = zeros(SVector{2,Float64}, axes(mag))

# Instantiate the NonmaximaSuppression functor.
f = SubpixelNonmaximaSuppression()

# Suppress the non-maximal gradient magnitudes and store the result in `nms`.
f(nms, subpixel_offsets, mag, g₁, g₂)

imshow(img)
imshow(mag)
imshow(nms)
```

# References
1. J. Canny, "A Computational Approach to Edge Detection," in IEEE Transactions on Pattern Analysis and Machine Intelligence, vol. PAMI-8, no. 6, pp. 679-698, Nov. 1986, doi: 10.1109/TPAMI.1986.4767851.
2. F. Devernay, "A non-maxima suppression method for edge detection with sub-pixel accuracy", Tech. Report RR-2724, INRIA, 1995.
"""
@with_kw struct SubpixelNonmaximaSuppression{T <: Union{Real,AbstractGray, Percentile}} <: AbstractEdgeThinningAlgorithm
    threshold::T = Percentile(20)
end


function (f::SubpixelNonmaximaSuppression)(out₁::AbstractArray, out₂::AbstractArray{<:StaticVector}, mag::AbstractArray, g₁::AbstractArray, g₂::AbstractArray)
    @unpack threshold = f

    low_threshold =  typeof(threshold) <: Percentile ? StatsBase.percentile(vec(mag), threshold.p) : threshold

    # Isolate local maxima of gradient magnitude by “non-maximum suppression”
    # along the local gradient direction.
    suppress_subpixel_non_maxima!(out₁, out₂, mag, g₁, g₂, low_threshold)

    return out₁, out₂
end

"""
```
    suppress_subpixel_non_maxima!(out₁::AbstractArray, out₂::AbstractArray{<:StaticVector}, mag::AbstractArray, gx::AbstractArray, gy::AbstractArray, threshold::Number)
```

Isolates local maxima of gradient magnitude by “non-maximum suppression” along the local gradient direction.

"""
function suppress_subpixel_non_maxima!(out₁::AbstractArray, out₂::AbstractArray{<:StaticVector},  mag::AbstractArray, g₁::AbstractArray, g₂::AbstractArray, threshold::Number)
    itp = interpolate(mag, BSpline(Linear()))
    etp = extrapolate(itp, Flat())
    m₁ = zero(eltype(mag))
    m₂ = zero(eltype(mag))
    @inbounds for i in CartesianIndices(mag)
        r, c = i.I
        d₁ = gray(g₁[i])
        d₂ = gray(g₂[i])
        mc = mag[i]
        if mc < threshold || mc == 0 || isnan(mc)
            out₁[r,c] = zero(eltype(mag))
        else
            # Ensure the vector 𝐝 = [d₁, d₂] has unit norm.
            d₁ = d₁ / mc
            d₂ = d₂ / mc
            m₁ = etp(r + d₁, c + d₂)
            m₂ = etp(r - d₁, c - d₂)
            if ((m₁ <= mc) && (m₂ < mc)) || ((m₁ < mc) && (m₂ <= mc))
                out₁[r,c] = mag[r,c]
                # To obtain subpixel precision we fit a parabola through the
                # three points:
                # (x₁ = -1, y₁ = m₂) , (x₂ = 0, y₂ = mc), (x₃ = 1, y₃ = m₂)
                # and then solve for the vertex of the parabola.
                λ = (m₂ - m₁) / (2*(m₂ - 2*mc + m₁))
                out₂[r,c] = SVector(λ*d₁, λ*d₂)
            else
                out₁[r,c] = zero(eltype(mag))
                out₂[r,c] = zero(eltype(out₂))
            end
        end
    end
    return nothing
end
