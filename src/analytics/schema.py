

# %%

import sqlite3

#%%

conn = sqlite3.connect(r"C:\Principal\Loyalty-Predict-Main\data\analytics\database.db")

cursor = conn.cursor()

#cursor.execute("PRAGMA table_info('fs_ciclo_de_vida')")

#for tabela in cursor.fetchall():
#    print(tabela[0 1])

#conn.close()

# %%

import pandas as pd

# %%

df = pd.read_sql_query("PRAGMA table_info(fs_ciclo_de_vida)", conn)

df.display()

