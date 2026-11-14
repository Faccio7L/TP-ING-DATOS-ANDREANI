USE Andreani
GO

CREATE TRIGGER trg_Validar_Pedidos
ON Pedido
INSTEAD OF INSERT
AS
BEGIN
    -- inserted trae todas las filas del INSERT: si alguna tiene la entrega antes del pedido, no se inserta nada
    -- CAST AS DATE: FechaPedido tiene hora y FechaEntregaSolicitada no
    IF EXISTS (
        SELECT 1
        FROM inserted
        WHERE FechaEntregaSolicitada < CAST(FechaPedido AS DATE)
    )
    BEGIN
        PRINT 'LA FECHA DE ENTREGA NO PUEDE SER ANTERIOR A LA FECHA DEL PEDIDO.'
        RETURN
    END

    -- Inserta todas las filas de inserted (con variables se guardaba una sola)
    INSERT INTO Pedido (IdCliente, IdDestino, FechaPedido, FechaEntregaSolicitada, EstadoPedido)
    SELECT IdCliente, IdDestino, FechaPedido, FechaEntregaSolicitada, EstadoPedido
    FROM inserted

    PRINT 'Pedido registrado correctamente.'
END
GO
