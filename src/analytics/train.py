


# %%

import pandas as pd
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
    random_state=42,
)

print(f"Base Treino: {y_train.shape[0]} Unid. | Tx. Target {100*y_train.mean():.2f}%" )
print(f"Base Teste: {y_test.shape[0]} Unid. | Tx. Target {100*y_test.mean():.2f}%" )



# %%
