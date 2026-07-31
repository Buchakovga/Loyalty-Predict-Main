


# %%

import pandas as pd

pd.set_option('display.max_columns',None)
pd.set_option('display.max_rows',None)


import sqlalchemy 
from sklearn import model_selection

conn = sqlalchemy.create_engine("sqlite:///../../data/analytics/database.db")

# %%

# sampla - import dos dados

df = pd.read_sql("abt_fiel", conn)
df.head()

# %%

# SAMPLA - OOT 

df_oot = df[df['dtref']==df['dtref'].max()].reset_index(drop=True)
df_oot 

# %%

# SAMPLA - teste e treino 

target = 'flFiel'

features = df.columns.tolist()[3:]

df_train_test = df[ df['dtref']<df['dtref'].max() ].reset_index(drop=True)

y = df_train_test[target]    # Isso é um pd.series (vetor)
X = df_train_test[features]  # Isso é um pd.dataframe ( matriz)

from sklearn import model_selection

X_train, X_test, y_train, y_test = model_selection.train_test_split(
    X, y, 
    test_size=0.2,
    stratify=y,
    random_state=42,
)

print(f"Base Treino: {y_train.shape[0]} Unid. | Tx. Target {100*y_train.mean():.2f}%" )
print(f"Base Teste: {y_test.shape[0]} Unid. | Tx. Target {100*y_test.mean():.2f}%" )



# %%

# EXPLORAR - MISSING


s_nas = X_train.isna().mean().T   

s_nas = s_nas[s_nas>0]
s_nas

# %%

cat_features = ['Ciclo_Vida_Atual','Ciclo_Vida_D28']

num_features = list(set(features) - set(cat_features) )
 
        
df_train =  X_train.copy()
df_train[target] = y_train.copy()

df_train[num_features] = df_train[num_features].astype(float)

bivariada = df_train.groupby(target)[num_features].median().T

bivariada['ratio'] = (bivariada[1] + 0.001) / (bivariada[0] + 0.001)
bivariada.sort_values(by='ratio',ascending=False)

