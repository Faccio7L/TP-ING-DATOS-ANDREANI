USE Andreani
GO

CREATE TABLE Despacho (
    IdDespacho INT IDENTITY(1,1) PRIMARY KEY,
    IdVehiculo INT NOT NULL FOREIGN KEY REFERENCES Vehiculo (IdVehiculo),
    FechaSalida DATETIME NULL,
    EstadoDespacho VARCHAR(20) NOT NULL DEFAULT ('Programado') CHECK (EstadoDespacho IN ('Programado', 'En ruta', 'Finalizado'))
)
GO

CREATE TABLE Caja (
    IdCaja INT IDENTITY(1,1) PRIMARY KEY,
    CodigoBarra VARCHAR(50) NOT NULL UNIQUE,
    IdDestino INT NOT NULL FOREIGN KEY REFERENCES Destino (IdDestino),
    IdDespacho INT NULL FOREIGN KEY REFERENCES Despacho (IdDespacho),
    FechaArmado DATETIME NOT NULL DEFAULT GETDATE(),
    EstadoCaja VARCHAR(20) NOT NULL DEFAULT ('Armada') CHECK (EstadoCaja IN ('Armada', 'Despachada', 'Entregada', 'Rechazada'))
)
GO

CREATE TABLE DetalleCaja (
    IdDetalleCaja INT IDENTITY(1,1) PRIMARY KEY,
    IdCaja INT NOT NULL FOREIGN KEY REFERENCES Caja (IdCaja),
    IdPreparacion INT NOT NULL FOREIGN KEY REFERENCES Preparacion (IdPreparacion),
    CantidadEmpacada INT NOT NULL CHECK (CantidadEmpacada > 0),
    CONSTRAINT UQ_DetalleCaja UNIQUE (IdCaja, IdPreparacion)
)
GO

CREATE TABLE Entrega (
    IdEntrega INT IDENTITY(1,1) PRIMARY KEY,
    IdPedido INT NOT NULL FOREIGN KEY REFERENCES Pedido (IdPedido),
    IdDespacho INT NOT NULL FOREIGN KEY REFERENCES Despacho (IdDespacho),
    FechaEntregaReal DATETIME NULL,
    LlegoFrio BIT,
    EstadoEntrega VARCHAR(20) NOT NULL DEFAULT ('Pendiente') CHECK (EstadoEntrega IN ('Pendiente', 'Entregada', 'Rechazada')),
    CONSTRAINT CK_Entrega_FechaReal CHECK (EstadoEntrega = 'Pendiente' OR FechaEntregaReal IS NOT NULL),
    CONSTRAINT UQ_Entrega UNIQUE (IdPedido, IdDespacho)
)
GO

