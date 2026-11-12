USE DW_Albarran;
GO

SELECT 
    v.VentaSK,
    v.VentaID_BK,
    t.Fecha,
    t.Anio,
    t.NombreMes,
    s.NombreSucursal,
    s.NombreComuna,
    c.NombreCompletoCliente,
    c.NombreSexo,
    e.NombreCompletoEmpleado,
    e.NombreCargo,
    p.NombreProducto,
    p.NombreCategoria,
    v.CantidadProducto,
    p.PrecioUnitarioReferencial,
    (v.CantidadProducto * p.PrecioUnitarioReferencial) AS MontoTotalCalculado
FROM FactVentas v
LEFT JOIN DimTiempo t ON v.TiempoSK = t.TiempoSK
LEFT JOIN DimSucursal s ON v.SucursalSK = s.SucursalSK
LEFT JOIN DimCliente c ON v.ClienteSK = c.ClienteSK
LEFT JOIN DimEmpleado e ON v.EmpleadoSK = e.EmpleadoSK
LEFT JOIN DimProducto p ON v.ProductoSK = p.ProductoSK;