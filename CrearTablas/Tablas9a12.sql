use andreani
go
create table DESPACHO(
	IdDespacho int IDENTITY(1,1) PRIMARY KEY,
	IdVehiculo int not null foreign key references VEHICULO(IdVehiculo),
	FechaSalida datetime null,
	EstadoDespacho varchar(20) not null default ('Programado') check (EstadoDespacho IN ('Programado', 'En ruta', 'Finalizado'))
	)
go
create table CAJA(
	IdCaja int IDENTITY(1,1) PRIMARY KEY,
	CodigoBarra varchar(50) not null unique,
	IdDestino int not null foreign key references DESTINO(IDDESTINO),
	IdDespacho int null foreign key references DESPACHO(IdDespacho),
	FechaArmado datetime not null default getdate(),
	EstadoCaja varchar(20) not null default ('Armada') check (EstadoCaja IN ('Armada', 'Despachada', 'Entregada', 'Rechazada'))
	)
go
create table DETALLECAJA(
	IdDetalleCaja int IDENTITY(1,1) PRIMARY KEY,
	IdCaja int not null foreign key references CAJA(IdCaja),
	IdPreparacion int not null foreign key references PREPARACION(IdPreparacion),
	CantidadEmpacada int not null check (CantidadEmpacada > 0),
	constraint UQ_DetalleCaja unique (IdCaja, IdPreparacion)
	)
go
create table ENTREGA(
	IdEntrega int IDENTITY(1,1) PRIMARY KEY,
	IdPedido int not null foreign key references PEDIDO(IdPedido),
	IdDespacho int not null foreign key references DESPACHO(IdDespacho),
	FechaEntregaReal datetime null,
	EstadoEntrega varchar(20) not null default ('Pendiente') check (EstadoEntrega IN ('Pendiente', 'Entregada', 'Rechazada')),
	constraint CK_Entrega_FechaReal check (EstadoEntrega = 'Pendiente' OR FechaEntregaReal IS NOT NULL),
	constraint UQ_Entrega unique (IdPedido, IdDespacho)
	)
go

