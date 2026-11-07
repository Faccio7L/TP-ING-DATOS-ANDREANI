USE andreani
GO

CREATE PROCEDURE sp_RegistrarPreparacion
	@IdPedido int,
	@IdProducto int,
	@IdLote int,
	@Cantidad int
AS
BEGIN
DECLARE @Vencimiento DATE;
    DECLARE @Bit BIT = 1; 

    SELECT @Vencimiento = FECHAVENCIMIENTO
    FROM LOTE
    WHERE IDLOTE = @IdLote;

    IF EXISTS (SELECT IDLOTE
               FROM LOTE
               WHERE STOCKLOTE >= @Cantidad
                 AND IDPRODUCTO = @IdProducto
                 AND FECHAVENCIMIENTO < @Vencimiento
                 AND IDLOTE != @IdLote
                 AND ESTADO = 'DISPONIBLE')
    BEGIN
        SET @Bit = 0;
    END

    INSERT INTO PREPARACION (IdLote, IdProducto, IdPedido, FechaPreparacion, CantidadPreparada, CumpleFEFO)
    VALUES (@IdLote, @IdProducto, @IdPedido, GETDATE(), @Cantidad, @Bit);
END;
GO
