USE Andreani
GO

--KPI 3
CREATE VIEW vw_PorcentajeIncumplimientoFEFO AS
SELECT(
        SELECT COUNT(IdPreparacion)
        FROM Preparacion
    ) AS TotalPreparaciones,
    (
        SELECT COUNT(pr.IdPreparacion)
        FROM Preparacion AS pr
        INNER JOIN Lote AS l ON l.IdLote = pr.IdLote
        WHERE pr.CumpleFEFO = 0
            OR l.FechaVencimiento < pr.FechaPreparacion
    ) AS PreparacionesConError,

    (
        (
            SELECT COUNT(pr.IdPreparacion)
            FROM Preparacion AS pr
            INNER JOIN Lote AS l ON l.IdLote = pr.IdLote
            WHERE pr.CumpleFEFO = 0
                OR l.FechaVencimiento < pr.FechaPreparacion
        ) * 100.0
    ) / NULLIF((SELECT COUNT(IdPreparacion) FROM Preparacion), 0) AS PorcentajeIncumplimientoFEFO;
GO
