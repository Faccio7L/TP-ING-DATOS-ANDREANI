USE Andreani
GO

CREATE VIEW vw_PedidosPorZona AS
SELECT d.Provincia,
       d.Ciudad,
       COUNT(p.IdPedido) AS CantidadPedidos
FROM Pedido AS p
JOIN Destino AS d
    ON d.IdDestino = p.IdDestino
GROUP BY d.Provincia, d.Ciudad;
GO
