USE Andreani
GO

CREATE FUNCTION fn_PorcentajeEnFechaComprometida (
    @Desde DATE,
    @Hasta DATE
)
RETURNS DECIMAL(5,2)
AS
BEGIN
    DECLARE @Porcentaje DECIMAL(5,2)
    DECLARE @EntregadosEnFecha INT
    DECLARE @CantidadPedidos INT

    SELECT @CantidadPedidos = COUNT(P.IdPedido)
    FROM Pedido AS P
    WHERE P.FechaEntregaSolicitada > @Desde
        AND P.FechaEntregaSolicitada < @Hasta
        AND P.EstadoPedido = 'ENTREGADO'

    IF @CantidadPedidos = 0
        RETURN 0

    SELECT @EntregadosEnFecha = COUNT(P.IdPedido)
    FROM Pedido AS P
    INNER JOIN Entrega AS E ON E.IdPedido = P.IdPedido
    WHERE P.FechaEntregaSolicitada > @Desde
        AND P.FechaEntregaSolicitada < @Hasta
        AND P.EstadoPedido = 'ENTREGADO'
        AND E.FechaEntregaReal <= P.FechaEntregaSolicitada

    SET @Porcentaje = (@EntregadosEnFecha * 100.0) / @CantidadPedidos
    RETURN @Porcentaje
END
GO
