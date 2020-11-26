# [Function References](@id function_reference)

```@contents
Pages = ["reference.md"]
Depth = 3
```

## General function

```@docs
detect_edges
detect_edges!
thin_edges
thin_edges!
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
ImageEdgeDetection.NonmaximaSubpixelSuppression
```

## Supplementary Types
```@docs
ImageEdgeDetection.Percentile
```


```@index
```
