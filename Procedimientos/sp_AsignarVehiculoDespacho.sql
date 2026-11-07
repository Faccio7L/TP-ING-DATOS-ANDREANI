USE andreani
GO

CREATE PROCEDURE sp_AsignarVehiculoDespacho
    @IdPedido int,
    @FechaSalida DATE
AS
BEGIN
    DECLARE @NecesitaFrio bit = 0;
    DECLARE @Vehiculo int;
    DECLARE @IdDespacho int;

    -- Validación por si el pedido no existe
    IF NOT EXISTS (SELECT 1 FROM PEDIDO WHERE IdPedido = @IdPedido)
        THROW 50001, 'El pedido no existe.', 1;

    -- ¿El pedido tiene algún producto que requiere refrigeración?
    IF EXISTS (SELECT 1
               FROM DETALLEPEDIDO dp
               JOIN PRODUCTO p ON p.IdProducto = dp.IdProducto
               WHERE dp.IdPedido = @IdPedido
                 AND p.RequiereRefrigeracion = 1)
        SET @NecesitaFrio = 1;

    -- Vehículo disponible y, si hace falta, con refrigeración
    SELECT TOP 1 @Vehiculo = IdVehiculo
    FROM VEHICULO
    WHERE Disponible = 1
      AND (TieneRefrigeracion =@NecesitaFrio)

    IF @Vehiculo IS NULL
        THROW 50002, 'No hay vehículo disponible apto para este pedido.', 1;

    BEGIN TRY
        BEGIN TRANSACTION;

            UPDATE VEHICULO
            SET Disponible = 0
            WHERE IdVehiculo = @Vehiculo;

            INSERT INTO DESPACHO (IdVehiculo, FechaSalida, EstadoDespacho)
            VALUES (@Vehiculo, @FechaSalida, 'Programado');

            SET @IdDespacho = SCOPE_IDENTITY();

            INSERT INTO ENTREGA (IdPedido, IdDespacho)
            VALUES (@IdPedido, @IdDespacho);

            -- Asignar el despacho a las cajas del pedido que todavía no tienen uno
            UPDATE CAJA
            SET CAJA.IdDespacho = @IdDespacho
            FROM CAJA c
            JOIN DETALLECAJA dc ON dc.IdCaja = c.IdCaja
            JOIN PREPARACION pp ON pp.IdPreparacion = dc.IdPreparacion
            WHERE pp.IdPedido = @IdPedido
              AND c.IdDespacho IS NULL;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO
