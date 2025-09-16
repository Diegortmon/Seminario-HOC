# estructuras.jl - Definiciones de tipos y estructuras

# Estructura para representar una ciudad
struct Ciudad
    id::Int
    name::String
    country::String
    population::Int
    lat::Float64  # latitud en grados
    lon::Float64  # longitud en grados
end

# Estructura para el problema TSP
struct TSP
    ciudades::Vector{Ciudad}
    grafica::Matrix{Bool}  # matriz de adyacencia
    distancias::Matrix{Float64}  # matriz de distancias
    max_distancia::Float64
    normalizador::Float64
    city_id_to_index::Dict{Int, Int}  # mapeo de ID de ciudad a índice
end

# Estructura para leer archivos .tsp
struct TSPInput
    path::Vector{Int}
end
