CREATE VIEW VW_TASADECUMPLIMIENTO_POR_VEHICULO AS
SELECT 
    V.IdVehiculo, COUNT(P.IdPedido) AS ENTREGASTOTALES, 
    (
        SELECT COUNT(V2.IdVehiculo) 
        FROM VEHICULO V2
        INNER JOIN DESPACHO D2 ON D2.IdVehiculo = V2.IdVehiculo
        INNER JOIN ENTREGA E2 ON E2.IdDespacho = D2.IdDespacho
        INNER JOIN PEDIDO P2 ON P2.IdPedido = E2.IdPedido
        WHERE E2.EstadoEntrega = 'Entregada' 
          AND E2.FechaEntregaReal <= P2.FechaEntregaSolicitada 
          AND V2.IdVehiculo = V.IdVehiculo
    ) AS ENTRGASaTiempo,
    ((
            SELECT COUNT(V2.IdVehiculo) 
            FROM VEHICULO V2
            INNER JOIN DESPACHO D2 ON D2.IdVehiculo = V2.IdVehiculo
            INNER JOIN ENTREGA E2 ON E2.IdDespacho = D2.IdDespacho
            INNER JOIN PEDIDO P2 ON P2.IdPedido = E2.IdPedido
            WHERE E2.EstadoEntrega = 'Entregada' 
              AND E2.FechaEntregaReal <= P2.FechaEntregaSolicitada 
              AND V2.IdVehiculo = V.IdVehiculo) * 100.0 
    ) / NULLIF(COUNT(P.IdPedido),0) AS PorcentajeCumplimiento
FROM VEHICULO V
INNER JOIN DESPACHO D ON D.IdVehiculo = V.IdVehiculo
INNER JOIN ENTREGA E ON E.IdDespacho = D.IdDespacho
INNER JOIN PEDIDO P ON P.IdPedido = E.IdPedido
WHERE E.EstadoEntrega = 'Entregada'
GROUP BY V.IdVehiculo;
