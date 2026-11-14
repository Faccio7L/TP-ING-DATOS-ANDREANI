USE Andreani
GO

CREATE VIEW vw_CumplimientoPorProvincia AS
SELECT
    D.Provincia,
    COUNT(E.IdPedido) AS PedidosTotales,
    (
        SELECT COUNT(E2.IdPedido)
        FROM Destino AS D2
        INNER JOIN Pedido AS P2
            ON P2.IdDestino = D2.IdDestino
        INNER JOIN Entrega AS E2
            ON E2.IdPedido = P2.IdPedido
        -- Solo entregas realizadas (no pendientes ni rechazadas)
        WHERE E2.EstadoEntrega = 'Entregada'
            -- CAST AS DATE: se compara solo el dia, sin la hora
            AND CAST(E2.FechaEntregaReal AS DATE) <= P2.FechaEntregaSolicitada
            AND D.Provincia = D2.Provincia
    ) AS EntregadoEnFecha,(
        (
            SELECT COUNT(E2.IdPedido)
            FROM Destino AS D2
            INNER JOIN Pedido AS P2
                ON P2.IdDestino = D2.IdDestino
            INNER JOIN Entrega AS E2
                ON E2.IdPedido = P2.IdPedido
            -- Mismas condiciones que la subconsulta de arriba
            WHERE E2.EstadoEntrega = 'Entregada'
                AND CAST(E2.FechaEntregaReal AS DATE) <= P2.FechaEntregaSolicitada
                AND D.Provincia = D2.Provincia
        ) * 100.0
    ) / NULLIF(COUNT(E.IdPedido), 0) AS Porcentaje
FROM Destino AS D
INNER JOIN Pedido AS P
    ON P.IdDestino = D.IdDestino
INNER JOIN Entrega AS E
    ON E.IdPedido = P.IdPedido
-- El total tambien cuenta solo entregas realizadas
WHERE E.EstadoEntrega = 'Entregada'
GROUP BY D.Provincia
GO
