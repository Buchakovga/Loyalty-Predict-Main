

with tb_join as (
    select 
        a.dtref,
        a.idCliente,
        a.ciclo_vida,
        b.ciclo_vida,

        case 
            when b.ciclo_vida = '02-Fiel' then 1 else 0 end as flFiel,
        ROW_NUMBER() over (PARTITION BY a.idCliente ORDER BY random() ) as random_row 

    from 
        ciclo_vida a 

        left join ciclo_vida b 
            on a.idCliente = b.idCliente and
            date(a.dtref,  '+28 day') = date(b.dtref)

    where
        (a.dtref <= '2025-08-01' or  a.dtref = '2025-09-01')   and 
        a.ciclo_vida <> '05-Zumbi'
 
  ), tb_cohort as (
   select 
         a.dtref,
         a.idCliente, 
         a.flFiel
   from 
        tb_join  a
   where 
        random_row <= 2 
   order by 
        idCliente, dtref 
)
select 
    a.*
from 
    tb_cohort  a

    left join fs_transacional b
        on a.idCliente = b.idCliente and 
           sqlia.dtref = b.dtref 

limit 10 