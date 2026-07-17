select 
    dtref,
    ciclo_vida,
    cluster,
    count(*) as qt_Clientes
 from 
    ciclo_vida
group by 
    dtref,
    ciclo_vida,
    cluster
