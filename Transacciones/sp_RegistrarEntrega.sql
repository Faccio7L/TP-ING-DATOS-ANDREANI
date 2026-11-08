USE andreani
GO
--TRANSACCIÓN: REGISTRO DE LA ENTREGA (RF07).
--REGISTRA LA FECHA Y HORA REAL DE ENTREGA, EL RESULTADO ('Entregada' O 'Rechazada') Y SI LLEGÓ EN FRÍO,
--Y ACTUALIZA EN CADENA EL RESTO DE LAS TABLAS:
--  - EL PEDIDO PASA A 'Entregado' O 'Rechazado'.
--  - LAS CAJAS DE ESE PEDIDO PASAN A 'Entregada' O 'Rechazada'.
--  - SI YA NO QUEDAN ENTREGAS PENDIENTES EN EL DESPACHO, EL DESPACHO PASA A 'Finalizado' Y EL VEHÍCULO
--    VUELVE A ESTAR DISPONIBLE (RDI07).
--VALIDA QUE LA FECHA REAL NO SEA ANTERIOR A LA FECHA DEL PEDIDO (RDI05) Y QUE, SI EL PEDIDO LLEVA
--PRODUCTOS REFRIGERADOS, SE INDIQUE SI LLEGÓ EN FRÍO.
--
--TABLAS QUE MODIFICA: ENTREGA, PEDIDO, CAJA, DESPACHO Y VEHICULO (TODAS UPDATE).
--SI CUALQUIER PASO FALLA, EL CATCH HACE ROLLBACK (EJ: NO PUEDE QUEDAR LA ENTREGA REGISTRADA CON EL
--PEDIDO TODAVÍA 'Despachado', NI EL DESPACHO FINALIZADO CON EL VEHÍCULO NO DISPONIBLE).
--
--USO: EXEC sp_RegistrarEntrega @IdPedido = 1, @FechaEntregaReal = '2026-11-12 14:00', @EstadoEntrega = 'Entregada', @LlegoFrio = 1
CREATE PROCEDURE sp_RegistrarEntrega
    @IdPedido int,
    @FechaEntregaReal datetime,
    @EstadoEntrega varchar(20),   -- 'Entregada' o 'Rechazada'
    @LlegoFrio bit = NULL         -- 1 llegó en frío, 0 no llegó en frío, NULL si el pedido no lleva productos refrigerados
AS
BEGIN
    DECLARE @FechaPedido datetime;
    DECLARE @IdEntrega int;
    DECLARE @IdDespacho int;
    DECLARE @IdVehiculo int;
    DECLARE @EstadoDespacho varchar(20);

    BEGIN TRY
        IF @EstadoEntrega NOT IN ('Entregada', 'Rechazada')
            THROW 50030, 'El estado de la entrega tiene que ser Entregada o Rechazada.', 1;

        SELECT @FechaPedido = FechaPedido
        FROM PEDIDO
        WHERE IdPedido = @IdPedido;

        -- Validación por si el pedido no existe
        IF @FechaPedido IS NULL
            THROW 50031, 'El pedido no existe.', 1;

        IF @FechaEntregaReal IS NULL OR @FechaEntregaReal < @FechaPedido
            THROW 50032, 'La fecha real de entrega no puede ser anterior a la fecha del pedido.', 1;

        -- Se busca la entrega pendiente del pedido y el despacho/vehículo en el que viaja
        SELECT @IdEntrega = e.IdEntrega,
               @IdDespacho = e.IdDespacho,
               @IdVehiculo = d.IdVehiculo,
               @EstadoDespacho = d.EstadoDespacho
        FROM ENTREGA e
        JOIN DESPACHO d ON d.IdDespacho = e.IdDespacho
        WHERE e.IdPedido = @IdPedido
          AND e.EstadoEntrega = 'Pendiente';

        IF @IdEntrega IS NULL
            THROW 50033, 'El pedido no tiene una entrega pendiente.', 1;

        IF @EstadoDespacho <> 'En ruta'
            THROW 50034, 'El despacho del pedido todavía no salió (tiene que estar En ruta).', 1;

        IF @LlegoFrio IS NULL
           AND EXISTS (SELECT 1
                       FROM DETALLEPEDIDO dp
                       JOIN PRODUCTO p ON p.IdProducto = dp.IdProducto
                       WHERE dp.IdPedido = @IdPedido
                         AND p.RequiereRefrigeracion = 1)
            THROW 50035, 'El pedido tiene productos refrigerados: hay que indicar si llegó en frío.', 1;

        BEGIN TRANSACTION;

            -- 1) Se registra la entrega
            UPDATE ENTREGA
            SET FechaEntregaReal = @FechaEntregaReal,
                EstadoEntrega = @EstadoEntrega,
                LlegoFrio = @LlegoFrio
            WHERE IdEntrega = @IdEntrega;

            -- 2) Se actualiza el estado del pedido
            UPDATE PEDIDO
            SET EstadoPedido = CASE WHEN @EstadoEntrega = 'Entregada' THEN 'Entregado' ELSE 'Rechazado' END
            WHERE IdPedido = @IdPedido;

            -- 3) Se actualizan las cajas del pedido que viajaron en ese despacho
            UPDATE CAJA
            SET EstadoCaja = CASE WHEN @EstadoEntrega = 'Entregada' THEN 'Entregada' ELSE 'Rechazada' END
            WHERE IdDespacho = @IdDespacho
              AND IdCaja IN (SELECT dc.IdCaja
                             FROM DETALLECAJA dc
                             JOIN PREPARACION pr ON pr.IdPreparacion = dc.IdPreparacion
                             WHERE pr.IdPedido = @IdPedido);

            -- 4) Si no quedan entregas pendientes en el despacho, se finaliza y se libera el vehículo
            IF NOT EXISTS (SELECT 1 FROM ENTREGA WHERE IdDespacho = @IdDespacho AND EstadoEntrega = 'Pendiente')
            BEGIN
                UPDATE DESPACHO
                SET EstadoDespacho = 'Finalizado'
                WHERE IdDespacho = @IdDespacho;

                UPDATE VEHICULO
                SET Disponible = 1
                WHERE IdVehiculo = @IdVehiculo;

                PRINT 'Despacho ' + CAST(@IdDespacho AS varchar(10)) + ' finalizado. El vehículo vuelve a estar disponible.';
            END

        COMMIT TRANSACTION;
        PRINT 'Entrega del pedido ' + CAST(@IdPedido AS varchar(10)) + ' registrada como ' + @EstadoEntrega + '.';
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;
        PRINT 'No se registró la entrega. Error: ' + ERROR_MESSAGE();
        THROW;
    END CATCH
END;
GO
