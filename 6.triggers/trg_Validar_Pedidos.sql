USE Andreani
GO

CREATE TRIGGER trg_Validar_Pedidos
ON Pedido
INSTEAD OF INSERT
AS
BEGIN

    DECLARE @IdCliente INT
    DECLARE @IdDestino INT
    DECLARE @FechaPedido DATETIME
    DECLARE @FechaEntrega DATE
    DECLARE @EstadoPedido VARCHAR(20)

    SELECT
        @IdCliente = IdCliente,
        @IdDestino = IdDestino,
        @FechaPedido = FechaPedido,
        @FechaEntrega = FechaEntregaSolicitada,
        @EstadoPedido = EstadoPedido
    FROM inserted

    IF (@FechaEntrega < GETDATE())
    BEGIN
        PRINT 'LA FECHA DE ENTREGA NO PUEDE SER MENOR A LA ACTUAL.'
        RETURN
    END

    INSERT INTO Pedido (IdCliente, IdDestino, FechaPedido, FechaEntregaSolicitada, EstadoPedido)
    VALUES (@IdCliente, @IdDestino, @FechaPedido, @FechaEntrega, @EstadoPedido)

    PRINT 'Pedido registrado correctamente.'
END
GO

