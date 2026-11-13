USE Andreani
GO

--KPI 2
CREATE VIEW vw_PromedioTardanzaDestino AS
SELECT
    d.Provincia,
    d.Ciudad,
    COUNT(e.IdEntrega) AS CantidadEntregas,
    AVG(DATEDIFF(HOUR, p.FechaPedido, e.FechaEntregaReal)) AS PromedioHoras,
    AVG(DATEDIFF(DAY, p.FechaPedido, e.FechaEntregaReal)) AS PromedioDias
FROM Pedido AS p
INNER JOIN Destino AS d ON d.IdDestino = p.IdDestino
INNER JOIN Entrega AS e ON e.IdPedido = p.IdPedido
WHERE e.EstadoEntrega = 'Entregada'
    AND e.FechaEntregaReal IS NOT NULL
GROUP BY d.Provincia, d.Ciudad;
GO
