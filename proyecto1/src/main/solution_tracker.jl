using Dates

"""
    SolutionRecord

Estructura para registrar cada solución encontrada.
"""
struct SolutionRecord
    iteracion::Int
    temperatura::Float64
    costo_normalizado::Float64
    es_mejor::Bool
    es_aceptada::Bool
    tipo::String
    timestamp::Float64
end

"""
    AllSolutionsTracker

Tracker que guarda todas las soluciones encontradas durante la ejecución.
"""
mutable struct AllSolutionsTracker
    semilla::Int
    archivo_salida::String
    tiempo_inicio::Float64
    ultimo_costo::Float64
    mejor_costo_global::Float64

    function AllSolutionsTracker(semilla::Int)
        archivo = "results/evolution/all_solutions_$semilla.csv"
        mkpath(dirname(archivo))
        tracker = new(
            semilla,
            archivo,
            time(),
            Inf,
            Inf
        )
        open(archivo, "w") do f
            println(f, "iteracion,temperatura,costo_normalizado,es_mejor,es_aceptada,tipo,tiempo_relativo")
        end
        return tracker
    end
end

"""
    registrar_solucion!(tracker, iteracion, temperatura, costo, es_aceptada; tipo="recocido")

Registra cualquier solución encontrada en el archivo de tracking.
"""
function registrar_solucion!(tracker::AllSolutionsTracker, iteracion::Int, temperatura::Float64, 
                            costo::Float64, es_aceptada::Bool, tipo::String = "recocido")
    tiempo_relativo = time() - tracker.tiempo_inicio
    es_mejor = costo < tracker.ultimo_costo
    if costo < tracker.mejor_costo_global
        tracker.mejor_costo_global = costo
    end
    if es_aceptada
        tracker.ultimo_costo = costo
    end
    open(tracker.archivo_salida, "a") do f
        println(f, "$iteracion,$temperatura,$costo,$es_mejor,$es_aceptada,$tipo,$tiempo_relativo")
    end
end

"""
    registrar_inicial!(tracker, costo)

Registra la solución inicial.
"""
function registrar_inicial!(tracker::AllSolutionsTracker, costo::Float64)
    tracker.ultimo_costo = costo
    tracker.mejor_costo_global = costo
    registrar_solucion!(tracker, 0, 0.0, costo, true, "inicial")
end

"""
    registrar_evaluacion!(tracker, iteracion, temperatura, costo_actual, costo_vecino, fue_aceptado)

Registra la evaluación de una solución durante el recocido.
"""
function registrar_evaluacion!(tracker::AllSolutionsTracker, iteracion::Int, temperatura::Float64,
                              costo_actual::Float64, costo_vecino::Float64, fue_aceptado::Bool)
    registrar_solucion!(tracker, iteracion, temperatura, costo_vecino, fue_aceptado, "recocido")
end

"""
    registrar_barrido!(tracker, iteracion_base, costo, es_mejor)

Registra una mejora encontrada durante el barrido.
"""
function registrar_barrido!(tracker::AllSolutionsTracker, iteracion_base::Int, costo::Float64, es_mejor::Bool)
    if es_mejor
        registrar_solucion!(tracker, iteracion_base + 1000, 0.0, costo, true, "barrido")
    end
end

"""
    finalizar_tracker!(tracker)

Finaliza el tracking e imprime información resumen.
"""
function finalizar_tracker!(tracker::AllSolutionsTracker)
    println("Todas las soluciones guardadas en: $(tracker.archivo_salida)")
    println("Mejor costo encontrado: $(tracker.mejor_costo_global)")
end