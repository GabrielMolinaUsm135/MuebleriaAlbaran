-- 1. Crear la base de datos del Data Warehouse
CREATE DATABASE DW_Albarran;
GO

USE DW_Albarran;
GO

-- 2. Crear Dimensión Cliente
CREATE TABLE DimCliente (
    ClienteSK INT IDENTITY(1,1) PRIMARY KEY,
    ClienteID_BK INT NOT NULL,
    NombreCompletoCliente VARCHAR(150),
    NombreSexo VARCHAR(50)
);

-- 3. Crear Dimensión Empleado
CREATE TABLE DimEmpleado (
    EmpleadoSK INT IDENTITY(1,1) PRIMARY KEY,
    EmpleadoID_BK INT NOT NULL,
    NombreCompletoEmpleado VARCHAR(150)
);

-- 4. Crear Dimensión Sucursal
CREATE TABLE DimSucursal (
    SucursalSK INT IDENTITY(1,1) PRIMARY KEY,
    SucursalID_BK INT NOT NULL,
    NombreSucursal VARCHAR(100),
    Comuna VARCHAR(100),
    Ciudad VARCHAR(100)
);

-- 5. Crear Dimensión Producto
CREATE TABLE DimProducto (
    ProductoSK INT IDENTITY(1,1) PRIMARY KEY,
    ProductoID_BK INT NOT NULL,
    NombreProducto VARCHAR(150),
    Categoria VARCHAR(100),
    PrecioUnitario DECIMAL(18,2)
);

-- 6. Crear Dimensión Tiempo (LIMPIA, sin NombreDiaSemana)
CREATE TABLE DimTiempo (
    TiempoSK INT IDENTITY(1,1) PRIMARY KEY,
    Fecha DATE NOT NULL,
    Anio INT,
    Trimestre INT,
    NumeroMes INT,
    NombreMes VARCHAR(50)
);

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
    Cantidad INT,
    PrecioUnitario DECIMAL(18,2),
    MontoTotalVenta DECIMAL(18,2)
);