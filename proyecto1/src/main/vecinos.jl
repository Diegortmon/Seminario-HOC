# vecinos.jl - Funciones relacionadas con la generación de soluciones vecinas

using Random
using StatsBase
include("estructuras.jl")

# Genera un vecino aleatorio intercambiando dos elementos
function vecino_aleatorio(permutacion::Vector{Int})
    nueva_perm = copy(permutacion)
    n = length(nueva_perm)
    
    # Seleccionar dos índices diferentes aleatoriamente
    s, t = sample(1:n, 2, replace=false)
    
    # Intercambiar elementos
    nueva_perm[s], nueva_perm[t] = nueva_perm[t], nueva_perm[s]
    
    return nueva_perm
end