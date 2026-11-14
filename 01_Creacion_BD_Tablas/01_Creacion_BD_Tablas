IF DB_ID('Andreani') IS NULL
BEGIN
    CREATE DATABASE Andreani;
END
GO

USE Andreani;
GO

-- 1. CLIENTE
CREATE TABLE Cliente (
    IdCliente INT IDENTITY(1,1) PRIMARY KEY,
    NombreCliente VARCHAR(50) NOT NULL
);
GO

-- 2. DESTINO
CREATE TABLE Destino (
    IdDestino INT IDENTITY(1,1) PRIMARY KEY,
    NombreDestino VARCHAR(100) NOT NULL,
    TipoDestino VARCHAR(30) CHECK (TipoDestino IN ('FARMACIA', 'CLINICA', 'DROGERIA', 'HOSPITAL')) NOT NULL,
    Direccion VARCHAR(100) NOT NULL,
    Ciudad VARCHAR(50) NOT NULL,
    Provincia VARCHAR(50) NOT NULL
);
GO

-- 3. PRODUCTO
CREATE TABLE Producto (
    IdProducto INT IDENTITY(1,1) PRIMARY KEY,
    NombreProducto VARCHAR(100) NOT NULL,
    CategoriaProducto VARCHAR(50) NOT NULL,
    RequiereRefrigeracion BIT DEFAULT 0 NOT NULL
);
GO

-- 4. LOTE
CREATE TABLE Lote (
    IdLote INT IDENTITY(1,1) PRIMARY KEY,
    -- NOT NULL: todo lote pertenece a un producto
    IdProducto INT NOT NULL FOREIGN KEY REFERENCES Producto (IdProducto),
    FechaVencimiento DATE NOT NULL,
    -- NOT NULL: el estado no puede quedar vacio
    Estado VARCHAR(20) NOT NULL DEFAULT 'DISPONIBLE' CHECK (Estado IN ('DISPONIBLE','BLOQUEADO','VENCIDO')),
    StockLote INT NOT NULL CHECK (StockLote >= 0)
);
GO

-- 5. VEHICULO
CREATE TABLE Vehiculo (
    IdVehiculo INT IDENTITY(1,1) PRIMARY KEY,
    Patente VARCHAR(7) NOT NULL UNIQUE CHECK (Patente LIKE '[A-Z][A-Z][A-Z][0-9][0-9][0-9]' OR Patente LIKE '[A-Z][A-Z][0-9][0-9][0-9][A-Z][A-Z]'),
    TipoVehiculo VARCHAR(30) NOT NULL,
    TieneRefrigeracion BIT NOT NULL,
    Disponible BIT NOT NULL DEFAULT 1
);
GO

-- 6. PEDIDO
CREATE TABLE Pedido (
    IdPedido INT IDENTITY(1,1) PRIMARY KEY,
    IdCliente INT NOT NULL FOREIGN KEY REFERENCES Cliente (IdCliente),
    IdDestino INT NOT NULL FOREIGN KEY REFERENCES Destino (IdDestino),
    FechaPedido DATETIME NOT NULL DEFAULT GETDATE(),
    FechaEntregaSolicitada DATE NOT NULL,
    EstadoPedido VARCHAR(20) NOT NULL DEFAULT ('Registrado') CHECK (EstadoPedido IN ('Registrado', 'En preparación', 'Preparado', 'Despachado', 'Entregado', 'Rechazado', 'Cancelado'))
);
GO

-- 7. DETALLEPEDIDO
CREATE TABLE DetallePedido (
    IdPedido INT FOREIGN KEY REFERENCES Pedido (IdPedido),
    IdProducto INT FOREIGN KEY REFERENCES Producto (IdProducto),
    CantidadSolicitada INT NOT NULL CHECK (CantidadSolicitada > 0),
    PRIMARY KEY (IdPedido, IdProducto)
);
GO

-- 8. PREPARACION
CREATE TABLE Preparacion (
    IdPreparacion INT IDENTITY(1,1) PRIMARY KEY,
    IdLote INT NOT NULL FOREIGN KEY REFERENCES Lote (IdLote),
    IdProducto INT NOT NULL,
    IdPedido INT NOT NULL,
    FechaPreparacion DATE NOT NULL DEFAULT GETDATE(),
    CantidadPreparada INT NOT NULL CHECK (CantidadPreparada > 0),
    CONSTRAINT FK_Preparacion_Detalle FOREIGN KEY (IdPedido, IdProducto)
        REFERENCES DetallePedido (IdPedido, IdProducto),
    CumpleFEFO BIT NOT NULL
);
GO

-- 9. DESPACHO
CREATE TABLE Despacho (
    IdDespacho INT IDENTITY(1,1) PRIMARY KEY,
    IdVehiculo INT NOT NULL FOREIGN KEY REFERENCES Vehiculo (IdVehiculo),
    FechaSalida DATETIME NULL,
    EstadoDespacho VARCHAR(20) NOT NULL DEFAULT ('Programado') CHECK (EstadoDespacho IN ('Programado', 'En ruta', 'Finalizado'))
);
GO

-- 10. CAJA
CREATE TABLE Caja (
    IdCaja INT IDENTITY(1,1) PRIMARY KEY,
    CodigoBarra VARCHAR(50) NOT NULL UNIQUE,
    IdDestino INT NOT NULL FOREIGN KEY REFERENCES Destino (IdDestino),
    IdDespacho INT NULL FOREIGN KEY REFERENCES Despacho (IdDespacho),
    FechaArmado DATETIME NOT NULL DEFAULT GETDATE(),
    EstadoCaja VARCHAR(20) NOT NULL DEFAULT ('Armada') CHECK (EstadoCaja IN ('Armada', 'Despachada', 'Entregada', 'Rechazada'))
);
GO

-- 11. DETALLECAJA
CREATE TABLE DetalleCaja (
    IdDetalleCaja INT IDENTITY(1,1) PRIMARY KEY,
    IdCaja INT NOT NULL FOREIGN KEY REFERENCES Caja (IdCaja),
    IdPreparacion INT NOT NULL FOREIGN KEY REFERENCES Preparacion (IdPreparacion),
    CantidadEmpacada INT NOT NULL CHECK (CantidadEmpacada > 0),
    CONSTRAINT UQ_DetalleCaja UNIQUE (IdCaja, IdPreparacion)
);
GO

-- 12. ENTREGA
CREATE TABLE Entrega (
    IdEntrega INT IDENTITY(1,1) PRIMARY KEY,
    IdPedido INT NOT NULL FOREIGN KEY REFERENCES Pedido (IdPedido),
    IdDespacho INT NOT NULL FOREIGN KEY REFERENCES Despacho (IdDespacho),
    FechaEntregaReal DATETIME NULL,
    LlegoFrio BIT,
    EstadoEntrega VARCHAR(20) NOT NULL DEFAULT ('Pendiente') CHECK (EstadoEntrega IN ('Pendiente', 'Entregada', 'Rechazada')),
    CONSTRAINT CK_Entrega_FechaReal CHECK (EstadoEntrega = 'Pendiente' OR FechaEntregaReal IS NOT NULL),
    CONSTRAINT UQ_Entrega UNIQUE (IdPedido, IdDespacho)
);
GO
