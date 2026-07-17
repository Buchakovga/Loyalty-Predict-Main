select 
    idcliente,
    count(distinct substr(dtcriacao,0,11)) as qt_Freq_28_dias,
    sum(case when QtdePontos > 0 then QtdePontos else 0 end) as qt_Pontos_28_dias
    
from 
    transacoes 

where 
    dtcriacao < '2025-09-01'
    and dtcriacao > date('2025-09-01' , '-28 day') 
group by idcliente
order by dtcriacao desc
