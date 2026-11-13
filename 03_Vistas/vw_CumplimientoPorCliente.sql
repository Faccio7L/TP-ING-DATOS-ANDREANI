USE Andreani
GO

CREATE VIEW vw_CumplimientoPorCliente AS
SELECT
    C.NombreCliente,
    COUNT(E.IdPedido) AS PedidosTotales,
    (
        SELECT COUNT((E2.IdPedido))
        FROM Cliente AS C2
        INNER JOIN Pedido AS P2
            ON P2.IdCliente = C2.IdCliente
        INNER JOIN Entrega AS E2
            ON E2.IdPedido = P2.IdPedido
        WHERE P2.FechaEntregaSolicitada >= E2.FechaEntregaReal
            AND C2.NombreCliente = C.NombreCliente
    ) AS EntregadoEnFecha,
    ((
        SELECT COUNT((E2.IdPedido))
        FROM Cliente AS C2
        INNER JOIN Pedido AS P2
            ON P2.IdCliente = C2.IdCliente
        INNER JOIN Entrega AS E2
            ON E2.IdPedido = P2.IdPedido
        WHERE P2.FechaEntregaSolicitada >= E2.FechaEntregaReal
            AND C2.NombreCliente = C.NombreCliente
    ) * 100.0
    ) / NULLIF(COUNT(E.IdPedido), 0) AS Porcentaje
FROM Cliente AS C
INNER JOIN Pedido AS P
    ON P.IdCliente = C.IdCliente
INNER JOIN Entrega AS E
    ON E.IdPedido = P.IdPedido
GROUP BY C.NombreCliente
GO
