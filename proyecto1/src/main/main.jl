# main.jl - Programa principal

using Random
using SQLite
using DataFrames
using StatsBase
include("estructuras.jl")
include("recocido_simulado.jl")
include("database_reader.jl")

# Función principal
# Función principal
function main(semilla::Int)
    Random.seed!(semilla)
    
    # Buscar y leer archivo .tsp
    archivo_tsp = encontrar_archivo_tsp()
    tsp_input = leer_archivo_tsp(archivo_tsp)
    
    # Construir problema TSP desde la base de datos
    tsp = construir_tsp_desde_db("../bd/tsp.db", tsp_input.path)
    
    # Convertir el path a permutación de índices
    solucion_inicial = ids_a_permutacion(tsp, tsp_input.path)
    
    # Ejecutar optimización
    mejor_solucion, _ = aceptacion_por_umbrales(
        tsp, 
        solucion_inicial,
        L=50,
        φ=0.95,
        ε=0.001,
        max_iteraciones=1000
    )
    
    # Convertir resultado a IDs
    mejor_path_ids = permutacion_a_ids(tsp, mejor_solucion)
    
    # Calcular métricas de la mejor solución
    costo_total = costo_total_solucion(tsp, mejor_solucion)
    costo_normalizado = funcion_costo(tsp, mejor_solucion)
    factible = es_factible(tsp, mejor_solucion) ? "YES" : "NO"
    
    # Imprimir en el formato requerido
    println("Filename: $archivo_tsp")
    println("Path: $(join(mejor_path_ids, ","))")
    println("Maximum: $(tsp.max_distancia)")
    println("Normalizer: $(tsp.normalizador)")
    println("Evaluation: $costo_normalizado")
    println("Feasible: $factible")
    println("Total Cost: $costo_total")
end

# Ejecutar si se proporciona argumento
if length(ARGS) > 0
    semilla = parse(Int, ARGS[1])
    main(semilla)
end