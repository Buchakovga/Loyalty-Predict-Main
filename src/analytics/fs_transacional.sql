

with pb_transacao as (
    select 
        * ,
        substr(dtcriacao,0, 11) as  dtDia
    from 
        transacoes

    where dtcriacao < '2025-10-01'
), tb_agg_transacao as (
    select 
        IdCliente,

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
        sum(distinct case when dtDia > date('2025-10-01', '-56 day') and qtdePontos < 0  then qtdePontos else 0 end ) as QtdePontos_Negativo_56Dias    




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

)
select * from tb_hora_cliente 



