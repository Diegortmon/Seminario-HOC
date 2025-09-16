# temperatura.jl

include("estructuras.jl")
include("utilidades.jl")
include("vecinos.jl")

"""
    porcentaje_aceptados(tsp::TSP, s::Vector{Int}, T::Float64, N::Int = 100) -> Float64

Calcula el porcentaje de soluciones vecinas aceptadas en N iteraciones a una temperatura T, usando el algoritmo de aceptación por umbrales.
"""
function porcentaje_aceptados(tsp::TSP, s::Vector{Int}, T::Float64, N::Int = 100)
    c = 0
    s_actual = copy(s)
    temp_vec = Vector{Int}(undef, length(s))
    distancias = tsp.distancias
    normalizador = tsp.normalizador

    @inline function costo_local(perm)
        costo = 0.0
        @inbounds for i in 2:length(perm)
            costo += distancias[perm[i-1], perm[i]]
        end
        return costo / normalizador
    end

    costo_actual = costo_local(s_actual)

    @inbounds for i in 1:N
        copyto!(temp_vec, s_actual)
        vecino_aleatorio!(temp_vec)
        costo_vecino = costo_local(temp_vec)
        if costo_vecino <= costo_actual + T
            c += 1
            copyto!(s_actual, temp_vec)
            costo_actual = costo_vecino
        end
    end

    return c / N
end

"""
    busqueda_binaria(tsp::TSP, s::Vector{Int}, T1::Float64, T2::Float64, P::Float64, εP::Float64 = 0.01) -> Float64

Realiza una búsqueda binaria para encontrar la temperatura que produce un porcentaje de aceptación cercano a P.
"""
function busqueda_binaria(tsp::TSP, s::Vector{Int}, T1::Float64, T2::Float64, P::Float64, εP::Float64 = 0.01)
    if T2 - T1 < εP
        return (T1 + T2) * 0.5
    end

    Tm = (T1 + T2) * 0.5
    p = porcentaje_aceptados(tsp, s, Tm)

    if abs(P - p) < εP
        return Tm
    elseif p > P
        return busqueda_binaria(tsp, s, T1, Tm, P, εP)
    else
        return busqueda_binaria(tsp, s, Tm, T2, P, εP)
    end
end

"""
    temperatura_inicial(tsp::TSP, s::Vector{Int}, T::Float64, P::Float64, εP::Float64 = 0.01) -> Float64

Calcula la temperatura inicial adecuada para que el porcentaje de aceptación sea cercano a P.
"""
function temperatura_inicial(tsp::TSP, s::Vector{Int}, T::Float64, P::Float64, εP::Float64 = 0.01)
    p = porcentaje_aceptados(tsp, s, T)

    if abs(P - p) <= εP
        return T
    end

    if p < P
        while p < P
            T *= 2.0
            p = porcentaje_aceptados(tsp, s, T)
        end
        T1 = T * 0.5
        T2 = T
    else
        while p > P
            T *= 0.5
            p = porcentaje_aceptados(tsp, s, T)
        end
        T1 = T
        T2 = T * 2.0
    end

    return busqueda_binaria(tsp, s, T1, T2, P, εP)
end