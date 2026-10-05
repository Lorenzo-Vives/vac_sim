# Reproducción de las simulaciones

Este documento separa los insumos públicos, los ajustes ya estimados y las
simulaciones precomputadas. La reproducción propuesta vuelve a ejecutar el
modelo epidemiológico; no usa `Output/models/reference.rda` como insumo.

## Qué se puede reproducir

Se puede reproducir la simulación estocástica de 2010--2019 a partir de:

- los ajustes públicos de `Output/cprd_degree/` y `Output/cover_degree/`;
- las coberturas derivadas y escenarios de `Data/`;
- la población regional, la matriz POLYMOD y las introducciones codificadas;
- el modelo `seirvodin`.

No se puede reconstruir de manera independiente:

- la estimación de cobertura desde los microdatos CPRD (`outcomes.parquet`,
  `study_population.parquet` y `nhs_vacc.parquet` no son públicos);
- el ajuste del modelo a los casos individuales de UKHSA, porque esos casos no
  son públicos.

Por tanto, esta es una reproducción de la etapa de simulación condicionada a
los parámetros ajustados públicos, no una reproducción completa desde
microdatos hasta posterior.

## Flujo real y orden

### Referencia CPRD sin waning

1. No ejecutar `R/Measles_coverage_scenarios_creation.R`. Su etapa inicial
   necesita datos CPRD privados y un objeto externo `datafiles`.
2. Usar los derivados públicos ya incluidos. Para `reference`, el modelo lee:
   `Data/Coverage_reg_year_orig_extrapol.csv`,
   `Data/regional_population.csv` y `Data/risk_assessment_ukhsa.csv`.
   `Data/coverage_cprd_extrapol.csv` es una copia byte a byte del primer
   archivo.
3. Leer el ajuste público `Output/cprd_degree/no.RDS`.
4. Construir población, nacimientos, coberturas diarias, matriz regional,
   matriz de contacto y tasa de introducciones con
   `R/function_vaccination_data.R`.
5. Generar nuevas trayectorias con `seirvodin::generate_outbreaks()` mediante
   `R/replicate_reference.R`.
6. Sólo después, comparar con `Output/models/reference.rda` mediante
   `R/compare_reference_replication.R`.
7. Crear la figura de referencia desde la salida nueva con
   `R/figure_reference_replication.R`.

### Familias completas del estudio

Los scripts originales corresponden a:

| Etapa | Script | Cobertura | Ajuste |
|---|---|---|---|
| Principal | `R/Outbreak_scenarios_CPRD.R` | CPRD derivada | `Output/cprd_degree/no.RDS` |
| Sensibilidad waning desde 5 | `R/Outbreak_scenarios_CPRD_waning.R` | CPRD derivada | `Output/cprd_degree/since_vax.RDS` |
| Sensibilidad waning desde 3 | `R/Outbreak_scenarios_CPRD_waning_from3.R` | CPRD derivada | `Output/cprd_degree/since_vax.RDS` |
| Sensibilidad COVER | `R/Outbreak_scenarios_COVER.R` | COVER derivada | `Output/cover_degree/no.RDS` |
| Cambio sólo desde 2015 | `R/Sensitivity_analyses_2015.R` | CPRD derivada | `Output/cprd_degree/no.RDS` |

`R/Measles_coverage_scenarios_creation_NHS.R` transforma el archivo COVER
derivado en escenarios alternativos. No recupera desde cero la parte CPRD
usada para extrapolar edades 3 y 4.

`R/script_sensitivity_scenarios_waning.R` es código legado incompleto: refiere
a `R/function_import_data.R`, `R/function_generate_outbreak.R` y
`R/model_odin_dust.R`, que no existen en este repositorio. No forma parte del
flujo descrito en el README.

## Datos de cobertura por escenario

La selección efectiva se hace en `import_ehr_vaccine()`:

| Escenario | Archivo principal |
|---|---|
| `reference`, CPRD | `Data/Coverage_reg_year_orig_extrapol.csv` |
| `reference`, COVER | `Data/Coverage_reg_year_nhs_extrapol.csv` |
| `early slow` | `Data/Coverage_slowearlysecond.csv` |
| `MMR2_at5` | `Data/MMR2_at_5.csv` |
| `MMR2_as_MMR1` | `Data/Coverage_MMR2likeMMR1.csv` |
| `D1_025`, `D1_05`, `D1_1` | `Data/d1_025.csv`, `d1_05.csv`, `d1_1.csv` |
| `D2_025`, `D2_05`, `D2_1`, `D2_3` | `Data/d2_025.csv`, `d2_05.csv`, `d2_1.csv`, `d2_3.csv` |
| `D2_earlyplus025/05/1` | `Data/Coverage_earlyplus025/05/1.csv` |
| `earlyminus3/5` | `Data/Coverage_earlyminus3/5.csv` |
| `CPRD_earlyMMR2_2015` | `Data/EarlyMMR2_2015.csv` |
| escenarios COVER | archivos `Data/COVER_*.csv` correspondientes |

Hay cuatro rutas referidas por `import_ehr_vaccine()` que no están presentes:
`Cov2minus10.csv`, `Cov2minus50.csv`, `Cove2zero.csv` y
`Coverage_reg_year_Londonpattern_extrapol.csv`. Ninguna es necesaria para
`reference` ni para los escenarios principales que ejecutan los cuatro scripts
del README.

## Ajustes versus resultados precomputados

Son insumos permitidos porque contienen las cadenas posteriores ajustadas:

- `Output/cprd_degree/no.RDS`: 20 000 filas, 19 parámetros;
- `Output/cprd_degree/since_vax.RDS`: 20 000 filas, 20 parámetros;
- `Output/cover_degree/no.RDS`: 20 000 filas, 19 parámetros;
- `Output/cover_degree/since_vax.RDS`: 20 000 filas, 20 parámetros.

No deben usarse como entrada de una réplica independiente de simulación:

- todos los `Output/models/*.rda` (aunque la extensión sea `.rda`, fueron
  escritos con `saveRDS()`);
- `Output/Summary_table_*.csv`, `Output/regional_cases*.csv` y
  `Output/yearly_cases*.csv`;
- las imágenes de `Figures/`.

Esos objetos sirven sólo para comparación posterior. `Data/sim_data.RDS` es un
conjunto sintético de casos, no una trayectoria del escenario reference.

## Ejecución en una sesión nueva

Desde la raíz del repositorio:

```r
install.packages(c(
  "dplyr", "socialmixr", "tidyr", "data.table", "ggplot2", "devtools"
))
install.packages(
  c("mcstate", "odin.dust"),
  repos = c("https://mrc-ide.r-universe.dev", "https://cloud.r-project.org")
)
remotes::install_github(
  "alxsrobert/seirvodin@ed0de4da83d248b3bf5a2d3e74a7a3dad52054bd",
  upgrade = "never", build_vignettes = FALSE
)
```

En Windows, instalar Rtools de la misma serie que R antes de instalar
`seirvodin`. La configuración comprobada fue R 4.5.3, `seirvodin` 1.0,
`socialmixr` 0.7.0, `odin.dust` 0.3.13, `dust` 0.15.3 y `mcstate` 0.9.22.
El SHA de `seirvodin` comprobado fue
`ed0de4da83d248b3bf5a2d3e74a7a3dad52054bd`.

Prueba rápida, cuatro simulaciones:

```powershell
Rscript R/replicate_reference.R
Rscript R/compare_reference_replication.R
Rscript R/figure_reference_replication.R
```

Configuración del paper, 2 500 simulaciones:

```powershell
Rscript R/replicate_reference.R --full
Rscript R/compare_reference_replication.R
Rscript R/figure_reference_replication.R
```

La salida nueva queda en
`Output/replication/reference_replication.rds`; nunca sobrescribe
`Output/models/reference.rda`. Se guarda además metadata con versiones y
tiempo de ejecución.

En la prueba rápida verificada, las cuatro trayectorias nuevas fueron idénticas
celda por celda a las columnas correspondientes de la salida original. Las dos
primeras coincidieron con las columnas 1--2; las otras dos, que usan la fila
posterior 7501 después del burn-in, coincidieron con las columnas 1251--1252.
`R/compare_reference_replication.R` repite automáticamente esta comprobación
para todas las filas posteriores compartidas.

`n_samples` es el número de filas de la cadena posterior seleccionadas después
de descartar `burnin = 5000`. `n_part` es el número de realizaciones
estocásticas por fila posterior. El total es:

```text
número de simulaciones = n_samples * n_part
```

El análisis principal usa `100 * 25 = 2500`. El script COVER original usa
`25 * 100 = 2500`. En `seirvodin 1.0`, los valores 1 activan dos bugs de
simplificación de dimensiones; por eso la prueba mínima usa 2 y 2.

## Compatibilidad corregida

- `socialmixr`: `age.limits` fue reemplazado por `age_limits`. La población UK
  2005 que antes se buscaba implícitamente en WPP2017 quedó fijada de forma
  explícita. La matriz resultante es idéntica elemento por elemento a la del
  código anterior con `socialmixr 0.7.0`.
- `polymod`: se carga explícitamente desde `socialmixr`.
- `seirvodin`: el modelo 1.0 contiene dos condiciones `i >= 1` que permiten un
  acceso a `array_cov1[i - 1, ...]` para el primer grupo. En Windows actual eso
  termina R con `0xC0000005`. `R/function_model_compatibility.R` verifica que
  existan exactamente esas dos expresiones, las cambia a `i > 1` en una copia
  temporal y compila esa copia. No altera el paquete instalado.
- Se eliminó la instalación de GitHub durante la ejecución de los scripts y se
  parametrizaron `n_samples` y `n_part`.
- Los objetos `vax` ya no se ignoran al llamar `import_all_data()`.

## Parámetros modificables

- Transmisión y epidemiología ajustada: columnas de `$pars` en los cuatro
  `Output/*_degree/*.RDS`. Incluyen `beta`, `delta`, `X`, `Y`, `X_import`,
  `Y_import`, `v_fail`, `vacc`, `report_import`, `theta`, `b`, `c`, estados
  recuperados iniciales y coberturas catch-up. Los ajustes con waning añaden
  `v_leak`.
- Periodos fijos: `alpha = 11` días de incubación y `gamma = 8` días infeccioso
  son los valores por defecto de `seirvodin::specs_simulations()`.
- Vacunación y timing MMR1/MMR2: archivos de cobertura de `Data/` y reglas de
  `import_ehr_vaccine()` en `R/function_vaccination_data.R`. El timing se
  representa como cobertura acumulada por edad/cohorte, no como un único
  parámetro escalar.
- Waning: `waning = "no"`, `"since_vax"` (desde edad 5) o `"early"`
  (sensibilidad desde edad 3), junto con `v_leak` del ajuste
  `since_vax.RDS`.
- Introducciones: matriz anual por región en `compute_importation()`; dentro de
  `seirvodin` se divide por `report_import`. La estacionalidad usa
  `X_import`/`Y_import`.
- Mezcla: POLYMOD en `compute_contact_matrix()` y matriz espacial en
  `compute_region_matrix()`; `theta`, `b` y `c` controlan el kernel espacial.
- Población y nacimientos: `Data/regional_population.csv` y
  `compute_n_birth()`.

## Figuras con simulaciones nuevas

`R/figure_reference_replication.R` reproduce el panel reference versus
vigilancia desde la réplica nueva. Una prueba de cuatro trayectorias sólo valida
el flujo; sus intervalos no son publicables.

Las demás figuras de `R/all_figures.R` comparan dos o más escenarios. Para
reproducirlas independientemente hay que generar primero cada escenario
requerido con los mismos ajustes y guardar todas las salidas bajo
`Output/replication/`. Sólo entonces se deben adaptar las rutas de
`R/function_figures.R`/`R/all_figures.R`; no se deben mezclar escenarios nuevos
con `Output/models/*.rda` originales.
