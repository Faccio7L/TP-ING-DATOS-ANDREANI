USE Andreani;
GO
-- Pruebas de los procedimientos. Todo va dentro de una transaccion con ROLLBACK
-- para que los datos queden como estaban.

-- ============ sp_RegistrarPreparacion ============
BEGIN TRAN;
    SELECT IdLote, StockLote FROM Lote WHERE IdLote IN (7, 21);   -- stock antes

    EXEC sp_RegistrarPreparacion 39, 6, 7, 70;    -- correcta: cumple FEFO y descuenta 70 del lote 7
    EXEC sp_RegistrarPreparacion 39, 6, 21, 70;   -- se registra con CumpleFEFO = 0 (el lote 7 vence antes) y no descuenta
    EXEC sp_RegistrarPreparacion 38, 12, 18, 40;  -- rechazada: lote bloqueado
    EXEC sp_RegistrarPreparacion 39, 6, 1, 70;    -- rechazada: el lote 1 es de otro producto
    EXEC sp_RegistrarPreparacion 39, 6, 7, 500;   -- rechazada: supera la cantidad solicitada

    SELECT IdPreparacion, IdLote, IdPedido, CantidadPreparada, CumpleFEFO
    FROM Preparacion
    WHERE IdPedido = 39;                                           -- tienen que aparecer 2 filas

    SELECT IdLote, StockLote FROM Lote WHERE IdLote IN (7, 21);   -- stock despues
ROLLBACK;
GO

-- ============ sp_AsignarVehiculoDespacho ============
BEGIN TRAN;
    EXEC sp_AsignarVehiculoDespacho 38, '2026-11-16T08:00:00';   -- correcta: el pedido 38 lleva frio
    EXEC sp_AsignarVehiculoDespacho 38, '2026-11-16T08:00:00';   -- rechazada: ya tiene despacho
    EXEC sp_AsignarVehiculoDespacho 39, '2026-11-16T08:00:00';   -- rechazada: no tiene cajas

    SELECT e.IdPedido, d.IdDespacho, d.FechaSalida, v.Patente, v.TieneRefrigeracion, v.Disponible
    FROM Entrega AS e
    JOIN Despacho AS d ON d.IdDespacho = e.IdDespacho
    JOIN Vehiculo AS v ON v.IdVehiculo = d.IdVehiculo
    WHERE e.IdPedido = 38;                                        -- 1 fila, vehiculo con frio y Disponible = 0

    SELECT IdCaja, CodigoBarra, IdDespacho FROM Caja WHERE IdCaja = 32;   -- la caja del pedido 38 ya tiene despacho
ROLLBACK;
GO
