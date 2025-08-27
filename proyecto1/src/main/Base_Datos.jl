using SQLite
using Dates
include("Estructuras.jl")

mutable struct BaseDatos
    db::SQLite.DB
    db_path::String
end

#Constructor para la base de datos
function BaseDatos(db_path::String)
    db = SQLite.DB(db_path)
    return BaseDatos(db, db_path)
end
