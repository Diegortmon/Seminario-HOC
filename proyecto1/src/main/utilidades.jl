# utilidades.jl - Funciones auxiliares y de utilidad

include("estructuras.jl")

# Convierte grados a radianes
rad(g::Float64) = g * π / 180.0

# Calcula la distancia natural entre dos ciudades usando la fórmula del documento
function distancia_natural(u::Ciudad, v::Ciudad)
    R = 6_373_000.0  # Radio de la Tierra en metros
    
    lat_u = rad(u.lat)
    lat_v = rad(v.lat)
    lon_u = rad(u.lon)
    lon_v = rad(v.lon)
    
    A = sin((lat_v - lat_u) / 2)^2 + 
        cos(lat_u) * cos(lat_v) * sin((lon_v - lon_u) / 2)^2
    
    C = 2 * atan(sqrt(A), sqrt(1 - A))
    
    return R * C
end

# Calcula el peso aumentado entre dos ciudades
function peso_aumentado(tsp::TSP, i::Int, j::Int)
    if tsp.grafica[i, j]
        return tsp.distancias[i, j]
    else
        return tsp.distancias[i, j] * tsp.max_distancia
    end
end

# Calcula el costo total de una solución sin normalizar
function costo_total_solucion(tsp::TSP, permutacion::Vector{Int})
    costo_total = 0.0
    n = length(permutacion)
    
    for i in 2:n
        # Usar solo distancias reales, no peso aumentado para el cálculo final
        if tsp.grafica[permutacion[i-1], permutacion[i]]
            costo_total += tsp.distancias[permutacion[i-1], permutacion[i]]
        else
            # Si no hay conexión, usar distancia natural penalizada
            costo_total += tsp.distancias[permutacion[i-1], permutacion[i]] * tsp.max_distancia
        end
    end
    
    return costo_total
end

# Función de costo para una permutación
function funcion_costo(tsp::TSP, permutacion::Vector{Int})
    costo_total = 0.0
    n = length(permutacion)
    
    for i in 2:n
        costo_total += peso_aumentado(tsp, permutacion[i-1], permutacion[i])
    end
    
    return costo_total / tsp.normalizador
end

# Verifica si una solución es factible
function es_factible(tsp::TSP, permutacion::Vector{Int})
    n = length(permutacion)
    for i in 2:n
        if !tsp.grafica[permutacion[i-1], permutacion[i]]
            return false
        end
    end
    return true
end

# Convierte una permutación de índices a IDs de ciudades
function permutacion_a_ids(tsp::TSP, permutacion::Vector{Int})
    return [tsp.ciudades[i].id for i in permutacion]
end

# Convierte una secuencia de IDs a permutación de índices
function ids_a_permutacion(tsp::TSP, city_ids::Vector{Int})
    permutacion = Int[]
    for city_id in city_ids
        if haskey(tsp.city_id_to_index, city_id)
            push!(permutacion, tsp.city_id_to_index[city_id])
        end
    end
    return permutacion
end