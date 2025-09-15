# main.jl - Programa principal con paralelismo automático
using Random
using SQLite
using DataFrames
using StatsBase
using Base.Threads

include("estructuras.jl")
include("recocido_simulado.jl")
include("database_reader.jl")

# Lock para sincronizar salida
const output_lock = ReentrantLock()

function main(semilla::Int)
    println("Hilo $(threadid()): Ejecutando semilla $semilla")
    Random.seed!(semilla)
    
    archivo_tsp = encontrar_archivo_tsp()
    tsp_input = leer_archivo_tsp(archivo_tsp)
    tsp = construir_tsp_desde_db("../bd/tsp.db", tsp_input.path)
    solucion_inicial = ids_a_permutacion(tsp, tsp_input.path)
    
    mejor_solucion, _ = aceptacion_por_umbrales(
        tsp, 
        solucion_inicial,
        L=40000,
        φ=0.95,
        ε=0.001,
        max_iteraciones=10000000
    )
    
    mejor_path_ids = permutacion_a_ids(tsp, mejor_solucion)
    costo_total = costo_total_solucion(tsp, mejor_solucion)
    costo_normalizado = funcion_costo(tsp, mejor_solucion)
    factible = es_factible(tsp, mejor_solucion) ? "YES" : "NO"
    
    # Imprimir con lock para evitar mezcla de salida
    lock(output_lock) do
        println("=" ^ 50)
        println("Filename: $archivo_tsp")
        println("Path: $(join(mejor_path_ids, ","))")
        println("Maximum: $(tsp.max_distancia)")
        println("Normalizer: $(tsp.normalizador)")
        println("Evaluation: $costo_normalizado")
        println("Feasible: $factible")
        println("Seed: $semilla")
        println("Thread: $(threadid())")
        println("=" ^ 50)
    end
    
    return (semilla, costo_normalizado, factible, mejor_path_ids, archivo_tsp, tsp.max_distancia, tsp.normalizador)
end

function ejecutar_semillas(semillas::Vector{Int})
    if nthreads() == 1
        println("Advertencia: Ejecutando con 1 hilo. Use --threads=auto para paralelismo")
    else
        println("Ejecutando $(length(semillas)) semillas en $(nthreads()) hilos...")
    end
    
    resultados = Vector{Any}(undef, length(semillas))
    
    if length(semillas) == 1
        # Una sola semilla - ejecutar directamente
        resultados[1] = main(semillas[1])
    else
        # Múltiples semillas - siempre en paralelo
        @threads for i in 1:length(semillas)
            resultados[i] = main(semillas[i])
        end
    end
    
    mostrar_resumen(resultados)
end

function mostrar_resumen(resultados)
    if length(resultados) == 1
        # Una sola semilla - ya se imprimió en main()
        return
    else
        # Múltiples semillas - resumen
        println("\n" * "=" * 60)
        println("RESUMEN DE EJECUCIÓN PARALELA")
        println("=" * 60)
        
        mejor_idx = argmin([r[2] for r in resultados])
        mejor = resultados[mejor_idx]
        
        costos = [r[2] for r in resultados]
        factibles = [r[3] == "YES" for r in resultados]
        
        println("Total ejecutadas: $(length(resultados))")
        println("Hilos utilizados: $(nthreads())")
        println("Soluciones factibles: $(sum(factibles))/$(length(factibles))")
        println("Mejor costo: $(minimum(costos)) (Semilla $(mejor[1]))")
        println("Peor costo: $(maximum(costos))")
        println("Promedio: $(round(sum(costos)/length(costos), digits=6))")
        
        println("\nMEJOR SOLUCIÓN ENCONTRADA:")
        println("Filename: $(mejor[5])")
        println("Path: $(join(mejor[4], ","))")
        println("Maximum: $(mejor[6])")
        println("Normalizer: $(mejor[7])")
        println("Evaluation: $(mejor[2])")
        println("Feasible: $(mejor[3])")
        println("Seed: $(mejor[1])")
        println("=" * 60)
    end
end

function parse_argumentos(args::Vector{String})
    if length(args) == 1
        return [parse(Int, args[1])]
    elseif length(args) == 3 && args[2] == "-"
        inicio = parse(Int, args[1])
        fin = parse(Int, args[3])
        return collect(inicio:fin)
    else
        return [parse(Int, arg) for arg in args]
    end
end

function printUso()
    println("Uso del programa (paralelismo automático):")
    println("  julia --threads=auto main.jl <semilla>")
    println("  julia --threads=auto main.jl <inicio> - <fin>")
    println("  julia --threads=auto main.jl <semilla1> <semilla2> ... <semillan>")
    println()
    println("Ejemplos:")
    println("  julia --threads=auto main.jl 123")
    println("  julia --threads=auto main.jl 100 - 199")
    println("  julia --threads=auto main.jl 123 456 789")
    println()
    println("Nota: Sin --threads=auto ejecutará con 1 hilo")
    println("Hilos disponibles actualmente: $(nthreads())")
end

# Ejecutar
if length(ARGS) > 0
    try
        semillas = parse_argumentos(ARGS)
        ejecutar_semillas(semillas)
    catch e
        println("Error parseando argumentos: $e")
        printUso()
    end
else
    printUso()
end