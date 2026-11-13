USE Andreani;
GO
--Pruba pedido con fecha pasada (lo frena el trigger)
BEGIN TRAN;
    SELECT COUNT(*) AS PedidosAntes FROM Pedido;

    INSERT INTO Pedido (IdCliente, IdDestino, FechaEntregaSolicitada)
    VALUES (1, 1, '2020-01-01');   -- fecha pasada

    SELECT COUNT(*) AS PedidosDespues FROM Pedido;   -- tiene que dar lo mismo que antes
ROLLBACK;