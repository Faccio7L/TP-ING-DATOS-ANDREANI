use andreani
go

create view vw_PorcentajeIncumplimientoFEFO
as
select cast(
        (select count(*) from PREPARACION where CumpleFEFO = 0) * 100.0
        / NULLIF((select count(*) from PREPARACION), 0)
    AS DECIMAL(5,2)) AS [Porcentaje de incumplimiento FEFO];
GO
