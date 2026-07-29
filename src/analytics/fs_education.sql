--select * from recompensas_usuarios

with user_curso as (
    select 
        idUsuario,
        descSlugCurso,
        count(descSlugCursoEpisodio) as qt_episodios
    from 
        cursos_episodios_completos a 
    where
        dtCriacao < '{date}'

    group by idUsuario,
            descSlugCurso

), tb_cursos_tot_eps as (
    select 
        descSlugCurso,
        count(descEpisodio) as qt_curso_eps
    from 
        cursos_episodios
    group by descSlugCurso

), tb_pct_cursos as (

select 
    a.idUsuario,
    a.descSlugCurso,
    a.qt_episodios,
    b.qt_curso_eps,
    1. * a.qt_episodios / b.qt_curso_eps as Perc_Curso_completo
from 
    user_curso a 

    left join tb_cursos_tot_eps b 
        on a.descSlugCurso = b.descSlugCurso 

), tb_usuario_pct_cursos_pivot as (

    select 
        a.idUsuario,
        sum(case when Perc_Curso_completo = 1 then 1 else 0 end ) as Qtd_Cursos_Completos,
        sum(case when Perc_Curso_completo > 0 and Perc_Curso_completo < 1  then 1 else 0 end ) as Qtd_Cursos_Incompletos,
        sum(case when a.descSlugCurso='carreira' then Perc_Curso_completo else 0 end) as carreira,
        sum(case when a.descSlugCurso='coleta-dados-2024' then Perc_Curso_completo else 0 end)  as coleta_dados,
        sum(case when a.descSlugCurso='ds-databricks-2024' then Perc_Curso_completo else 0 end)  as ds_databricks,
        sum(case when a.descSlugCurso='ds-pontos-2024' then Perc_Curso_completo else 0 end)  as ds_pontos,
        sum(case when a.descSlugCurso='estatistica-2024' then Perc_Curso_completo else 0 end) as estat_2024,
        sum(case when a.descSlugCurso='estatistica-2025' then Perc_Curso_completo else 0 end) as estat_2025,
        sum(case when a.descSlugCurso='f1-lake' then Perc_Curso_completo else 0 end) as f1_lake,
        sum(case when a.descSlugCurso='github-2024' then Perc_Curso_completo else 0 end) as github_2024 ,
        sum(case when a.descSlugCurso='github-2025' then Perc_Curso_completo else 0 end)  as github_2025 ,
        sum(case when a.descSlugCurso='go-2026' then Perc_Curso_completo else 0 end) as go_2026 ,
        sum(case when a.descSlugCurso='ia-canal-2025' then Perc_Curso_completo else 0 end) as ia_canal_2026 ,
        sum(case when a.descSlugCurso='lago-mago-2024' then Perc_Curso_completo else 0 end) as lago_mago_2024,
        sum(case when a.descSlugCurso='loyalty-predict-2025' then Perc_Curso_completo else 0 end) as loyalty_pred_2025,
        sum(case when a.descSlugCurso='machine-learning-2025' then Perc_Curso_completo else 0 end) as ML_2025,
        sum(case when a.descSlugCurso='matchmaking-trampar-de-casa-2024' then Perc_Curso_completo else 0 end)  as matchmaking_2024,
        sum(case when a.descSlugCurso='ml-2024' then Perc_Curso_completo else 0 end) as ml_2024,
        sum(case when a.descSlugCurso='mlflow-2025' then Perc_Curso_completo else 0 end) as mlflow_2025,
        sum(case when a.descSlugCurso='nekt-2025' then Perc_Curso_completo else 0 end) as nekt_2025,
        sum(case when a.descSlugCurso='pandas-2024' then Perc_Curso_completo else 0 end) as pandas_2024,
        sum(case when a.descSlugCurso='pandas-2025' then Perc_Curso_completo else 0 end) as pandas_2025,
        sum(case when a.descSlugCurso='plataforma-ml-2026' then Perc_Curso_completo else 0 end) as plataforma_ml_2026,
        sum(case when a.descSlugCurso='python-2024' then Perc_Curso_completo else 0 end) as python_2024,
        sum(case when a.descSlugCurso='python-2025' then Perc_Curso_completo else 0 end)  as python_2025,
        sum(case when a.descSlugCurso='ragia' then Perc_Curso_completo else 0 end) as ragia,
        sum(case when a.descSlugCurso='speed-f1' then Perc_Curso_completo else 0 end) as speed_f1,
        sum(case when a.descSlugCurso='sql-2020' then Perc_Curso_completo else 0 end) as sql_2020,
        sum(case when a.descSlugCurso='sql-2025' then Perc_Curso_completo else 0 end)  as sql_2025,
        sum(case when a.descSlugCurso='streamlit-2025' then Perc_Curso_completo else 0 end) as streamlit_2025,
        sum(case when a.descSlugCurso='trampar-lakehouse-2024' then Perc_Curso_completo else 0 end) as trampar_lakehouse_2024,
        sum(case when a.descSlugCurso='tse-analytics-2024' then Perc_Curso_completo else 0 end) as tse_analytics_2024
    from 
        tb_pct_cursos a 

    group by idUsuario

), tb_ult_atividade as (

select 
    idUsuario,
    idRecompensa as descAtividade,
    dtRecompensa as dtCriacao
 from 
    recompensas_usuarios
    where
        dtRecompensa < '{date}'    
union  
select idUsuario,
       descNomeHabilidade as  descAtividade,
       dtCriacao
from 
    habilidades_usuarios
    where
        dtCriacao < '{date}'        
union  
select 
    idUsuario,
    descSlugCurso as  descAtividade,
    dtCriacao
from 
    cursos_episodios_completos
    where
        dtCriacao < '{date}'            

), tb_ultima_atividade as (
select 
    idUsuario,
    min(julianday('{date}')-julianday(dtCriacao)) as Qt_Dias_ult_atividade
    
from 
    tb_ult_atividade
group by idUsuario

), tb_join as (

select 
    c.idTMWCliente as idCliente,
    a.Qtd_Cursos_Completos,
    a.Qtd_Cursos_Incompletos,
    a.carreira,
    a.coleta_dados,
    a.ds_databricks,
    a.ds_pontos,
    a.estat_2024,
    a.estat_2025,
    a.f1_lake,
    a.github_2024 ,
    a.github_2025 ,
    a.go_2026 ,
    a.ia_canal_2026 ,
    a.lago_mago_2024,
    a.loyalty_pred_2025,
    a.ML_2025,
    a.matchmaking_2024,
    a.ml_2024,
    a.mlflow_2025,
    a.nekt_2025,
    a.pandas_2024,
    a.pandas_2025,
    a.plataforma_ml_2026,
    a.python_2024,
    a.python_2025,
    a.ragia,
    a.speed_f1,
    a.sql_2020,
    a.sql_2025,
    a.streamlit_2025,
    a.trampar_lakehouse_2024,
    a.tse_analytics_2024,
    b.Qt_Dias_ult_atividade
from 
    tb_usuario_pct_cursos_pivot a 

    left join tb_ultima_atividade b 
        on a.idUsuario = b.idUsuario

    inner join usuarios_tmw c 
        on a.idUsuario = c.idUsuario

) 
select
     date('{date}', '-1 day') as dtref,
     * 
from
     tb_join 


