function make_circle()
    img = zeros(Gray{N0f8},50, 50)
    draw!(img, CirclePointRadius(Point(25,25), 20))
    return img
end
