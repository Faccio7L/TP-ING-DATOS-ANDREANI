USE Andreani
GO
CREATE VIEW vw_PedidosPorCliente AS
SELECT c.IdCliente,
       c.NombreCliente,
       COUNT(p.IdPedido) AS CantidadPedidos
FROM Pedido AS p
JOIN Cliente AS c
    ON c.IdCliente = p.IdCliente
GROUP BY c.IdCliente, c.NombreCliente;
GO
