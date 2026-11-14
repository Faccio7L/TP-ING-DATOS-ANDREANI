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
    -- >= y <= para que el rango incluya los dias @Desde y @Hasta
    WHERE P.FechaEntregaSolicitada >= @Desde
        AND P.FechaEntregaSolicitada <= @Hasta
        AND P.EstadoPedido = 'Entregado'

    IF @CantidadPedidos = 0
        RETURN 0

    SELECT @EntregadosEnFecha = COUNT(P.IdPedido)
    FROM Pedido AS P
    INNER JOIN Entrega AS E ON E.IdPedido = P.IdPedido
    WHERE P.FechaEntregaSolicitada >= @Desde
        AND P.FechaEntregaSolicitada <= @Hasta
        AND P.EstadoPedido = 'Entregado'
        -- CAST AS DATE: se compara solo el dia, sin la hora de la entrega
        AND CAST(E.FechaEntregaReal AS DATE) <= P.FechaEntregaSolicitada

    SET @Porcentaje = (@EntregadosEnFecha * 100.0) / @CantidadPedidos
    RETURN @Porcentaje
END
GO
