# Certamen 2 - Inteligencia de Negocios

**Universidad Técnica Federico Santa María · Año académico 2026**

## Caso seleccionado

**Caso 1: Mueblería Albarrán**

| Dato | Detalle |
|---|---|
| Sección | 300 |
| Profesor | Hernán Saavedra |

## Integrantes

| Integrante | Usuario GitHub |
|---|---|
| Gabriel Molina | [GabrielMolinaUsm135](https://github.com/GabrielMolinaUsm135) |
| Macarena Mogollón | [makimogollon](https://github.com/makimogollon) |
| Lukas Cordova | [lukascordova](https://github.com/lukascordova) |
| Daniel González | [GonzalezDanielRojas](https://github.com/GonzalezDanielRojas) |

# ---------------------- FASE 1 ---------------------- 

## 1. Descripción del problema

La Mueblería Albarrán almacena en una base de datos relacional información de sucursales y comunas, clientes, empleados y cargos, productos y categorías, ventas y detalle de ventas. El proyecto propone una solución de Inteligencia de Negocios que consolide estos datos para analizar el desempeño de las ventas y apoyar las decisiones del propietario.

## 2. Objetivo y alcance

Desarrollar una solución de Inteligencia de Negocios para analizar las ventas de la empresa.

- **Fase 1:** diseñar e implementar el Data Warehouse dimensional y el proceso ETL con SQL Server y SSIS.
- **Fase 2:** el repositorio incluye el proyecto SSAS y el archivo `powerbi/dashboard.pbix`. Este README describe los KPI y análisis previstos.

## 3. KPI definidos

| KPI | Fórmula | Utilidad |
|---|---|---|
| **Total de ventas netas ($)** | `SUM(MontoTotalVenta)`, donde `MontoTotalVenta = CantidadProducto × PrecioUnitarioProducto − DescuentoProducto` | Mide los ingresos después de aplicar descuentos. |
| **Unidades vendidas** | `SUM(CantidadProducto)` | Permite analizar volumen y demanda por producto, categoría y sucursal. |
| **Ticket promedio por venta ($)** | `SUM(MontoTotalVenta) / COUNT(DISTINCT VentaID_BK)` | Mide el monto neto medio por transacción. |
| **Descuento promedio otorgado (%)** | `SUM(DescuentoProducto) / SUM(CantidadProducto × PrecioUnitarioProducto) × 100` | Mide la proporción descontada respecto del monto bruto vendido. |

Los KPI se pueden analizar por fecha, sucursal y comuna, producto y categoría, empleado y cargo, y cliente.

Los datos transaccionales permiten calcular los KPI porque contienen el encabezado y detalle de ventas, con fecha, producto, cantidad, precio y descuento, además de las entidades que permiten segmentar por cliente, empleado y sucursal. En la transformación se consideran posibles valores nulos, fechas faltantes, relaciones a categoría/cargo/comuna no encontradas y espacios sobrantes. La ejecución de las validaciones de origen y destino se documenta en la sección **Validación de la carga**.

## 4. Modelo dimensional

Se utiliza un esquema estrella siguiendo los cuatro pasos de Kimball:

| Paso | Decisión |
|---|---|
| Proceso de negocio | Ventas y facturación de productos en las sucursales. |
| Granularidad | Una fila por línea de detalle de una venta. |
| Dimensiones | Cliente, producto, empleado, sucursal y tiempo. |
| Medidas y tabla de hechos | `FactVentas`: cantidad, precio unitario, descuento y monto neto. |

### Dimensiones

Las dimensiones de cliente, producto, empleado y sucursal tienen una clave subrogada `IDENTITY` y conservan la clave de negocio de origen (`*_BK`). La dimensión de tiempo utiliza como clave primaria la fecha en formato entero `YYYYMMDD`.

| Tabla | Atributos |
|---|---|
| `DimCliente` | `ClienteSK`, `ClienteID_BK`, `NombreCompletoCliente`, `NombreSexo`, `EstadoCivilCliente`, `FechaNacimientoCliente` |
| `DimProducto` | `ProductoSK`, `ProductoID_BK`, `NombreProducto`, `NombreCategoria`, `PrecioUnitarioReferencial` |
| `DimEmpleado` | `EmpleadoSK`, `EmpleadoID_BK`, `NombreCompletoEmpleado`, `NombreCargo`, `FechaContratoEmpleado` |
| `DimSucursal` | `SucursalSK`, `SucursalID_BK`, `NombreSucursal`, `NombreComuna` |
| `DimTiempo` | `TiempoSK`, `Fecha`, `Anio`, `Trimestre`, `NumeroMes`, `NombreMes`, `NumeroDia`, `NombreDiaSemana` |

### Tabla de hechos

`FactVentas` almacena una fila por línea de venta. Sus claves foráneas son `ProductoSK`, `ClienteSK`, `EmpleadoSK`, `SucursalSK` y `TiempoSK`. `NumeroDocumento` y `TipoDocumento` se conservan como dimensiones degeneradas.

| Medida | Descripción |
|---|---|
| `CantidadProducto` | Unidades incluidas en la línea. |
| `PrecioUnitarioProducto` | Precio unitario registrado en la venta. |
| `DescuentoProducto` | Descuento aplicado a la línea. |
| `MontoTotalVenta` | Monto neto de la línea: cantidad por precio unitario menos descuento. |

`PrecioUnitarioProducto` es una medida no aditiva: no se debe sumar para obtener un total de ventas.

### Diagrama Modelo Dimensional (Estrella)

![Diagrama estrella del Data Warehouse](modelo_dimensional/diagrama_estrella_dw.png)

## Construcción del Data Warehouse
### a. Restauración de la Base de Datos Original (Albarran.bak)
Se cargó el archivo de respaldo original de la mueblería en SQL Server Management Studio (SSMS) mediante una operación de restauración, lo que permitió disponer de toda la data transaccional cruda del negocio como punto de partida.

### b. Diseño y Creación del Esquema del Data Warehouse
Se estructuró el modelo dimensional compuesto por una tabla central de hechos (FactVentas) que almacena las métricas clave (MontoTotalVenta, CantidadProducto), conectada directamente a sus respectivas dimensiones (DimTiempo, DimCliente, DimEmpleado, DimSucursal y DimProducto) para dar el contexto analítico.

### c. Proceso de Inserción de Datos
Se ejecutaron los scripts de poblamiento para transformar y trasladar la información hacia el nuevo esquema, asegurando la asignación correcta de claves subrogadas (SK) y el manejo adecuado de atributos temporales (como el ordenamiento numérico de los meses).

### d. Validación y Verificación de la Carga
Se corrieron consultas de control y scripts de verificación para contrastar los montos totales y comprobar que la integridad referencial entre la tabla de hechos y las dimensiones fuera exacta y sin pérdida de datos.


## 5. Proceso ETL
El proyecto SSIS se encuentra en [`etl/proyecto-ssis/ProyectoMuebleria/`](etl/proyecto-ssis/ProyectoMuebleria/). El paquete extrae datos de la base transaccional `Albarran` y los carga en `DW_Albarran`.

El flujo carga las dimensiones antes de la tabla de hechos para que las claves foráneas estén disponibles. En la carga de hechos se resuelven las claves de negocio hacia las claves subrogadas. La dimensión de tiempo usa la clave `YYYYMMDD`, compartida entre la dimensión y los hechos.

### Diagrama de proceso ETL



### Transformaciones documentadas

- Se eliminan espacios sobrantes al componer nombres de clientes y empleados.
- El sexo del cliente se estandariza (`M` como masculino, `F` como femenino y otros valores como no especificados).
- Categoría, cargo y comuna se integran en las dimensiones de producto, empleado y sucursal.
- Se asignan valores por defecto cuando no se encuentra categoría, cargo o comuna; el descuento nulo se trata como cero.
- El monto neto de cada línea resta el descuento al producto de cantidad por precio unitario.
- Las ventas sin fecha no se incorporan a la dimensión de tiempo.

# ---------------------- FASE 2 ---------------------- 

## 7. Cubo OLAP

### a. Conexión y Vista de Origen de Datos (DSV):
Se creó el proyecto multidimensional en Visual Studio (Analysis Services) y se estableció la conexión directa al Data Warehouse de la mueblería en SQL Server. A partir de ahí, se generó la Vista de Origen de Datos importando el modelo estrella (FactVentas y todas sus tablas de dimensiones) para mapear las relaciones en el entorno analítico.   

### b. Configuración de Dimensiones y Jerarquías:
Se construyeron las dimensiones del cubo (DimTiempo, DimProducto, DimSucursal, DimEmpleado, DimCliente) exponiendo los atributos necesarios para el análisis.
  
### c. Definición de Medidas y Cálculos MDX:
Se estructuró el cubo integrando las métricas base desde la tabla de hechos (MontoTotalVenta, CantidadProducto) y se programaron miembros calculados mediante expresiones MDX para obtener indicadores de negocio clave como el TicketPromedio y DescuentoPromedio definido anteriormente.
  
### d. Implementación (Deploy) y Procesamiento del Cubo: 
Se compiló e implementó la solución en el servidor local de Analysis Services (localhost), procesando las estructuras y cargando los datos en memoria para dejar el cubo operativo y listo para ser consumido en vivo (Live Connection) desde Power BI. 

## 8. Dashboard Power BI

### a. Conexión en Vivo (Live Connection) al Cubo SSAS: 
Se conectó Power BI Desktop directamente a la instancia local de Analysis Services, consumiendo en tiempo real el modelo multidimensional, sus jerarquías y los miembros calculados previamente definidos sin duplicar datos.

### b. Definición de Tarjetas KPI (Indicadores Clave)
En la zona superior se implementaron tarjetas de resumen ejecutivo para monitorear de un vistazo el rendimiento global del negocio: Monto Total Venta, Cantidad Producto, TicketPromedio y DescuentoPromedio.

### c. Análisis Visual por Dimensiones: 
Se desarrollaron gráficos comparativos para desglosar los ingresos según los ejes principales de la mueblería: ventas por producto, evolución mensual, rendimiento de ventas por vendedor y ventas por sucursal en un grafico de anillo, complementados con tablas de detalle de productos y clientes.

### d. Segmentación e Interactividad: 
Se integró un panel lateral de filtros desplegables (Nombre Completo Cliente, Nombre Sucursal, Numero Mes y Nombre Producto) que permiten cruzar información dinámicamente y analizar escenarios específicos en todo el reporte.

### Imagen dashboard

# ------------------- DOCUMENTACIÓN ------------------- 

## 1. Tecnologías y estructura del repositorio

**Tecnologías:** SQL Server, Visual Studio con SQL Server Integration Services (SSIS), SQL Server Analysis Services (SSAS), Power BI y GitHub.

```text
database/
  backup/                         Backups de las bases de datos de origen y DW
  scripts/                        Creación y carga SQL del Data Warehouse
docs/                             Caso y pauta del certamen
etl/proyecto-ssis/ProyectoMuebleria/
                                  Solución y paquete ETL de SSIS
modelo_dimensional/               Diagrama estrella
olap/proyecto-ssas/                Ubicación del proyecto SSAS
powerbi/                          Ubicación del archivo Power BI
README.md                         Documentación del proyecto
```

## 2. Instrucciones de ejecución y revisión

1. Restaurar el backup transaccional [`Albarran.bak`](database/backup/Albarran.bak) en SQL Server con el nombre `Albarran`, que es el utilizado por las conexiones y consultas del proyecto.
2. Ejecutar [`01_creacion_dw_albarran.sql`](database/scripts/01_creacion_dw_albarran.sql) para crear el Data Warehouse.
   **Advertencia:** este script elimina y vuelve a crear `DW_Albarran`. Respaldar la base antes de ejecutarlo si se desea conservarla.
3. Para cargar el DW mediante SQL, ejecutar [`02_insercion_de_datos_al_dw.sql`](database/scripts/02_insercion_de_datos_al_dw.sql). Este script limpia las tablas del DW antes de insertar los datos.
4. Para ejecutar el ETL, abrir [`ProyectoMuebleria.sln`](etl/proyecto-ssis/ProyectoMuebleria/ProyectoMuebleria.sln) en Visual Studio con la extensión de proyectos SSIS. Verificar las conexiones de origen `Albarran` y destino `DW_Albarran`, y ejecutar el paquete.
5. Ejecutar las consultas de la sección **Validación de la carga** y guardar los resultados de la comprobación.

# ------------- Responsabilidades y los principales aportes de cada  integrante ------------ 

| Integrante | Aporte |
|---|---|
| Gabriel Molina | Construcción de ETL y las consultas de recepción de datos, revisón y edición del archivo README.md. |
| Macarena Mogollón | Construcción del DW y consultas SQL de insercción y verificación de datos. Construcción cubo OLAP mediante SQL Server Analysis Services y sus KPI. Creacion de dashboard de powerbi con datos cargados anteriormente del cubo olap. Revisón y edición del archivo README.md. |
| Lukas Cordova | Cliente, producto, empleado, sucursal y tiempo. |
| Daniel González | Revisar archivo README.md |
