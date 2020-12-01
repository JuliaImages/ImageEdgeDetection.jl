# [Function References](@id function_reference)

```@contents
Pages = ["reference.md"]
Depth = 3
```

## General function

```@docs
detect_edges
detect_edges!
detect_subpixel_edges
detect_subpixel_edges!
detect_gradient_orientation
detect_gradient_orientation!
thin_edges
thin_edges!
thin_subpixel_edges
thin_subpixel_edges!
```

## Edge Detection Algorithms
```@docs
ImageEdgeDetection.EdgeDetectionAPI.AbstractEdgeDetectionAlgorithm
```

### Canny
```@docs
ImageEdgeDetection.Canny
```

## Edge Thinning Algorithms
```@docs
ImageEdgeDetection.EdgeDetectionAPI.AbstractEdgeThinningAlgorithm
```

### Non-maxima Suppression
```@docs
ImageEdgeDetection.NonmaximaSuppression
```

### Non-maxima Suppression (Subpixel)
```@docs
ImageEdgeDetection.SubpixelNonmaximaSuppression
```

### OrientationConvention
```@docs
ImageEdgeDetection.OrientationConvention
```

## Supplementary Types
```@docs
ImageEdgeDetection.Percentile
```


```@index
```
