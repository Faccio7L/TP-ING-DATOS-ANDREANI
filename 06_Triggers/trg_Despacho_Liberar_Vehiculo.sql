USE Andreani
GO

CREATE TRIGGER trg_Despacho_Liberar_Vehiculo
ON Despacho
AFTER UPDATE
AS
BEGIN
    -- Cuando un despacho pasa a 'Finalizado', su vehiculo vuelve a estar disponible
    UPDATE Vehiculo
    SET Disponible = 1
    -- inserted trae los despachos como quedaron despues del UPDATE
    WHERE IdVehiculo IN (SELECT IdVehiculo FROM inserted WHERE EstadoDespacho = 'Finalizado')
        -- No se libera si el vehiculo tiene otro despacho todavia abierto
        AND IdVehiculo NOT IN (SELECT IdVehiculo FROM Despacho WHERE EstadoDespacho <> 'Finalizado')
END
GO
