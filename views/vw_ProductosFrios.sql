CREATE VIEW vw_ProductosFrios AS
SELECT P.IdProducto,
       P.NombreProducto,
       P.CategoriaProducto
FROM Producto AS P
WHERE P.RequiereRefrigeracion = 1;
GO
