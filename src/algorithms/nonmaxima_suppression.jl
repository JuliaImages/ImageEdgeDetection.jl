"""
```
    NonmaximaSuppression <: AbstractEdgeThinningAlgorithm
    NonmaximaSuppression(;) #TODO Decide on keywords

    thin_edges([T,] img, f::NonmaximaSuppression)
    thin_edges!([out,] img, f::NonmaximaSuppression)
```

Returns an image that contains a single response per edge.

# Details

TODO

# Example

```julia

using TestImages, FileIO, ImageView

img =  testimage("mandril_gray")
img_edges = detect_edges(img, Canny())
img_thin_edges = thin_edges(img_edges, NonmaximaSuppression())

imshow(img)
imshow(img_edges)
imshow(img_thin_edges)
```

# References
TODO.
"""
@with_kw struct NonmaximaSuppression{T₁ <: Union{Real,AbstractGray},
                                     T₂ <: Union{Real,AbstractGray}} <: AbstractEdgeDetectionAlgorithm
    # TO BE DECIDED
    example_keyword_1::T₁ = 0
    example_keyword_2::T₂ = 0
end

function (f::NonmaximaSuppression)(out::GenericGrayImage, img::GenericGrayImage)
    # TODO
end

function (f::NonmaximaSuppression)(out::AbstractArray{<:Color3}, img::AbstractArray{<:Color3})
    # TODO
end

(f::NonmaximaSuppression)(out::GenericGrayImage, img::AbstractArray{<:Color3}) =
    f(out, of_eltype(Gray, img))
