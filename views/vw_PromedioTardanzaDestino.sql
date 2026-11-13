use andreani
go

Create view vw_PromedioTardanzaDestino as
select TP.Provincia, TP.Ciudad, avg(DiasTranscurridos) as PromedioDiasTardanza 
from (select d.Provincia, d.Ciudad, DATEDIFF(day,p.FechaPedido, e.FechaEntregaReal) as DiasTranscurridos
	from PEDIDO p
	JOIN DESTINO d on d.IDDESTINO=p.IdDestino
	JOIN ENTREGA e on p.IdPedido=e.IdPedido
	) as TP
group by TP.Provincia, TP.Ciudad
go
