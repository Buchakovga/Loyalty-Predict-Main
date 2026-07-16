

select dtRef, 
        ciclo_vida,
        count(idCliente) as qt_cli from ciclo_vida
group by 1,2
order by 1,2



