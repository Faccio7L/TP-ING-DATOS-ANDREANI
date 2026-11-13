USE Andreani
GO

--KPI 1
CREATE VIEW vw_PorcentajeCumplimientoPedidos AS
SELECT(
        SELECT COUNT(IdEntrega)
        FROM Entrega
        WHERE EstadoEntrega = 'Entregada'
    ) AS TotalEntregas,
    (
        SELECT COUNT(e.IdEntrega)
        FROM Entrega AS e
        INNER JOIN Pedido AS p ON p.IdPedido = e.IdPedido
        WHERE e.EstadoEntrega = 'Entregada'
            AND e.FechaEntregaReal <= p.FechaEntregaSolicitada
    ) AS EntregasEnFecha,(
        (
            SELECT COUNT(e.IdEntrega)
            FROM Entrega AS e
            INNER JOIN Pedido AS p ON p.IdPedido = e.IdPedido
            WHERE e.EstadoEntrega = 'Entregada'
                AND e.FechaEntregaReal <= p.FechaEntregaSolicitada
        ) * 100.0
    ) / NULLIF((SELECT COUNT(IdEntrega) FROM Entrega WHERE EstadoEntrega = 'Entregada'), 0) AS PorcentajeCumplimiento;
GO
