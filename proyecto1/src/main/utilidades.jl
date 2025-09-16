# utilidades.jl - SOLO OPTIMIZACIONES TÉCNICAS

include("estructuras.jl")

"""
    rad(g::Float64) -> Float64

Convierte grados a radianes.
"""
@inline rad(g::Float64) = g * π / 180.0

"""
    distancia_natural(u::Ciudad, v::Ciudad) -> Float64

Calcula la distancia geodésica entre dos ciudades usando la fórmula de Haversine.
"""
@inline function distancia_natural(u::Ciudad, v::Ciudad)
    R = 6_373_000.0

    lat_u = rad(u.lat)
    lat_v = rad(v.lat)
    lon_u = rad(u.lon)
    lon_v = rad(v.lon)

    sin_lat_half = sin((lat_v - lat_u) * 0.5)
    sin_lon_half = sin((lon_v - lon_u) * 0.5)

    A = sin_lat_half * sin_lat_half + cos(lat_u) * cos(lat_v) * sin_lon_half * sin_lon_half
    C = 2.0 * atan(sqrt(A), sqrt(1.0 - A))

    return R * C
end

"""
    peso_aumentado(tsp::TSP, i::Int, j::Int) -> Float64

Devuelve el peso entre dos nodos en la matriz de distancias del TSP.
"""
@inline peso_aumentado(tsp::TSP, i::Int, j::Int) = tsp.distancias[i, j]

"""
    funcion_costo(tsp::TSP, permutacion::Vector{Int}) -> Float64

Calcula el costo total de una permutación de ciudades normalizado.
"""
function funcion_costo(tsp::TSP, permutacion::Vector{Int})
    costo_total = 0.0
    distancias = tsp.distancias
    n = length(permutacion)

    @inbounds for i in 2:n
        costo_total += distancias[permutacion[i-1], permutacion[i]]
    end

    return costo_total / tsp.normalizador
end

"""
    es_factible(tsp::TSP, permutacion::Vector{Int}) -> Bool

Verifica si una permutación es factible según la gráfica del TSP.
"""
function es_factible(tsp::TSP, permutacion::Vector{Int})
    grafica = tsp.grafica
    n = length(permutacion)

    @inbounds for i in 2:n
        if !grafica[permutacion[i-1], permutacion[i]]
            return false
        end
    end
    return true
end

"""
    permutacion_a_ids(tsp::TSP, permutacion::Vector{Int}) -> Vector{Int}

Convierte una permutación de índices a un vector de IDs de ciudades.
"""
@inline function permutacion_a_ids(tsp::TSP, permutacion::Vector{Int})
    ciudades = tsp.ciudades
    n = length(permutacion)
    ids = Vector{Int}(undef, n)

    @inbounds for i in 1:n
        ids[i] = ciudades[permutacion[i]].id
    end

    return ids
end

"""
    ids_a_permutacion(tsp::TSP, city_ids::Vector{Int}) -> Vector{Int}

Convierte un vector de IDs de ciudades a una permutación de índices.
"""
function ids_a_permutacion(tsp::TSP, city_ids::Vector{Int})
    city_id_to_index = tsp.city_id_to_index
    permutacion = Vector{Int}()
    sizehint!(permutacion, length(city_ids))

    @inbounds for city_id in city_ids
        if haskey(city_id_to_index, city_id)
            push!(permutacion, city_id_to_index[city_id])
        end
    end
    return permutacion
end