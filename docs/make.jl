using Documenter, ImageEdgeDetection

format = Documenter.HTML(edit_link = "master",
                         prettyurls = get(ENV, "CI", nothing) == "true",
                         assets = String[])

makedocs(;
    modules=[ImageEdgeDetection],
    format = format,
    pages=[
        "Home" => "index.md",
    ],
    sitename="ImageEdgeDetection.jl",
    authors="Dr. Zygmunt L. Szpak"
)

deploydocs(;
    repo="github.com/JuliaImages/ImageEdgeDetection.jl.git",
)
