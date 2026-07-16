
with tb_diaria as (
    select distinct 
        substr(DtCriacao,0,11) as dt_dia,
        idCliente
    from 
        transacoes
    order by dt_dia
), tb_dias_distintos as (
select 
    distinct dt_dia as dt_ref  
    from 
      tb_diaria
)

select 
    a.dt_ref,
    count(distinct idCliente ) as mau ,
    count(distinct b.dt_dia) as qt_dias 
from 
    tb_dias_distintos a 

    left join tb_diaria b 
        on  b.dt_dia <= a.dt_ref
        and julianday(a.dt_ref) - julianday(b.dt_dia) < 28
group by a.dt_ref

order by a.dt_ref desc 

