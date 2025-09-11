# database_reader.jl - Manejo de entrada/salida y base de datos

using SQLite
using DataFrames
using DBInterface
include("estructuras.jl")
include("utilidades.jl")

# Lee un archivo .tsp que solo contiene la secuencia de IDs
function leer_archivo_tsp(archivo::String)
    content = strip(read(archivo, String))
    path = [parse(Int, x) for x in split(content, ",")]
    return TSPInput(path)
end

# Carga ciudades desde la base de datos
function cargar_ciudades_desde_db(db_path::String, city_ids::Vector{Int})
    db = SQLite.DB(db_path)
    
    # Crear la consulta SQL para obtener las ciudades
    ids_str = join(city_ids, ",")
    query = "SELECT id, name, country, population, latitude, longitude FROM cities WHERE id IN ($ids_str)"
    
    result = DBInterface.execute(db, query) |> DataFrame
    
    ciudades = Ciudad[]
    for row in eachrow(result)
        push!(ciudades, Ciudad(
            row.id,
            row.name,
            row.country,
            row.population,
            row.latitude,
            row.longitude
        ))
    end
    
    # Crear mapeo de ID a índice
    city_id_to_index = Dict{Int, Int}()
    for (i, ciudad) in enumerate(ciudades)
        city_id_to_index[ciudad.id] = i
    end
    
    SQLite.close(db)
    return ciudades, city_id_to_index
end

# Carga las conexiones desde la base de datos
function cargar_conexiones_desde_db(db_path::String, city_ids::Vector{Int})
    db = SQLite.DB(db_path)
    
    # Crear la consulta SQL para obtener las conexiones
    ids_str = join(city_ids, ",")
    query = """
    SELECT id_city_1, id_city_2, distance 
    FROM connections 
    WHERE id_city_1 IN ($ids_str) AND id_city_2 IN ($ids_str)
    """
    
    result = DBInterface.execute(db, query) |> DataFrame
    
    SQLite.close(db)
    return result
end

# Construye el problema TSP desde la base de datos
function construir_tsp_desde_db(db_path::String, city_ids::Vector{Int})
    # Cargar ciudades
    ciudades, city_id_to_index = cargar_ciudades_desde_db(db_path, city_ids)
    n = length(ciudades)
    
    # Inicializar matrices
    grafica = falses(n, n)
    distancias = zeros(Float64, n, n)
    
    # Calcular todas las distancias naturales
    for i in 1:n
        for j in 1:n
            if i != j
                distancias[i, j] = distancia_natural(ciudades[i], ciudades[j])
            end
        end
    end
    
    # Cargar conexiones desde la base de datos
    conexiones = cargar_conexiones_desde_db(db_path, city_ids)
    
    # Actualizar la matriz de adyacencia con las conexiones reales
    for row in eachrow(conexiones)
        id1 = row.id_city_1
        id2 = row.id_city_2
        
        if haskey(city_id_to_index, id1) && haskey(city_id_to_index, id2)
            i = city_id_to_index[id1]
            j = city_id_to_index[id2]
            
            grafica[i, j] = true
            grafica[j, i] = true  # Asumiendo que es no dirigida
            
            # Usar la distancia de la base de datos si está disponible
            if !ismissing(row.distance) && row.distance > 0
                distancias[i, j] = row.distance
                distancias[j, i] = row.distance
            end
        end
    end
    
    # Calcular distancia máxima
    max_dist = 0.0
    for i in 1:n
        for j in 1:n
            if grafica[i, j] && distancias[i, j] > max_dist
                max_dist = distancias[i, j]
            end
        end
    end
    
    # Calcular normalizador
    distancias_existentes = Float64[]
    for i in 1:n
        for j in i+1:n
            if grafica[i, j]
                push!(distancias_existentes, distancias[i, j])
            end
        end
    end
    
    sort!(distancias_existentes, rev=true)
    k = min(length(distancias_existentes), n - 1)
    normalizador = k > 0 ? sum(distancias_existentes[1:k]) : 1.0
    
    return TSP(ciudades, grafica, distancias, max_dist, normalizador, city_id_to_index)
end

# Busca el archivo .tsp en el directorio actual
function encontrar_archivo_tsp()
    return "../inputs/input-40.tsp"
end