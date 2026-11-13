USE Andreani
GO

CREATE TABLE Cliente (
    IdCliente INT IDENTITY(1,1) PRIMARY KEY,
    NombreCliente VARCHAR(50) NOT NULL
)
GO

CREATE TABLE Destino (
    IdDestino INT IDENTITY(1,1) PRIMARY KEY,
    NombreDestino VARCHAR(100) NOT NULL,
    TipoDestino VARCHAR(30) CHECK (TipoDestino IN ('FARMACIA', 'CLINICA', 'DROGERIA', 'HOSPITAL')) NOT NULL,
    Direccion VARCHAR(100) NOT NULL,
    Ciudad VARCHAR(50) NOT NULL,
    Provincia VARCHAR(50) NOT NULL
)
GO

CREATE TABLE Producto (
    IdProducto INT IDENTITY(1,1) PRIMARY KEY,
    NombreProducto VARCHAR(100) NOT NULL,
    CategoriaProducto VARCHAR(50) NOT NULL,
    RequiereRefrigeracion BIT DEFAULT 0 NOT NULL
)
