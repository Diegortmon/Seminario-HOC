.PHONY: setup test run clean help

# Variables
JULIA = julia
SEED = 42

# Crear directorio de resultados
setup:
	@echo "Configurando proyecto..."
	mkdir -p results/soluciones results/logs results/benchmarks
	$(JULIA) -e 'using Pkg; Pkg.activate("."); Pkg.instantiate()'

# Ejecución
run:
	@echo "Ejecutando algoritmo..."
	$(JULIA) run.jl $(SEED)

run-range:
	@echo "Ejecutando rango de semillas..."
	$(JULIA) run.jl 1 - 10

# Test básico
test:
	@echo "Verificando estructura..."
	@test -f src/main/main.jl && echo "✅ main.jl encontrado"
	@test -f src/bd/tsp.db && echo "✅ base de datos encontrada"
	@test -f src/inputs/input-150.tsp && echo "✅ archivo de entrada encontrado"

# Limpieza
clean:
	@echo "Limpiando archivos temporales..."
	rm -rf results/soluciones/*.tsp
	rm -rf results/logs/*.log

help:
	@echo "Comandos disponibles:"
	@echo "  setup      - Configurar proyecto"
	@echo "  run        - Ejecutar con semilla por defecto"
	@echo "  run-range  - Ejecutar semillas 1-10"
	@echo "  test       - Verificar estructura"
	@echo "  clean      - Limpiar archivos temporales"
	@echo ""
	@echo "Variables:"
	@echo "  SEED       - Semilla (default: 42)"	