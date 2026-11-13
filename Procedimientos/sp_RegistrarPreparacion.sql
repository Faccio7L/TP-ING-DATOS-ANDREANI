USE Andreani
GO

CREATE PROCEDURE sp_RegistrarPreparacion
    @IdPedido INT,
    @IdProducto INT,
    @IdLote INT,
    @Cantidad INT
AS
BEGIN
    DECLARE @Vencimiento DATE;
    DECLARE @Bit BIT = 1;

    BEGIN TRY
        SELECT @Vencimiento = FechaVencimiento
        FROM Lote
        WHERE IdLote = @IdLote;

        IF EXISTS (
            SELECT 1
            FROM Lote
            WHERE StockLote >= @Cantidad
                AND IdProducto = @IdProducto
                AND FechaVencimiento < @Vencimiento
                AND IdLote != @IdLote
                AND Estado = 'DISPONIBLE'
        )
        BEGIN
            SET @Bit = 0;
        END

        BEGIN TRANSACTION

            INSERT INTO Preparacion (IdLote, IdProducto, IdPedido, FechaPreparacion, CantidadPreparada, CumpleFEFO)
            VALUES (@IdLote, @IdProducto, @IdPedido, GETDATE(), @Cantidad, @Bit);

        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION
        PRINT 'Error al registrar la preparación'
    END CATCH
END
GO
