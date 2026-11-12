USE andreani;
GO

-- 1. CLIENTE
INSERT INTO CLIENTE (NOMBRECLIENTE) VALUES
('Laboratorios Bagó S.A.'),
('Roemmers S.A.I.C.F.'),
('Elea Phoenix S.A.'),
('Pfizer Argentina S.R.L.'),
('Biosidus S.A.');
GO

-- 2. DESTINO
INSERT INTO DESTINO (NOMBREDESTINO, TIPODESTINO, DIRECCION, CIUDAD, PROVINCIA) VALUES
('Hospital Italiano de Buenos Aires', 'HOSPITAL', 'Tte. Gral. Juan D. Perón 4190', 'CABA', 'Buenos Aires'),
('Farmacity Microcentro', 'FARMACIA', 'Av. Corrientes 840', 'CABA', 'Buenos Aires'),
('Clínica Adventista Belgrano', 'CLINICA', 'Estomba 1710', 'CABA', 'Buenos Aires'),
('Droguería Monroe Americana', 'DROGERIA', 'Av. Pellegrini 2350', 'Rosario', 'Santa Fe'),
('Hospital Privado Universitario', 'HOSPITAL', 'Av. Naciones Unidas 346', 'Córdoba', 'Córdoba'),
('Farmacia Del Pueblo', 'FARMACIA', 'Av. Bunge 620', 'Pinamar', 'Buenos Aires');
GO

-- 3. PRODUCTO
INSERT INTO PRODUCTO (NOMBREPRODUCTO, CATEGORIAPRODUCTO, RequiereRefrigeracion) VALUES
('Insulina Glargina 100 UI/ml', 'Biológicos', 1),
('Vacuna Antigripal Tetravalente', 'Vacunas', 1),
('Amoxicilina 500mg x 21 comp', 'Antibióticos', 0),
('Ibuprofeno 600mg x 20 comp', 'Analgésicos', 0),
('Adalimumab 40mg Jeringa Prellenada', 'Biológicos', 1),
('Omeprazol 20mg x 30 cáps', 'Gastroenterología', 0);
GO

-- 4. LOTE
INSERT INTO LOTE (IDPRODUCTO, FECHAVENCIMIENTO, ESTADO, STOCKLOTE) VALUES
(1, '2027-03-15', 'DISPONIBLE', 500),
(1, '2027-08-20', 'DISPONIBLE', 300),
(2, '2027-01-30', 'DISPONIBLE', 800),
(3, '2028-05-10', 'DISPONIBLE', 1200),
(4, '2028-09-01', 'DISPONIBLE', 1500),
(5, '2027-04-12', 'DISPONIBLE', 250),
(6, '2027-11-25', 'DISPONIBLE', 900),
(2, '2026-06-01', 'VENCIDO', 40);
GO

-- 5. VEHICULO
INSERT INTO VEHICULO (Patente, TipoVehiculo, TieneRefrigeracion, Disponible) VALUES
('AF123CD', 'Furgón Refrigerado', 1, 1),
('AE456FG', 'Camión Térmico', 1, 1),
('AD789HI', 'Utilitario Liviano', 0, 1),
('AC321JK', 'Furgón Refrigerado', 1, 1),
('JKL987',  'Camión Mediano', 0, 1);
GO

-- 6. PEDIDO (uno por INSERT por TRG_VALIDAR_PEDIDOS)
INSERT INTO PEDIDO (IdCliente, IdDestino, FechaPedido, FechaEntregaSolicitada, EstadoPedido)
VALUES (1, 1, GETDATE(), DATEADD(DAY, 2, CAST(GETDATE() AS DATE)), 'Entregado');

INSERT INTO PEDIDO (IdCliente, IdDestino, FechaPedido, FechaEntregaSolicitada, EstadoPedido)
VALUES (2, 2, GETDATE(), DATEADD(DAY, 3, CAST(GETDATE() AS DATE)), 'Entregado');

INSERT INTO PEDIDO (IdCliente, IdDestino, FechaPedido, FechaEntregaSolicitada, EstadoPedido)
VALUES (3, 4, GETDATE(), DATEADD(DAY, 4, CAST(GETDATE() AS DATE)), 'Rechazado');

INSERT INTO PEDIDO (IdCliente, IdDestino, FechaPedido, FechaEntregaSolicitada, EstadoPedido)
VALUES (4, 5, GETDATE(), DATEADD(DAY, 5, CAST(GETDATE() AS DATE)), 'Despachado');

INSERT INTO PEDIDO (IdCliente, IdDestino, FechaPedido, FechaEntregaSolicitada, EstadoPedido)
VALUES (5, 3, GETDATE(), DATEADD(DAY, 6, CAST(GETDATE() AS DATE)), 'En preparación');

INSERT INTO PEDIDO (IdCliente, IdDestino, FechaPedido, FechaEntregaSolicitada, EstadoPedido)
VALUES (1, 6, GETDATE(), DATEADD(DAY, 8, CAST(GETDATE() AS DATE)), 'Registrado');
GO

-- 7. DETALLEPEDIDO
INSERT INTO DETALLEPEDIDO (IdPedido, IdProducto, CantidadSolicitada) VALUES
(1, 1, 50),
(1, 2, 100),
(2, 3, 200),
(2, 4, 150),
(3, 1, 30),
(3, 5, 20),
(4, 6, 120),
(5, 2, 80),
(6, 3, 60);
GO

-- 8. PREPARACION
INSERT INTO PREPARACION (IdLote, IdProducto, IdPedido, FechaPreparacion, CantidadPreparada, CumpleFEFO) VALUES
(1, 1, 1, CAST(GETDATE() AS DATE), 50, 1),
(3, 2, 1, CAST(GETDATE() AS DATE), 100, 1),
(4, 3, 2, CAST(GETDATE() AS DATE), 200, 1),
(5, 4, 2, CAST(GETDATE() AS DATE), 150, 1),
(2, 1, 3, CAST(GETDATE() AS DATE), 30, 0),
(6, 5, 3, CAST(GETDATE() AS DATE), 20, 1),
(7, 6, 4, CAST(GETDATE() AS DATE), 120, 1),
(3, 2, 5, CAST(GETDATE() AS DATE), 80, 1);
GO

-- 9. DESPACHO (uno por INSERT por TRG_DESPACHO_ACTUALIZAR_VEHICULO; deja libre el vehículo 5)
INSERT INTO DESPACHO (IdVehiculo, FechaSalida, EstadoDespacho)
VALUES (1, DATEADD(HOUR, -5, GETDATE()), 'Finalizado');

INSERT INTO DESPACHO (IdVehiculo, FechaSalida, EstadoDespacho)
VALUES (2, DATEADD(HOUR, -3, GETDATE()), 'Finalizado');

INSERT INTO DESPACHO (IdVehiculo, FechaSalida, EstadoDespacho)
VALUES (3, DATEADD(HOUR, -1, GETDATE()), 'En ruta');

INSERT INTO DESPACHO (IdVehiculo, FechaSalida, EstadoDespacho)
VALUES (4, NULL, 'Programado');
GO

-- 10. CAJA
INSERT INTO CAJA (CodigoBarra, IdDestino, IdDespacho, FechaArmado, EstadoCaja) VALUES
('AND-CB-0001', 1, 1, GETDATE(), 'Entregada'),
('AND-CB-0002', 2, 3, GETDATE(), 'Despachada'),
('AND-CB-0003', 4, 2, GETDATE(), 'Rechazada'),
('AND-CB-0004', 5, 3, GETDATE(), 'Despachada'),
('AND-CB-0005', 3, NULL, GETDATE(), 'Armada');
GO

-- 11. DETALLECAJA
INSERT INTO DETALLECAJA (IdCaja, IdPreparacion, CantidadEmpacada) VALUES
(1, 1, 50),
(1, 2, 100),
(2, 3, 200),
(2, 4, 150),
(3, 5, 30),
(3, 6, 20),
(4, 7, 120),
(5, 8, 80);
GO

-- 12. ENTREGA
INSERT INTO ENTREGA (IdPedido, IdDespacho, FechaEntregaReal, LlegoFrio, EstadoEntrega) VALUES
(1, 1, GETDATE(), 1, 'Entregada'),
(2, 3, GETDATE(), NULL, 'Entregada'),
(3, 2, GETDATE(), 0, 'Rechazada'),
(4, 3, NULL, NULL, 'Pendiente'),
(5, 4, NULL, 1, 'Pendiente');
GO
