-- ===================== 7) KPIs =====================

-- KPI 1: Porcentaje de pedidos entregados dentro de la fecha comprometida
SELECT
    COUNT(*) AS TotalEntregasRealizadas,
    SUM(CASE WHEN CAST(e.FechaEntregaReal AS DATE) <= p.FechaEntregaSolicitada THEN 1 ELSE 0 END) AS EntregasEnFecha,
    CAST(
        SUM(CASE WHEN CAST(e.FechaEntregaReal AS DATE) <= p.FechaEntregaSolicitada THEN 1 ELSE 0 END) * 100.0
        / NULLIF(COUNT(*), 0)
    AS DECIMAL(5,2)) AS PorcentajeCumplimiento
FROM ENTREGA e
INNER JOIN PEDIDO p ON p.IdPedido = e.IdPedido
WHERE e.EstadoEntrega = 'Entregada';

-- KPI 2: Tiempo promedio entre registro del pedido y su entrega (por provincia y ciudad)
SELECT
    d.PROVINCIA,
    d.CIUDAD,
    COUNT(*) AS CantidadEntregas,
    CAST(AVG(DATEDIFF(HOUR, p.FechaPedido, e.FechaEntregaReal) * 1.0) AS DECIMAL(10,2)) AS PromedioHoras,
    CAST(AVG(DATEDIFF(HOUR, p.FechaPedido, e.FechaEntregaReal) / 24.0) AS DECIMAL(10,2)) AS PromedioDias
FROM ENTREGA e
INNER JOIN PEDIDO p  ON p.IdPedido  = e.IdPedido
INNER JOIN DESTINO d ON d.IDDESTINO = p.IdDestino
WHERE e.EstadoEntrega = 'Entregada'
  AND e.FechaEntregaReal IS NOT NULL
GROUP BY d.PROVINCIA, d.CIUDAD;

-- KPI 3: Porcentaje de errores de validación FEFO / lotes vencidos durante la preparación
SELECT
    COUNT(*) AS TotalPreparaciones,
    SUM(CASE WHEN pr.CumpleFEFO = 0 OR l.FECHAVENCIMIENTO < pr.FechaPreparacion THEN 1 ELSE 0 END) AS PreparacionesConError,
    CAST(
        SUM(CASE WHEN pr.CumpleFEFO = 0 OR l.FECHAVENCIMIENTO < pr.FechaPreparacion THEN 1 ELSE 0 END) * 100.0
        / NULLIF(COUNT(*), 0)
    AS DECIMAL(5,2)) AS PorcentajeErroresValidacion
FROM PREPARACION pr
INNER JOIN LOTE l ON l.IDLOTE = pr.IdLote;
