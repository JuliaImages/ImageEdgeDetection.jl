# ImageEdgeDetection.jl Documentation

A Julia package containing a number of algorithms for detecting edges in images.

```@contents
Depth = 3
```

## Getting started
This package is part of a wider Julia-based image processing
[ecosystem](https://github.com/JuliaImages). If you are starting out, then you
may benefit from [reading](https://juliaimages.org/latest/quickstart/) about
some fundamental conventions that the ecosystem utilizes that are markedly
different from how images are typically represented in OpenCV, MATLAB, ImageJ or
Python.

The usage examples in the `ImageEdgeDetection.jl` package assume that you have
already installed some key packages. Notably, the examples assume that you are
able to load and display an image. Loading an image is facilitated through the
[FileIO.jl](https://github.com/JuliaIO/FileIO.jl) package, which uses
[QuartzImageIO.jl](https://github.com/JuliaIO/QuartzImageIO.jl) if you are on
`MacOS`, and [ImageMagick.jl](https://github.com/JuliaIO/ImageMagick.jl)
otherwise. Depending on your particular system configuration, you might
encounter problems installing the image loading packages, in which case you can
refer to the [troubleshooting
guide](https://juliaimages.org/latest/troubleshooting/#Installation-troubleshooting-1).

Image display is typically handled by the
[ImageView.jl](https://github.com/JuliaImages/ImageView.jl) package.
Alternatives include the various plotting packages, including
[Makie.jl](https://github.com/JuliaPlots/Makie.jl). There is
also the [ImageShow.jl](https://github.com/JuliaImages/ImageShow.jl) package
which facilitates displaying images in `Jupyter` notebooks via
[IJulia.jl](https://github.com/JuliaLang/IJulia.jl).
Finally, one can also obtain a useful preview of an image in the REPL using the
[ImageInTerminal.jl](https://github.com/JuliaImages/ImageInTerminal.jl) package.
However, this package assumes that the terminal uses a monospace font, and tends
not to produce adequate results in a Windows environment.

Another package that is used to illustrate the functionality in
`ImageEdgeDetection.jl` is the
[TestImages.jl](https://github.com/JuliaImages/TestImages.jl) which serves as a
repository of many standard image processing test images.


## Basic usage

Each edge detection algorithm in `ImageEdgeDetection.jl` is an [`AbstractEdgeDetectionAlgorithm`](@ref ImageEdgeDetection.EdgeDetectionAPI.AbstractEdgeDetectionAlgorithm).

Suppose one wants to mark the edges in an image. This can be achieved by simply choosing
an appropriate algorithm and calling [`detect_edges`](@ref) or [`detect_edges!`](@ref) in the
image.

Let's see a simple demo using the famous Canny edge detection algorithm:

```@setup Canny
mkpath("images")
```

```@example Canny
using TestImages, ImageEdgeDetection, MosaicViews
using FileIO # hide
img =  testimage("mandril_gray")
# Detect edges at different scales by adjusting the `spatial_scale` parameter.
img_edges₁ = detect_edges(img, Canny(spatial_scale = 1.4))
img_edges₂ = detect_edges(img, Canny(spatial_scale = 2.8))
img_edges₃ = detect_edges(img, Canny(spatial_scale = 5.6))
demo₁ = mosaicview(img, img_edges₁, img_edges₂, img_edges₃; nrow = 2)
save("images/demo1.jpg", demo₁); # hide
```
```@raw html
<img src="images/demo1.jpg" width="512px" alt="edge detection demo 1 image" />
<p>
```


You can control the Canny hysteresis thresholds by setting appropriate keyword
parameters.

```@example Canny
# Control the hysteresis thresholds by specifying the low and high threshold values.
img =  testimage("cameraman")
img_edges₄ = detect_edges(img, Canny(spatial_scale = 1.4, low = Percentile(5), high = Percentile(80)))
img_edges₅ = detect_edges(img, Canny(spatial_scale = 1.4, low = Percentile(60), high = Percentile(90)))
img_edges₆ = detect_edges(img, Canny(spatial_scale = 1.4, low = Percentile(70), high = Percentile(95)))
demo₂ = mosaicview(img, img_edges₄, img_edges₅, img_edges₆; nrow = 2)
save("images/demo2.jpg", demo₂); # hide
```
```@raw html
<img src="images/demo2.jpg" width="512px" alt="edge detection demo 2 image" />
<p>
<p>
```

Each edge thinning algorithm in `ImageEdgeDetection.jl` is an [`AbstractEdgeThinningAlgorithm`](@ref ImageEdgeDetection.EdgeDetectionAPI.AbstractEdgeThinningAlgorithm).

Suppose one wants to suppress the typical double edge response of an edge detection filter.
This can be achieved by simply choosing an appropriate algorithm and calling [`thin_edges`](@ref) or [`thin_edges!`](@ref) on the image gradients and gradient magnitudes.

For example, one can suppress undesirable multi-edge responses associated with the Sobel filter:

```@example NonmaximaSuppression
using TestImages, ImageEdgeDetection, MosaicViews, ImageFiltering, ImageCore
using FileIO # hide
img =  Gray.(testimage("lake_gray"))
# Determine the image gradients
g₁, g₂ = imgradients(img, KernelFactors.sobel)
# Determine the gradient magnitude
mag = hypot.(g₁, g₂)
# Suppress the non-maximal gradient magnitudes
nms₁ = thin_edges(mag, g₁, g₂, NonmaximaSuppression())
nms₂ = thin_edges(mag, g₁, g₂, NonmaximaSuppression(threshold = Percentile(95)))
demo₃ = mosaicview(img, Gray.(nms₂), Gray.(mag), Gray.(nms₁); nrow = 2)
save("images/demo3.jpg", demo₃); # hide
```
```@raw html
<img src="images/demo3.jpg" width="512px" alt="edge thinning demo image" />
<p>
```

For more advanced usage, please check [function reference](@ref function_reference) page.
