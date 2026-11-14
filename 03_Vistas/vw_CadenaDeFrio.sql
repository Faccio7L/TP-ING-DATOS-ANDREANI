USE Andreani
GO

-- Cuantas entregas de pedidos refrigerados perdieron la cadena de frio
CREATE VIEW vw_CadenaDeFrio AS
SELECT(
        -- LlegoFrio solo se carga en pedidos refrigerados (en el resto queda NULL)
        SELECT COUNT(IdEntrega)
        FROM Entrega
        WHERE LlegoFrio IS NOT NULL
    ) AS EntregasRefrigeradas,
    (
        -- LlegoFrio = 0: llego sin mantener la cadena de frio
        SELECT COUNT(IdEntrega)
        FROM Entrega
        WHERE LlegoFrio = 0
    ) AS EntregasSinFrio,
    (
        -- Porcentaje = sin frio * 100 / refrigeradas (NULLIF evita dividir por cero)
        (
            SELECT COUNT(IdEntrega)
            FROM Entrega
            WHERE LlegoFrio = 0
        ) * 100.0
    ) / NULLIF((SELECT COUNT(IdEntrega) FROM Entrega WHERE LlegoFrio IS NOT NULL), 0) AS PorcentajeSinFrio;
GO
