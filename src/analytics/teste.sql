select 
    dtref,
    ciclo_vida,
    cluster,
    count(idCliente) as qt_Clientes
from 
    ciclo_vida
group by dtref,
         ciclo_vida,
         cluster
order by dtref 

