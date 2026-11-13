USE Andreani
GO

CREATE VIEW vw_PedidosSegunSuEstado AS
SELECT EstadoPedido,COUNT(IdPedido) AS CantidadPedidos
FROM Pedido
GROUP BY EstadoPedido
GO
