select 
    substr(DtCriacao,0,11) as dt_Dia,
    count(distinct idCliente)  as DAU
from 
    transacoes
group by 1
order by dt_Dia desc 
