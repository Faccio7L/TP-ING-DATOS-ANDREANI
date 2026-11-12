use andreani
go

create view vw_PorcentajeIncumplimientoFEFO
as
select cast(
        (SELECT COUNT(*) FROM PREPARACION WHERE CumpleFEFO = 0) * 100.0
        / NULLIF((SELECT COUNT(*) FROM PREPARACION), 0)
    AS DECIMAL(5,2)) AS [Porcentaje de incumplimiento FEFO];
GO
