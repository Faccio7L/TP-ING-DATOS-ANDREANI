USE Andreani
GO

CREATE TRIGGER trg_Despacho_Actualizar_Vehiculo
ON Despacho
AFTER INSERT
AS
BEGIN
    -- IN (SELECT ... FROM inserted): marca los vehiculos de todos los despachos insertados
    UPDATE Vehiculo
    SET Disponible = 0
    WHERE IdVehiculo IN (SELECT IdVehiculo FROM inserted)

    PRINT('VEHICULO ASIGNADO COMO NO DISPONIBLE')
END
GO
