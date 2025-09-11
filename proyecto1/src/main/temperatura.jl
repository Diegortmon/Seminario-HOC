# temperatura.jl - Funciones para el cálculo de temperatura inicial

include("estructuras.jl")
include("utilidades.jl")
include("vecinos.jl")

# Calcula el porcentaje de soluciones aceptadas
function porcentaje_aceptados(tsp::TSP, s::Vector{Int}, T::Float64, N::Int = 100)
    c = 0
    s_actual = copy(s)
    
    for i in 1:N
        s_prima = vecino_aleatorio(s_actual)
        
        if funcion_costo(tsp, s_prima) <= funcion_costo(tsp, s_actual) + T
            c += 1
            s_actual = s_prima
        end
    end
    
    return c / N
end

# Búsqueda binaria para encontrar temperatura
function busqueda_binaria(tsp::TSP, s::Vector{Int}, T1::Float64, T2::Float64, P::Float64, εP::Float64 = 0.01)
    if T2 - T1 < εP
        return (T1 + T2) / 2
    end
    
    Tm = (T1 + T2) / 2
    p = porcentaje_aceptados(tsp, s, Tm)
    
    if abs(P - p) < εP
        return Tm
    elseif p > P
        return busqueda_binaria(tsp, s, T1, Tm, P, εP)
    else
        return busqueda_binaria(tsp, s, Tm, T2, P, εP)
    end
end

# Calcula la temperatura inicial
function temperatura_inicial(tsp::TSP, s::Vector{Int}, T::Float64, P::Float64, εP::Float64 = 0.01)
    p = porcentaje_aceptados(tsp, s, T)
    
    if abs(P - p) <= εP
        return T
    end
    
    if p < P
        while p < P
            T *= 2
            p = porcentaje_aceptados(tsp, s, T)
        end
        T1 = T / 2
        T2 = T
    else
        while p > P
            T /= 2
            p = porcentaje_aceptados(tsp, s, T)
        end
        T1 = T
        T2 = 2 * T
    end
    
    return busqueda_binaria(tsp, s, T1, T2, P, εP)
end