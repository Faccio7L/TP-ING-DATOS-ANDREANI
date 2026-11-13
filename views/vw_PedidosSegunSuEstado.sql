CREATE VIEW vw_PedidosSegunSuEstado
    -- Muestra la cantidad de pedidos según su estado y muestra sus detalles.
AS
WITH CantidadPorEstado AS (
    SELECT COUNT(P.IdPedido) AS Cantidad,
           P.EstadoPedido
    FROM Pedido AS P
    GROUP BY P.EstadoPedido
)
SELECT CPE.Cantidad,
       CPE.EstadoPedido,
       DP.CantidadSolicitada,
       DP.IdPedido,
       DP.IdProducto
FROM CantidadPorEstado AS CPE
INNER JOIN Pedido AS P ON P.EstadoPedido = CPE.EstadoPedido
INNER JOIN DetallePedido AS DP ON DP.IdPedido = P.IdPedido
GO
