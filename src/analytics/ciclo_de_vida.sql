/*

    Curiosa......: Idade menor que 7
    Fiel.........: recencia < 7 e recencia anterior < 15 
    turista......: recencia >=7  e recencia <= 14 
    desencantado.: recencia <= 28
    zumbi........: recencia > 28
    reconquistado: recencia < 7 e (recencia anterior >= 14 e recencia anterior <= 28)
    reborn.......: recencia < 7 e recencia anterior < 28)


*/

with tb_diario as (
    select 
        distinct 
        idCliente,
        substr(DtCriacao,0,11) as dt_dia
    from 
        transacoes
    where DtCriacao < '{date}'
   
), tb_idade as (
select 
    idCliente,
    --min(dt_dia) as dtPrimeiraTransacao,
    cast(max(julianday('{date}') - julianday(dt_dia)) as int) as qtdias_primeira_transacao,
    --max(dt_dia) as dtUltimaTransacao,
    cast(min(julianday('{date}') - julianday(dt_dia)) as int) as qtdias_ultima_transacao
from 
    tb_diario
   
group by idCliente

) , tb_rn as (
select 
    *,
    row_number() over (PARTITION by idCliente order by dt_dia desc ) as  rn_dia
from 
    tb_diario
), tb_penultima_tran as (
    select 
        idCliente,
        dt_dia,
        cast(min(julianday('{date}') - julianday(dt_dia)) as int) as qtdias_penultima_transacao
    from 
        tb_rn
    where rn_dia = 2
    group by idCliente

)

, tb_ciclo_vida_cluster as (

select 
    a.* ,
    b.qtdias_penultima_transacao as qtdias_penultima_transacao,
    case    
        when qtdias_primeira_transacao <= 7 then '01-Curioso'
        when qtdias_ultima_transacao <= 7 and (qtdias_penultima_transacao-qtdias_ultima_transacao) <= 14 then '02-Fiel'
        when qtdias_ultima_transacao between 8 and 14 then '03-Turista'
        when qtdias_ultima_transacao between 15 and 28 then '04-Desencantada'        
        when qtdias_ultima_transacao > 28 then '05-Zumbi'        
        when qtdias_ultima_transacao <= 7 and  (qtdias_penultima_transacao-qtdias_ultima_transacao) between 15 and 28 then '06-Reconquistado'                
        when qtdias_ultima_transacao <= 7 and  (qtdias_penultima_transacao-qtdias_ultima_transacao) > 28 then '07-Reborn'                        
    end as ciclo_vida

    from 
        tb_idade a 

    left join tb_penultima_tran b 
        on a.idCliente = b.idCliente

)
select 
    date('{date}', '-1 day') as dtRef,
    *
from 
    tb_ciclo_vida_cluster 

  