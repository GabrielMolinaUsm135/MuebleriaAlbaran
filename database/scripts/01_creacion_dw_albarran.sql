-- 1. Crear o reiniciar la base de datos del Data Warehouse
DROP DATABASE IF EXISTS DW_Albarran;
GO

CREATE DATABASE DW_Albarran;
GO

USE DW_Albarran;
GO

-- 2. Crear DimCliente
CREATE TABLE DimCliente (
    ClienteSK INT IDENTITY(1,1) PRIMARY KEY,
    ClienteID_BK INT NOT NULL,
    NombreCompletoCliente VARCHAR(150),
    NombreSexo VARCHAR(50),
    EstadoCivilCliente VARCHAR(100),
    FechaNacimientoCliente DATE
);
GO

-- 3. Crear DimEmpleado
CREATE TABLE DimEmpleado (
    EmpleadoSK INT IDENTITY(1,1) PRIMARY KEY,
    EmpleadoID_BK INT NOT NULL,
    NombreCompletoEmpleado VARCHAR(150),
    NombreCargo VARCHAR(100),
    FechaContratoEmpleado DATE
);
GO

-- 4. Crear DimSucursal
CREATE TABLE DimSucursal (
    SucursalSK INT IDENTITY(1,1) PRIMARY KEY,
    SucursalID_BK INT NOT NULL,
    NombreSucursal VARCHAR(100),
    NombreComuna VARCHAR(100)
);
GO

-- 5. Crear DimProducto
CREATE TABLE DimProducto (
    ProductoSK INT IDENTITY(1,1) PRIMARY KEY,
    ProductoID_BK INT NOT NULL,
    NombreProducto VARCHAR(150),
    NombreCategoria VARCHAR(100),
    PrecioUnitarioReferencial DECIMAL(18,2)
);
GO

-- 6. Crear DimTiempo con clave YYYYMMDD.
CREATE TABLE DimTiempo (
    TiempoSK INT PRIMARY KEY,
    Fecha DATE NOT NULL,
    Anio INT,
    Trimestre INT,
    NumeroMes INT,
    NombreMes VARCHAR(50),
    NumeroDia INT,
    NombreDiaSemana VARCHAR(20)
);
GO

-- 7. Crear Tabla de Hechos (FactVentas)
CREATE TABLE FactVentas (
    VentaSK INT IDENTITY(1,1) PRIMARY KEY,
    VentaID_BK INT NOT NULL,
    ProductoSK INT FOREIGN KEY REFERENCES DimProducto(ProductoSK),
    ClienteSK INT FOREIGN KEY REFERENCES DimCliente(ClienteSK),
    EmpleadoSK INT FOREIGN KEY REFERENCES DimEmpleado(EmpleadoSK),
    SucursalSK INT FOREIGN KEY REFERENCES DimSucursal(SucursalSK),
    TiempoSK INT FOREIGN KEY REFERENCES DimTiempo(TiempoSK),
    NumeroDocumento VARCHAR(50),
    TipoDocumento VARCHAR(50),
    CantidadProducto INT,
    PrecioUnitarioProducto DECIMAL(18,2),
    DescuentoProducto DECIMAL(18,2),
    MontoTotalVenta DECIMAL(18,2)
);
GO