CREATE DATABASE DW_Albarran;
GO
USE DW_Albarran;
GO

-- 1. Dimensión Tiempo
CREATE TABLE DimTiempo (
    TiempoSK INT PRIMARY KEY,  
    Fecha DATE NOT NULL,
    Anio INT NOT NULL,
    Trimestre INT NOT NULL,
    NumeroMes INT NOT NULL,
    NombreMes VARCHAR(20) NOT NULL,
    NumeroDia INT NOT NULL,
    NombreDiaSemana VARCHAR(20) NOT NULL 
);

-- 2. Dimensión Cliente
CREATE TABLE DimCliente (
    ClienteSK INT IDENTITY(1,1) PRIMARY KEY,
    ClienteID_BK INT NOT NULL, 
    NombreCompletoCliente VARCHAR(150),
    NombreSexo VARCHAR(20),
    EstadoCivilCliente VARCHAR(50),
    FechaNacimientoCliente DATE
);

-- 3. Dimensión Empleado
CREATE TABLE DimEmpleado (
    EmpleadoSK INT IDENTITY(1,1) PRIMARY KEY,
    EmpleadoID_BK INT NOT NULL,
    NombreCompletoEmpleado VARCHAR(150),
    NombreCargo VARCHAR(100),
    FechaContratoEmpleado DATE
);

-- 4. Dimensión Producto
CREATE TABLE DimProducto (
    ProductoSK INT IDENTITY(1,1) PRIMARY KEY,
    ProductoID_BK INT NOT NULL,
    NombreProducto VARCHAR(100),
    NombreCategoria VARCHAR(100),
    PrecioUnitarioReferencial DECIMAL(12,2)
);

-- 5. Dimensión Sucursal
CREATE TABLE DimSucursal (
    SucursalSK INT IDENTITY(1,1) PRIMARY KEY,
    SucursalID_BK INT NOT NULL,
    NombreSucursal VARCHAR(100),
    NombreComuna VARCHAR(100)
);

-- 6. Tabla de Hechos FactVentas
CREATE TABLE FactVentas (
    VentaID_BK INT NOT NULL,
    ProductoSK INT NOT NULL,
    ClienteSK INT NOT NULL,
    EmpleadoSK INT NOT NULL,
    SucursalSK INT NOT NULL,
    TiempoSK INT NOT NULL,
    NumeroDocumento VARCHAR(50),
    TipoDocumento VARCHAR(50),
    CantidadProducto INT,
    PrecioUnitarioProducto DECIMAL(12,2),
    DescuentoProducto DECIMAL(12,2),
    MontoTotalVenta DECIMAL(12,2),
    CONSTRAINT PK_FactVentas PRIMARY KEY (VentaID_BK, ProductoSK, ClienteSK, EmpleadoSK, SucursalSK, TiempoSK),
    CONSTRAINT FK_FactVentas_Producto FOREIGN KEY (ProductoSK) REFERENCES DimProducto(ProductoSK),
    CONSTRAINT FK_FactVentas_Cliente FOREIGN KEY (ClienteSK) REFERENCES DimCliente(ClienteSK),
    CONSTRAINT FK_FactVentas_Empleado FOREIGN KEY (EmpleadoSK) REFERENCES DimEmpleado(EmpleadoSK),
    CONSTRAINT FK_FactVentas_Sucursal FOREIGN KEY (SucursalSK) REFERENCES DimSucursal(SucursalSK),
    CONSTRAINT FK_FactVentas_Tiempo FOREIGN KEY (TiempoSK) REFERENCES DimTiempo(TiempoSK)
);