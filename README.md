# Proyecto Capstone: Análisis Exploratorio de Datos (EDA) en PostgreSQL
## E-commerce: análisis de ventas, clientes y productos

**Autor:** Marcos Bulgheroni  
**Tecnología:** PostgreSQL  
**Lenguaje:** SQL  
**Tipo de proyecto:** Análisis Exploratorio de Datos (EDA)

---

## 1. Descripción del proyecto

Este proyecto consiste en realizar un Análisis Exploratorio de Datos (EDA) sobre un conjunto de datos de un comercio electrónico, utilizando PostgreSQL como herramienta principal.

El objetivo es simular el trabajo de un analista de datos que debe transformar datos sin procesar en información útil para la toma de decisiones comerciales. Para ello, se construyó una base de datos relacional, se identificaron y trataron valores faltantes y se desarrollaron consultas SQL para analizar el comportamiento de las ventas, los clientes y los productos.

El análisis se realizó sobre un conjunto de datos de práctica creado específicamente para este proyecto, compuesto por cuatro tablas relacionadas: clientes, productos, pedidos y detalle_pedido.

A partir de esta información, se busca identificar los clientes que generan mayor facturación, comprender la evolución mensual de las ventas, detectar los productos con menor volumen de unidades vendidas y comparar el desempeño de los pedidos por categoría.

## 2. Problema de negocio

Un comercio electrónico necesita comprender mejor el comportamiento de sus ventas para identificar oportunidades de mejora y orientar sus decisiones comerciales.

Para abordar esta necesidad, se plantearon las siguientes preguntas de negocio:

1. ¿Qué clientes generan mayor facturación para el negocio?
2. ¿Cómo evolucionan las ventas mensualmente?
3. ¿Cuáles son los productos con menor cantidad de unidades vendidas?
4. ¿Qué posición ocupa cada pedido dentro de su categoría según el importe generado?
5. ¿Qué categorías de productos concentran la mayor facturación?
6. ¿Qué limitaciones de calidad de datos deben considerarse antes de tomar decisiones?

Estas preguntas permiten analizar tanto el desempeño comercial como la calidad de la información disponible.

## 3. Estructura de la base de datos

La base de datos utilizada se denomina `capstone_project` y está compuesta por las siguientes tablas:

| Tabla | Descripción |
|---|---|
| `clientes` | Contiene el identificador, nombre, ciudad y fecha de alta de cada cliente. |
| `productos` | Contiene el identificador, nombre, categoría y precio de cada producto. |
| `pedidos` | Registra los pedidos realizados y su relación con los clientes. |
| `detalle_pedido` | Registra los productos incluidos en cada pedido y sus cantidades. |

### Relaciones entre las tablas

- Un cliente puede realizar varios pedidos.
- Un pedido puede contener varios productos.
- Un producto puede aparecer en distintos pedidos.
- La tabla `detalle_pedido` relaciona los pedidos con los productos y registra las cantidades vendidas.

Las relaciones se implementaron mediante claves primarias (`PRIMARY KEY`) y claves foráneas (`FOREIGN KEY`), garantizando la integridad referencial entre las tablas.

También se definieron tipos de datos adecuados para cada campo, como `INTEGER` para identificadores y cantidades, `VARCHAR` para textos, `DATE` para fechas y `NUMERIC(12,2)` para precios.

La cantidad de productos de cada detalle debe ser mayor que cero, condición controlada mediante una restricción `CHECK`.

## 4. Preparación y limpieza de datos

Antes de realizar el análisis comercial, se desarrolló una etapa de control de calidad para identificar valores faltantes en columnas relevantes.

### Identificación de valores nulos

Se detectaron los siguientes casos:

- **Productos sin precio:** un producto presenta un precio nulo, correspondiente a la lámpara de escritorio.
- **Pedidos sin fecha:** un pedido, el número 1015, no tiene una fecha registrada.

Estos casos requieren tratamientos diferentes, ya que la ausencia de un precio y la ausencia de una fecha no tienen las mismas implicancias para el análisis.

### Tratamiento de precios faltantes

Para el ejercicio se decidió reemplazar el precio faltante por el promedio de los precios conocidos.

Se utilizó una vista denominada `productos_limpios`, que aplica `COALESCE` para conservar el precio original cuando existe y utilizar el promedio cuando el valor es nulo.

El precio imputado para la lámpara de escritorio fue de **$33.142,86**.

Además, se incorporó la columna `precio_imputado`, que permite identificar qué productos recibieron un valor estimado y distinguirlos de aquellos cuyos precios originales estaban completos.

Esta decisión se tomó con fines didácticos. En un entorno real, antes de imputar un precio, sería necesario validar el criterio con el área comercial, ya que el promedio no necesariamente representa el precio de mercado del producto.

### Tratamiento de fechas faltantes

El pedido 1015 no tiene fecha registrada. Se decidió mantener el valor `NULL` en lugar de asignarle una fecha ficticia.

De esta manera, el pedido queda excluido de la evolución mensual de ventas, pero puede participar en otros análisis que no dependan de la fecha.

Esta decisión evita distorsionar las tendencias temporales y deja identificado un dato que debe corregirse en el sistema de origen.

### Construcción de la vista de ventas

Se creó una segunda vista, `ventas_limpias`, que combina las tablas de pedidos, detalle de pedidos y productos mediante `JOIN`.

Esta vista permite calcular el importe de cada línea de venta multiplicando la cantidad de unidades por el precio utilizado para el análisis.

**Importe de línea = Cantidad × Precio de análisis**

La utilización de vistas permite reutilizar los resultados de la preparación de datos sin modificar los registros originales de las tablas.

## 5. Metodología y herramientas utilizadas

El proyecto se desarrolló siguiendo un flujo de trabajo de análisis de datos compuesto por cuatro etapas:

1. **Modelado y carga:** creación de las tablas, definición de relaciones e inserción de datos de ejemplo.
2. **Control y limpieza:** identificación de valores nulos y construcción de vistas para preparar la información.
3. **Análisis exploratorio:** consultas para calcular métricas comerciales, comparar resultados y construir rankings.
4. **Interpretación:** análisis de los resultados para identificar oportunidades, limitaciones y posibles acciones de negocio.

Las principales herramientas y funciones SQL utilizadas fueron:

- `JOIN`: integración de información de distintas tablas.
- `LEFT JOIN`: inclusión de productos que podrían no registrar ventas.
- `GROUP BY`: agrupación de datos por cliente, mes, pedido o categoría.
- `SUM` y `COUNT`: cálculo de facturación, unidades y cantidades de pedidos.
- `COALESCE`: tratamiento de valores faltantes.
- `AVG` y `ROUND`: cálculo y presentación de promedios.
- `DATE_TRUNC`: agrupación de las ventas por mes.
- `RANK() OVER (PARTITION BY ...)`: clasificación de pedidos dentro de cada categoría.
- `NULLIF`: prevención de divisiones por cero en el cálculo de porcentajes.

## 6. Principales hallazgos del análisis

### 6.1. Clientes que generan mayor facturación

Se calcularon los importes totales por cliente, la cantidad de pedidos asociados y el gasto acumulado. Los resultados se ordenaron de mayor a menor para identificar a los principales generadores de facturación.

Los cinco clientes con mayor gasto fueron:

| Cliente | Cantidad de pedidos | Gasto total |
|---|---:|---:|
| Ana Torres | 3 | $322.000,00 |
| Bruno Díaz | 2 | $220.000,00 |
| Carla Gómez | 2 | $189.000,00 |
| Diego López | 2 | $138.285,72 |
| Gabriela Sosa | 1 | $99.000,00 |

**Interpretación de negocio**

Ana Torres es la clienta que más facturación genera dentro de la muestra, con un gasto acumulado de $322.000,00 y tres pedidos registrados.

La diferencia respecto del segundo cliente permite identificar un grupo de clientes de alto valor comercial que podría ser relevante para acciones de fidelización, promociones segmentadas o estrategias de recompra.

Sin embargo, el gasto total no es suficiente para determinar por sí solo la lealtad de un cliente. Para profundizar este análisis sería conveniente incorporar la frecuencia de compra a lo largo del tiempo, la recencia de la última compra y el margen de rentabilidad.

### 6.2. Evolución mensual de las ventas

Se agruparon las ventas por mes mediante `DATE_TRUNC`, excluyendo los pedidos que no tienen una fecha registrada.

| Mes | Ventas totales | Pedidos |
|---|---:|---:|
| Enero 2026 | $258.000,00 | 3 |
| Febrero 2026 | $256.000,00 | 3 |
| Marzo 2026 | $353.000,00 | 4 |
| Abril 2026 | $291.000,00 | 4 |

**Interpretación de negocio**

Marzo fue el mes de mayor facturación, con $353.000,00, seguido por abril, con $291.000,00.

Entre febrero y marzo, las ventas aumentaron aproximadamente un 37,9 %. En cambio, entre marzo y abril disminuyeron alrededor de un 17,6 %.

Estos cambios permiten identificar períodos que merecen una revisión más detallada. Para explicar las variaciones sería necesario analizar qué productos impulsaron las ventas, el importe promedio por pedido, las promociones vigentes y otros factores comerciales.

La facturación mensual de la muestra asciende a $1.158.000,00. Este importe no incluye el pedido 1015, que no puede asignarse a un mes hasta que se confirme su fecha.

### 6.3. Productos con menor cantidad de unidades vendidas

Se utilizó `LEFT JOIN` para incluir los productos aunque no tengan ventas asociadas y `COALESCE` para representar con cero las cantidades que pudieran resultar nulas.

Los tres productos identificados en el resultado obtenido fueron:

| Producto | Categoría | Unidades vendidas |
|---|---|---:|
| Lámpara de escritorio | Oficina | 2 |
| Mochila | Accesorios | 4 |
| Silla de escritorio | Hogar | 4 |

**Interpretación de negocio**

La lámpara de escritorio registra el menor volumen de unidades vendidas dentro del resultado obtenido, con dos unidades.

Este dato podría motivar una revisión de su precio, posicionamiento, descripción comercial o visibilidad en la tienda. No obstante, no es suficiente para concluir que el producto tiene un problema de demanda, ya que el análisis no incluye visitas a la página, disponibilidad de stock, margen ni antigüedad del producto.

Además, como el precio de la lámpara fue imputado, cualquier análisis de facturación o rentabilidad asociado a ella debe interpretarse con precaución.

### 6.4. Ranking de pedidos por categoría

Se calculó el importe total de cada combinación de pedido y categoría. Luego se aplicó `RANK()` para establecer la posición de cada pedido dentro de su categoría, ordenándolo de mayor a menor importe.

La función de ventana permite realizar esta clasificación sin perder el detalle de cada pedido. Cuando dos pedidos tienen el mismo importe, pueden compartir la misma posición y dejar un salto en la numeración siguiente.

Entre los principales resultados se encuentran:

- **Hogar:** el pedido 1002 ocupa la primera posición, con $131.000,00.
- **Electrónica:** el pedido 1007 ocupa la primera posición, con $89.000,00.
- **Accesorios:** el pedido 1009 ocupa la primera posición, con $84.000,00.
- **Oficina:** el pedido 1015 ocupa la primera posición, con $71.285,72.

**Interpretación de negocio**

El ranking permite detectar qué pedidos aportan mayor facturación dentro de cada categoría, lo que facilita comparar el comportamiento comercial de los productos entre distintas compras.

El pedido 1015 requiere una consideración particular: figura en el ranking de Oficina porque contiene productos de esa categoría, pero su fecha es desconocida. Por lo tanto, puede incluirse en un análisis por importe, aunque no sea posible ubicarlo temporalmente.

### 6.5. Facturación por categoría

Se agruparon las ventas por categoría para comparar las unidades vendidas, la facturación y la participación porcentual sobre el total analizado.

| Categoría | Unidades vendidas | Ventas totales | Participación |
|---|---:|---:|---:|
| Hogar | 14 | $560.000,00 | 45,55 % |
| Electrónica | 15 | $360.000,00 | 29,29 % |
| Accesorios | 4 | $168.000,00 | 13,67 % |
| Oficina | 17 | $141.285,72 | 11,49 % |

**Interpretación de negocio**

Hogar es la categoría con mayor facturación, representando el 45,55 % del total. Electrónica ocupa el segundo lugar, con el 29,29 %.

En conjunto, ambas categorías concentran aproximadamente el 74,84 % de la facturación analizada, por lo que representan los principales aportantes de ingresos dentro de la muestra.

Por otro lado, Oficina registra la mayor cantidad de unidades vendidas, con 17, pero genera una facturación inferior a la de Hogar y Electrónica. Esto evidencia que el volumen de unidades no necesariamente se traduce en una mayor facturación, ya que también depende de los precios de los productos.

El importe de Oficina incluye el pedido 1015 y, por lo tanto, incorpora el precio imputado de la lámpara de escritorio. Esta circunstancia debe tenerse en cuenta al interpretar el resultado.

## 7. Conclusiones generales

El análisis permitió obtener una primera visión del comportamiento comercial del e-commerce y demostrar cómo SQL puede utilizarse para convertir datos relacionales en información relevante para la toma de decisiones.

Los principales hallazgos son:

1. **Concentración de facturación por cliente:** Ana Torres presenta el mayor gasto acumulado, por lo que constituye un caso de interés para estudiar estrategias de fidelización y recompra.
2. **Variación de las ventas mensuales:** marzo registra la mayor facturación del período analizado, mientras que abril muestra una disminución que merece una revisión comercial.
3. **Identificación de productos de bajo volumen:** la lámpara de escritorio es uno de los productos con menor cantidad de unidades vendidas, aunque se requiere información adicional para determinar las causas.
4. **Diferencias entre categorías:** Hogar y Electrónica concentran cerca de tres cuartas partes de la facturación total.
5. **Importancia de la calidad de los datos:** los valores faltantes pueden afectar los indicadores y deben identificarse antes de elaborar reportes definitivos.

Desde una perspectiva de negocio, estos resultados pueden servir como punto de partida para analizar oportunidades comerciales, revisar el desempeño de los productos y diseñar nuevas métricas de seguimiento.

Sin embargo, el dataset utilizado es pequeño y fue construido con fines educativos. Por ese motivo, los resultados describen únicamente los registros incluidos en el ejercicio y no deben generalizarse a un comercio real sin contar con un volumen de datos mayor y más variables de contexto.

Como próximos pasos, se recomienda incorporar información sobre costos, márgenes, stock, canales de venta, descuentos y fechas de compra completas. También sería conveniente calcular indicadores como ticket promedio, frecuencia de compra, participación de cada cliente y evolución de las unidades vendidas por producto.

## 8. Cómo ejecutar el proyecto

### Requisitos

- PostgreSQL instalado y en funcionamiento.
- Una herramienta para conectarse a PostgreSQL, como DBeaver o pgAdmin.
- Acceso para crear la base de datos y ejecutar los scripts SQL.

### Paso 1. Crear la base de datos

Crear una base de datos denominada `capstone_project`.

En PostgreSQL se puede ejecutar:

```sql
CREATE DATABASE capstone_project;
```

Si la base ya existe, no es necesario crearla nuevamente.

### Paso 2. Ejecutar `estructura.sql`

Conectarse a la base `capstone_project` y ejecutar el archivo `estructura.sql`.

Este script:

- Crea las tablas del proyecto.
- Define claves primarias, claves foráneas y restricciones.
- Inserta los datos de clientes, productos, pedidos y detalles.
- Ejecuta controles iniciales para verificar la cantidad de registros y detectar valores nulos.

**Importante:** el script elimina las tablas del proyecto si ya existen antes de crearlas nuevamente. Por ello, al volver a ejecutarlo se reinician los datos de esas tablas. No debe utilizarse sobre tablas con información que se necesite conservar.

### Paso 3. Ejecutar `analisis.sql`

Una vez completada la carga, ejecutar `analisis.sql` conectado a `capstone_project`.

Este archivo realiza los controles de calidad, crea las vistas `productos_limpios` y `ventas_limpias` y ejecuta las consultas de análisis comercial.

Las consultas generan resultados independientes que pueden revisarse en las distintas pestañas de resultados de DBeaver o pgAdmin.

### Paso 4. Revisar los resultados

Verificar que:

- Los valores nulos se identifiquen correctamente.
- La vista `productos_limpios` muestre el precio imputado y el indicador `precio_imputado`.
- La vista `ventas_limpias` permita calcular los importes por línea.
- Las consultas de clientes, evolución mensual, productos menos vendidos, ranking por categoría y facturación por categoría devuelvan resultados.
- El pedido 1015 se excluya de la evolución mensual por no contar con fecha, pero permanezca disponible en los análisis que no dependen de ese dato.

**Orden de ejecución recomendado:** `estructura.sql` → `analisis.sql`.

## 9. Archivos del repositorio

El repositorio contiene los siguientes archivos:

| Archivo | Contenido |
|---|---|
| `estructura.sql` | Creación de tablas, relaciones, restricciones, inserción de datos y controles iniciales. |
| `analisis.sql` | Perfil de calidad, limpieza mediante vistas y consultas de análisis comentadas. |
| `README.md` | Contexto del problema, metodología, resultados, conclusiones e instrucciones de ejecución. |

## 10. Aprendizajes del proyecto

Este Capstone permitió aplicar conceptos fundamentales de análisis de datos con PostgreSQL, desde el modelado de una base relacional hasta la interpretación de resultados de negocio.

Entre los principales aprendizajes se destacan:

- Diseñar tablas con tipos de datos y relaciones adecuados.
- Utilizar claves primarias y foráneas para mantener la integridad de los datos.
- Integrar información de varias tablas mediante `JOIN`.
- Identificar y tratar valores faltantes con criterios explícitos.
- Construir vistas para reutilizar datos preparados para el análisis.
- Aplicar agregaciones y funciones de ventana para obtener métricas y rankings.
- Interpretar los resultados y reconocer las limitaciones de la información disponible.

El proyecto demuestra que una consulta SQL no es únicamente una instrucción técnica: es una herramienta para responder preguntas, validar supuestos y generar información que permita tomar mejores decisiones.

---
