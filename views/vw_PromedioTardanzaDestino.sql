USE Andreani
GO

CREATE VIEW vw_PromedioTardanzaDestino AS
SELECT TP.Provincia,
       TP.Ciudad,
       AVG(DiasTranscurridos) AS PromedioDiasTardanza
FROM (
    SELECT d.Provincia,
           d.Ciudad,
           DATEDIFF(DAY, p.FechaPedido, e.FechaEntregaReal) AS DiasTranscurridos
    FROM Pedido AS p
    JOIN Destino AS d  ON d.IdDestino = p.IdDestino
    JOIN Entrega AS e  ON p.IdPedido = e.IdPedido
) AS TP
GROUP BY TP.Provincia, TP.Ciudad
GO
