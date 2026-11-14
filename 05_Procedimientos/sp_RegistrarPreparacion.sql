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
    DECLARE @Estado VARCHAR(20);   -- estado del lote
    DECLARE @Stock INT;            -- stock del lote
    DECLARE @Solicitada INT;       -- cantidad pedida de ese producto
    DECLARE @Bit BIT = 1;

    BEGIN TRY
        -- 1) El lote tiene que existir y ser del producto que se prepara
        SELECT @Vencimiento = FechaVencimiento,
               @Estado = Estado,
               @Stock = StockLote
        FROM Lote
        WHERE IdLote = @IdLote
            AND IdProducto = @IdProducto;

        -- Si quedo en NULL es porque no encontro el lote
        IF @Vencimiento IS NULL
        BEGIN
            PRINT 'El lote no existe o no corresponde al producto.'
            RETURN
        END

        -- 2) El lote no puede estar bloqueado ni vencido
        IF @Estado <> 'DISPONIBLE' OR @Vencimiento < CAST(GETDATE() AS DATE)
        BEGIN
            PRINT 'El lote esta bloqueado o vencido.'
            RETURN
        END

        -- 3) El producto tiene que estar en el pedido y no se puede preparar mas de lo solicitado
        SELECT @Solicitada = CantidadSolicitada
        FROM DetallePedido
        WHERE IdPedido = @IdPedido
            AND IdProducto = @IdProducto;

        -- Si quedo en NULL es porque el pedido no tiene ese producto
        IF @Solicitada IS NULL
        BEGIN
            PRINT 'El producto no esta en el pedido.'
            RETURN
        END

        IF @Cantidad > @Solicitada
        BEGIN
            PRINT 'La cantidad supera la cantidad solicitada.'
            RETURN
        END

        -- 4) El lote tiene que tener stock suficiente
        IF @Cantidad > @Stock
        BEGIN
            PRINT 'El lote no tiene stock suficiente.'
            RETURN
        END

        -- 5) FEFO: si hay otro lote disponible del mismo producto que vence antes, no cumple
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

            -- Solo las preparaciones aprobadas descuentan stock (las que no cumplen FEFO no se empacan)
            IF @Bit = 1
            BEGIN
                UPDATE Lote
                SET StockLote = StockLote - @Cantidad
                WHERE IdLote = @IdLote;
            END

        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        -- Solo hace ROLLBACK si la transaccion llego a abrirse
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION
        PRINT 'Error al registrar la preparacion'
    END CATCH
END
GO
