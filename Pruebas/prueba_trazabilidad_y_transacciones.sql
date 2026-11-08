USE andreani
GO
--SCRIPT DE PRUEBA: RECORRE EL CIRCUITO COMPLETO DE UN PEDIDO Y DESPUÉS CONSULTA LA TRAZABILIDAD DEL LOTE.
--CARGA DATOS PROPIOS (TODOS CON LA PALABRA 'PRUEBA') PARA NO DEPENDER DE LO QUE YA HAYA EN LA BASE.
--NECESITA QUE ESTÉN CREADOS: LAS TABLAS, LOS TRIGGERS, sp_RegistrarPreparacion, sp_AsignarVehiculoDespacho,
--sp_ArmarCaja, sp_IniciarDespacho, sp_RegistrarEntrega Y FN_TRAZABILIDAD_LOTE.
--CORRERLO ENTERO DE UNA VEZ (F5).

SET NOCOUNT ON;

DECLARE @IdCliente int, @IdDestino int, @IdProdComun int, @IdProdFrio int;
DECLARE @IdLoteViejo int, @IdLoteNuevo int, @IdLoteFrio int;
DECLARE @IdPedido int, @IdDespacho int, @Codigo varchar(50);

-- ===================== DATOS BASE =====================
INSERT INTO CLIENTE (NOMBRECLIENTE) VALUES ('LABORATORIO PRUEBA');
SET @IdCliente = SCOPE_IDENTITY();

INSERT INTO DESTINO (NOMBREDESTINO, TIPODESTINO, DIRECCION, CIUDAD, PROVINCIA)
VALUES ('FARMACIA PRUEBA', 'FARMACIA', 'AV. SIEMPRE VIVA 742', 'ROSARIO', 'SANTA FE');
SET @IdDestino = SCOPE_IDENTITY();

INSERT INTO PRODUCTO (NOMBREPRODUCTO, CATEGORIAPRODUCTO, RequiereRefrigeracion) VALUES ('IBUPROFENO 400 PRUEBA', 'ANALGESICO', 0);
SET @IdProdComun = SCOPE_IDENTITY();
INSERT INTO PRODUCTO (NOMBREPRODUCTO, CATEGORIAPRODUCTO, RequiereRefrigeracion) VALUES ('INSULINA PRUEBA', 'HORMONA', 1);
SET @IdProdFrio = SCOPE_IDENTITY();

-- Dos lotes del mismo producto: el "viejo" vence antes, así que FEFO obliga a usar ese primero
INSERT INTO LOTE (IDPRODUCTO, FECHAVENCIMIENTO, STOCKLOTE) VALUES (@IdProdComun, DATEADD(MONTH, 3, GETDATE()), 100);
SET @IdLoteViejo = SCOPE_IDENTITY();
INSERT INTO LOTE (IDPRODUCTO, FECHAVENCIMIENTO, STOCKLOTE) VALUES (@IdProdComun, DATEADD(MONTH, 9, GETDATE()), 100);
SET @IdLoteNuevo = SCOPE_IDENTITY();
INSERT INTO LOTE (IDPRODUCTO, FECHAVENCIMIENTO, STOCKLOTE) VALUES (@IdProdFrio, DATEADD(MONTH, 6, GETDATE()), 50);
SET @IdLoteFrio = SCOPE_IDENTITY();

-- Vehículo refrigerado (si ya existe la patente de prueba, se reutiliza y se deja disponible)
IF NOT EXISTS (SELECT 1 FROM VEHICULO WHERE Patente = 'PR123UE')
    INSERT INTO VEHICULO (Patente, TipoVehiculo, TieneRefrigeracion, Disponible) VALUES ('PR123UE', 'CAMION', 1, 1);
ELSE
    UPDATE VEHICULO SET Disponible = 1 WHERE Patente = 'PR123UE';

-- ===================== 1) PEDIDO =====================
INSERT INTO PEDIDO (IdCliente, IdDestino, FechaPedido, FechaEntregaSolicitada, EstadoPedido)
VALUES (@IdCliente, @IdDestino, GETDATE(), DATEADD(DAY, 3, GETDATE()), 'Registrado');
SELECT @IdPedido = MAX(IdPedido) FROM PEDIDO WHERE IdCliente = @IdCliente;   -- el trigger INSTEAD OF no deja usar SCOPE_IDENTITY

INSERT INTO DETALLEPEDIDO (IdPedido, IdProducto, CantidadSolicitada) VALUES (@IdPedido, @IdProdComun, 10);
INSERT INTO DETALLEPEDIDO (IdPedido, IdProducto, CantidadSolicitada) VALUES (@IdPedido, @IdProdFrio, 5);

-- ===================== 2) PREPARACIÓN =====================
EXEC sp_RegistrarPreparacion @IdPedido = @IdPedido, @IdProducto = @IdProdComun, @IdLote = @IdLoteViejo, @Cantidad = 10;
EXEC sp_RegistrarPreparacion @IdPedido = @IdPedido, @IdProducto = @IdProdFrio,  @IdLote = @IdLoteFrio,  @Cantidad = 5;

-- ===================== 3) ARMADO DE CAJA (TRANSACCIÓN) =====================
SET @Codigo = 'PRUEBA-' + CAST(@IdPedido AS varchar(10));
EXEC sp_ArmarCaja @IdPedido = @IdPedido, @CodigoBarra = @Codigo;

-- Prueba de error: el mismo código de barras otra vez -> el CATCH hace ROLLBACK y no se crea nada
BEGIN TRY
    EXEC sp_ArmarCaja @IdPedido = @IdPedido, @CodigoBarra = @Codigo;
END TRY
BEGIN CATCH
    PRINT '>> Error esperado: ' + ERROR_MESSAGE();
END CATCH

-- ===================== 4) DESPACHO =====================
DECLARE @Manana date = DATEADD(DAY, 1, GETDATE());
EXEC sp_AsignarVehiculoDespacho @IdPedido = @IdPedido, @FechaSalida = @Manana;
SELECT @IdDespacho = IdDespacho FROM ENTREGA WHERE IdPedido = @IdPedido;

EXEC sp_IniciarDespacho @IdDespacho = @IdDespacho;

-- ===================== 5) ENTREGA (TRANSACCIÓN) =====================
-- Prueba de error: pedido con producto refrigerado sin indicar si llegó en frío
BEGIN TRY
    DECLARE @Ahora datetime = DATEADD(HOUR, 30, GETDATE());
    EXEC sp_RegistrarEntrega @IdPedido = @IdPedido, @FechaEntregaReal = @Ahora, @EstadoEntrega = 'Entregada';
END TRY
BEGIN CATCH
    PRINT '>> Error esperado: ' + ERROR_MESSAGE();
END CATCH

EXEC sp_RegistrarEntrega @IdPedido = @IdPedido, @FechaEntregaReal = @Ahora, @EstadoEntrega = 'Entregada', @LlegoFrio = 1;

-- ===================== 6) TRAZABILIDAD DEL LOTE =====================
SELECT * FROM FN_TRAZABILIDAD_LOTE(@IdLoteViejo);
SELECT * FROM FN_TRAZABILIDAD_LOTE(@IdLoteFrio);

-- Estados finales de todo lo que se tocó
SELECT IdPedido, EstadoPedido FROM PEDIDO WHERE IdPedido = @IdPedido;
SELECT IdCaja, CodigoBarra, IdDespacho, EstadoCaja FROM CAJA WHERE CodigoBarra = @Codigo;
SELECT d.IdDespacho, d.EstadoDespacho, d.FechaSalida, v.Patente, v.Disponible
FROM DESPACHO d JOIN VEHICULO v ON v.IdVehiculo = d.IdVehiculo
WHERE d.IdDespacho = @IdDespacho;
GO
