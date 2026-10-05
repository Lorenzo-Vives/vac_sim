# Resumen de la replicación de las simulaciones

La cadena de simulación del escenario `reference` quedó funcionando con los
datos derivados y los parámetros ajustados públicos del repositorio. Se
generaron las 2500 trayectorias de la configuración del paper: el proceso no
carga
`Output/models/reference.rda` como insumo y no sobrescribe ningún resultado
original.

## Resultado principal

La ejecución completa, con `n_samples = 100` y `n_part = 25`, produjo un objeto
de dimensiones `324 x 2500 x 10`. El objeto nuevo es literalmente idéntico al
resultado original (`identical = TRUE`), todas las 2500 trayectorias coinciden
y la diferencia máxima es `0`. Todos sus valores son finitos y no negativos.

Antes de la ejecución completa, la prueba rápida con `n_samples = 2` y
`n_part = 2` produjo cuatro
simulaciones nuevas con dimensiones `324 x 4 x 10`. Las cuatro trayectorias
coincidieron exactamente, celda por celda, con las columnas correspondientes
del resultado original:

- simulaciones nuevas 1 y 2: columnas originales 1 y 2;
- simulaciones nuevas 3 y 4: columnas originales 1251 y 1252;
- diferencia máxima observada: `0`.

Esta coincidencia demuestra que las correcciones de compatibilidad conservan
el comportamiento publicado del modelo para las mismas muestras posteriores y
semillas.

En la prueba rápida, el número total de casos fue `6136`, `7084`, `8498` y
`7324`. Su mediana fue `7204` y su intervalo intercuartílico fue
`6847–7617.5`. Estos cuatro valores sólo validan la ejecución y no sustituyen
la distribución completa del paper.

La réplica completa y el resultado original de 2500 simulaciones comparten:

- mediana: `7169`;
- intervalo intercuartílico: `6096.5–8534.5`;
- intervalo central del 95 %: `4556.325–11712.175`;
- rango: `3551–18715`.

Los resúmenes anuales también coinciden exactamente. La mediana y el intervalo
intercuartílico son los valores publicados en el artículo.

## Siguientes pasos

1. Aplicar el mismo flujo de ejecución segura a los demás escenarios de
   cobertura, timing de MMR2, COVER y waning, guardándolos en
   `Output/replication/`.
2. Comparar cada escenario nuevo con su equivalente precomputado, sin utilizar
   este último como entrada del modelo.
3. Adaptar `R/all_figures.R` y sus funciones auxiliares para que lean
   exclusivamente los escenarios nuevos.
4. Regenerar las figuras comparativas principales del paper y documentar qué
   escenarios son reproducibles con los archivos públicos disponibles.

## Cómo ejecutar la réplica

Desde una sesión nueva, situada en la raíz del repositorio, la prueba rápida se
ejecuta con:

```powershell
Rscript R/replicate_reference.R
Rscript R/compare_reference_replication.R
Rscript R/figure_reference_replication.R
```

La configuración completa del paper se ejecuta con:

```powershell
Rscript R/replicate_reference.R --full
Rscript R/compare_reference_replication.R
Rscript R/figure_reference_replication.R `
  Output/replication/reference_replication.rds `
  Output/replication/Reference_Surveillance_replication_full.png
```

Si `Rscript` no está en el `PATH` de Positron, puede lanzarse desde R con:

```r
system2(
  file.path(R.home("bin"), "Rscript"),
  c("R/replicate_reference.R", "--full")
)
```

La simulación nueva se guarda en:

```text
Output/replication/reference_replication.rds
```

La metadata, comparaciones y figura completa también quedan bajo
`Output/replication/`. Los objetos originales de `Output/models/` no se
modifican.

## Relación entre muestras, partículas y simulaciones

`n_samples` es el número de filas de la cadena posterior usadas después del
`burnin`. `n_part` es el número de realizaciones estocásticas ejecutadas por
cada fila posterior.

```text
número total de simulaciones = n_samples * n_part
```

Por tanto:

- prueba rápida: `2 * 2 = 4` simulaciones;
- configuración principal del paper: `100 * 25 = 2500` simulaciones;
- el script COVER original invierte la descomposición, `25 * 100`, pero también
  genera `2500` simulaciones.

Con `seirvodin 1.0`, usar `1` en cualquiera de esos dos parámetros activa
problemas de simplificación de dimensiones. Por eso la prueba mínima usa
`n_samples = 2` y `n_part = 2`.

## Flujo de reproducción

Para el escenario de referencia:

1. No ejecutar `R/Measles_coverage_scenarios_creation.R`, porque requiere
   microdatos CPRD privados.
2. Usar los datos derivados públicos de `Data/`, en particular
   `Coverage_reg_year_orig_extrapol.csv`, `regional_population.csv` y
   `risk_assessment_ukhsa.csv`.
3. Cargar el ajuste público `Output/cprd_degree/no.RDS`.
4. Construir coberturas, población, nacimientos, contactos, mezcla regional e
   introducciones mediante `R/function_vaccination_data.R`.
5. Ejecutar el modelo con `R/replicate_reference.R`.
6. Comparar con el resultado precomputado sólo después de haber generado la
   simulación nueva.
7. Crear figuras desde la salida nueva.

Los scripts que representan las familias de simulaciones del estudio son:

| Etapa | Script | Ajuste público |
|---|---|---|
| Principal CPRD | `R/Outbreak_scenarios_CPRD.R` | `Output/cprd_degree/no.RDS` |
| Waning desde edad 5 | `R/Outbreak_scenarios_CPRD_waning.R` | `Output/cprd_degree/since_vax.RDS` |
| Waning desde edad 3 | `R/Outbreak_scenarios_CPRD_waning_from3.R` | `Output/cprd_degree/since_vax.RDS` |
| Sensibilidad COVER | `R/Outbreak_scenarios_COVER.R` | `Output/cover_degree/no.RDS` |
| Cambio desde 2015 | `R/Sensitivity_analyses_2015.R` | `Output/cprd_degree/no.RDS` |

## Qué es reproducible y qué no

Es reproducible la etapa de simulación estocástica de 2010–2019, condicionada
a:

- los ajustes públicos de `Output/cprd_degree/` y `Output/cover_degree/`;
- las coberturas derivadas y los escenarios incluidos en `Data/`;
- la población regional, POLYMOD, las introducciones y el modelo
  `seirvodin`.

No es posible reproducir de forma independiente:

- la estimación de coberturas desde los microdatos CPRD originales;
- el ajuste del modelo desde los casos individuales de UKHSA.

Los archivos `outcomes.parquet`, `study_population.parquet` y
`nhs_vacc.parquet` no son públicos. Por tanto, la réplica parte de parámetros
ajustados y datos derivados públicos, no de los microdatos originales.

## Resultados precomputados que no deben usarse como entrada

Para una réplica independiente del modelo no deben cargarse antes de simular:

- `Output/models/*.rda`;
- `Output/Summary_table_*.csv`;
- `Output/regional_cases*.csv`;
- `Output/yearly_cases*.csv`;
- las imágenes de `Figures/`.

Esos archivos se reservan para la comparación posterior. Aunque los archivos
de `Output/models/` terminan en `.rda`, fueron escritos con `saveRDS()`.

## Problemas de compatibilidad corregidos

- `socialmixr`: se sustituyó el argumento obsoleto `age.limits` por
  `age_limits` y se hizo explícita la población de Reino Unido de 2005 que
  antes se obtenía implícitamente. La matriz de contacto resultante es
  idéntica a la anterior.
- `polymod`: ahora se carga explícitamente desde `socialmixr`.
- `seirvodin`: dos condiciones `i >= 1` permitían acceder a
  `array_cov1[i - 1, ...]` en el primer grupo de edad y provocaban un cierre de
  R en Windows con `0xC0000005`. La función de compatibilidad verifica y
  corrige esas expresiones en una copia temporal del modelo, sin alterar el
  paquete instalado.
- Se eliminó la instalación de paquetes desde GitHub durante la ejecución.
- `n_samples` y `n_part` quedaron parametrizados.
- Los argumentos `vax` ya no se ignoran al importar los datos del escenario.

## Archivos creados

- `R/function_model_compatibility.R`
- `R/replicate_reference.R`
- `R/compare_reference_replication.R`
- `R/figure_reference_replication.R`
- `REPRODUCIBILITY.md`
- `RESUMEN_REPLICACION.md`

## Archivos modificados

- `R/function_vaccination_data.R`
- `R/Outbreak_scenarios_CPRD.R`
- `R/Outbreak_scenarios_CPRD_waning.R`
- `R/Outbreak_scenarios_CPRD_waning_from3.R`
- `R/Outbreak_scenarios_COVER.R`
- `R/Sensitivity_analyses_2015.R`
- `README.md`

## Parámetros epidemiológicos modificables

Los principales parámetros ajustados están en `$pars` dentro de los cuatro
archivos `Output/*_degree/*.RDS`. Incluyen:

- transmisión: `beta`, `delta`, `X`, `Y`;
- estacionalidad de introducciones: `X_import`, `Y_import`;
- vacunación: `v_fail`, `vacc` y los parámetros `catchup`;
- observación de introducciones: `report_import`;
- mezcla espacial: `theta`, `b`, `c`;
- estados recuperados iniciales;
- waning: `v_leak` en los ajustes `since_vax.RDS`.

Los periodos fijos por defecto del modelo son `alpha = 11` días de incubación
y `gamma = 8` días infecciosos.

La cobertura y el timing de MMR1/MMR2 están definidos en los CSV de `Data/` y
en `import_ehr_vaccine()` dentro de `R/function_vaccination_data.R`. El modelo
los representa mediante coberturas acumuladas por edad y cohorte, no mediante
una única fecha escalar.

Las introducciones anuales por región están codificadas en
`compute_importation()`. POLYMOD se usa en `compute_contact_matrix()` y la
mezcla entre regiones se construye en `compute_region_matrix()`.

## Figuras

`R/figure_reference_replication.R` genera el panel del escenario `reference`
frente a la vigilancia utilizando exclusivamente la simulación nueva. La
figura completa ya generada se encuentra en
`Output/replication/Reference_Surveillance_replication_full.png`.

Las demás figuras combinan varios escenarios. Para reproducirlas sin reutilizar
resultados almacenados, primero hay que simular cada escenario requerido,
guardar todas las salidas en `Output/replication/` y después adaptar las rutas
de las funciones de figuras. No se deben mezclar simulaciones nuevas con los
escenarios originales de `Output/models/`.

La documentación técnica detallada está en `REPRODUCIBILITY.md`.
