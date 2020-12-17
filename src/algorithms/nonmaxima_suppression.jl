"""
```
    NonmaximaSuppression <: AbstractEdgeThinningAlgorithm
    NonmaximaSuppression(; threshold::Union{Number, Percentile} = Percentile(20))

    f = NonmaximaSuppression()
    f(out::AbstractArray, mag::AbstractArray, g₁::AbstractArray, g₂::AbstractArray, f::NonmaximaSuppression)
```

Isolates local maxima of gradient magnitude `mag` along the local gradient
direction and stores the result in `out`.  The arguments `g₁` and `g₂` represent
the  gradient in the first spatial dimension (y), and the second spatial
dimension (x), respectively.

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
# Instantiate the NonmaximaSuppression functor.
f = NonmaximaSuppression()

# Suppress the non-maximal gradient magnitudes and store the result in `nms`.
f(nms, mag, g₁, g₂)

imshow(img)
imshow(mag)
imshow(nms)
```

# References
J. Canny, "A Computational Approach to Edge Detection," in IEEE Transactions on Pattern Analysis and Machine Intelligence, vol. PAMI-8, no. 6, pp. 679-698, Nov. 1986, doi: 10.1109/TPAMI.1986.4767851.
"""
@with_kw struct NonmaximaSuppression{ T <: Union{Real,AbstractGray, Percentile}} <: AbstractEdgeThinningAlgorithm
    threshold::T = Percentile(20)
end


function (f::NonmaximaSuppression)(out::AbstractArray, mag::AbstractArray, g₁::AbstractArray, g₂::AbstractArray)
    @unpack threshold = f

    low_threshold =  typeof(threshold) <: Percentile ? StatsBase.percentile(vec(mag), threshold.p) : threshold

    # Isolate local maxima of gradient magnitude by “non-maximum suppression”
    # along the local gradient direction.
    suppress_non_maxima!(out, mag, g₁, g₂, low_threshold)

    return out
end

"""
```
    suppress_non_maxima!(out::AbstractArray, mag::AbstractArray, gx::AbstractArray, gy::AbstractArray, threshold::Number)
```

Isolates local maxima of gradient magnitude by “non-maximum suppression” along the local gradient direction.

"""
function suppress_non_maxima!(out::AbstractArray, mag::AbstractArray, g₁::AbstractArray, g₂::AbstractArray, threshold::Number)
    itp = interpolate(mag, BSpline(Linear()))
    etp = extrapolate(itp, Flat())
    m₁ = zero(eltype(mag))
    m₂ = zero(eltype(mag))
    @inbounds for i in CartesianIndices(mag)
        r, c = i.I
        d₁ = g₁[i]
        d₂ = g₂[i]
        mc = mag[i]
        if mc < threshold || mc == 0 || isnan(mc)
            out[r,c] = zero(eltype(mag))
        else
            # Ensure the vector 𝐝 = [d₁, d₂] has unit norm.
            d₁ = d₁ / mc
            d₂ = d₂ / mc
            m₁ = etp(r + d₁, c + d₂)
            m₂ = etp(r - d₁, c - d₂)
            out[r,c] = (m₁ <= mc) && (mc >= m₂) ? mag[r,c] : zero(eltype(mag))
        end
    end
    return nothing
end
