# aceptacion_umbrales.jl - Implementación del algoritmo de Aceptación por Umbrales

include("estructuras.jl")
include("utilidades.jl")
include("vecinos.jl")
include("temperatura.jl")

# Calcula un lote según el Procedimiento 1
function calcula_lote(tsp::TSP, L::Int, T::Float64, s::Vector{Int}, max_intentos::Int = 10 * L)
    c = 0
    r = 0.0
    intentos = 0
    s_actual = copy(s)
    
    while c < L && intentos < max_intentos
        s_prima = vecino_aleatorio(s_actual)
        
        if funcion_costo(tsp, s_prima) <= funcion_costo(tsp, s_actual) + T
            s_actual = s_prima
            c += 1
            r += funcion_costo(tsp, s_prima)
        end
        
        intentos += 1
    end
    
    if c == 0
        return Inf, s_actual
    end
    
    return r / c, s_actual
end

# Algoritmo principal de Aceptación por Umbrales
function aceptacion_por_umbrales(tsp::TSP, s::Vector{Int}; 
                                L::Int = 50,
                                φ::Float64 = 0.95,
                                ε::Float64 = 0.001,
                                T_inicial::Float64 = 8.0,
                                P::Float64 = 0.9,
                                max_iteraciones::Int = 1000)
    
    # Calcular temperatura inicial
    T = temperatura_inicial(tsp, s, T_inicial, P)
    
    # Variables para rastrear la mejor solución
    mejor_solucion = copy(s)
    mejor_costo = funcion_costo(tsp, s)
    
    iteracion = 0
    
    while T > ε && iteracion < max_iteraciones
        iteracion += 1
        p = 0.0
        q = Inf
        
        # Buscar equilibrio térmico
        intentos_equilibrio = 0
        max_intentos_equilibrio = 5
        
        while p <= q && intentos_equilibrio < max_intentos_equilibrio
            q = p
            p, s = calcula_lote(tsp, L, T, s)
            intentos_equilibrio += 1
            
            if p == Inf
                break
            end
            
            # Actualizar mejor solución si es necesario
            costo_actual = funcion_costo(tsp, s)
            if costo_actual < mejor_costo
                mejor_solucion = copy(s)
                mejor_costo = costo_actual
            end
            
            if abs(p - q) < 0.001
                break
            end
        end
        
        # Enfriar el sistema
        T *= φ
    end
    
    return mejor_solucion, mejor_costo
end