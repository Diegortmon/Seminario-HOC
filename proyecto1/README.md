# TSP Recocido Simulado

Implementación optimizada del algoritmo de Recocido Simulado (Simulated Annealing) para el Problema del Viajante de Comercio (TSP) con grafo no completo.

## Estructura del Proyecto

```
.
├── project.toml                 # Gestión de dependencias Julia
├── README.md                   # Este archivo
├── run.jl                      # Punto de entrada desde la raíz
├── Makefile                    # Comandos automatizados
├── results/                    # Archivos de salida (creado automáticamente)
│   ├── soluciones/             # Soluciones generadas (.tsp)
│   ├── logs/                   # Logs de ejecución
│   └── benchmarks/             # Resultados de benchmarks
└── src/
    ├── bd/                     # Base de datos
    │   ├── tsp.db              # Base de datos SQLite con ciudades y conexiones
    │   └── tsp.sql             # Script SQL (opcional)
    ├── inputs/                 # Archivos de entrada
    │   ├── input-150.tsp       # Instancia de 150 ciudades
    │   ├── input-40.tsp        # Instancia de 40 ciudades
    │   └── input-50.tsp        # Instancia de 50 ciudades
    └── main/                   # Código fuente principal
        ├── Estructuras.jl      # Definición de tipos (Ciudad, TSP, etc.)
        ├── database_reader.jl  # Lectura de datos desde SQLite
        ├── main.jl             # Lógica principal del programa
        ├── recocido_simulado.jl # Algoritmo de recocido simulado
        ├── temperatura.jl      # Cálculo de temperatura inicial
        ├── utilidades.jl       # Funciones auxiliares (costo, factibilidad)
        └── vecinos.jl          # Generación de soluciones vecinas
```

## Setup Inicial

### 1. Instalar Dependencias

```bash
# Desde la raíz del proyecto
julia -e 'using Pkg; Pkg.activate("."); Pkg.instantiate()'

# O usando make
make setup
```

### 2. Verificar Instalación

```bash
# Verificar que todo esté en su lugar
make test

# Ejecutar ejemplo rápido
julia run.jl 42
```

## Uso del Programa

### Ejecución Básica

```bash
# Ejecutar con una semilla específica
julia run.jl 42
julia --threads=auto run.jl 123

# Ejecutar rango de semillas (paralelo)
julia --threads=auto run.jl 1 - 10

# Ejecutar múltiples semillas específicas (paralelo)
julia --threads=auto run.jl 42 123 456 789
```

### Comandos con Make (Recomendado)

```bash
# Setup inicial (una sola vez)
make setup

# Ejecutar con semilla por defecto (42)
make run

# Ejecutar con semilla específica
make run SEED=123

# Ejecutar rango de semillas 1-10 (paralelo)
make run-range

# Ejecutar con número específico de hilos
make run THREADS=16 SEED=456

# Limpiar resultados anteriores
make clean

# Ver ayuda
make help
```

### Seleccionar Archivo de Entrada

Por defecto usa `input-150.tsp`. Para cambiar:

1. Edita `src/main/database_reader.jl`
2. Modifica la función `encontrar_archivo_tsp()`:

```julia
function encontrar_archivo_tsp()
    return "../inputs/input-40.tsp"   # Cambiar aquí
    # return "../inputs/input-50.tsp"
    # return "../inputs/input-150.tsp"
end
```

## Parámetros del Algoritmo

### Parámetros Actuales

El algoritmo usa estos parámetros (en `src/main/main.jl`):

```julia
aceptacion_por_umbrales(
    tsp, 
    solucion_inicial,
    L=40000,              # Tamaño del lote
    φ=0.9,                # Factor de enfriamiento  
    ε=0.0001,             # Criterio de parada
    max_iteraciones=10000000  # Máximo de iteraciones
)
```

### Optimización de Parámetros

Para problemas más pequeños o ejecución más rápida:

```julia
# Para input-40.tsp o input-50.tsp (más rápido)
L=20000,
φ=0.92,
ε=0.001,
max_iteraciones=5000000

# Para input-150.tsp (balanceado)
L=30000,
φ=0.92,
ε=0.0005,
max_iteraciones=6000000

# Para máxima calidad (más lento)
L=50000,
φ=0.88,
ε=0.00001,
max_iteraciones=15000000
```

### Cómo Modificar Parámetros

Edita la función `ejecutar_semilla` en `src/main/main.jl`:

```julia
mejor_solucion, _ = aceptacion_por_umbrales(
    tsp, 
    solucion_inicial,
    L=30000,              # Modificar aquí
    φ=0.92,               # Modificar aquí
    ε=0.0005,             # Modificar aquí
    max_iteraciones=6000000   # Modificar aquí
)
```

## Formato de Salida

Los resultados se guardan en `results/soluciones/salida_<semilla>.tsp`:

```
Filename: ../inputs/input-150.tsp
Path: 1234,5678,9012,3456,...
Maximum: 1234567.89
Normalizer: 987654.32
Evaluation: 1.234567
Feasible: YES
Seed: 42
```

### Campos de Salida

- **Filename**: Archivo de entrada usado
- **Path**: Secuencia de IDs de ciudades (solución)
- **Maximum**: Distancia máxima en el grafo
- **Normalizer**: Factor de normalización usado
- **Evaluation**: Costo normalizado de la solución
- **Feasible**: YES si la solución usa solo aristas válidas, NO si no
- **Seed**: Semilla usada para generar esta solución

## Comandos Disponibles

### Make Commands

| Comando | Descripción |
|---------|------------|
| `make setup` | Instalar dependencias y crear directorios |
| `make run` | Ejecutar con semilla 42 |
| `make run-range` | Ejecutar semillas 1-10 en paralelo |
| `make test` | Verificar estructura del proyecto |
| `make clean` | Limpiar archivos de salida |
| `make help` | Mostrar todos los comandos disponibles |

### Variables de Make

| Variable | Default | Descripción |
|----------|---------|------------|
| `THREADS` | `auto` | Número de hilos Julia |
| `SEED` | `42` | Semilla para ejecución simple |

### Ejemplos de Uso

```bash
# Ejecución básica
make run

# Semilla específica
make run SEED=999

# Más hilos
make run THREADS=8 SEED=123

# Rango con hilos específicos
make run-range THREADS=16

# Ejecutar directamente con Julia
julia --threads=auto run.jl 1 - 5
julia run.jl 42 123 456 789 999
```

## Estructura de Archivos Principales

### Código Principal

- **`src/main/main.jl`**: Punto de entrada, manejo de argumentos, paralelización
- **`src/main/Estructuras.jl`**: Definición de tipos `Ciudad`, `TSP`, `TSPInput`
- **`src/main/recocido_simulado.jl`**: Algoritmo principal de recocido simulado
- **`src/main/temperatura.jl`**: Cálculo automático de temperatura inicial
- **`src/main/vecinos.jl`**: Generación de soluciones vecinas (swap)
- **`src/main/utilidades.jl`**: Función de costo, factibilidad, conversiones
- **`src/main/database_reader.jl`**: Lectura de datos desde SQLite

### Datos

- **`src/bd/tsp.db`**: Base de datos SQLite con información de ciudades y conexiones
- **`src/inputs/*.tsp`**: Archivos con secuencias de IDs de ciudades a resolver

### Configuración

- **`project.toml`**: Dependencias del proyecto Julia
- **`run.jl`**: Script de entrada que activa el proyecto y llama al main
- **`Makefile`**: Automatización de comandos comunes

## Dependencias del Proyecto

### Módulos de Julia Stdlib (incluidos automáticamente)
- **Random**: Generación de números aleatorios controlada por semilla
- **Statistics**: Cálculos estadísticos básicos

### Dependencias Externas (en project.toml)
- **SQLite**: Lectura de base de datos con ciudades y conexiones
- **DataFrames**: Manipulación de datos de la base de datos  
- **StatsBase**: Funciones estadísticas avanzadas (sample, etc.)

### Control de Aleatoriedad

El programa usa una semilla única por ejecución para garantizar reproducibilidad:

```julia
Random.seed!(semilla)           # Controla TODA la aleatoriedad
shuffle(copy(solucion_base))    # Usa la semilla establecida
vecino_aleatorio(solucion)      # Usa la semilla establecida
rand(1:n)                       # Usa la semilla establecida
```

Todas las funciones aleatorias usan la misma semilla para resultados determinísticos.

## Performance y Paralelización

### Multihilo

El programa soporta ejecución paralela automáticamente:

```bash
# Usar todos los hilos disponibles
julia --threads=auto run.jl 1 - 10

# Usar número específico de hilos
julia --threads=8 run.jl 1 - 10
```

### Verificar Hilos Disponibles

```bash
julia -e 'using Base.Threads; println("Hilos disponibles: ", nthreads())'
```

### Optimización de Performance

Para diferentes tamaños de problema:

| Instancia | L | φ | ε | max_iter | Tiempo estimado |
|-----------|---|---|---|----------|----------------|
| input-40.tsp | 15000 | 0.93 | 0.001 | 3000000 | ~30 segundos |
| input-50.tsp | 20000 | 0.92 | 0.001 | 4000000 | ~60 segundos |
| input-150.tsp | 40000 | 0.9 | 0.0001 | 10000000 | ~10 minutos |

## Desarrollo y Debugging

### Modificar el Código

1. Edita archivos en `src/main/`
2. No necesitas recompilar - Julia usa JIT
3. Ejecuta directamente: `julia run.jl 42`

### Debugging

```bash
# Ejecutar con output detallado
julia --threads=auto run.jl 42 2>&1 | tee results/logs/debug.log

# Verificar estructura
make test

# Limpiar y ejecutar
make clean && make run
```

### Logs y Monitoreo

```bash
# Crear log de ejecución
julia run.jl 1 - 5 > results/logs/experimento.log 2>&1

# Monitorear progreso en tiempo real
julia run.jl 1 - 10 | tee results/logs/live.log
```

## Troubleshooting

### Errores Comunes

**Error: "cannot find input file"**