using Documenter, ImageEdgeDetection

makedocs(;
    modules=[ImageEdgeDetection],
    format=Documenter.HTML(prettyurls = get(ENV, "CI", nothing) == "true")),
    pages=[
        "Home" => "index.md",
    ],
    repo="https://github.com/JuliaImages/ImageEdgeDetection.jl/blob/{commit}{path}#L{line}",
    sitename="ImageEdgeDetection.jl",
    authors="Dr. Zygmunt L. Szpak",
    assets=String[],
)

deploydocs(;
    repo="github.com/JuliaImages/ImageEdgeDetection.jl.git",
)
