-- 1. Cria uma tabela física temporária com os dados diários limpos
DROP TABLE IF EXISTS temp_diario;

CREATE TABLE temp_diario AS 
SELECT DISTINCT 
    idCliente,
    date(DtCriacao) AS dt_dia
FROM 
    transacoes
where DtCriacao < '2025-09-30';

-- 2. Cria um índice nessa tabela temporária (isso vai fazer a query voar!)
CREATE INDEX idx_temp_diario ON temp_diario(idCliente, dt_dia DESC);

WITH tb_rn AS (
    SELECT 
        idCliente,
        dt_dia,
        ROW_NUMBER() OVER (PARTITION BY idCliente ORDER BY dt_dia DESC) as rn_dia
    FROM 
        temp_diario
), 
tb_idade AS (
    SELECT 
        idCliente,
        CAST(max(julianday('now') - julianday(dt_dia)) as int) as qtdias_primeira_transacao,
        CAST(min(julianday('now') - julianday(dt_dia)) as int) as qtdias_ultima_transacao
    FROM 
        temp_diario
    GROUP BY 
        idCliente
), 
tb_penultima_tran AS (
    SELECT 
        idCliente,
        CAST(min(julianday('now') - julianday(dt_dia)) as int) as qtdias_penultima_transacao
    FROM 
        tb_rn
    WHERE 
        rn_dia = 2
    GROUP BY 
        idCliente
)
    SELECT 
        date('2025-09-30', '-1 day') as dtRef,
        a.*,
        b.qtdias_penultima_transacao,
        CASE    
            WHEN qtdias_primeira_transacao < 7 then '01-Curioso'
            WHEN qtdias_ultima_transacao <= 7 and (qtdias_penultima_transacao-qtdias_ultima_transacao) <= 14 then '02-Fiel'
            WHEN qtdias_ultima_transacao between 8 and 14 then '03-Turista'
            WHEN qtdias_ultima_transacao between 15 and 28 then '04-Desencantada'        
            WHEN qtdias_ultima_transacao > 28 then '05-Zumbi'        
            WHEN qtdias_ultima_transacao <= 7 and (qtdias_penultima_transacao-qtdias_ultima_transacao) between 15 and 28 then '06-Reconquistado'                
            WHEN qtdias_ultima_transacao <= 7 and (qtdias_penultima_transacao-qtdias_ultima_transacao) > 28 then '07-Reborn'                        
        END as ciclo_vida
    FROM 
        tb_idade a 
        
    LEFT JOIN tb_penultima_tran b 
        ON a.idCliente = b.idCliente;