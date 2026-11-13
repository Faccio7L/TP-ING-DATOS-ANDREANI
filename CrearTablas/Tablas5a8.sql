USE Andreani
GO

CREATE TABLE Vehiculo (
    IdVehiculo INT IDENTITY(1,1) PRIMARY KEY,
    Patente VARCHAR(7) NOT NULL UNIQUE CHECK (Patente LIKE '[A-Z][A-Z][A-Z][0-9][0-9][0-9]' OR Patente LIKE '[A-Z][A-Z][0-9][0-9][0-9][A-Z][A-Z]'),
    TipoVehiculo VARCHAR(30) NOT NULL,
    TieneRefrigeracion BIT NOT NULL,
    Disponible BIT NOT NULL DEFAULT 1
)
GO

CREATE TABLE Pedido (
    IdPedido INT IDENTITY(1,1) PRIMARY KEY,
    IdCliente INT NOT NULL FOREIGN KEY REFERENCES Cliente (IdCliente),
    IdDestino INT NOT NULL FOREIGN KEY REFERENCES Destino (IdDestino),
    FechaPedido DATETIME NOT NULL DEFAULT GETDATE(),
    FechaEntregaSolicitada DATE NOT NULL,
    EstadoPedido VARCHAR(20) NOT NULL DEFAULT ('Registrado') CHECK (EstadoPedido IN ('Registrado', 'En preparación', 'Preparado', 'Despachado', 'Entregado', 'Rechazado', 'Cancelado')),
)
GO

CREATE TABLE DetallePedido (
    IdPedido INT FOREIGN KEY REFERENCES Pedido (IdPedido),
    IdProducto INT FOREIGN KEY REFERENCES Producto (IdProducto),
    CantidadSolicitada INT NOT NULL CHECK (CantidadSolicitada > 0),
    PRIMARY KEY (IdPedido, IdProducto)
)
GO

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
)
GO
