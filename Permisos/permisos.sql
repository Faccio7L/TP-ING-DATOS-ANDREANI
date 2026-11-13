USE Andreani
GO

CREATE LOGIN AdminLogin WITH PASSWORD = 'IngDeDatos1' -- Si la contraseña es muy fácil tira error.
GO
CREATE USER AdminUser FOR LOGIN AdminLogin
GO
ALTER ROLE db_owner ADD MEMBER AdminUser
GO

CREATE LOGIN EmpleadoLogisticaLogin WITH PASSWORD = 'IngDeDatos1'
GO
CREATE USER EmpleadoLogisticaUser FOR LOGIN EmpleadoLogisticaLogin
GO
ALTER ROLE db_datawriter ADD MEMBER EmpleadoLogisticaUser
GO
ALTER ROLE db_datareader ADD MEMBER EmpleadoLogisticaUser
