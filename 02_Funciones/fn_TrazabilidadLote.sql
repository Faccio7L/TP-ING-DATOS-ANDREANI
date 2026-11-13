USE Andreani
GO

-- Trazabilidad de un lote (RF08).
-- ¿Cuál es la ruta exacta de un lote específico, incluyendo qué medicamento es, cuánto se preparó,
-- en qué caja fue, en qué despacho viajó y quién lo recibió?
--
-- Devuelve una fila por cada preparación (y caja) en la que se usó el lote, con todo el recorrido:
-- Lote -> Producto -> Preparacion -> DetalleCaja -> Caja -> Despacho -> Vehiculo -> Entrega -> Destino.
-- Se usan LEFT JOIN desde la caja en adelante para que también aparezcan los lotes que todavía no
-- terminaron el recorrido (ej: preparado pero sin caja, o en caja pero sin despacho). En ese caso
-- las columnas que faltan quedan en NULL y la columna EtapaActual indica dónde está el lote.
-- "Quién lo recibió" es el destino del pedido (farmacia, clínica, hospital o droguería), y solo se
-- muestra en RecibidoPor cuando la entrega quedó como 'Entregada'.
--
-- Uso: SELECT * FROM fn_Trazabilidad_Lote(1)
CREATE FUNCTION fn_TrazabilidadLote (
    @IdLote INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        L.IdLote,
        PR.IdProducto,
        PR.NombreProducto AS Medicamento,
        PR.CategoriaProducto,
        L.FechaVencimiento,
        PRE.IdPreparacion,
        PRE.IdPedido,
        CL.NombreCliente AS Cliente,
        PRE.FechaPreparacion,
        PRE.CantidadPreparada,
        PRE.CumpleFEFO,
        C.IdCaja,
        C.CodigoBarra,
        DC.CantidadEmpacada,
        C.EstadoCaja,
        D.IdDespacho,
        D.FechaSalida,
        D.EstadoDespacho,
        V.Patente AS PatenteVehiculo,
        DE.NombreDestino AS Destino,
        DE.TipoDestino,
        DE.Direccion,
        DE.Ciudad,
        DE.Provincia,
        E.FechaEntregaReal,
        E.EstadoEntrega,
        E.LlegoFrio,
        CASE WHEN E.EstadoEntrega = 'Entregada' THEN DE.NombreDestino END AS RecibidoPor,
        CASE
            WHEN E.EstadoEntrega = 'Entregada' THEN 'ENTREGADO'
            WHEN E.EstadoEntrega = 'Rechazada' THEN 'RECHAZADO EN DESTINO'
            WHEN D.EstadoDespacho = 'En ruta' THEN 'EN VIAJE'
            WHEN D.IdDespacho IS NOT NULL THEN 'ASIGNADO A DESPACHO'
            WHEN C.IdCaja IS NOT NULL THEN 'EN CAJA'
            ELSE 'PREPARADO SIN CAJA'
        END AS EtapaActual
    FROM Lote AS L
    INNER JOIN Producto AS PR
        ON PR.IdProducto = L.IdProducto
    INNER JOIN Preparacion AS PRE
        ON PRE.IdLote = L.IdLote
    INNER JOIN Pedido AS P
        ON P.IdPedido = PRE.IdPedido
    INNER JOIN Cliente AS CL
        ON CL.IdCliente = P.IdCliente
    INNER JOIN Destino AS DE
        ON DE.IdDestino = P.IdDestino
    LEFT JOIN DetalleCaja AS DC
        ON DC.IdPreparacion = PRE.IdPreparacion
    LEFT JOIN Caja AS C
        ON C.IdCaja = DC.IdCaja
    LEFT JOIN Despacho AS D
        ON D.IdDespacho = C.IdDespacho
    LEFT JOIN Vehiculo AS V
        ON V.IdVehiculo = D.IdVehiculo
    LEFT JOIN Entrega AS E
        ON E.IdPedido = PRE.IdPedido
        AND E.IdDespacho = C.IdDespacho
    WHERE L.IdLote = @IdLote
)
GO
