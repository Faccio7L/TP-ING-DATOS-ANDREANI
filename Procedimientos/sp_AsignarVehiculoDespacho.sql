USE Andreani
GO

CREATE PROCEDURE sp_AsignarVehiculoDespacho
    @IdPedido INT,
    @FechaSalida DATE
AS
BEGIN
    DECLARE @NecesitaFrio BIT = 0
    DECLARE @Vehiculo INT
    DECLARE @IdDespacho INT

    BEGIN TRY
        -- Validación por si el pedido no existe
        IF NOT EXISTS (SELECT 1 FROM Pedido WHERE IdPedido = @IdPedido)
        BEGIN
            PRINT 'El pedido no existe.'
            RETURN
        END

        -- ¿El pedido tiene algún producto que requiere refrigeración?
        IF EXISTS (
            SELECT 1
            FROM DetallePedido AS dp
            JOIN Producto AS p
                ON p.IdProducto = dp.IdProducto
            WHERE dp.IdPedido = @IdPedido
                AND p.RequiereRefrigeracion = 1
        )
        BEGIN
            SET @NecesitaFrio = 1
        END

        -- Vehículo disponible y, si hace falta, con refrigeración
        SELECT TOP 1 @Vehiculo = IdVehiculo
        FROM Vehiculo
        WHERE Disponible = 1
            AND (TieneRefrigeracion >=@NecesitaFrio)

        IF @Vehiculo IS NULL
        BEGIN
            PRINT 'No hay vehiculo disponible apto para este pedido.'
            RETURN
        END

        BEGIN TRANSACTION

            UPDATE Vehiculo
            SET Disponible = 0
            WHERE IdVehiculo = @Vehiculo

            INSERT INTO Despacho (IdVehiculo, FechaSalida, EstadoDespacho)
            VALUES (@Vehiculo, @FechaSalida, 'Programado')

            SET @IdDespacho = SCOPE_IDENTITY()

            INSERT INTO Entrega (IdPedido, IdDespacho)
            VALUES (@IdPedido, @IdDespacho)

            -- Asignar el despacho a las cajas del pedido que todavía no tienen uno
            UPDATE Caja
            SET Caja.IdDespacho = @IdDespacho
            FROM Caja AS c
            JOIN DetalleCaja AS dc
                ON dc.IdCaja = c.IdCaja
            JOIN Preparacion AS pp
                ON pp.IdPreparacion = dc.IdPreparacion
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
