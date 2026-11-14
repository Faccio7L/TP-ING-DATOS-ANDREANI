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
        -- Solo entregas realizadas (no pendientes ni rechazadas)
        WHERE E2.EstadoEntrega = 'Entregada'
            -- CAST AS DATE: se compara solo el dia, sin la hora
            AND CAST(E2.FechaEntregaReal AS DATE) <= P2.FechaEntregaSolicitada
            AND C2.NombreCliente = C.NombreCliente
    ) AS EntregadoEnFecha,
    ((
        SELECT COUNT((E2.IdPedido))
        FROM Cliente AS C2
        INNER JOIN Pedido AS P2
            ON P2.IdCliente = C2.IdCliente
        INNER JOIN Entrega AS E2
            ON E2.IdPedido = P2.IdPedido
        -- Mismas condiciones que la subconsulta de arriba
        WHERE E2.EstadoEntrega = 'Entregada'
            AND CAST(E2.FechaEntregaReal AS DATE) <= P2.FechaEntregaSolicitada
            AND C2.NombreCliente = C.NombreCliente
    ) * 100.0
    ) / NULLIF(COUNT(E.IdPedido), 0) AS Porcentaje
FROM Cliente AS C
INNER JOIN Pedido AS P
    ON P.IdCliente = C.IdCliente
INNER JOIN Entrega AS E
    ON E.IdPedido = P.IdPedido
-- El total tambien cuenta solo entregas realizadas
WHERE E.EstadoEntrega = 'Entregada'
GROUP BY C.NombreCliente
GO
