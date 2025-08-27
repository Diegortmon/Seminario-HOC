using  Random

include("Estructuras.jl")
include("Base_Datos.jl")

mutable struct Grafica
    datodb::BaseDatos
    ciudades::Vector{Ciudad}
    rutas::Vector{Ruta}
    matriz_adjacencia::Msatrix{Float64}
end