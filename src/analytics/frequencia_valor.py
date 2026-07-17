# %% 

import pandas as pd
import sqlalchemy

import matplotlib.pyplot as plt 



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

df = df[df['qt_Pontos_28_dias'] < 4000]

df.head()

# %%

plt.plot(df['qt_Freq_28_dias'], df['qt_Pontos_28_dias'],'o')
plt.grid(True)
plt.xlabel('Frequência (28 dias)')
plt.ylabel('Pontos (28 dias)')  
plt.show()

# %% 

import os
os.environ["OMP_NUM_THREADS"] = "3"

from sklearn import cluster

from sklearn import preprocessing 

import seaborn as sns

# %% 

minmax = preprocessing.MinMaxScaler()


X = minmax.fit_transform(df[['qt_Freq_28_dias', 'qt_Pontos_28_dias']])


kmeans = cluster.KMeans(n_clusters=4,
                        random_state=42, 
                        max_iter=1000)

kmeans.fit(df[['qt_Freq_28_dias', 'qt_Pontos_28_dias']])

df['cluster_calc'] = kmeans.labels_
df 


# %%

df.groupby(by='cluster_calc')['idcliente'].count()

# %%

sns.scatterplot(data=df,
                     x='qt_Freq_28_dias',
                     y='qt_Pontos_28_dias', hue='cluster_calc', palette='deep')


plt.hlines(y=1500,xmin=0,xmax=25,colors='black')

plt.hlines(y=750,xmin=0,xmax=25,colors='black')

plt.vlines(x=4,ymin=0,ymax=750,colors='red')
plt.vlines(x=10,ymin=0,ymax=3000,colors='red')


# %%

sns.scatterplot(data=df,
                     x='qt_Freq_28_dias',
                     y='qt_Pontos_28_dias', hue='cluster', palette='deep')


plt.grid()



