CREATE FUNCTION fn_PorcentajeEnFechaComprometida (
    -- Función para ver el porcentaje de entregas en fecha comprometida, siempre y cuando la fecha de entrega
    -- solicitada se encuentre en el lapso planteado en los parámetros.
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

    SELECT @EntregadosEnFecha = COUNT(P.IdPedido)
    FROM Pedido AS P
    INNER JOIN Entrega AS E
        ON E.IdPedido = P.IdPedido
    WHERE P.FechaEntregaSolicitada > @Desde
        AND P.FechaEntregaSolicitada < @Hasta
        AND P.EstadoPedido = 'ENTREGADO'
        AND E.FechaEntregaReal <= P.FechaEntregaSolicitada

    SET @Porcentaje = @EntregadosEnFecha * 100 / @CantidadPedidos
    RETURN ISNULL(@Porcentaje, 0)
END
