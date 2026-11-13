USE Andreani
GO

CREATE VIEW vw_PorcentajeIncumplimientoFEFO
AS
SELECT CAST(
        (SELECT COUNT(*) FROM Preparacion WHERE CumpleFEFO = 0) * 100.0
        / NULLIF((SELECT COUNT(*) FROM Preparacion), 0)
    AS DECIMAL(5,2)) AS PorcentajeIncumplimientoFEFO;
GO
