USE andreani;
GO

SET NOCOUNT ON;

DELETE FROM ENTREGA;
DELETE FROM DETALLECAJA;
DELETE FROM CAJA;
DELETE FROM DESPACHO;
DELETE FROM PREPARACION;
DELETE FROM DETALLEPEDIDO;
DELETE FROM PEDIDO;
DELETE FROM VEHICULO;
DELETE FROM LOTE;
DELETE FROM PRODUCTO;
DELETE FROM DESTINO;
DELETE FROM CLIENTE;

IF EXISTS (SELECT 1 FROM sys.identity_columns WHERE object_id = OBJECT_ID('dbo.ENTREGA') AND last_value IS NOT NULL) DBCC CHECKIDENT ('dbo.ENTREGA', RESEED, 0);
IF EXISTS (SELECT 1 FROM sys.identity_columns WHERE object_id = OBJECT_ID('dbo.DETALLECAJA') AND last_value IS NOT NULL) DBCC CHECKIDENT ('dbo.DETALLECAJA', RESEED, 0);
IF EXISTS (SELECT 1 FROM sys.identity_columns WHERE object_id = OBJECT_ID('dbo.CAJA') AND last_value IS NOT NULL) DBCC CHECKIDENT ('dbo.CAJA', RESEED, 0);
IF EXISTS (SELECT 1 FROM sys.identity_columns WHERE object_id = OBJECT_ID('dbo.DESPACHO') AND last_value IS NOT NULL) DBCC CHECKIDENT ('dbo.DESPACHO', RESEED, 0);
IF EXISTS (SELECT 1 FROM sys.identity_columns WHERE object_id = OBJECT_ID('dbo.PREPARACION') AND last_value IS NOT NULL) DBCC CHECKIDENT ('dbo.PREPARACION', RESEED, 0);
IF EXISTS (SELECT 1 FROM sys.identity_columns WHERE object_id = OBJECT_ID('dbo.PEDIDO') AND last_value IS NOT NULL) DBCC CHECKIDENT ('dbo.PEDIDO', RESEED, 0);
IF EXISTS (SELECT 1 FROM sys.identity_columns WHERE object_id = OBJECT_ID('dbo.VEHICULO') AND last_value IS NOT NULL) DBCC CHECKIDENT ('dbo.VEHICULO', RESEED, 0);
IF EXISTS (SELECT 1 FROM sys.identity_columns WHERE object_id = OBJECT_ID('dbo.LOTE') AND last_value IS NOT NULL) DBCC CHECKIDENT ('dbo.LOTE', RESEED, 0);
IF EXISTS (SELECT 1 FROM sys.identity_columns WHERE object_id = OBJECT_ID('dbo.PRODUCTO') AND last_value IS NOT NULL) DBCC CHECKIDENT ('dbo.PRODUCTO', RESEED, 0);
IF EXISTS (SELECT 1 FROM sys.identity_columns WHERE object_id = OBJECT_ID('dbo.DESTINO') AND last_value IS NOT NULL) DBCC CHECKIDENT ('dbo.DESTINO', RESEED, 0);
IF EXISTS (SELECT 1 FROM sys.identity_columns WHERE object_id = OBJECT_ID('dbo.CLIENTE') AND last_value IS NOT NULL) DBCC CHECKIDENT ('dbo.CLIENTE', RESEED, 0);
GO

-- ===================== 1. CLIENTE (5) =====================
INSERT INTO CLIENTE (NOMBRECLIENTE) VALUES
('Laboratorios Bagó S.A.'),
('Roemmers S.A.I.C.F.'),
('Elea Phoenix S.A.'),
('Pfizer Argentina S.R.L.'),
('Biosidus S.A.');
GO

-- ===================== 2. DESTINO (16 en 8 provincias) =====================
INSERT INTO DESTINO (NOMBREDESTINO, TIPODESTINO, DIRECCION, CIUDAD, PROVINCIA) VALUES
('Hospital Italiano de Buenos Aires', 'HOSPITAL', 'Tte. Gral. Juan D. Perón 4190', 'CABA', 'Buenos Aires'),
('Farmacity Microcentro', 'FARMACIA', 'Av. Corrientes 840', 'CABA', 'Buenos Aires'),
('Clínica Adventista Belgrano', 'CLINICA', 'Estomba 1710', 'CABA', 'Buenos Aires'),
('Droguería Monroe Americana', 'DROGERIA', 'Av. Pellegrini 2350', 'Rosario', 'Santa Fe'),
('Hospital Privado Universitario', 'HOSPITAL', 'Av. Naciones Unidas 346', 'Córdoba', 'Córdoba'),
('Farmacia Del Pueblo', 'FARMACIA', 'Av. Bunge 620', 'Pinamar', 'Buenos Aires'),
('Hospital Central de Mendoza', 'HOSPITAL', 'Alem 450', 'Mendoza', 'Mendoza'),
('Droguería del Sud Tucumán', 'DROGERIA', 'Av. Mate de Luna 1820', 'San Miguel de Tucumán', 'Tucumán'),
('Clínica Santa Catalina', 'CLINICA', 'Bv. Oroño 1420', 'Rosario', 'Santa Fe'),
('Farmacia Pasteur', 'FARMACIA', 'Av. Colón 750', 'Córdoba', 'Córdoba'),
('Hospital San Bernardo', 'HOSPITAL', 'Tobías 69', 'Salta', 'Salta'),
('Clínica Pasteur Neuquén', 'CLINICA', 'La Rioja 36', 'Neuquén', 'Neuquén'),
('Hospital Interzonal Mar del Plata', 'HOSPITAL', 'Av. Juan B. Justo 6701', 'Mar del Plata', 'Buenos Aires'),
('Farmacia Santa Fe Centro', 'FARMACIA', 'San Martín 2410', 'Santa Fe', 'Santa Fe'),
('Clínica Modelo Paraná', 'CLINICA', 'San Martín 1238', 'Paraná', 'Entre Ríos'),
('Droguería Cuyo', 'DROGERIA', 'Av. San Martín 1150', 'Godoy Cruz', 'Mendoza');
GO

-- ===================== 3. PRODUCTO (12) =====================
INSERT INTO PRODUCTO (NOMBREPRODUCTO, CATEGORIAPRODUCTO, RequiereRefrigeracion) VALUES
('Insulina Glargina 100 UI/ml', 'Biológicos', 1),
('Vacuna Antigripal Tetravalente', 'Vacunas', 1),
('Amoxicilina 500mg x 21 comp', 'Antibióticos', 0),
('Ibuprofeno 600mg x 20 comp', 'Analgésicos', 0),
('Adalimumab 40mg Jeringa Prellenada', 'Biológicos', 1),
('Omeprazol 20mg x 30 cáps', 'Gastroenterología', 0),
('Bevacizumab 400mg Vial', 'Oncológicos', 1),
('Atorvastatina 20mg x 30 comp', 'Cardiología', 0),
('Metformina 850mg x 30 comp', 'Endocrinología', 0),
('Somatropina 12mg Cartucho', 'Biológicos', 1),
('Enalapril 10mg x 30 comp', 'Cardiología', 0),
('Vacuna Neumocócica 13-valente', 'Vacunas', 1);
GO

-- ===================== 4. LOTE (24) =====================
INSERT INTO LOTE (IDPRODUCTO, FECHAVENCIMIENTO, ESTADO, STOCKLOTE) VALUES
(1,  '2027-03-15', 'DISPONIBLE', 500),
(1,  '2027-08-20', 'DISPONIBLE', 300),
(2,  '2027-01-30', 'DISPONIBLE', 800),
(3,  '2028-05-10', 'DISPONIBLE', 1200),
(4,  '2028-09-01', 'DISPONIBLE', 1500),
(5,  '2027-04-12', 'DISPONIBLE', 250),
(6,  '2027-11-25', 'DISPONIBLE', 900),
(2,  '2026-06-01', 'VENCIDO',    40),
(7,  '2027-05-18', 'DISPONIBLE', 180),
(8,  '2028-02-14', 'DISPONIBLE', 1100),
(9,  '2028-07-09', 'DISPONIBLE', 950),
(10, '2027-06-22', 'DISPONIBLE', 140),
(11, '2028-10-30', 'DISPONIBLE', 1300),
(12, '2027-02-19', 'DISPONIBLE', 600),
(5,  '2027-03-01', 'BLOQUEADO',  60),
(7,  '2027-12-01', 'DISPONIBLE', 220),
(10, '2026-04-10', 'VENCIDO',    15),
(12, '2027-09-15', 'BLOQUEADO',  90),
(3,  '2028-11-11', 'DISPONIBLE', 700),
(4,  '2029-01-20', 'DISPONIBLE', 850),
(6,  '2028-04-15', 'DISPONIBLE', 640),
(8,  '2028-08-05', 'DISPONIBLE', 900),
(9,  '2026-09-01', 'VENCIDO',    25),
(11, '2026-10-01', 'VENCIDO',    30);
GO

-- ===================== 5. VEHICULO (15) =====================
INSERT INTO VEHICULO (Patente, TipoVehiculo, TieneRefrigeracion, Disponible) VALUES
('AF123CD', 'Furgón Refrigerado', 1, 1),
('AE456FG', 'Camión Térmico',     1, 1),
('AD789HI', 'Utilitario Liviano', 0, 1),
('AC321JK', 'Furgón Refrigerado', 1, 1),
('AG654LM', 'Furgón Refrigerado', 1, 1),
('AB987NP', 'Utilitario Liviano', 0, 1),
('AA147QR', 'Camión Térmico',     1, 1),
('JKL987',  'Camión Mediano',     0, 1),
('MNO654',  'Furgón Refrigerado', 1, 1),
('PQR321',  'Utilitario Liviano', 0, 1),
('AH258ST', 'Camión Térmico',     1, 1),
('AI369UV', 'Furgón Refrigerado', 1, 1),
('AJ741WX', 'Camión Mediano',     0, 1),
('AK852YZ', 'Furgón Refrigerado', 1, 1),
('STU111',  'Utilitario Liviano', 0, 1);
GO

-- ===================== 6. PEDIDO (40 pedidos, uno por INSERT) =====================
INSERT INTO PEDIDO (IdCliente, IdDestino, FechaPedido, FechaEntregaSolicitada, EstadoPedido) VALUES (1, 1,  DATEADD(DAY, -10, GETDATE()), DATEADD(DAY, 1, CAST(GETDATE() AS DATE)), 'Entregado');
INSERT INTO PEDIDO (IdCliente, IdDestino, FechaPedido, FechaEntregaSolicitada, EstadoPedido) VALUES (2, 2,  DATEADD(DAY, -12, GETDATE()), DATEADD(DAY, 1, CAST(GETDATE() AS DATE)), 'Entregado');
INSERT INTO PEDIDO (IdCliente, IdDestino, FechaPedido, FechaEntregaSolicitada, EstadoPedido) VALUES (3, 3,  DATEADD(DAY, -8,  GETDATE()), DATEADD(DAY, 1, CAST(GETDATE() AS DATE)), 'Entregado');
INSERT INTO PEDIDO (IdCliente, IdDestino, FechaPedido, FechaEntregaSolicitada, EstadoPedido) VALUES (4, 4,  DATEADD(DAY, -14, GETDATE()), DATEADD(DAY, 2, CAST(GETDATE() AS DATE)), 'Entregado');
INSERT INTO PEDIDO (IdCliente, IdDestino, FechaPedido, FechaEntregaSolicitada, EstadoPedido) VALUES (5, 5,  DATEADD(DAY, -15, GETDATE()), DATEADD(DAY, 1, CAST(GETDATE() AS DATE)), 'Entregado');
INSERT INTO PEDIDO (IdCliente, IdDestino, FechaPedido, FechaEntregaSolicitada, EstadoPedido) VALUES (1, 6,  DATEADD(DAY, -9,  GETDATE()), DATEADD(DAY, 2, CAST(GETDATE() AS DATE)), 'Entregado');
INSERT INTO PEDIDO (IdCliente, IdDestino, FechaPedido, FechaEntregaSolicitada, EstadoPedido) VALUES (2, 7,  DATEADD(DAY, -16, GETDATE()), DATEADD(DAY, 1, CAST(GETDATE() AS DATE)), 'Entregado');
INSERT INTO PEDIDO (IdCliente, IdDestino, FechaPedido, FechaEntregaSolicitada, EstadoPedido) VALUES (3, 8,  DATEADD(DAY, -18, GETDATE()), DATEADD(DAY, 2, CAST(GETDATE() AS DATE)), 'Entregado');
INSERT INTO PEDIDO (IdCliente, IdDestino, FechaPedido, FechaEntregaSolicitada, EstadoPedido) VALUES (4, 9,  DATEADD(DAY, -11, GETDATE()), DATEADD(DAY, 1, CAST(GETDATE() AS DATE)), 'Entregado');
INSERT INTO PEDIDO (IdCliente, IdDestino, FechaPedido, FechaEntregaSolicitada, EstadoPedido) VALUES (5, 10, DATEADD(DAY, -13, GETDATE()), DATEADD(DAY, 2, CAST(GETDATE() AS DATE)), 'Entregado');
INSERT INTO PEDIDO (IdCliente, IdDestino, FechaPedido, FechaEntregaSolicitada, EstadoPedido) VALUES (1, 11, DATEADD(DAY, -17, GETDATE()), DATEADD(DAY, 1, CAST(GETDATE() AS DATE)), 'Entregado');
INSERT INTO PEDIDO (IdCliente, IdDestino, FechaPedido, FechaEntregaSolicitada, EstadoPedido) VALUES (2, 12, DATEADD(DAY, -15, GETDATE()), DATEADD(DAY, 2, CAST(GETDATE() AS DATE)), 'Entregado');
INSERT INTO PEDIDO (IdCliente, IdDestino, FechaPedido, FechaEntregaSolicitada, EstadoPedido) VALUES (3, 13, DATEADD(DAY, -7,  GETDATE()), DATEADD(DAY, 1, CAST(GETDATE() AS DATE)), 'Entregado');
INSERT INTO PEDIDO (IdCliente, IdDestino, FechaPedido, FechaEntregaSolicitada, EstadoPedido) VALUES (4, 14, DATEADD(DAY, -10, GETDATE()), DATEADD(DAY, 2, CAST(GETDATE() AS DATE)), 'Entregado');
INSERT INTO PEDIDO (IdCliente, IdDestino, FechaPedido, FechaEntregaSolicitada, EstadoPedido) VALUES (5, 15, DATEADD(DAY, -11, GETDATE()), DATEADD(DAY, 1, CAST(GETDATE() AS DATE)), 'Entregado');
INSERT INTO PEDIDO (IdCliente, IdDestino, FechaPedido, FechaEntregaSolicitada, EstadoPedido) VALUES (1, 16, DATEADD(DAY, -14, GETDATE()), DATEADD(DAY, 2, CAST(GETDATE() AS DATE)), 'Entregado');
INSERT INTO PEDIDO (IdCliente, IdDestino, FechaPedido, FechaEntregaSolicitada, EstadoPedido) VALUES (2, 1,  DATEADD(DAY, -6,  GETDATE()), DATEADD(DAY, 1, CAST(GETDATE() AS DATE)), 'Entregado');
INSERT INTO PEDIDO (IdCliente, IdDestino, FechaPedido, FechaEntregaSolicitada, EstadoPedido) VALUES (3, 4,  DATEADD(DAY, -9,  GETDATE()), DATEADD(DAY, 1, CAST(GETDATE() AS DATE)), 'Entregado');
INSERT INTO PEDIDO (IdCliente, IdDestino, FechaPedido, FechaEntregaSolicitada, EstadoPedido) VALUES (4, 5,  DATEADD(DAY, -12, GETDATE()), DATEADD(DAY, 1, CAST(GETDATE() AS DATE)), 'Entregado');
INSERT INTO PEDIDO (IdCliente, IdDestino, FechaPedido, FechaEntregaSolicitada, EstadoPedido) VALUES (5, 7,  DATEADD(DAY, -13, GETDATE()), DATEADD(DAY, 1, CAST(GETDATE() AS DATE)), 'Entregado');
INSERT INTO PEDIDO (IdCliente, IdDestino, FechaPedido, FechaEntregaSolicitada, EstadoPedido) VALUES (1, 8,  DATEADD(DAY, -15, GETDATE()), DATEADD(DAY, 1, CAST(GETDATE() AS DATE)), 'Entregado');
INSERT INTO PEDIDO (IdCliente, IdDestino, FechaPedido, FechaEntregaSolicitada, EstadoPedido) VALUES (2, 11, DATEADD(DAY, -16, GETDATE()), DATEADD(DAY, 1, CAST(GETDATE() AS DATE)), 'Entregado');
INSERT INTO PEDIDO (IdCliente, IdDestino, FechaPedido, FechaEntregaSolicitada, EstadoPedido) VALUES (3, 12, DATEADD(DAY, -14, GETDATE()), DATEADD(DAY, 1, CAST(GETDATE() AS DATE)), 'Entregado');
INSERT INTO PEDIDO (IdCliente, IdDestino, FechaPedido, FechaEntregaSolicitada, EstadoPedido) VALUES (4, 15, DATEADD(DAY, -8,  GETDATE()), DATEADD(DAY, 1, CAST(GETDATE() AS DATE)), 'Entregado');
INSERT INTO PEDIDO (IdCliente, IdDestino, FechaPedido, FechaEntregaSolicitada, EstadoPedido) VALUES (5, 16, DATEADD(DAY, -11, GETDATE()), DATEADD(DAY, 1, CAST(GETDATE() AS DATE)), 'Entregado');
INSERT INTO PEDIDO (IdCliente, IdDestino, FechaPedido, FechaEntregaSolicitada, EstadoPedido) VALUES (1, 4,  DATEADD(DAY, -7,  GETDATE()), DATEADD(DAY, 2, CAST(GETDATE() AS DATE)), 'Entregado');
INSERT INTO PEDIDO (IdCliente, IdDestino, FechaPedido, FechaEntregaSolicitada, EstadoPedido) VALUES (2, 5,  DATEADD(DAY, -10, GETDATE()), DATEADD(DAY, 2, CAST(GETDATE() AS DATE)), 'Entregado');
INSERT INTO PEDIDO (IdCliente, IdDestino, FechaPedido, FechaEntregaSolicitada, EstadoPedido) VALUES (3, 9,  DATEADD(DAY, -9,  GETDATE()), DATEADD(DAY, 2, CAST(GETDATE() AS DATE)), 'Entregado');
INSERT INTO PEDIDO (IdCliente, IdDestino, FechaPedido, FechaEntregaSolicitada, EstadoPedido) VALUES (4, 10, DATEADD(DAY, -11, GETDATE()), DATEADD(DAY, 2, CAST(GETDATE() AS DATE)), 'Rechazado');
INSERT INTO PEDIDO (IdCliente, IdDestino, FechaPedido, FechaEntregaSolicitada, EstadoPedido) VALUES (5, 13, DATEADD(DAY, -8,  GETDATE()), DATEADD(DAY, 2, CAST(GETDATE() AS DATE)), 'Rechazado');
INSERT INTO PEDIDO (IdCliente, IdDestino, FechaPedido, FechaEntregaSolicitada, EstadoPedido) VALUES (1, 14, DATEADD(DAY, -7,  GETDATE()), DATEADD(DAY, 3, CAST(GETDATE() AS DATE)), 'Rechazado');
INSERT INTO PEDIDO (IdCliente, IdDestino, FechaPedido, FechaEntregaSolicitada, EstadoPedido) VALUES (2, 3,  DATEADD(DAY, -5,  GETDATE()), DATEADD(DAY, 3, CAST(GETDATE() AS DATE)), 'Rechazado');
INSERT INTO PEDIDO (IdCliente, IdDestino, FechaPedido, FechaEntregaSolicitada, EstadoPedido) VALUES (3, 6,  DATEADD(DAY, -4,  GETDATE()), DATEADD(DAY, 4, CAST(GETDATE() AS DATE)), 'Despachado');
INSERT INTO PEDIDO (IdCliente, IdDestino, FechaPedido, FechaEntregaSolicitada, EstadoPedido) VALUES (4, 7,  DATEADD(DAY, -3,  GETDATE()), DATEADD(DAY, 4, CAST(GETDATE() AS DATE)), 'Despachado');
INSERT INTO PEDIDO (IdCliente, IdDestino, FechaPedido, FechaEntregaSolicitada, EstadoPedido) VALUES (5, 11, DATEADD(DAY, -3,  GETDATE()), DATEADD(DAY, 5, CAST(GETDATE() AS DATE)), 'Despachado');
INSERT INTO PEDIDO (IdCliente, IdDestino, FechaPedido, FechaEntregaSolicitada, EstadoPedido) VALUES (1, 12, DATEADD(DAY, -2,  GETDATE()), DATEADD(DAY, 5, CAST(GETDATE() AS DATE)), 'Despachado');
INSERT INTO PEDIDO (IdCliente, IdDestino, FechaPedido, FechaEntregaSolicitada, EstadoPedido) VALUES (2, 1,  DATEADD(DAY, -2,  GETDATE()), DATEADD(DAY, 6, CAST(GETDATE() AS DATE)), 'Preparado');
INSERT INTO PEDIDO (IdCliente, IdDestino, FechaPedido, FechaEntregaSolicitada, EstadoPedido) VALUES (3, 2,  DATEADD(DAY, -1,  GETDATE()), DATEADD(DAY, 6, CAST(GETDATE() AS DATE)), 'En preparación');
INSERT INTO PEDIDO (IdCliente, IdDestino, FechaPedido, FechaEntregaSolicitada, EstadoPedido) VALUES (4, 8,  GETDATE(),                    DATEADD(DAY, 7, CAST(GETDATE() AS DATE)), 'Registrado');
INSERT INTO PEDIDO (IdCliente, IdDestino, FechaPedido, FechaEntregaSolicitada, EstadoPedido) VALUES (5, 9,  DATEADD(DAY, -5,  GETDATE()), DATEADD(DAY, 7, CAST(GETDATE() AS DATE)), 'Cancelado');
GO

-- ===================== 7. DETALLEPEDIDO (56 ítems) =====================
INSERT INTO DETALLEPEDIDO (IdPedido, IdProducto, CantidadSolicitada) VALUES
(1,  1,  50), (1,  2,  80),
(2,  3, 120), (2,  4, 100),
(3,  5,  30),
(4,  6,  90), (4,  7,  40),
(5,  8,  60), (5,  9,  70),
(6,  10, 25),
(7,  11, 80), (7,  12, 50),
(8,  1,  40), (8,  3,  90),
(9,  2,  75),
(10, 4, 110), (10, 6,  60),
(11, 5,  20), (11, 7,  35),
(12, 8,  95),
(13, 9, 100), (13, 11, 85),
(14, 10, 30),
(15, 12, 65),
(16, 1,  45), (16, 4, 130),
(17, 2,  90),
(18, 3, 150), (18, 6,  70),
(19, 7,  50),
(20, 8, 120), (20, 11, 60),
(21, 9,  80),
(22, 10, 40),
(23, 12, 55),
(24, 1,  35), (24, 5,  25),
(25, 2,  70), (25, 3,  95),
(26, 4, 140),
(27, 6, 110), (27, 7,  30),
(28, 8,  75),
(29, 1,  60),
(30, 2,  50),
(31, 9,  85),
(32, 11, 90),
(33, 3, 100),
(34, 4, 120),
(35, 5,  30),
(36, 7,  45),
(37, 10, 20),
(38, 12, 60),
(39, 6,  70),
(40, 8,  50);
GO

-- ===================== 8. PREPARACION (52 preparaciones, 10 con error FEFO/vencido) =====================
INSERT INTO PREPARACION (IdLote, IdProducto, IdPedido, FechaPreparacion, CantidadPreparada, CumpleFEFO) VALUES
(1,  1,  1,  DATEADD(DAY, -9,  GETDATE()), 50,  1),
(3,  2,  1,  DATEADD(DAY, -9,  GETDATE()), 80,  1),
(4,  3,  2,  DATEADD(DAY, -11, GETDATE()), 120, 1),
(5,  4,  2,  DATEADD(DAY, -11, GETDATE()), 100, 1),
(6,  5,  3,  DATEADD(DAY, -7,  GETDATE()), 30,  1),
(7,  6,  4,  DATEADD(DAY, -13, GETDATE()), 90,  1),
(9,  7,  4,  DATEADD(DAY, -13, GETDATE()), 40,  1),
(10, 8,  5,  DATEADD(DAY, -14, GETDATE()), 60,  1),
(11, 9,  5,  DATEADD(DAY, -14, GETDATE()), 70,  1),
(12, 10, 6,  DATEADD(DAY, -8,  GETDATE()), 25,  1),
(13, 11, 7,  DATEADD(DAY, -15, GETDATE()), 80,  1),
(14, 12, 7,  DATEADD(DAY, -15, GETDATE()), 50,  1),
(2,  1,  8,  DATEADD(DAY, -17, GETDATE()), 40,  0),
(19, 3,  8,  DATEADD(DAY, -17, GETDATE()), 90,  0),
(3,  2,  9,  DATEADD(DAY, -10, GETDATE()), 75,  1),
(5,  4,  10, DATEADD(DAY, -12, GETDATE()), 110, 1),
(21, 6,  10, DATEADD(DAY, -12, GETDATE()), 60,  0),
(6,  5,  11, DATEADD(DAY, -16, GETDATE()), 20,  1),
(9,  7,  11, DATEADD(DAY, -16, GETDATE()), 35,  1),
(10, 8,  12, DATEADD(DAY, -14, GETDATE()), 95,  1),
(11, 9,  13, DATEADD(DAY, -6,  GETDATE()), 100, 1),
(24, 11, 13, DATEADD(DAY, -6,  GETDATE()), 85,  0),
(12, 10, 14, DATEADD(DAY, -9,  GETDATE()), 30,  1),
(14, 12, 15, DATEADD(DAY, -10, GETDATE()), 65,  1),
(1,  1,  16, DATEADD(DAY, -13, GETDATE()), 45,  1),
(20, 4,  16, DATEADD(DAY, -13, GETDATE()), 130, 0),
(3,  2,  17, DATEADD(DAY, -5,  GETDATE()), 90,  1),
(4,  3,  18, DATEADD(DAY, -8,  GETDATE()), 150, 1),
(7,  6,  18, DATEADD(DAY, -8,  GETDATE()), 70,  1),
(16, 7,  19, DATEADD(DAY, -11, GETDATE()), 50,  0),
(10, 8,  20, DATEADD(DAY, -12, GETDATE()), 120, 1),
(13, 11, 20, DATEADD(DAY, -12, GETDATE()), 60,  1),
(23, 9,  21, DATEADD(DAY, -14, GETDATE()), 80,  0),
(17, 10, 22, DATEADD(DAY, -15, GETDATE()), 40,  0),
(14, 12, 23, DATEADD(DAY, -13, GETDATE()), 55,  1),
(1,  1,  24, DATEADD(DAY, -7,  GETDATE()), 35,  1),
(6,  5,  24, DATEADD(DAY, -7,  GETDATE()), 25,  1),
(8,  2,  25, DATEADD(DAY, -10, GETDATE()), 70,  0),
(4,  3,  25, DATEADD(DAY, -10, GETDATE()), 95,  1),
(5,  4,  26, DATEADD(DAY, -6,  GETDATE()), 140, 1),
(7,  6,  27, DATEADD(DAY, -9,  GETDATE()), 110, 1),
(9,  7,  27, DATEADD(DAY, -9,  GETDATE()), 30,  1),
(10, 8,  28, DATEADD(DAY, -8,  GETDATE()), 75,  1),
(2,  1,  29, DATEADD(DAY, -10, GETDATE()), 60,  0),
(3,  2,  30, DATEADD(DAY, -7,  GETDATE()), 50,  1),
(11, 9,  31, DATEADD(DAY, -6,  GETDATE()), 85,  1),
(13, 11, 32, DATEADD(DAY, -4,  GETDATE()), 90,  1),
(4,  3,  33, DATEADD(DAY, -3,  GETDATE()), 100, 1),
(5,  4,  34, DATEADD(DAY, -2,  GETDATE()), 120, 1),
(6,  5,  35, DATEADD(DAY, -2,  GETDATE()), 30,  1),
(9,  7,  36, DATEADD(DAY, -1,  GETDATE()), 45,  1),
(12, 10, 37, DATEADD(DAY, -1,  GETDATE()), 20,  1);
GO

-- ===================== 9. DESPACHO (13 despachos, uno por INSERT) =====================
INSERT INTO DESPACHO (IdVehiculo, FechaSalida, EstadoDespacho) VALUES (1,  DATEADD(DAY, -9,  GETDATE()), 'Finalizado');
INSERT INTO DESPACHO (IdVehiculo, FechaSalida, EstadoDespacho) VALUES (2,  DATEADD(DAY, -11, GETDATE()), 'Finalizado');
INSERT INTO DESPACHO (IdVehiculo, FechaSalida, EstadoDespacho) VALUES (3,  DATEADD(DAY, -7,  GETDATE()), 'Finalizado');
INSERT INTO DESPACHO (IdVehiculo, FechaSalida, EstadoDespacho) VALUES (4,  DATEADD(DAY, -13, GETDATE()), 'Finalizado');
INSERT INTO DESPACHO (IdVehiculo, FechaSalida, EstadoDespacho) VALUES (5,  DATEADD(DAY, -14, GETDATE()), 'Finalizado');
INSERT INTO DESPACHO (IdVehiculo, FechaSalida, EstadoDespacho) VALUES (6,  DATEADD(DAY, -8,  GETDATE()), 'Finalizado');
INSERT INTO DESPACHO (IdVehiculo, FechaSalida, EstadoDespacho) VALUES (7,  DATEADD(DAY, -15, GETDATE()), 'Finalizado');
INSERT INTO DESPACHO (IdVehiculo, FechaSalida, EstadoDespacho) VALUES (8,  DATEADD(DAY, -16, GETDATE()), 'Finalizado');
INSERT INTO DESPACHO (IdVehiculo, FechaSalida, EstadoDespacho) VALUES (9,  DATEADD(DAY, -10, GETDATE()), 'Finalizado');
INSERT INTO DESPACHO (IdVehiculo, FechaSalida, EstadoDespacho) VALUES (10, DATEADD(DAY, -6,  GETDATE()), 'Finalizado');
INSERT INTO DESPACHO (IdVehiculo, FechaSalida, EstadoDespacho) VALUES (11, DATEADD(DAY, -3,  GETDATE()), 'En ruta');
INSERT INTO DESPACHO (IdVehiculo, FechaSalida, EstadoDespacho) VALUES (12, DATEADD(DAY, -2,  GETDATE()), 'En ruta');
INSERT INTO DESPACHO (IdVehiculo, FechaSalida, EstadoDespacho) VALUES (13, NULL,                         'Programado');
GO

-- ===================== 10. CAJA (37 cajas) =====================
INSERT INTO CAJA (CodigoBarra, IdDestino, IdDespacho, FechaArmado, EstadoCaja) VALUES
('AND-CB-0001', 1,  1,    DATEADD(DAY, -9,  GETDATE()), 'Entregada'),
('AND-CB-0002', 2,  2,    DATEADD(DAY, -11, GETDATE()), 'Entregada'),
('AND-CB-0003', 3,  3,    DATEADD(DAY, -7,  GETDATE()), 'Entregada'),
('AND-CB-0004', 4,  4,    DATEADD(DAY, -13, GETDATE()), 'Entregada'),
('AND-CB-0005', 5,  5,    DATEADD(DAY, -14, GETDATE()), 'Entregada'),
('AND-CB-0006', 6,  6,    DATEADD(DAY, -8,  GETDATE()), 'Entregada'),
('AND-CB-0007', 7,  7,    DATEADD(DAY, -15, GETDATE()), 'Entregada'),
('AND-CB-0008', 8,  8,    DATEADD(DAY, -16, GETDATE()), 'Entregada'),
('AND-CB-0009', 9,  4,    DATEADD(DAY, -10, GETDATE()), 'Entregada'),
('AND-CB-0010', 10, 5,    DATEADD(DAY, -12, GETDATE()), 'Entregada'),
('AND-CB-0011', 11, 8,    DATEADD(DAY, -16, GETDATE()), 'Entregada'),
('AND-CB-0012', 12, 7,    DATEADD(DAY, -14, GETDATE()), 'Entregada'),
('AND-CB-0013', 13, 6,    DATEADD(DAY, -6,  GETDATE()), 'Entregada'),
('AND-CB-0014', 14, 9,    DATEADD(DAY, -9,  GETDATE()), 'Entregada'),
('AND-CB-0015', 15, 9,    DATEADD(DAY, -10, GETDATE()), 'Entregada'),
('AND-CB-0016', 16, 7,    DATEADD(DAY, -13, GETDATE()), 'Entregada'),
('AND-CB-0017', 1,  10,   DATEADD(DAY, -5,  GETDATE()), 'Entregada'),
('AND-CB-0018', 4,  9,    DATEADD(DAY, -8,  GETDATE()), 'Entregada'),
('AND-CB-0019', 5,  5,    DATEADD(DAY, -11, GETDATE()), 'Entregada'),
('AND-CB-0020', 7,  7,    DATEADD(DAY, -12, GETDATE()), 'Entregada'),
('AND-CB-0021', 8,  8,    DATEADD(DAY, -14, GETDATE()), 'Entregada'),
('AND-CB-0022', 11, 8,    DATEADD(DAY, -15, GETDATE()), 'Entregada'),
('AND-CB-0023', 12, 7,    DATEADD(DAY, -13, GETDATE()), 'Entregada'),
('AND-CB-0024', 15, 9,    DATEADD(DAY, -7,  GETDATE()), 'Entregada'),
('AND-CB-0025', 16, 7,    DATEADD(DAY, -10, GETDATE()), 'Entregada'),
('AND-CB-0026', 4,  10,   DATEADD(DAY, -6,  GETDATE()), 'Entregada'),
('AND-CB-0027', 5,  5,    DATEADD(DAY, -9,  GETDATE()), 'Entregada'),
('AND-CB-0028', 9,  9,    DATEADD(DAY, -8,  GETDATE()), 'Entregada'),
('AND-CB-0029', 10, 5,    DATEADD(DAY, -10, GETDATE()), 'Rechazada'),
('AND-CB-0030', 13, 6,    DATEADD(DAY, -7,  GETDATE()), 'Rechazada'),
('AND-CB-0031', 14, 9,    DATEADD(DAY, -6,  GETDATE()), 'Rechazada'),
('AND-CB-0032', 3,  10,   DATEADD(DAY, -4,  GETDATE()), 'Rechazada'),
('AND-CB-0033', 6,  11,   DATEADD(DAY, -3,  GETDATE()), 'Despachada'),
('AND-CB-0034', 7,  11,   DATEADD(DAY, -2,  GETDATE()), 'Despachada'),
('AND-CB-0035', 11, 12,   DATEADD(DAY, -2,  GETDATE()), 'Despachada'),
('AND-CB-0036', 12, 12,   DATEADD(DAY, -1,  GETDATE()), 'Despachada'),
('AND-CB-0037', 1,  NULL, DATEADD(DAY, -1,  GETDATE()), 'Armada');
GO

-- ===================== 11. DETALLECAJA (52 ítems empacados) =====================
INSERT INTO DETALLECAJA (IdCaja, IdPreparacion, CantidadEmpacada) VALUES
(1,  1,  50),  (1,  2,  80),
(2,  3,  120), (2,  4,  100),
(3,  5,  30),
(4,  6,  90),  (4,  7,  40),
(5,  8,  60),  (5,  9,  70),
(6,  10, 25),
(7,  11, 80),  (7,  12, 50),
(8,  13, 40),  (8,  14, 90),
(9,  15, 75),
(10, 16, 110), (10, 17, 60),
(11, 18, 20),  (11, 19, 35),
(12, 20, 95),
(13, 21, 100), (13, 22, 85),
(14, 23, 30),
(15, 24, 65),
(16, 25, 45),  (16, 26, 130),
(17, 27, 90),
(18, 28, 150), (18, 29, 70),
(19, 30, 50),
(20, 31, 120), (20, 32, 60),
(21, 33, 80),
(22, 34, 40),
(23, 35, 55),
(24, 36, 35),  (24, 37, 25),
(25, 38, 70),  (25, 39, 95),
(26, 40, 140),
(27, 41, 110), (27, 42, 30),
(28, 43, 75),
(29, 44, 60),
(30, 45, 50),
(31, 46, 85),
(32, 47, 90),
(33, 48, 100),
(34, 49, 120),
(35, 50, 30),
(36, 51, 45),
(37, 52, 20);
GO

-- ===================== 12. ENTREGA (36 entregas: en fecha, demoradas, rechazadas y pendientes) =====================
INSERT INTO ENTREGA (IdPedido, IdDespacho, FechaEntregaReal, LlegoFrio, EstadoEntrega) VALUES
-- Entregadas EN FECHA (20 pedidos) con tiempos de viaje variados por zona
(1,  1,  DATEADD(HOUR, 20,  DATEADD(DAY, -10, GETDATE())), 1,    'Entregada'), -- CABA 20hs
(2,  2,  DATEADD(HOUR, 24,  DATEADD(DAY, -12, GETDATE())), NULL, 'Entregada'), -- CABA 24hs
(3,  3,  DATEADD(HOUR, 18,  DATEADD(DAY, -8,  GETDATE())), 1,    'Entregada'), -- CABA 18hs
(4,  4,  DATEADD(HOUR, 42,  DATEADD(DAY, -14, GETDATE())), 1,    'Entregada'), -- Rosario 42hs
(5,  5,  DATEADD(HOUR, 56,  DATEADD(DAY, -15, GETDATE())), NULL, 'Entregada'), -- Córdoba 56hs
(6,  6,  DATEADD(HOUR, 36,  DATEADD(DAY, -9,  GETDATE())), 1,    'Entregada'), -- Pinamar 36hs
(7,  7,  DATEADD(HOUR, 78,  DATEADD(DAY, -16, GETDATE())), 1,    'Entregada'), -- Mendoza 78hs
(8,  8,  DATEADD(HOUR, 96,  DATEADD(DAY, -18, GETDATE())), 1,    'Entregada'), -- Tucumán 96hs
(9,  4,  DATEADD(HOUR, 38,  DATEADD(DAY, -11, GETDATE())), 1,    'Entregada'), -- Rosario 38hs
(10, 5,  DATEADD(HOUR, 60,  DATEADD(DAY, -13, GETDATE())), NULL, 'Entregada'), -- Córdoba 60hs
(11, 8,  DATEADD(HOUR, 104, DATEADD(DAY, -17, GETDATE())), 1,    'Entregada'), -- Salta 104hs
(12, 7,  DATEADD(HOUR, 88,  DATEADD(DAY, -15, GETDATE())), NULL, 'Entregada'), -- Neuquén 88hs
(13, 6,  DATEADD(HOUR, 30,  DATEADD(DAY, -7,  GETDATE())), NULL, 'Entregada'), -- Mar del Plata 30hs
(14, 9,  DATEADD(HOUR, 48,  DATEADD(DAY, -10, GETDATE())), 1,    'Entregada'), -- Santa Fe 48hs
(15, 9,  DATEADD(HOUR, 44,  DATEADD(DAY, -11, GETDATE())), 1,    'Entregada'), -- Paraná 44hs
(16, 7,  DATEADD(HOUR, 72,  DATEADD(DAY, -14, GETDATE())), 1,    'Entregada'), -- Godoy Cruz 72hs
(17, 10, DATEADD(HOUR, 22,  DATEADD(DAY, -6,  GETDATE())), 1,    'Entregada'), -- CABA 22hs
(18, 9,  DATEADD(HOUR, 40,  DATEADD(DAY, -9,  GETDATE())), NULL, 'Entregada'), -- Rosario 40hs
(19, 5,  DATEADD(HOUR, 64,  DATEADD(DAY, -12, GETDATE())), 1,    'Entregada'), -- Córdoba 64hs
(20, 7,  DATEADD(HOUR, 84,  DATEADD(DAY, -13, GETDATE())), NULL, 'Entregada'), -- Mendoza 84hs

-- Entregadas FUERA DE FECHA / DEMORADAS (8 pedidos: FechaEntregaReal > FechaEntregaSolicitada)
(21, 8,  DATEADD(DAY, 3, GETDATE()), 1,    'Entregada'), -- Tucumán demorado
(22, 8,  DATEADD(DAY, 4, GETDATE()), 1,    'Entregada'), -- Salta demorado
(23, 7,  DATEADD(DAY, 3, GETDATE()), 1,    'Entregada'), -- Neuquén demorado
(24, 9,  DATEADD(DAY, 2, GETDATE()), 1,    'Entregada'), -- Paraná demorado
(25, 7,  DATEADD(DAY, 3, GETDATE()), 1,    'Entregada'), -- Godoy Cruz demorado
(26, 10, DATEADD(DAY, 3, GETDATE()), NULL, 'Entregada'), -- Rosario demorado
(27, 5,  DATEADD(DAY, 4, GETDATE()), 1,    'Entregada'), -- Córdoba demorado
(28, 9,  DATEADD(DAY, 3, GETDATE()), NULL, 'Entregada'), -- Rosario demorado

-- Rechazadas (4) y Pendientes (4)
(29, 5,  DATEADD(HOUR, 68, DATEADD(DAY, -11, GETDATE())), 0,    'Rechazada'),
(30, 6,  DATEADD(HOUR, 34, DATEADD(DAY, -8,  GETDATE())), 0,    'Rechazada'),
(31, 9,  DATEADD(HOUR, 50, DATEADD(DAY, -7,  GETDATE())), NULL, 'Rechazada'),
(32, 10, DATEADD(HOUR, 26, DATEADD(DAY, -5,  GETDATE())), NULL, 'Rechazada'),
(33, 11, NULL, NULL, 'Pendiente'),
(34, 11, NULL, NULL, 'Pendiente'),
(35, 12, NULL, NULL, 'Pendiente'),
(36, 12, NULL, NULL, 'Pendiente');
GO

-- ===================== 13. CONSULTA DE LOS 3 KPIs =====================
SELECT
    COUNT(*) AS TotalEntregasRealizadas,
    SUM(CASE WHEN CAST(e.FechaEntregaReal AS DATE) <= p.FechaEntregaSolicitada THEN 1 ELSE 0 END) AS EntregasEnFecha,
    CAST(
        SUM(CASE WHEN CAST(e.FechaEntregaReal AS DATE) <= p.FechaEntregaSolicitada THEN 1 ELSE 0 END) * 100.0
        / NULLIF(COUNT(*), 0)
    AS DECIMAL(5,2)) AS PorcentajeCumplimiento
FROM ENTREGA e
INNER JOIN PEDIDO p ON p.IdPedido = e.IdPedido
WHERE e.EstadoEntrega = 'Entregada';

SELECT
    d.PROVINCIA,
    d.CIUDAD,
    COUNT(*) AS CantidadEntregas,
    CAST(AVG(DATEDIFF(HOUR, p.FechaPedido, e.FechaEntregaReal) * 1.0) AS DECIMAL(10,2)) AS PromedioHoras,
    CAST(AVG(DATEDIFF(HOUR, p.FechaPedido, e.FechaEntregaReal) / 24.0) AS DECIMAL(10,2)) AS PromedioDias
FROM ENTREGA e
INNER JOIN PEDIDO p  ON p.IdPedido  = e.IdPedido
INNER JOIN DESTINO d ON d.IDDESTINO = p.IdDestino
WHERE e.EstadoEntrega = 'Entregada'
  AND e.FechaEntregaReal IS NOT NULL
GROUP BY d.PROVINCIA, d.CIUDAD
ORDER BY PromedioHoras DESC;

SELECT
    COUNT(*) AS TotalPreparaciones,
    SUM(CASE WHEN pr.CumpleFEFO = 0 OR l.FECHAVENCIMIENTO < pr.FechaPreparacion THEN 1 ELSE 0 END) AS PreparacionesConError,
    CAST(
        SUM(CASE WHEN pr.CumpleFEFO = 0 OR l.FECHAVENCIMIENTO < pr.FechaPreparacion THEN 1 ELSE 0 END) * 100.0
        / NULLIF(COUNT(*), 0)
    AS DECIMAL(5,2)) AS PorcentajeErroresValidacion
FROM PREPARACION pr
INNER JOIN LOTE l ON l.IDLOTE = pr.IdLote;
GO
