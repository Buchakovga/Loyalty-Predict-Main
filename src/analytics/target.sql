


drop table if exists abt_fiel;

create table if not exists abt_fiel as 

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
        a.*,
        b.IdadeDias ,
        b.QtDias_Ativacao_Vida ,
        b.QtDias_Ativacao_7Dias ,
        b.QtDias_Ativacao_14Dias ,
        b.QtDias_Ativacao_28Dias ,
        b.QtDias_Ativacao_56Dias ,
        b.Qt_Transacao_Vida ,
        b.Qt_Transacao_7Dias ,
        b.Qt_Transacao_14Dias ,
        b.Qt_Transacao_28Dias ,
        b.Qt_Transacao_56Dias ,
        b.SaldoVida ,
        b.Saldo_7Dias ,
        b.Saldo_14Dias ,
        b.Saldo_28Dias ,
        b.Saldo_56Dias ,
        b.QtdePontos_Positivo_Vida ,
        b.QtdePontos_Positivo_7Dias ,
        b.QtdePontos_Positivo_14Dias ,
        b.QtdePontos_Positivo_28Dias ,
        b.QtdePontos_Positivo_56Dias ,
        b.QtdePontos_Negativo_Vida ,
        b.QtdePontos_Negativo_7Dias ,
        b.QtdePontos_Negativo_14Dias ,
        b.QtdePontos_Negativo_28Dias ,
        b.QtdePontos_Negativo_56Dias ,
        b.qt_trn_Manha ,
        b.qt_trn_Tarde ,
        b.qt_trn_Noite ,
        b.pct_trn_Manha ,
        b.pct_trn_Tarde ,
        b.pct_trn_Noite ,
        b.qtd_Trn_Dia_Vida ,
        b.qtd_Trn_Dia_7dias ,
        b.qtd_Trn_Dia_14dias ,
        b.qtd_Trn_Dia_28dias ,
        b.qtd_Trn_Dia_56dias ,
        b.Pct_Ativacao_Mau ,
        b.qt_horas_vida ,
        b.qt_horas_vida_7dias ,
        b.qt_horas_vida_14dias ,
        b.qt_horas_vida_28dias ,
        b.qt_horas_vida_56dias ,
        b.MediaIntervaloDias_Vida ,
        b.MediaIntervaloDias_28dias ,
        b.qtdeChatMessage ,
        b.qtdeAirflow ,
        b.qtdeLover ,
        b.qtdeResgatarPonei ,
        b.qtdeLista ,
        b.qtdeStreak ,
        b.qtdeStreamElements ,
        b.qtdeReembolsoStreamElements ,
        b.qtdeRPG ,
        b.qtdechurn,
        c.qt_Freq_28_dias ,
        c.Ciclo_Vida_Atual ,
        c.Ciclo_Vida_D28 ,
        c.pct_Curioso ,
        c.pct_Desencantada ,
        c.pct_Fiel ,
        c.pct_Zumbi ,
        c.pct_Turista ,
        c.pct_Reconquista ,
        c.pct_Reborn ,
        c.Qtde_Frequencia_Grupo ,
        c.ratio_freq_Grupo ,
        d.Qtd_Cursos_Completos ,
        d.Qtd_Cursos_Incompletos ,
        d.carreira ,
        d.coleta_dados ,
        d.ds_databricks ,
        d.ds_pontos ,
        d.estat_2024 ,
        d.estat_2025 ,
        d.f1_lake ,
        d.github_2024 ,
        d.github_2025 ,
        d.go_2026 ,
        d.ia_canal_2026 ,
        d.lago_mago_2024 ,
        d.loyalty_pred_2025 ,
        d.ML_2025 ,
        d.matchmaking_2024 ,
        d.ml_2024 ,
        d.mlflow_2025 ,
        d.nekt_2025 ,
        d.pandas_2024 ,
        d.pandas_2025 ,
        d.plataforma_ml_2026 ,
        d.python_2024 ,
        d.python_2025 ,
        d.ragia ,
        d.speed_f1 ,
        d.sql_2020 ,
        d.sql_2025 ,
        d.streamlit_2025 ,
        d.trampar_lakehouse_2024 ,
        d.tse_analytics_2024 ,
        d.Qt_Dias_ult_atividade 

from 
    tb_cohort  a

    left join fs_transacional b
        on a.idCliente = b.idCliente and 
           a.dtref = b.dtref 

    left join fs_ciclo_de_vida c
        on a.idCliente = c.idCliente and 
           a.dtref = c.dtref 

    left join fs_education d
        on a.idCliente = d.idCliente and 
           a.dtref = d.dtref 

where c.dtref is not null 



