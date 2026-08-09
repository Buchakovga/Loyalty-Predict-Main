select 
    dtref, 
    ciclo_vida,
    count(*) as qt_Clientes 
from 
    ciclo_vida
where 
    dtref = (select max(dtref) from ciclo_vida)
    
group by 
    dtref, 
    ciclo_vida

