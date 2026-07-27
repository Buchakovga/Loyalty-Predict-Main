

with ciclo_vida_atual as (
    select 
        idCliente,
        qt_Freq_28_dias,
        ciclo_vida as Ciclo_Vida_Atual
        
    from 
        ciclo_vida
    where 
        dtref = date('2025-10-01', '-1 day')
), ciclo_vida_d28 as (

    select 
        idCliente,
        ciclo_vida as Ciclo_Vida_D28        
    from 
        ciclo_vida
    where 
        dtref = date('2025-10-01', '-29 day')

), tb_share_ciclos as (
select
    idCliente,
    1. * sum(case when ciclo_vida = '01-Curioso' then 1 else 0 end ) / count(*) as pct_Curioso,
    1. * sum(case when ciclo_vida = '04-Desencantada' then 1 else 0 end ) / count(*) as pct_Desencantada ,
    1. * sum(case when ciclo_vida = '02-Fiel' then 1 else 0 end ) / count(*) as pct_Fiel ,
    1. * sum(case when ciclo_vida = '05-Zumbi' then 1 else 0 end ) / count(*) as pct_Zumbi, 
    1. * sum(case when ciclo_vida = '03-Turista' then 1 else 0 end ) / count(*) as pct_Turista ,
    1. * sum(case when ciclo_vida = '06-Reconquistado' then 1 else 0 end ) / count(*) as pct_Reconquista ,
    1. * sum(case when ciclo_vida = '07-Reborn' then 1 else 0 end ) / count(*) as pct_Reborn 

     
from 
    ciclo_vida
where dtref < '2025-10-01'

group by idCliente

), tb_avg_ciclo as (

select 
    Ciclo_Vida_Atual,
    avg(qt_Freq_28_dias) as Qtde_Frequencia_grupo
from 
    ciclo_vida_atual  
group by Ciclo_Vida_Atual

), tb_join as (
    select 
        a.idCliente,
        a.qt_Freq_28_dias,
        a.Ciclo_Vida_Atual,
        b.Ciclo_Vida_D28,
        c.pct_Curioso,
        c.pct_Desencantada ,
        c.pct_Fiel ,
        c.pct_Zumbi, 
        c.pct_Turista ,
        c.pct_Reconquista ,
        c.pct_Reborn ,
        d.Qtde_Frequencia_Grupo,
        (a.qt_Freq_28_dias / d.Qtde_Frequencia_Grupo) as ratio_freq_Grupo


    from 
        ciclo_vida_atual a 

        left join ciclo_vida_d28 b 
            on a.idCliente = b.idCliente

        left join tb_share_ciclos c
             on a.idCliente = c.idCliente

        left join tb_avg_ciclo d
            on a.Ciclo_Vida_Atual = d.ciclo_vida_atual             

)
select 
     date('2025-10-01', '-1 day') as dtref,
     * 
from 
    tb_join
