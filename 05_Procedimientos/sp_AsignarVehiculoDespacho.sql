USE Andreani
GO

CREATE PROCEDURE sp_AsignarVehiculoDespacho
    @IdPedido INT,
    @FechaSalida DATETIME   -- DATETIME para guardar tambien la hora de salida
AS
BEGIN
    DECLARE @NecesitaFrio BIT = 0
    DECLARE @Vehiculo INT
    DECLARE @IdDespacho INT

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM Pedido WHERE IdPedido = @IdPedido)
        BEGIN
            PRINT 'El pedido no existe.'
            RETURN
        END

        -- Un pedido que ya tiene entrega ya fue asignado a un despacho
        IF EXISTS (SELECT 1 FROM Entrega WHERE IdPedido = @IdPedido)
        BEGIN
            PRINT 'El pedido ya tiene un despacho asignado.'
            RETURN
        END

        -- Tiene que haber al menos una caja armada para el pedido
        IF NOT EXISTS (
            SELECT 1
            FROM DetalleCaja AS dc
            JOIN Preparacion AS pp ON pp.IdPreparacion = dc.IdPreparacion
            WHERE pp.IdPedido = @IdPedido
        )
        BEGIN
            PRINT 'El pedido no tiene cajas armadas.'
            RETURN
        END

        IF EXISTS (
            SELECT 1
            FROM DetallePedido AS dp
            JOIN Producto AS p ON p.IdProducto = dp.IdProducto
            WHERE dp.IdPedido = @IdPedido AND p.RequiereRefrigeracion = 1
        )
        BEGIN
            SET @NecesitaFrio = 1
        END

        SELECT TOP 1 @Vehiculo = IdVehiculo
        FROM Vehiculo
        WHERE Disponible = 1
            AND (TieneRefrigeracion >= @NecesitaFrio)
        -- Primero los vehiculos sin frio (0 antes que 1): un pedido comun no ocupa uno refrigerado
        ORDER BY TieneRefrigeracion, IdVehiculo

        IF @Vehiculo IS NULL
        BEGIN
            PRINT 'No hay vehiculo disponible apto para este pedido.'
            RETURN
        END

        BEGIN TRANSACTION

            INSERT INTO Despacho (IdVehiculo, FechaSalida, EstadoDespacho)
            VALUES (@Vehiculo, @FechaSalida, 'Programado')

            SET @IdDespacho = SCOPE_IDENTITY()

            INSERT INTO Entrega (IdPedido, IdDespacho)
            VALUES (@IdPedido, @IdDespacho)

            UPDATE Caja
            SET Caja.IdDespacho = @IdDespacho
            FROM Caja AS c
            JOIN DetalleCaja AS dc ON dc.IdCaja = c.IdCaja
            JOIN Preparacion AS pp ON pp.IdPreparacion = dc.IdPreparacion
            WHERE pp.IdPedido = @IdPedido
                AND c.IdDespacho IS NULL

        COMMIT TRANSACTION
        PRINT 'Vehiculo y despacho asignados correctamente.'
    END TRY
    BEGIN CATCH
        -- Solo hace ROLLBACK si la transaccion llego a abrirse
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION
        PRINT 'Error al asignar vehiculo y despacho'
    END CATCH
END
GO
