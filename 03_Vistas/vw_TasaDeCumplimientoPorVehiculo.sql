USE Andreani
GO

CREATE VIEW vw_TasaDeCumplimientoPorVehiculo AS
SELECT
    V.IdVehiculo,COUNT(P.IdPedido) AS EntregasTotales,
    (
        SELECT COUNT(V2.IdVehiculo)
        FROM Vehiculo AS V2
        INNER JOIN Despacho AS D2 ON D2.IdVehiculo = V2.IdVehiculo
        INNER JOIN Entrega AS E2 ON E2.IdDespacho = D2.IdDespacho
        INNER JOIN Pedido AS P2 ON P2.IdPedido = E2.IdPedido
        WHERE E2.EstadoEntrega = 'Entregada'
            -- CAST AS DATE: se compara solo el dia, sin la hora de la entrega
            AND CAST(E2.FechaEntregaReal AS DATE) <= P2.FechaEntregaSolicitada
            AND V2.IdVehiculo = V.IdVehiculo
    ) AS EntregasATiempo,
    ((
        SELECT COUNT(V2.IdVehiculo)
        FROM Vehiculo AS V2
        INNER JOIN Despacho AS D2 ON D2.IdVehiculo = V2.IdVehiculo
        INNER JOIN Entrega AS E2 ON E2.IdDespacho = D2.IdDespacho
        INNER JOIN Pedido AS P2 ON P2.IdPedido = E2.IdPedido
        WHERE E2.EstadoEntrega = 'Entregada'
            AND CAST(E2.FechaEntregaReal AS DATE) <= P2.FechaEntregaSolicitada
            AND V2.IdVehiculo = V.IdVehiculo
    ) * 100.0
    ) / NULLIF(COUNT(P.IdPedido), 0) AS PorcentajeCumplimiento
FROM Vehiculo AS V
INNER JOIN Despacho AS D ON D.IdVehiculo = V.IdVehiculo
INNER JOIN Entrega AS E ON E.IdDespacho = D.IdDespacho
INNER JOIN Pedido AS P ON P.IdPedido = E.IdPedido
WHERE E.EstadoEntrega = 'Entregada'
GROUP BY V.IdVehiculo
GO
