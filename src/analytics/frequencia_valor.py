# %% 

import pandas as pd
import sqlalchemy


# %% 

engine_app =  sqlalchemy.create_engine("sqlite:///../../loyalty-system/database.db")


# %% 

def import_query(path):
    with open(path) as open_file:
        query = open_file.read()
    return query


query = import_query('frequencia_valor.sql')


# %%

df = pd.read_sql_query(query,engine_app)
df.head()

