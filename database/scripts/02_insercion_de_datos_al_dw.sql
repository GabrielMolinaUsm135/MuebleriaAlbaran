USE DW_Albarran;
GO

-- 1. Limpieza previa en orden inverso por las Foreign Keys
DELETE FROM FactVentas;
DELETE FROM DimTiempo;
DELETE FROM DimCliente;
DELETE FROM DimEmpleado;
DELETE FROM DimSucursal;
DELETE FROM DimProducto;

-- 2. Cargar DimCliente
-- 2. Cargar DimCliente (Transformando M -> Masculino y F -> Femenino)
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
    c.estado_civil,
    CAST(c.fecha_nacimiento AS DATE)
FROM MuebleriaAlbarran..clientes c;

-- 3. Cargar DimEmpleado (con alias e. en appatemo y apmatemo)
INSERT INTO DimEmpleado (EmpleadoID_BK, NombreCompletoEmpleado, NombreCargo, FechaContratoEmpleado)
SELECT DISTINCT 
    e.empleado_id, 
    LTRIM(RTRIM(e.nombre)) + ' ' + 
    ISNULL(LTRIM(RTRIM(e.appaterno)), '') + ' ' + 
    ISNULL(LTRIM(RTRIM(e.apmaterno)), ''),
    ISNULL(ca.nombre, 'Sin Cargo'),
    CAST(e.fecha_contrato AS DATE)
FROM MuebleriaAlbarran..empleados e
LEFT JOIN MuebleriaAlbarran..cargos ca ON e.cargo_id = ca.cargo_id;

-- 4. Cargar DimSucursal
INSERT INTO DimSucursal (SucursalID_BK, NombreSucursal, NombreComuna)
SELECT DISTINCT 
    s.sucursal_id, 
    s.sucursal, 
    ISNULL(co.comuna, 'Sin Comuna')
FROM MuebleriaAlbarran..sucursales s
LEFT JOIN MuebleriaAlbarran..comunas co ON s.comuna_id = co.comuna_id;

-- 5. Cargar DimProducto (usando cat.categoria)
INSERT INTO DimProducto (ProductoID_BK, NombreProducto, NombreCategoria, PrecioUnitarioReferencial)
SELECT DISTINCT 
    p.producto_id, 
    p.nombre, 
    ISNULL(cat.categoria, 'General'),
    p.precio
FROM MuebleriaAlbarran..productos p
LEFT JOIN MuebleriaAlbarran..categorias cat ON p.categoria_id = cat.categoria_id;

-- 6. Cargar DimTiempo (usando NumeroTrimestre)
INSERT INTO DimTiempo (Fecha, Anio, NumeroTrimestre, NumeroMes, NombreMes, NumeroDia)
SELECT DISTINCT 
    CAST(v.fecha AS DATE) AS Fecha,
    YEAR(v.fecha) AS Anio,
    CASE 
        WHEN MONTH(v.fecha) BETWEEN 1 AND 3 THEN 1
        WHEN MONTH(v.fecha) BETWEEN 4 AND 6 THEN 2
        WHEN MONTH(v.fecha) BETWEEN 7 AND 9 THEN 3
        WHEN MONTH(v.fecha) BETWEEN 10 AND 12 THEN 4
    END AS NumeroTrimestre,
    MONTH(v.fecha) AS NumeroMes,
    CASE MONTH(v.fecha)
        WHEN 1 THEN 'Enero'
        WHEN 2 THEN 'Febrero'
        WHEN 3 THEN 'Marzo'
        WHEN 4 THEN 'Abril'
        WHEN 5 THEN 'Mayo'
        WHEN 6 THEN 'Junio'
        WHEN 7 THEN 'Julio'
        WHEN 8 THEN 'Agosto'
        WHEN 9 THEN 'Septiembre'
        WHEN 10 THEN 'Octubre'
        WHEN 11 THEN 'Noviembre'
        WHEN 12 THEN 'Diciembre'
    END AS NombreMes,
    DAY(v.fecha) AS NumeroDia
FROM MuebleriaAlbarran..ventas v
WHERE v.fecha IS NOT NULL
ORDER BY CAST(v.fecha AS DATE);

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
FROM MuebleriaAlbarran..ventas v
INNER JOIN MuebleriaAlbarran..detalle_ventas dv ON v.venta_id = dv.venta_id
INNER JOIN DimCliente cli ON v.cliente_id = cli.ClienteID_BK
INNER JOIN DimEmpleado emp ON v.vendedor_id = emp.EmpleadoID_BK
INNER JOIN DimSucursal suc ON v.sucursal_id = suc.SucursalID_BK
INNER JOIN DimProducto prod ON dv.producto_id = prod.ProductoID_BK
INNER JOIN DimTiempo t ON CAST(v.fecha AS DATE) = t.Fecha;