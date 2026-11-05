use andreani 
go

CREATE VIEW vw_PedidosPorZona AS
SELECT d.Provincia,
       d.Ciudad,
       COUNT(p.IdPedido) AS CantidadPedidos
FROM PEDIDO p
JOIN DESTINO d ON d.IdDestino = p.IdDestino
GROUP BY d.Provincia, d.Ciudad;
GO