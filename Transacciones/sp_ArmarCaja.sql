USE andreani
GO
--TRANSACCIÓN: ARMADO DE CAJA / CONSOLIDACIÓN (RF05).
--TOMA LAS PREPARACIONES DE UN PEDIDO QUE TODAVÍA NO ESTÁN EN NINGUNA CAJA, CREA UNA CAJA NUEVA PARA EL
--DESTINO DEL PEDIDO, CARGA EL DETALLE DE LA CAJA Y ACTUALIZA EL ESTADO DEL PEDIDO.
--SOLO SE EMPACAN LAS PREPARACIONES QUE CUMPLEN FEFO (LAS QUE NO LO CUMPLEN SON ERRORES DE VALIDACIÓN).
--LA CANTIDAD EMPACADA ES LA CANTIDAD PREPARADA, ASÍ NUNCA LA SUPERA.
--
--TABLAS QUE MODIFICA: CAJA (INSERT), DETALLECAJA (INSERT), PEDIDO (UPDATE).
--SI CUALQUIER PASO FALLA, EL CATCH HACE ROLLBACK Y NO QUEDA NADA A MEDIAS (EJ: UNA CAJA SIN DETALLE).
--
--USO: EXEC sp_ArmarCaja @IdPedido = 1, @CodigoBarra = 'CAJA-0001'
CREATE PROCEDURE sp_ArmarCaja
    @IdPedido int,
    @CodigoBarra varchar(50)
AS
BEGIN
    DECLARE @IdDestino int;
    DECLARE @EstadoPedido varchar(20);
    DECLARE @IdCaja int;

    BEGIN TRY
        SELECT @IdDestino = IdDestino, @EstadoPedido = EstadoPedido
        FROM PEDIDO
        WHERE IdPedido = @IdPedido;

        -- Validación por si el pedido no existe
        IF @IdDestino IS NULL
            THROW 50010, 'El pedido no existe.', 1;

        IF @EstadoPedido IN ('Despachado', 'Entregado', 'Rechazado', 'Cancelado')
            THROW 50011, 'El pedido ya no se puede empacar por su estado actual.', 1;

        IF EXISTS (SELECT 1 FROM CAJA WHERE CodigoBarra = @CodigoBarra)
            THROW 50012, 'Ya existe una caja con ese código de barras.', 1;

        -- Tiene que haber al menos una preparación válida (cumple FEFO) que no esté en otra caja
        IF NOT EXISTS (SELECT 1
                       FROM PREPARACION pr
                       WHERE pr.IdPedido = @IdPedido
                         AND pr.CumpleFEFO = 1
                         AND NOT EXISTS (SELECT 1 FROM DETALLECAJA dc WHERE dc.IdPreparacion = pr.IdPreparacion))
            THROW 50013, 'El pedido no tiene preparaciones válidas pendientes de empacar.', 1;

        BEGIN TRANSACTION;

            -- 1) Se crea la caja para el destino del pedido
            INSERT INTO CAJA (CodigoBarra, IdDestino, EstadoCaja)
            VALUES (@CodigoBarra, @IdDestino, 'Armada');

            SET @IdCaja = SCOPE_IDENTITY();

            -- 2) Se cargan en la caja las preparaciones válidas que todavía no tienen caja
            INSERT INTO DETALLECAJA (IdCaja, IdPreparacion, CantidadEmpacada)
            SELECT @IdCaja, pr.IdPreparacion, pr.CantidadPreparada
            FROM PREPARACION pr
            WHERE pr.IdPedido = @IdPedido
              AND pr.CumpleFEFO = 1
              AND NOT EXISTS (SELECT 1 FROM DETALLECAJA dc WHERE dc.IdPreparacion = pr.IdPreparacion);

            -- 3) Si todos los productos del pedido ya tienen empacada la cantidad solicitada el pedido
            --    queda 'Preparado'; si falta alguno queda 'En preparación'
            UPDATE PEDIDO
            SET EstadoPedido = CASE
                    WHEN EXISTS (SELECT 1
                                 FROM DETALLEPEDIDO dp
                                 WHERE dp.IdPedido = @IdPedido
                                   AND dp.CantidadSolicitada > (SELECT ISNULL(SUM(dc.CantidadEmpacada), 0)
                                                                FROM DETALLECAJA dc
                                                                JOIN PREPARACION pr ON pr.IdPreparacion = dc.IdPreparacion
                                                                WHERE pr.IdPedido = dp.IdPedido
                                                                  AND pr.IdProducto = dp.IdProducto))
                    THEN 'En preparación'
                    ELSE 'Preparado'
                END
            WHERE IdPedido = @IdPedido;

        COMMIT TRANSACTION;
        PRINT 'Caja ' + CAST(@IdCaja AS varchar(10)) + ' armada correctamente para el pedido ' + CAST(@IdPedido AS varchar(10)) + '.';
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;
        PRINT 'No se armó la caja. Error: ' + ERROR_MESSAGE();
        THROW;
    END CATCH
END;
GO
