# run.jl - Punto de entrada desde la raíz
using Pkg

# Activar el proyecto
Pkg.activate(".")

# Llamar al main real
include("src/main/main.jl")