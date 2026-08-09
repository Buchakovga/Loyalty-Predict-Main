

# %%


import pandas as pd
import sqlalchemy 
from datetime import datetime, timedelta


# %%

def import_query(path):
    with open(path) as open_file:
        query = open_file.read()
    return query


query = import_query('ciclo_vida.sql')

engine_app =  sqlalchemy.create_engine("sqlite:///../../data/loyalty-system/database.db")

engine_analitico = sqlalchemy.create_engine("sqlite:///../../data/analytics/database.db")


# %%


def date_range(start, stop):
    start = datetime.strptime(start, '%Y-%m-%d')
    stop = datetime.strptime(stop, '%Y-%m-%d')

    dates = []

    while start <= stop:
        dates.append(start.strftime('%Y-%m-%d'))
        start += timedelta(days=1)

    return dates

dates = date_range('2024-03-01', '2025-10-01')

# %% 

for i in dates:

    with engine_analitico.connect() as con:
        query_delete = f"delete from ciclo_vida where dtref = date('{i}','-1 day')"
        con.execute(sqlalchemy.text(query_delete) )
        con.commit()

    print(i)
    query_format = query.format(date=i)
    df = pd.read_sql_query(query_format,engine_app)
    df.to_sql("ciclo_vida", engine_analitico, index=False, if_exists="append")




# %%
