USE andreani
GO
--TRANSACCIÓN: SALIDA DE UN DESPACHO (RF06).
--CUANDO EL VEHÍCULO SALE DEL CENTRO DE DISTRIBUCIÓN SE REGISTRA LA FECHA Y HORA DE SALIDA Y SE ACTUALIZAN
--LOS ESTADOS DE TODO LO QUE VIAJA EN ÉL: EL DESPACHO PASA A 'En ruta', SUS CAJAS A 'Despachada' Y LOS
--PEDIDOS QUE SE ENTREGAN EN ESE DESPACHO A 'Despachado'.
--SE USA DESPUÉS DE sp_AsignarVehiculoDespacho (QUE CREA EL DESPACHO Y LE ASIGNA LAS CAJAS).
--
--TABLAS QUE MODIFICA: DESPACHO (UPDATE), CAJA (UPDATE), PEDIDO (UPDATE).
--SI CUALQUIER PASO FALLA, EL CATCH HACE ROLLBACK Y NO QUEDAN ESTADOS MEZCLADOS
--(EJ: DESPACHO EN RUTA CON CAJAS QUE SIGUEN FIGURANDO COMO ARMADAS).
--
--USO: EXEC sp_IniciarDespacho @IdDespacho = 1                -- sale ahora
--     EXEC sp_IniciarDespacho @IdDespacho = 1, @FechaSalida = '2026-11-10 08:30'
CREATE PROCEDURE sp_IniciarDespacho
    @IdDespacho int,
    @FechaSalida datetime = NULL
AS
BEGIN
    DECLARE @EstadoDespacho varchar(20);

    BEGIN TRY
        SELECT @EstadoDespacho = EstadoDespacho
        FROM DESPACHO
        WHERE IdDespacho = @IdDespacho;

        -- Validación por si el despacho no existe
        IF @EstadoDespacho IS NULL
            THROW 50020, 'El despacho no existe.', 1;

        IF @EstadoDespacho <> 'Programado'
            THROW 50021, 'Solo puede salir un despacho que esté en estado Programado.', 1;

        IF NOT EXISTS (SELECT 1 FROM CAJA WHERE IdDespacho = @IdDespacho)
            THROW 50022, 'El despacho no tiene cajas asignadas.', 1;

        BEGIN TRANSACTION;

            -- 1) El despacho sale: se registra la hora real de salida
            UPDATE DESPACHO
            SET EstadoDespacho = 'En ruta',
                FechaSalida = ISNULL(@FechaSalida, GETDATE())
            WHERE IdDespacho = @IdDespacho;

            -- 2) Las cajas que viajan en el despacho pasan a 'Despachada'
            UPDATE CAJA
            SET EstadoCaja = 'Despachada'
            WHERE IdDespacho = @IdDespacho;

            -- 3) Los pedidos que se entregan en este despacho pasan a 'Despachado'
            UPDATE PEDIDO
            SET EstadoPedido = 'Despachado'
            WHERE IdPedido IN (SELECT IdPedido FROM ENTREGA WHERE IdDespacho = @IdDespacho);

        COMMIT TRANSACTION;
        PRINT 'El despacho ' + CAST(@IdDespacho AS varchar(10)) + ' salió correctamente.';
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;
        PRINT 'No se pudo iniciar el despacho. Error: ' + ERROR_MESSAGE();
        THROW;
    END CATCH
END;
GO
