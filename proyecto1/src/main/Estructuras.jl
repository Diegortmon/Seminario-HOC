# Definicion de las estructuras de datos 

# Estructura para representar una ciudad
struct Ciudad
    id::Int
    nombre::String
    x::Float64
    y::Float64
end


# Estructura para representar una ruta entre dos ciudades
struct Ruta
    origen::Ciudad
    destino::Ciudad
    distancia::Float64
end

# FUncion para calcular la distancia de una ruta suponinedo que la tierra es una esfera perfecta
function calcular_distancia(ruta::Ruta)
    R = 6371.0  # Radio de la Tierra en kilómetros
    dlat = deg2rad(ruta.destino.y - ruta.origen.y)
    dlon = deg2rad(ruta.destino.x - ruta.origen.x)
    a = sin(dlat / 2)^2 + cos(deg2rad(ruta.origen.y)) * cos(deg2rad(Ruta.destino.y)) * sin(dlon / 2)^2
    c = 2 * atan2(sqrt(a), sqrt(1 - a))
    distancia = R * c
    return distancia
end



