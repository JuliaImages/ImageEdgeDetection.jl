using Documenter, ImageEdgeDetection

makedocs(;
    modules=[ImageEdgeDetection],
    format=Documenter.HTML(),
    pages=[
        "Home" => "index.md",
    ],
    repo="https://github.com/zygmuntszpak/ImageEdgeDetection.jl/blob/{commit}{path}#L{line}",
    sitename="ImageEdgeDetection.jl",
    authors="Dr. Zygmunt L. Szpak",
    assets=String[],
)

deploydocs(;
    repo="github.com/zygmuntszpak/ImageEdgeDetection.jl",
)
