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

TODO

```@index
```

```@autodocs
Modules = [ImageEdgeDetection]
```
