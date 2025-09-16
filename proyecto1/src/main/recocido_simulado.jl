# recocido_simulado.jl - SOLO OPTIMIZACIONES TÉCNICAS

include("estructuras.jl")
include("utilidades.jl")
include("vecinos.jl")
include("temperatura.jl")

"""
    costo_cached(tsp::TSP, permutacion::Vector{Int}, distancias::Matrix{Float64}, normalizador::Float64) -> Float64

Calcula el costo total de una permutación usando referencias cacheadas a la matriz de distancias y el normalizador.
"""
@inline function costo_cached(tsp::TSP, permutacion::Vector{Int}, distancias::Matrix{Float64}, normalizador::Float64)
    costo_total = 0.0
    n = length(permutacion)
    @inbounds for i in 2:n
        costo_total += distancias[permutacion[i-1], permutacion[i]]
    end
    return costo_total / normalizador
end

"""
    calcula_lote(tsp::TSP, L::Int, T::Float64, s::Vector{Int}, max_intentos::Int = 100 * L) -> Tuple{Float64, Vector{Int}}

Realiza un lote de iteraciones para el algoritmo de recocido simulado, devolviendo el costo promedio y la mejor solución encontrada.
"""
function calcula_lote(tsp::TSP, L::Int, T::Float64, s::Vector{Int}, max_intentos::Int = 100 * L)
    c = 0
    r = 0.0
    intentos = 0
    s_actual = copy(s)
    distancias = tsp.distancias
    normalizador = tsp.normalizador
    costo_s_actual = costo_cached(tsp, s_actual, distancias, normalizador)
    while c < L && intentos < max_intentos
        s_prima = vecino_aleatorio(s_actual)
        costo_s_prima = costo_cached(tsp, s_prima, distancias, normalizador)
        if costo_s_prima <= costo_s_actual + T
            s_actual = s_prima
            costo_s_actual = costo_s_prima
            c += 1
            r += costo_s_prima
        end
        intentos += 1
    end
    if c == 0
        return Inf, s_actual
    end
    return r / c, s_actual
end

"""
    aceptacion_por_umbrales(tsp::TSP, s::Vector{Int}; L::Int, φ::Float64, ε::Float64, T_inicial::Float64 = 8.0, P::Float64 = 0.9, max_iteraciones::Int) -> Tuple{Vector{Int}, Float64}

Implementa el algoritmo de aceptación por umbrales para el TSP, devolviendo la mejor solución y su costo.
"""
function aceptacion_por_umbrales(tsp::TSP, s::Vector{Int}; 
                                L::Int,
                                φ::Float64,
                                ε::Float64,
                                T_inicial::Float64 = 8.0,
                                P::Float64 = 0.9,
                                max_iteraciones::Int)
    distancias = tsp.distancias
    normalizador = tsp.normalizador
    T = temperatura_inicial(tsp, s, T_inicial, P)
    mejor_solucion = copy(s)
    mejor_costo = costo_cached(tsp, s, distancias, normalizador)
    iteracion = 0
    while T > ε && iteracion < max_iteraciones
        iteracion += 1
        p = 0.0
        q = Inf
        intentos_equilibrio = 0
        max_intentos_equilibrio = 5
        while p <= q && intentos_equilibrio < max_intentos_equilibrio
            q = p
            p, s = calcula_lote(tsp, L, T, s)
            intentos_equilibrio += 1
            if p == Inf
                break
            end
            costo_actual = costo_cached(tsp, s, distancias, normalizador)
            if costo_actual < mejor_costo
                mejor_solucion = copy(s)
                mejor_costo = costo_actual
            end
            if abs(p - q) < 0.001
                break
            end
        end
        T *= φ
    end
    return mejor_solucion, mejor_costo
end

"""
    barrido(tsp::TSP, solucion::Vector{Int}) -> Vector{Int}

Realiza un barrido 2-opt sobre la solución dada, devolviendo la mejor solución encontrada.
"""
function barrido(tsp::TSP, solucion::Vector{Int})
    mejor_solucion = copy(solucion)
    distancias = tsp.distancias
    normalizador = tsp.normalizador
    mejor_costo = costo_cached(tsp, mejor_solucion, distancias, normalizador)
    n = length(solucion)
    vecino = Vector{Int}(undef, n)
    mejorado = true
    while mejorado
        mejorado = false
        for i in 1:n-1
            for j in i+2:n
                copyto!(vecino, mejor_solucion)
                reverse!(vecino, i+1, j)
                costo_vecino = costo_cached(tsp, vecino, distancias, normalizador)
                if costo_vecino < mejor_costo
                    copyto!(mejor_solucion, vecino)
                    mejor_costo = costo_vecino
                    mejorado = true
                end
            end
        end
    end
    return mejor_solucion
end