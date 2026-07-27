

with pb_transacao as (
    select 
        * ,
        substr(dtcriacao,0, 11) as  dtDia,
        cast(substr(DtCriacao,12,2) as int) as hora_trn
    from 
        transacoes

    where dtcriacao < '2025-10-01'
), tb_agg_transacao as (
    select 
        IdCliente,


        max(julianday('2025-10-01') - julianday(DtCriacao) ) as IdadeDias,
        count(distinct dtDia) as QtDias_Ativacao_Vida,
        count(distinct case when dtDia > date('2025-10-01', '-7 day') then dtDia end ) as QtDias_Ativacao_7Dias,
        count(distinct case when dtDia > date('2025-10-01', '-14 day') then dtDia end ) as QtDias_Ativacao_14Dias,
        count(distinct case when dtDia > date('2025-10-01', '-28 day') then dtDia end ) as QtDias_Ativacao_28Dias,
        count(distinct case when dtDia > date('2025-10-01', '-56 day') then dtDia end ) as QtDias_Ativacao_56Dias    ,

        count(distinct IdTransacao) as Qt_Transacao_Vida,
        count(distinct case when IdTransacao > date('2025-10-01', '-7 day') then IdTransacao end ) as Qt_Transacao_7Dias,
        count(distinct case when IdTransacao > date('2025-10-01', '-14 day') then IdTransacao end ) as Qt_Transacao_14Dias,
        count(distinct case when IdTransacao > date('2025-10-01', '-28 day') then IdTransacao end ) as Qt_Transacao_28Dias,
        count(distinct case when IdTransacao > date('2025-10-01', '-56 day') then IdTransacao end ) as Qt_Transacao_56Dias  ,  

        sum(qtdePontos) as SaldoVida,
        sum(case when dtDia > date('2025-10-01', '-7 day') then qtdePontos else 0 end  ) as Saldo_7Dias,
        sum(case when dtDia > date('2025-10-01', '-14 day') then qtdePontos else 0 end ) as Saldo_14Dias,
        sum(case when dtDia > date('2025-10-01', '-28 day') then qtdePontos else 0 end ) as Saldo_28Dias,
        sum(case when dtDia > date('2025-10-01', '-56 day') then qtdePontos else 0 end ) as Saldo_56Dias ,   


        sum(case when qtdePontos > 0 then qtdePontos else 0 end ) as QtdePontos_Positivo_Vida,
        sum(distinct case when dtDia > date('2025-10-01', '-7 day')  and qtdePontos > 0  then qtdePontos else 0 end  ) as QtdePontos_Positivo_7Dias,
        sum(distinct case when dtDia > date('2025-10-01', '-14 day') and qtdePontos > 0  then qtdePontos else 0 end ) as QtdePontos_Positivo_14Dias,
        sum(distinct case when dtDia > date('2025-10-01', '-28 day') and qtdePontos > 0  then qtdePontos else 0 end ) as QtdePontos_Positivo_28Dias,
        sum(distinct case when dtDia > date('2025-10-01', '-56 day') and qtdePontos > 0  then qtdePontos else 0 end ) as QtdePontos_Positivo_56Dias ,   


        sum(case when qtdePontos < 0 then qtdePontos else 0 end ) as QtdePontos_Negativo_Vida,
        sum(distinct case when dtDia > date('2025-10-01', '-7 day')  and qtdePontos < 0  then qtdePontos else 0 end  ) as QtdePontos_Negativo_7Dias,
        sum(distinct case when dtDia > date('2025-10-01', '-14 day') and qtdePontos < 0  then qtdePontos else 0 end ) as QtdePontos_Negativo_14Dias,
        sum(distinct case when dtDia > date('2025-10-01', '-28 day') and qtdePontos < 0  then qtdePontos else 0 end ) as QtdePontos_Negativo_28Dias,
        sum(distinct case when dtDia > date('2025-10-01', '-56 day') and qtdePontos < 0  then qtdePontos else 0 end ) as QtdePontos_Negativo_56Dias ,   

        count(case when hora_trn between 10 and 14 then IdTransacao end ) as qt_trn_Manha,
        count(case when hora_trn between 15 and 21 then IdTransacao end ) as qt_trn_Tarde,        
        count(case when hora_trn > 21 or hora_trn < 10 then IdTransacao end ) as qt_trn_Noite     ,   

        1. * count(case when hora_trn between 10 and 14 then IdTransacao end ) / count(IdTransacao) as pct_trn_Manha,
        1. * count(case when hora_trn between 15 and 21 then IdTransacao end ) / count(IdTransacao) as pct_trn_Tarde,        
        1. * count(case when hora_trn > 21 or hora_trn < 10 then IdTransacao end ) / count(IdTransacao) as pct_trn_Noite 
        


    from 
        pb_transacao
    group by IdCliente

), tb_agg_calculado as (
    select 
        *,
        coalesce(1. * Qt_Transacao_Vida /  QtDias_Ativacao_Vida,0) as qtd_Trn_Dia_Vida,
        coalesce(1. * Qt_Transacao_7Dias / QtDias_Ativacao_7Dias,0) as qtd_Trn_Dia_7dias,
        coalesce(1. * Qt_Transacao_14Dias / QtDias_Ativacao_14Dias,0) as qtd_Trn_Dia_14dias,
        coalesce(1. * Qt_Transacao_28Dias / QtDias_Ativacao_28Dias,0) as qtd_Trn_Dia_28dias,
        coalesce(1. * Qt_Transacao_56Dias / QtDias_Ativacao_56Dias,0) as qtd_Trn_Dia_56dias,
        coalesce(1. * QtDias_Ativacao_28Dias / 28,0) as Pct_Ativacao_Mau

    from 
        tb_agg_transacao
), tb_horas_dias as (

select 
    idCliente,
    dtDia, 
    ((24 * 60 ) / 60) * (max(julianday(DtCriacao)) - min(julianday(DtCriacao))) as Duracao
    
from 
    pb_transacao
group by idCliente,
        dtDia
), tb_hora_cliente as (

select 
    idCliente,
    sum(duracao)  as qt_horas_vida,
    sum(case when dtdia >= date('2025-10-01', '-7 day') then duracao else 0 end )  as qt_horas_vida_7dias,
    sum(case when dtdia >= date('2025-10-01', '-14 day') then duracao else 0 end )  as qt_horas_vida_14dias,
    sum(case when dtdia >= date('2025-10-01', '-28 day') then duracao else 0 end )  as qt_horas_vida_28dias,
    sum(case when dtdia >= date('2025-10-01', '-56 day') then duracao else 0 end )  as qt_horas_vida_56dias

from 
    tb_horas_dias
group by idCliente

), tb_lag_dia as (

select 
    idCliente,
    dtdia,
    lag(dtdia) over (PARTITION BY idCliente ORDER BY dtdia) as lagdia
    
 from 
    tb_horas_dias

), tb_intervalo as ( 

select 
    idCliente,
    avg(julianday(dtdia) - julianday(lagdia)) as MediaIntervaloDias_Vida,
    avg(case when dtdia >= date('2025-10-01', '-28 day') then  julianday(dtdia) - julianday(lagdia) else 0 end ) as MediaIntervaloDias_28dias
from 
    tb_lag_dia
GROUP BY 
    idCliente

), tb_share_prod as (

select 

    idCliente,
    1. * count( case when DescNomeProduto= 'ChatMessage'       then a.IdTransacao end ) / count(a.IdTransacao) as qtdeChatMessage,
    1. * count( case when DescNomeProduto= 'Airflow Lover'     then a.IdTransacao end ) / count(a.IdTransacao) as qtdeAirflow,
    1. * count( case when DescNomeProduto= 'R Lover'           then a.IdTransacao end ) / count(a.IdTransacao) as qtdeLover,
    1. * count( case when DescNomeProduto= 'Resgatar Ponei'    then a.IdTransacao end ) / count(a.IdTransacao) as qtdeResgatarPonei,
    1. * count( case when DescNomeProduto= 'Lista de presença' then a.IdTransacao end ) / count(a.IdTransacao) as qtdeLista,
    1. * count( case when DescNomeProduto= 'Presença Streak'   then a.IdTransacao end ) / count(a.IdTransacao) as qtdeStreak,
    1. * count( case when DescNomeProduto= 'Troca de Pontos StreamElements'           then a.IdTransacao end ) / count(a.IdTransacao) as qtdeStreamElements,
    1. * count( case when DescNomeProduto= 'Reembolso: Troca de Pontos StreamElements' then a.IdTransacao end ) / count(a.IdTransacao) as qtdeReembolsoStreamElements,
    1. * count( case when DescCategoriaProduto='rpg' then a.IdTransacao end ) / count(a.IdTransacao) as qtdeRPG,
    1. * count( case when DescCategoriaProduto='churn_model' then a.IdTransacao end ) / count(a.IdTransacao) as qtdechurn
    

from 
    pb_transacao a 

    left join transacao_produto b 
        on a.IdTransacao = b.IdTransacao

    left join produtos c 
        on c.IdProduto = b.IdProduto
        
group by idCliente
),  tb_join_tudo as (

select 
    a.*,
    c.qt_horas_vida,
    c.qt_horas_vida_7dias,
    c.qt_horas_vida_14dias,
    c.qt_horas_vida_28dias,
    c.qt_horas_vida_56dias,
    b.MediaIntervaloDias_Vida,
    b.MediaIntervaloDias_28dias,
    d.qtdeChatMessage,
    d.qtdeAirflow,
    d.qtdeLover,
    d.qtdeResgatarPonei,
    d.qtdeLista,
    d.qtdeStreak,
    d.qtdeStreamElements,
    d.qtdeReembolsoStreamElements,
    d.qtdeRPG,
    d.qtdechurn

from
    tb_agg_calculado a 

    left join tb_intervalo b 
        on a.idCliente = b.idCliente 
    

    left join tb_hora_cliente c 
        on a.idCliente = c.idCliente
    
    left join tb_share_prod d 
        on a.idCliente = d.idCliente
) 

select 
    date('2025-10-01', '-1 day') as dtref,
    *
 from 
    tb_join_tudo
