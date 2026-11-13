USE Andreani;
GO
-- =====================================================================================================
-- Carga de datos de prueba (fechas fijas: no dependen de GETDATE()).
-- Se puede correr las veces que haga falta: borra todo, reinicia los IDENTITY y vuelve a cargar.
-- Necesita: las tablas ya creadas. Los triggers y procedimientos pueden existir o no.
--
-- Qué representa (corte de datos: 12/11/2026 08:00):
--   40 pedidos de 5 clientes a 16 destinos de 8 provincias, con un circuito coherente en el tiempo
--   (pedido -> preparación -> caja -> despacho -> entrega):
--     * 28 entregas realizadas (20 en fecha y 8 fuera de fecha, una de ellas con la cadena de frío cortada)
--       y 4 rechazadas (2 por cadena de frío cortada).
--     * 4 pedidos en ruta, 1 preparado con despacho programado, 1 en preparación, 1 registrado y 1 cancelado.
--     * 10 preparaciones con error de validación (FEFO o lote vencido): quedan sin caja y se corrigen
--       con una nueva preparación del lote correcto, que es la que se empaca.
--     * Algunas cajas juntan pedidos de distintos clientes con el mismo destino (consolidación).
--   Se respetan las reglas RDI07 (un vehículo queda no disponible solo mientras tiene un despacho abierto),
--   RDI11 (los lotes quedan con el stock descontado de lo preparado y aprobado), RDI12 (solo preparaciones
--   aprobadas en cajas, con el mismo destino), RDI13 (frío solo en vehículos con frío) y RDI15 (la caja y
--   la entrega de un pedido van en el mismo despacho).
--
-- Por qué se deshabilitan los triggers durante la carga:
--   trg_Validar_Pedidos rechaza pedidos con fecha de entrega anterior a hoy: sirve para cargas en vivo,
--   no para cargar historial. trg_Despacho_Actualizar_Vehiculo marcaría como no disponibles a todos los
--   vehículos de despachos ya finalizados. Se vuelven a habilitar al terminar (también si hay un error).
-- =====================================================================================================
SET NOCOUNT ON;

-- 0) Limpieza (en orden inverso a las FK) y reinicio de IDENTITY
DELETE FROM Entrega;
DELETE FROM DetalleCaja;
DELETE FROM Caja;
DELETE FROM Despacho;
DELETE FROM Preparacion;
DELETE FROM DetallePedido;
DELETE FROM Pedido;
DELETE FROM Vehiculo;
DELETE FROM Lote;
DELETE FROM Producto;
DELETE FROM Destino;
DELETE FROM Cliente;
IF EXISTS (SELECT 1 FROM sys.identity_columns WHERE object_id = OBJECT_ID('dbo.Entrega') AND last_value IS NOT NULL)
    DBCC CHECKIDENT ('dbo.Entrega', RESEED, 0);
IF EXISTS (SELECT 1 FROM sys.identity_columns WHERE object_id = OBJECT_ID('dbo.DetalleCaja') AND last_value IS NOT NULL)
    DBCC CHECKIDENT ('dbo.DetalleCaja', RESEED, 0);
IF EXISTS (SELECT 1 FROM sys.identity_columns WHERE object_id = OBJECT_ID('dbo.Caja') AND last_value IS NOT NULL)
    DBCC CHECKIDENT ('dbo.Caja', RESEED, 0);
IF EXISTS (SELECT 1 FROM sys.identity_columns WHERE object_id = OBJECT_ID('dbo.Despacho') AND last_value IS NOT NULL)
    DBCC CHECKIDENT ('dbo.Despacho', RESEED, 0);
IF EXISTS (SELECT 1 FROM sys.identity_columns WHERE object_id = OBJECT_ID('dbo.Preparacion') AND last_value IS NOT NULL)
    DBCC CHECKIDENT ('dbo.Preparacion', RESEED, 0);
IF EXISTS (SELECT 1 FROM sys.identity_columns WHERE object_id = OBJECT_ID('dbo.Pedido') AND last_value IS NOT NULL)
    DBCC CHECKIDENT ('dbo.Pedido', RESEED, 0);
IF EXISTS (SELECT 1 FROM sys.identity_columns WHERE object_id = OBJECT_ID('dbo.Vehiculo') AND last_value IS NOT NULL)
    DBCC CHECKIDENT ('dbo.Vehiculo', RESEED, 0);
IF EXISTS (SELECT 1 FROM sys.identity_columns WHERE object_id = OBJECT_ID('dbo.Lote') AND last_value IS NOT NULL)
    DBCC CHECKIDENT ('dbo.Lote', RESEED, 0);
IF EXISTS (SELECT 1 FROM sys.identity_columns WHERE object_id = OBJECT_ID('dbo.Producto') AND last_value IS NOT NULL)
    DBCC CHECKIDENT ('dbo.Producto', RESEED, 0);
IF EXISTS (SELECT 1 FROM sys.identity_columns WHERE object_id = OBJECT_ID('dbo.Destino') AND last_value IS NOT NULL)
    DBCC CHECKIDENT ('dbo.Destino', RESEED, 0);
IF EXISTS (SELECT 1 FROM sys.identity_columns WHERE object_id = OBJECT_ID('dbo.Cliente') AND last_value IS NOT NULL)
    DBCC CHECKIDENT ('dbo.Cliente', RESEED, 0);
GO

IF OBJECT_ID('dbo.trg_Validar_Pedidos', 'TR') IS NOT NULL
    DISABLE TRIGGER trg_Validar_Pedidos ON Pedido;
IF OBJECT_ID('dbo.trg_Despacho_Actualizar_Vehiculo', 'TR') IS NOT NULL
    DISABLE TRIGGER trg_Despacho_Actualizar_Vehiculo ON Despacho;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    -- ===================== 1. Cliente (5) =====================
    INSERT INTO Cliente (NombreCliente) VALUES
    ('Laboratorios Bagó S.A.'),
    ('Roemmers S.A.I.C.F.'),
    ('Elea Phoenix S.A.'),
    ('Pfizer Argentina S.R.L.'),
    ('Biosidus S.A.');

    -- ===================== 2. Destino (16 en 8 provincias) =====================
    INSERT INTO Destino (NombreDestino, TipoDestino, Direccion, Ciudad, Provincia) VALUES
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

    -- ===================== 3. Producto (12, 6 con cadena de frío) =====================
    INSERT INTO Producto (NombreProducto, CategoriaProducto, RequiereRefrigeracion) VALUES
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

    -- ===================== 4. Lote (24: disponibles, bloqueados y vencidos) =====================
    -- StockLote es el stock inicial: al final de la sección 8 se descuenta lo preparado y aprobado.
    INSERT INTO Lote (IdProducto, FechaVencimiento, Estado, StockLote) VALUES
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

    -- ===================== 5. Vehiculo (15) =====================
    -- Disponible = 0 solo para los que tienen un despacho programado o en ruta.
    INSERT INTO Vehiculo (Patente, TipoVehiculo, TieneRefrigeracion, Disponible) VALUES
    ('AF123CD', 'Furgón Refrigerado', 1, 0),  -- con despacho abierto
    ('AE456FG', 'Camión Térmico', 1, 1),  -- Disponible
    ('AD789HI', 'Utilitario Liviano', 0, 1),  -- Disponible
    ('AC321JK', 'Furgón Refrigerado', 1, 1),  -- Disponible
    ('AG654LM', 'Furgón Refrigerado', 1, 1),  -- Disponible
    ('AB987NP', 'Utilitario Liviano', 0, 1),  -- Disponible
    ('AA147QR', 'Camión Térmico', 1, 1),  -- Disponible
    ('JKL987', 'Camión Mediano', 0, 0),  -- con despacho abierto
    ('MNO654', 'Furgón Refrigerado', 1, 0),  -- con despacho abierto
    ('PQR321', 'Utilitario Liviano', 0, 1),  -- Disponible
    ('AH258ST', 'Camión Térmico', 1, 1),  -- Disponible
    ('AI369UV', 'Furgón Refrigerado', 1, 1),  -- Disponible
    ('AJ741WX', 'Camión Mediano', 0, 0),  -- con despacho abierto
    ('AK852YZ', 'Furgón Refrigerado', 1, 0),  -- con despacho abierto
    ('STU111', 'Utilitario Liviano', 0, 1);  -- Disponible

    -- ===================== 6. Pedido (40) =====================
    INSERT INTO Pedido (IdCliente, IdDestino, FechaPedido, FechaEntregaSolicitada, EstadoPedido) VALUES
    (1, 1, '2026-10-15T09:07:00', '2026-10-21', 'Entregado'),  -- pedido 1
    (2, 2, '2026-10-17T10:14:00', '2026-10-23', 'Entregado'),  -- pedido 2
    (3, 3, '2026-10-15T11:21:00', '2026-10-20', 'Entregado'),  -- pedido 3
    (4, 4, '2026-10-19T12:28:00', '2026-10-24', 'Entregado'),  -- pedido 4
    (5, 5, '2026-10-18T13:35:00', '2026-10-26', 'Entregado'),  -- pedido 5
    (1, 6, '2026-10-16T08:42:00', '2026-10-20', 'Entregado'),  -- pedido 6
    (2, 7, '2026-10-19T09:49:00', '2026-10-27', 'Entregado'),  -- pedido 7
    (3, 8, '2026-10-16T10:56:00', '2026-10-25', 'Entregado'),  -- pedido 8
    (4, 9, '2026-10-18T11:03:00', '2026-10-23', 'Entregado'),  -- pedido 9
    (5, 10, '2026-10-19T12:10:00', '2026-10-25', 'Entregado'),  -- pedido 10
    (1, 11, '2026-10-15T13:17:00', '2026-10-25', 'Entregado'),  -- pedido 11
    (2, 12, '2026-10-20T08:24:00', '2026-10-27', 'Entregado'),  -- pedido 12
    (3, 13, '2026-10-16T09:31:00', '2026-10-22', 'Entregado'),  -- pedido 13
    (4, 14, '2026-10-24T10:38:00', '2026-10-31', 'Entregado'),  -- pedido 14
    (5, 15, '2026-10-23T11:45:00', '2026-10-29', 'Entregado'),  -- pedido 15
    (1, 16, '2026-10-20T12:52:00', '2026-10-27', 'Entregado'),  -- pedido 16
    (2, 1, '2026-10-23T13:59:00', '2026-10-30', 'Entregado'),  -- pedido 17
    (3, 4, '2026-10-19T08:06:00', '2026-10-23', 'Entregado'),  -- pedido 18
    (4, 5, '2026-10-18T09:13:00', '2026-10-25', 'Entregado'),  -- pedido 19
    (5, 7, '2026-10-20T10:20:00', '2026-10-28', 'Entregado'),  -- pedido 20
    (1, 8, '2026-10-15T11:27:00', '2026-10-20', 'Entregado'),  -- pedido 21  (fuera de fecha)
    (2, 11, '2026-10-16T12:34:00', '2026-10-21', 'Entregado'),  -- pedido 22  (fuera de fecha)
    (3, 12, '2026-10-19T13:41:00', '2026-10-24', 'Entregado'),  -- pedido 23  (fuera de fecha)
    (4, 15, '2026-10-24T08:48:00', '2026-10-27', 'Entregado'),  -- pedido 24  (fuera de fecha)
    (5, 16, '2026-10-19T09:55:00', '2026-10-23', 'Entregado'),  -- pedido 25  (fuera de fecha)
    (1, 4, '2026-10-19T10:02:00', '2026-10-21', 'Entregado'),  -- pedido 26  (fuera de fecha)
    (2, 5, '2026-10-18T11:09:00', '2026-10-21', 'Entregado'),  -- pedido 27  (fuera de fecha)
    (3, 9, '2026-10-19T12:16:00', '2026-10-21', 'Entregado'),  -- pedido 28  (fuera de fecha)
    (4, 10, '2026-10-18T13:23:00', '2026-10-26', 'Rechazado'),  -- pedido 29
    (5, 13, '2026-10-24T08:30:00', '2026-10-28', 'Rechazado'),  -- pedido 30
    (1, 14, '2026-10-23T09:37:00', '2026-10-30', 'Rechazado'),  -- pedido 31
    (2, 3, '2026-10-17T10:44:00', '2026-10-23', 'Rechazado'),  -- pedido 32
    (3, 6, '2026-11-06T11:51:00', '2026-11-14', 'Despachado'),  -- pedido 33
    (4, 7, '2026-11-06T12:58:00', '2026-11-15', 'Despachado'),  -- pedido 34
    (5, 11, '2026-11-05T13:05:00', '2026-11-15', 'Despachado'),  -- pedido 35
    (1, 12, '2026-11-06T08:12:00', '2026-11-16', 'Despachado'),  -- pedido 36
    (2, 1, '2026-11-09T10:15:00', '2026-11-16', 'Preparado'),  -- pedido 37
    (3, 2, '2026-11-09T14:40:00', '2026-11-17', 'En preparación'),  -- pedido 38
    (4, 8, '2026-11-12T08:30:00', '2026-11-18', 'Registrado'),  -- pedido 39
    (5, 9, '2026-11-07T15:05:00', '2026-11-16', 'Cancelado');  -- pedido 40

    -- ===================== 7. DetallePedido (56 ítems) =====================
    INSERT INTO DetallePedido (IdPedido, IdProducto, CantidadSolicitada) VALUES
    (1, 1, 50), (1, 2, 80),
    (2, 3, 120), (2, 4, 100),
    (3, 5, 30),
    (4, 6, 90), (4, 7, 40),
    (5, 8, 60), (5, 9, 70),
    (6, 10, 25),
    (7, 11, 80), (7, 12, 50),
    (8, 1, 40), (8, 3, 90),
    (9, 2, 75),
    (10, 4, 110), (10, 6, 60),
    (11, 5, 20), (11, 7, 35),
    (12, 8, 95),
    (13, 9, 100), (13, 11, 85),
    (14, 10, 30),
    (15, 12, 65),
    (16, 1, 45), (16, 4, 130),
    (17, 2, 90),
    (18, 3, 150), (18, 6, 70),
    (19, 7, 50),
    (20, 8, 120), (20, 11, 60),
    (21, 9, 80),
    (22, 10, 40),
    (23, 12, 55),
    (24, 1, 35), (24, 5, 25),
    (25, 2, 70), (25, 3, 95),
    (26, 4, 140),
    (27, 6, 110), (27, 7, 30),
    (28, 8, 75),
    (29, 1, 60),
    (30, 2, 50),
    (31, 9, 85),
    (32, 11, 90),
    (33, 3, 100),
    (34, 4, 120),
    (35, 5, 30),
    (36, 7, 45),
    (37, 10, 20),
    (38, 4, 60), (38, 12, 40),
    (39, 6, 70),
    (40, 8, 50);

    -- ===================== 8. Preparacion (63) =====================
    -- CumpleFEFO = 0: la preparación tuvo un error de validación (lote que no es el que vence primero, o lote vencido).
    -- Esas filas NO se empacan: se corrigen con la fila siguiente, que usa el lote correcto.
    INSERT INTO Preparacion (IdLote, IdProducto, IdPedido, FechaPreparacion, CantidadPreparada, CumpleFEFO) VALUES
    (1, 1, 1, '2026-10-18', 50, 1),
    (3, 2, 1, '2026-10-18', 80, 1),
    (6, 5, 3, '2026-10-18', 30, 1),
    (12, 10, 6, '2026-10-18', 25, 1),
    (4, 3, 2, '2026-10-19', 120, 1),
    (5, 4, 2, '2026-10-19', 100, 1),
    (11, 9, 13, '2026-10-19', 100, 1),
    (24, 11, 13, '2026-10-19', 85, 0),  -- Error: lote vencido (pedido 13, no se empaca)
    (13, 11, 13, '2026-10-19', 85, 1),
    (13, 11, 32, '2026-10-19', 90, 1),
    (2, 1, 8, '2026-10-20', 40, 0),  -- Error FEFO: había un lote que vence antes (pedido 8, no se empaca)
    (1, 1, 8, '2026-10-20', 40, 1),
    (19, 3, 8, '2026-10-20', 90, 0),  -- Error FEFO: había un lote que vence antes (pedido 8, no se empaca)
    (4, 3, 8, '2026-10-20', 90, 1),
    (6, 5, 11, '2026-10-20', 20, 1),
    (9, 7, 11, '2026-10-20', 35, 1),
    (23, 9, 21, '2026-10-20', 80, 0),  -- Error: lote vencido (pedido 21, no se empaca)
    (11, 9, 21, '2026-10-20', 80, 1),
    (17, 10, 22, '2026-10-20', 40, 0),  -- Error: lote vencido (pedido 22, no se empaca)
    (12, 10, 22, '2026-10-20', 40, 1),
    (7, 6, 4, '2026-10-21', 90, 1),
    (9, 7, 4, '2026-10-21', 40, 1),
    (3, 2, 9, '2026-10-21', 75, 1),
    (4, 3, 18, '2026-10-21', 150, 1),
    (7, 6, 18, '2026-10-21', 70, 1),
    (5, 4, 26, '2026-10-21', 140, 1),
    (10, 8, 28, '2026-10-21', 75, 1),
    (10, 8, 5, '2026-10-22', 60, 1),
    (11, 9, 5, '2026-10-22', 70, 1),
    (5, 4, 10, '2026-10-22', 110, 1),
    (21, 6, 10, '2026-10-22', 60, 0),  -- Error FEFO: había un lote que vence antes (pedido 10, no se empaca)
    (7, 6, 10, '2026-10-22', 60, 1),
    (16, 7, 19, '2026-10-22', 50, 0),  -- Error FEFO: había un lote que vence antes (pedido 19, no se empaca)
    (9, 7, 19, '2026-10-22', 50, 1),
    (7, 6, 27, '2026-10-22', 110, 1),
    (9, 7, 27, '2026-10-22', 30, 1),
    (2, 1, 29, '2026-10-22', 60, 0),  -- Error FEFO: había un lote que vence antes (pedido 29, no se empaca)
    (1, 1, 29, '2026-10-22', 60, 1),
    (13, 11, 7, '2026-10-23', 80, 1),
    (14, 12, 7, '2026-10-23', 50, 1),
    (1, 1, 16, '2026-10-23', 45, 1),
    (20, 4, 16, '2026-10-23', 130, 0),  -- Error FEFO: había un lote que vence antes (pedido 16, no se empaca)
    (5, 4, 16, '2026-10-23', 130, 1),
    (10, 8, 20, '2026-10-23', 120, 1),
    (13, 11, 20, '2026-10-23', 60, 1),
    (8, 2, 25, '2026-10-23', 70, 0),  -- Error: lote vencido (pedido 25, no se empaca)
    (3, 2, 25, '2026-10-23', 70, 1),
    (4, 3, 25, '2026-10-23', 95, 1),
    (10, 8, 12, '2026-10-24', 95, 1),
    (14, 12, 23, '2026-10-24', 55, 1),
    (3, 2, 17, '2026-10-26', 90, 1),
    (3, 2, 30, '2026-10-26', 50, 1),
    (12, 10, 14, '2026-10-27', 30, 1),
    (14, 12, 15, '2026-10-27', 65, 1),
    (1, 1, 24, '2026-10-27', 35, 1),
    (6, 5, 24, '2026-10-27', 25, 1),
    (11, 9, 31, '2026-10-27', 85, 1),
    (4, 3, 33, '2026-11-09', 100, 1),
    (5, 4, 34, '2026-11-09', 120, 1),
    (6, 5, 35, '2026-11-10', 30, 1),
    (16, 7, 36, '2026-11-10', 45, 1),
    (5, 4, 38, '2026-11-10', 60, 1),
    (12, 10, 37, '2026-11-11', 20, 1);

    -- Se descuenta del stock de cada lote lo preparado y aprobado (RDI11). Las preparaciones con error no descuentan.
    UPDATE l
    SET l.StockLote = l.StockLote - a.Total
    FROM Lote AS l
    JOIN (
        SELECT IdLote, SUM(CantidadPreparada) AS Total
        FROM Preparacion
        WHERE CumpleFEFO = 1
        GROUP BY IdLote
    ) AS a ON a.IdLote = l.IdLote;

    -- ===================== 9. Despacho (14) =====================
    -- Un vehículo puede hacer varios despachos (nunca superpuestos) y cada despacho puede tener varias paradas.
    -- El despacho programado tiene como fecha de salida la fecha prevista.
    INSERT INTO Despacho (IdVehiculo, FechaSalida, EstadoDespacho) VALUES
    (1, '2026-10-19T07:00:00', 'Finalizado'),  -- despacho 1: pedidos 1, 3, 6
    (3, '2026-10-20T07:00:00', 'Finalizado'),  -- despacho 2: pedidos 2, 32, 13
    (12, '2026-10-21T07:00:00', 'Finalizado'),  -- despacho 3: pedidos 8, 21, 11, 22
    (5, '2026-10-22T07:00:00', 'Finalizado'),  -- despacho 4: pedidos 4, 18, 26, 9, 28
    (2, '2026-10-23T07:00:00', 'Finalizado'),  -- despacho 5: pedidos 5, 19, 27, 10, 29
    (7, '2026-10-24T07:00:00', 'Finalizado'),  -- despacho 6: pedidos 7, 20, 16, 25
    (11, '2026-10-25T07:00:00', 'Finalizado'),  -- despacho 7: pedidos 12, 23
    (4, '2026-10-27T07:00:00', 'Finalizado'),  -- despacho 8: pedidos 17, 30
    (9, '2026-10-28T07:00:00', 'Finalizado'),  -- despacho 9: pedidos 14, 31, 15, 24
    (13, '2026-11-10T07:00:00', 'En ruta'),  -- despacho 10: pedidos 33
    (8, '2026-11-10T08:00:00', 'En ruta'),  -- despacho 11: pedidos 34
    (9, '2026-11-11T06:00:00', 'En ruta'),  -- despacho 12: pedidos 35
    (14, '2026-11-11T06:30:00', 'En ruta'),  -- despacho 13: pedidos 36
    (1, '2026-11-13T08:00:00', 'Programado');  -- despacho 14: pedidos 37

    -- ===================== 10. Caja (33) =====================
    -- IdDespacho NULL = todavía sin despacho asignado. La caja del despacho programado sigue 'Armada'.
    INSERT INTO Caja (CodigoBarra, IdDestino, IdDespacho, FechaArmado, EstadoCaja) VALUES
    ('AND-CB-0001', 1, 1, '2026-10-18T14:01:00', 'Entregada'),  -- pedido 1
    ('AND-CB-0002', 3, 1, '2026-10-18T14:03:00', 'Entregada'),  -- pedido 3
    ('AND-CB-0003', 6, 1, '2026-10-18T14:06:00', 'Entregada'),  -- pedido 6
    ('AND-CB-0004', 2, 2, '2026-10-19T14:02:00', 'Entregada'),  -- pedido 2
    ('AND-CB-0005', 13, 2, '2026-10-19T14:13:00', 'Entregada'),  -- pedido 13
    ('AND-CB-0006', 3, 2, '2026-10-19T14:32:00', 'Rechazada'),  -- pedido 32
    ('AND-CB-0007', 8, 3, '2026-10-20T14:08:00', 'Entregada'),  -- pedidos 8 y 21  (caja compartida)
    ('AND-CB-0008', 11, 3, '2026-10-20T14:11:00', 'Entregada'),  -- pedidos 11 y 22  (caja compartida)
    ('AND-CB-0009', 4, 4, '2026-10-21T14:04:00', 'Entregada'),  -- pedidos 4 y 18  (caja compartida)
    ('AND-CB-0010', 9, 4, '2026-10-21T14:09:00', 'Entregada'),  -- pedidos 9 y 28  (caja compartida)
    ('AND-CB-0011', 4, 4, '2026-10-21T14:26:00', 'Entregada'),  -- pedido 26
    ('AND-CB-0012', 5, 5, '2026-10-22T14:05:00', 'Entregada'),  -- pedidos 5 y 19  (caja compartida)
    ('AND-CB-0013', 10, 5, '2026-10-22T14:10:00', 'Entregada'),  -- pedido 10
    ('AND-CB-0014', 5, 5, '2026-10-22T14:27:00', 'Entregada'),  -- pedido 27
    ('AND-CB-0015', 10, 5, '2026-10-22T14:29:00', 'Rechazada'),  -- pedido 29
    ('AND-CB-0016', 7, 6, '2026-10-23T14:07:00', 'Entregada'),  -- pedido 7
    ('AND-CB-0017', 16, 6, '2026-10-23T14:16:00', 'Entregada'),  -- pedido 16
    ('AND-CB-0018', 7, 6, '2026-10-23T14:20:00', 'Entregada'),  -- pedido 20
    ('AND-CB-0019', 16, 6, '2026-10-23T14:25:00', 'Entregada'),  -- pedido 25
    ('AND-CB-0020', 12, 7, '2026-10-24T14:12:00', 'Entregada'),  -- pedido 12
    ('AND-CB-0021', 12, 7, '2026-10-24T14:23:00', 'Entregada'),  -- pedido 23
    ('AND-CB-0022', 1, 8, '2026-10-26T14:17:00', 'Entregada'),  -- pedido 17
    ('AND-CB-0023', 13, 8, '2026-10-26T14:30:00', 'Rechazada'),  -- pedido 30
    ('AND-CB-0024', 14, 9, '2026-10-27T14:14:00', 'Entregada'),  -- pedido 14
    ('AND-CB-0025', 15, 9, '2026-10-27T14:15:00', 'Entregada'),  -- pedido 15
    ('AND-CB-0026', 15, 9, '2026-10-27T14:24:00', 'Entregada'),  -- pedido 24
    ('AND-CB-0027', 14, 9, '2026-10-27T14:31:00', 'Rechazada'),  -- pedido 31
    ('AND-CB-0028', 6, 10, '2026-11-09T14:33:00', 'Despachada'),  -- pedido 33
    ('AND-CB-0029', 7, 11, '2026-11-09T14:34:00', 'Despachada'),  -- pedido 34
    ('AND-CB-0030', 11, 12, '2026-11-10T14:35:00', 'Despachada'),  -- pedido 35
    ('AND-CB-0031', 12, 13, '2026-11-10T14:36:00', 'Despachada'),  -- pedido 36
    ('AND-CB-0032', 2, NULL, '2026-11-11T11:00:00', 'Armada'),  -- pedido 38
    ('AND-CB-0033', 1, 14, '2026-11-11T16:00:00', 'Armada');  -- pedido 37

    -- ===================== 11. DetalleCaja (53) =====================
    -- Solo preparaciones aprobadas (CumpleFEFO = 1) y con la cantidad empacada igual a la preparada.
    INSERT INTO DetalleCaja (IdCaja, IdPreparacion, CantidadEmpacada) VALUES
    (1, 1, 50),
    (1, 2, 80),
    (2, 3, 30),
    (3, 4, 25),
    (4, 5, 120),
    (4, 6, 100),
    (5, 7, 100),
    (5, 9, 85),
    (6, 10, 90),
    (7, 12, 40),
    (7, 14, 90),
    (7, 18, 80),
    (8, 15, 20),
    (8, 16, 35),
    (8, 20, 40),
    (9, 21, 90),
    (9, 22, 40),
    (9, 24, 150),
    (9, 25, 70),
    (10, 23, 75),
    (10, 27, 75),
    (11, 26, 140),
    (12, 28, 60),
    (12, 29, 70),
    (12, 34, 50),
    (13, 30, 110),
    (13, 32, 60),
    (14, 35, 110),
    (14, 36, 30),
    (15, 38, 60),
    (16, 39, 80),
    (16, 40, 50),
    (17, 41, 45),
    (17, 43, 130),
    (18, 44, 120),
    (18, 45, 60),
    (19, 47, 70),
    (19, 48, 95),
    (20, 49, 95),
    (21, 50, 55),
    (22, 51, 90),
    (23, 52, 50),
    (24, 53, 30),
    (25, 54, 65),
    (26, 55, 35),
    (26, 56, 25),
    (27, 57, 85),
    (28, 58, 100),
    (29, 59, 120),
    (30, 60, 30),
    (31, 61, 45),
    (32, 62, 60),
    (33, 63, 20);

    -- ===================== 12. Entrega (37) =====================
    -- LlegoFrio: 1 = mantuvo la cadena de frío, 0 = la perdió, NULL = el pedido no lleva productos refrigerados (o aún no se entregó).
    INSERT INTO Entrega (IdPedido, IdDespacho, FechaEntregaReal, LlegoFrio, EstadoEntrega) VALUES
    (1, 1, '2026-10-19T12:15:00', 1, 'Entregada'),  -- pedido 1: en fecha
    (2, 2, '2026-10-20T12:30:00', NULL, 'Entregada'),  -- pedido 2: en fecha
    (3, 1, '2026-10-19T13:45:00', 1, 'Entregada'),  -- pedido 3: en fecha
    (4, 4, '2026-10-22T14:00:00', 1, 'Entregada'),  -- pedido 4: en fecha
    (5, 5, '2026-10-23T19:15:00', NULL, 'Entregada'),  -- pedido 5: en fecha
    (6, 1, '2026-10-19T17:30:00', 1, 'Entregada'),  -- pedido 6: en fecha
    (7, 6, '2026-10-25T00:45:00', 1, 'Entregada'),  -- pedido 7: en fecha
    (8, 3, '2026-10-22T03:00:00', 1, 'Entregada'),  -- pedido 8: en fecha
    (9, 4, '2026-10-22T15:15:00', 1, 'Entregada'),  -- pedido 9: en fecha
    (10, 5, '2026-10-23T20:30:00', NULL, 'Entregada'),  -- pedido 10: en fecha
    (11, 3, '2026-10-22T08:45:00', 1, 'Entregada'),  -- pedido 11: en fecha
    (12, 7, '2026-10-26T02:00:00', NULL, 'Entregada'),  -- pedido 12: en fecha
    (13, 2, '2026-10-20T18:15:00', NULL, 'Entregada'),  -- pedido 13: en fecha
    (14, 9, '2026-10-28T16:30:00', 1, 'Entregada'),  -- pedido 14: en fecha
    (15, 9, '2026-10-28T19:45:00', 1, 'Entregada'),  -- pedido 15: en fecha
    (16, 6, '2026-10-25T02:00:00', 1, 'Entregada'),  -- pedido 16: en fecha
    (17, 8, '2026-10-27T12:15:00', 1, 'Entregada'),  -- pedido 17: en fecha
    (18, 4, '2026-10-22T14:00:00', NULL, 'Entregada'),  -- pedido 18: en fecha
    (19, 5, '2026-10-23T19:15:00', 1, 'Entregada'),  -- pedido 19: en fecha
    (20, 6, '2026-10-25T00:45:00', NULL, 'Entregada'),  -- pedido 20: en fecha
    (21, 3, '2026-10-22T03:00:00', NULL, 'Entregada'),  -- pedido 21: fuera de fecha
    (22, 3, '2026-10-22T08:45:00', 1, 'Entregada'),  -- pedido 22: fuera de fecha
    (23, 7, '2026-10-26T02:00:00', 1, 'Entregada'),  -- pedido 23: fuera de fecha
    (24, 9, '2026-10-28T19:45:00', 1, 'Entregada'),  -- pedido 24: fuera de fecha
    (25, 6, '2026-10-25T02:00:00', 0, 'Entregada'),  -- pedido 25: fuera de fecha - perdió la cadena de frío
    (26, 4, '2026-10-22T14:00:00', NULL, 'Entregada'),  -- pedido 26: fuera de fecha
    (27, 5, '2026-10-23T19:15:00', 1, 'Entregada'),  -- pedido 27: fuera de fecha
    (28, 4, '2026-10-22T15:15:00', NULL, 'Entregada'),  -- pedido 28: fuera de fecha
    (29, 5, '2026-10-23T20:30:00', 0, 'Rechazada'),  -- pedido 29: rechazada - perdió la cadena de frío
    (30, 8, '2026-10-27T17:15:00', 0, 'Rechazada'),  -- pedido 30: rechazada - perdió la cadena de frío
    (31, 9, '2026-10-28T16:30:00', NULL, 'Rechazada'),  -- pedido 31: rechazada
    (32, 2, '2026-10-20T13:45:00', NULL, 'Rechazada'),  -- pedido 32: rechazada
    (33, 10, NULL, NULL, 'Pendiente'),  -- pedido 33: pendiente
    (34, 11, NULL, NULL, 'Pendiente'),  -- pedido 34: pendiente
    (35, 12, NULL, NULL, 'Pendiente'),  -- pedido 35: pendiente
    (36, 13, NULL, NULL, 'Pendiente'),  -- pedido 36: pendiente
    (37, 14, NULL, NULL, 'Pendiente');  -- pedido 37: pendiente

    COMMIT TRANSACTION;

    IF OBJECT_ID('dbo.trg_Validar_Pedidos', 'TR') IS NOT NULL
        ENABLE TRIGGER trg_Validar_Pedidos ON Pedido;
    IF OBJECT_ID('dbo.trg_Despacho_Actualizar_Vehiculo', 'TR') IS NOT NULL
        ENABLE TRIGGER trg_Despacho_Actualizar_Vehiculo ON Despacho;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
    IF OBJECT_ID('dbo.trg_Validar_Pedidos', 'TR') IS NOT NULL
        ENABLE TRIGGER trg_Validar_Pedidos ON Pedido;
    IF OBJECT_ID('dbo.trg_Despacho_Actualizar_Vehiculo', 'TR') IS NOT NULL
        ENABLE TRIGGER trg_Despacho_Actualizar_Vehiculo ON Despacho;
    THROW;
END CATCH
GO
