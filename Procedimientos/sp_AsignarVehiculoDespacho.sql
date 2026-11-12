USE andreani
GO

CREATE PROCEDURE sp_AsignarVehiculoDespacho
    @IdPedido int,
    @FechaSalida DATE
AS
BEGIN
    DECLARE @NecesitaFrio bit = 0
    DECLARE @Vehiculo int
    DECLARE @IdDespacho int

    BEGIN TRY
        -- Validación por si el pedido no existe
        IF NOT EXISTS (SELECT 1 FROM PEDIDO WHERE IdPedido = @IdPedido)
        BEGIN
            PRINT 'El pedido no existe.'
            RETURN
        END

        -- ¿El pedido tiene algún producto que requiere refrigeración?
        IF EXISTS (SELECT 1
                   FROM DETALLEPEDIDO dp
                   JOIN PRODUCTO p ON p.IdProducto = dp.IdProducto
                   WHERE dp.IdPedido = @IdPedido
                     AND p.RequiereRefrigeracion = 1)
        BEGIN
            SET @NecesitaFrio = 1
        END

        -- Vehículo disponible y, si hace falta, con refrigeración
        SELECT TOP 1 @Vehiculo = IdVehiculo
        FROM VEHICULO
        WHERE Disponible = 1
          AND (TieneRefrigeracion = @NecesitaFrio)

        IF @Vehiculo IS NULL
        BEGIN
            PRINT 'No hay vehiculo disponible apto para este pedido.'
            RETURN
        END

        BEGIN TRANSACTION

            UPDATE VEHICULO
            SET Disponible = 0
            WHERE IdVehiculo = @Vehiculo

            INSERT INTO DESPACHO (IdVehiculo, FechaSalida, EstadoDespacho)
            VALUES (@Vehiculo, @FechaSalida, 'Programado')

            SET @IdDespacho = SCOPE_IDENTITY()

            INSERT INTO ENTREGA (IdPedido, IdDespacho)
            VALUES (@IdPedido, @IdDespacho)

            -- Asignar el despacho a las cajas del pedido que todavía no tienen uno
            UPDATE CAJA
            SET CAJA.IdDespacho = @IdDespacho
            FROM CAJA c
            JOIN DETALLECAJA dc ON dc.IdCaja = c.IdCaja
            JOIN PREPARACION pp ON pp.IdPreparacion = dc.IdPreparacion
            WHERE pp.IdPedido = @IdPedido
              AND c.IdDespacho IS NULL

        COMMIT TRANSACTION
        PRINT 'Vehiculo y despacho asignados correctamente.'
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION
        PRINT 'Error al asignar vehiculo y despacho'
    END CATCH
END
GO
