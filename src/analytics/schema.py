


import sqlite3
import pandas as pd

conn = sqlite3.connect("sqlite:///../../data/analytics/database.db")

tabela = "fs"

df = pd.read_sql(
    f"PRAGMA table_info({tabela})",
    conn
)

print(df[['name', 'type']])

    engine_analitico = sqlalchemy.create_engine(f"sqlite:///../../data/analytics/database.db")

    with engine_analitico.connect() as con:
        query_delete = f"delete from {table} where dtref = date('{i}','-1 day')"
        con.execute(sqlalchemy.text(query_delete) )
        con.commit()
             