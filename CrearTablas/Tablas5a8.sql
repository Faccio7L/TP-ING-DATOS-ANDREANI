use andreani
go
create table VEHICULO (
	IdVehiculo int IDENTITY(1,1) PRIMARY KEY,
	Patente VARCHAR(7) NOT NULL UNIQUE CHECK(Patente LIKE '[A-Z][A-Z][A-Z][0-9][0-9][0-9]' OR Patente LIKE '[A-Z][A-Z][0-9][0-9][0-9][A-Z][A-Z]'),
	TipoVehiculo varchar(30) not null,
	TieneRefrigeracion bit not null,
	Disponible bit not null default 1
	)
Go
create table PEDIDO(
	IdPedido int IDENTITY(1,1) PRIMARY KEY,
	IdCliente int not null foreign key references CLIENTE (IDCLIENTE),
	IdDestino int not null foreign key references DESTINO(IDDESTINO),
	FechaPedido datetime not null default getDate(),
	FechaEntregaSolicitada date not null,
	EstadoPedido varchar(20) not null default ('Registrado') Check (EstadoPedido IN ('Registrado','En preparación', 'Preparado', 'Despachado', 'Entregado', 'Rechazado', 'Cancelado')),
	TemperaturaPedido decimal(4,1)
	)
go
Create table DETALLEPEDIDO(
	IdPedido int foreign key  references PEDIDO(IdPedido),
	IdProducto int foreign key references PRODUCTO(IDPRODUCTO),
	CantidadSolicitada int not null CHECK (CantidadSolicitada > 0),
	PRIMARY KEY (IdPedido, IdProducto)
	)
go
create table PREPARACION(
	IdPreparacion int IDENTITY(1,1) PRIMARY KEY,
	IdLote int not null foreign key references LOTE(IDLOTE), 
	IdProducto int not null,
	IdPedido int not null,
	FechaPreparacion date not null default getdate(),
	CantidadPreparada int not null check (CantidadPreparada>0),
	constraint FK_Preparacion_Detalle foreign key (IdPedido, IdProducto)
		references DETALLEPEDIDO(IdPedido, IdProducto)
)
go

