USE Andreani
GO

CREATE TRIGGER trg_Despacho_Actualizar_Vehiculo
ON Despacho
AFTER INSERT
AS
BEGIN
    DECLARE @IdVehiculo INT
    SELECT @IdVehiculo = IdVehiculo FROM inserted

    UPDATE Vehiculo
    SET Disponible = 0
    WHERE IdVehiculo = @IdVehiculo
    PRINT('VEHICULO ASIGNADO COMO NO DISPONIBLE')
END
