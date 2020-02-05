"""
```
    Canny <: AbstractEdgeDetectionAlgorithm
    Canny(;) #TODO Decide on keywords

    detect_edges([T,] img, f::Canny)
    detect_edges!([out,] img, f::Canny)
```

Returns an image depicting the edges of the input image.

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
                      T₂ <: Union{Real,AbstractGray}} <: AbstractEdgeDetectionAlgorithm
    # TO BE DECIDED
    example_keyword_1::T₁ = 0
    example_keyword_2::T₂ = 0
end

function (f::Canny)(out::GenericGrayImage, img::GenericGrayImage)
    # TODO
end

function (f::Canny)(out::AbstractArray{<:Color3}, img::AbstractArray{<:Color3})
    # TODO
end

(f::Canny)(out::GenericGrayImage, img::AbstractArray{<:Color3}) =
    f(out, of_eltype(Gray, img))
