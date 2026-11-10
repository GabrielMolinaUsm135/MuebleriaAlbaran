USE DW_Albarran;
GO

-- 1. Limpieza previa en orden inverso por las Foreign Keys
DELETE FROM FactVentas;
DELETE FROM DimTiempo;
DELETE FROM DimCliente;
DELETE FROM DimEmpleado;
DELETE FROM DimSucursal;
DELETE FROM DimProducto;

-- 2. Cargar DimCliente (transformando M -> Masculino y F -> Femenino)
INSERT INTO DimCliente (ClienteID_BK, NombreCompletoCliente, NombreSexo, EstadoCivilCliente, FechaNacimientoCliente)
SELECT DISTINCT 
    c.cliente_id, 
    LTRIM(RTRIM(c.nombre)) + ' ' + 
    ISNULL(LTRIM(RTRIM(c.appaterno)), '') + ' ' + 
    ISNULL(LTRIM(RTRIM(c.apmaterno)), ''),
    CASE UPPER(LTRIM(RTRIM(c.sexo)))
        WHEN 'M' THEN 'Masculino'
        WHEN 'F' THEN 'Femenino'
        ELSE 'No especificado'
    END,
    ISNULL(c.estado_civil, 'Sin Información'),
    CAST(c.fecha_nacimiento AS DATE)
FROM Albarran.dbo.clientes c;

-- 3. Cargar DimEmpleado
INSERT INTO DimEmpleado (EmpleadoID_BK, NombreCompletoEmpleado, NombreCargo, FechaContratoEmpleado)
SELECT DISTINCT 
    e.empleado_id, 
    LTRIM(RTRIM(e.nombre)) + ' ' + 
    ISNULL(LTRIM(RTRIM(e.appaterno)), '') + ' ' + 
    ISNULL(LTRIM(RTRIM(e.apmaterno)), ''),
    ISNULL(ca.nombre, 'Sin Cargo'),
    CAST(e.fecha_contrato AS DATE)
FROM Albarran.dbo.empleados e
LEFT JOIN Albarran.dbo.cargos ca ON e.cargo_id = ca.cargo_id;

-- 4. Cargar DimSucursal
INSERT INTO DimSucursal (SucursalID_BK, NombreSucursal, NombreComuna)
SELECT DISTINCT 
    s.sucursal_id, 
    s.sucursal, 
    ISNULL(co.comuna, 'Sin Comuna')
FROM Albarran.dbo.sucursales s
LEFT JOIN Albarran.dbo.comunas co ON s.comuna_id = co.comuna_id;

-- 5. Cargar DimProducto (usando cat.categoria)
INSERT INTO DimProducto (ProductoID_BK, NombreProducto, NombreCategoria, PrecioUnitarioReferencial)
SELECT DISTINCT 
    p.producto_id, 
    p.nombre, 
    ISNULL(cat.categoria, 'General'),
    p.precio
FROM Albarran.dbo.productos p
LEFT JOIN Albarran.dbo.categorias cat ON p.categoria_id = cat.categoria_id;

INSERT INTO DimTiempo (TiempoSK, Fecha, Anio, Trimestre, NumeroMes, NombreMes, NumeroDia, NombreDiaSemana)
SELECT DISTINCT 
    CAST(CONVERT(CHAR(8), v.fecha, 112) AS INT) AS TiempoSK,
    CAST(v.fecha AS DATE) AS Fecha,
    YEAR(v.fecha) AS Anio,
    DATEPART(QUARTER, v.fecha) AS Trimestre,
    MONTH(v.fecha) AS NumeroMes,
    DATENAME(MONTH, v.fecha) AS NombreMes,
    DAY(v.fecha) AS NumeroDia,
    DATENAME(WEEKDAY, v.fecha) AS NombreDiaSemana
FROM Albarran.dbo.ventas v
WHERE v.fecha IS NOT NULL;

-- 7. Cargar FactVentas
INSERT INTO FactVentas (
    VentaID_BK, ProductoSK, ClienteSK, EmpleadoSK, SucursalSK, TiempoSK, 
    NumeroDocumento, TipoDocumento, CantidadProducto, PrecioUnitarioProducto, DescuentoProducto, MontoTotalVenta
)
SELECT 
    v.venta_id,
    prod.ProductoSK,
    cli.ClienteSK,
    emp.EmpleadoSK,
    suc.SucursalSK,
    t.TiempoSK,
    v.numero_documento,
    v.tipo_documento,
    dv.cantidad,
    dv.precio_unitario,
    ISNULL(dv.descuento, 0),
    (CAST(dv.cantidad AS DECIMAL(18,2)) * CAST(dv.precio_unitario AS DECIMAL(18,2))) - ISNULL(dv.descuento, 0) AS MontoTotalVenta
FROM Albarran.dbo.ventas v
INNER JOIN Albarran.dbo.detalle_ventas dv ON v.venta_id = dv.venta_id
INNER JOIN DimCliente cli ON v.cliente_id = cli.ClienteID_BK
INNER JOIN DimEmpleado emp ON v.vendedor_id = emp.EmpleadoID_BK
INNER JOIN DimSucursal suc ON v.sucursal_id = suc.SucursalID_BK
INNER JOIN DimProducto prod ON dv.producto_id = prod.ProductoID_BK
INNER JOIN DimTiempo t ON CAST(v.fecha AS DATE) = t.Fecha;