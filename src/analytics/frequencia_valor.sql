
with freq_valor as (

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

), segmentacao as (

select 
    * ,
    case 
        when qt_Freq_28_dias <= 10 and qt_Pontos_28_dias >= 1500 then "12-HYPERS"
        when qt_Freq_28_dias > 10 and qt_Pontos_28_dias >= 1500 then "22-EFICIENTES"
        when qt_Freq_28_dias <= 10 and qt_Pontos_28_dias >= 750 then "11-INDECISO"
        when qt_Freq_28_dias > 10 and qt_Pontos_28_dias >= 750 then "21-ESFORÇADO"        
        when qt_Freq_28_dias < 5 then "00-LURKER"        
        when qt_Freq_28_dias <= 10 then "01-PREGUIÇOSO"        
        when qt_Freq_28_dias > 10 then "20-POTENCIAL" 
    end as cluster        

from 
    freq_valor   


) 
select *  from segmentacao



