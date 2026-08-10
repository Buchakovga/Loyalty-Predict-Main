

# %%

import pandas as pd
import sqlalchemy 
from feature_engine import selection 
from feature_engine import imputation
from feature_engine import encoding
from sklearn import model_selection
from sklearn import tree
from sklearn import ensemble 
from sklearn import metrics


pd.set_option('display.max_columns',None)
pd.set_option('display.max_rows',None)

conn = sqlalchemy.create_engine("sqlite:///../../data/analytics/database.db")

# %%

# SAMPLE - IMPORTA OS DADOS DA ABT 

df = pd.read_sql("select * from abt_fiel", conn)
df.head()

# %%

# SAMPLE - SEPARA A BASE OOT 

df_oot = df[df['dtref']==df['dtref'].max()].reset_index(drop=True)
df_oot 

# %%

# SAMPLE - TESTE E TREINO

target = 'flFiel'

features = df.columns.tolist()[3:]

df_train_test = df[ df['dtref']<df['dtref'].max() ].reset_index(drop=True)

y = df_train_test[target]    # Isso é um pd.series (vetor)
X = df_train_test[features]  # Isso é um pd.dataframe ( matriz)

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

# ANALISE BIVARIADA 

# variáveis categóricas 
cat_features = ['Ciclo_Vida_Atual','Ciclo_Vida_D28']
# varáveis numericas
num_features = list(set(features) - set(cat_features) )
 
        
df_train =  X_train.copy()
df_train[target] = y_train.copy()
df_train[num_features] = df_train[num_features].astype(float)

bivariada = df_train.groupby(target)[num_features].median().T
bivariada['ratio'] = (bivariada[1] + 0.001) / (bivariada[0] + 0.001)
bivariada.sort_values(by='ratio',ascending=False)
bivariada


# %% 

# ANALISE BIVARIADA COM AS CATEGÓRICAS

df_train.groupby('Ciclo_Vida_Atual')[target].mean()


# %%

# ANALISE BIVARIADA COM AS CATEGÓRICAS

df_train.groupby('Ciclo_Vida_D28')[target].mean()


# %%

# MODIFY - DROP . VARIÁVEIS QUE NÃO MUDAM O COMPORTAMENTO

X_train[num_features] = X_train[num_features].astype(float) # TRANSFORMA TUDO EM FLOAT, NUMERICO

to_remove = bivariada[bivariada['ratio']==1].index.tolist()

drop_feature = selection.DropFeatures(to_remove)

# MODIFY - CRIA AS MODIFICAÇÕES MÉTODOS DE IMPUTAÇÃO

fill_0 = ['python_2025']
imput_0 = imputation.ArbitraryNumberImputer(
          arbitrary_number=0,
          variables=fill_0) 

imput_new = imputation.CategoricalImputer(
            fill_value='Não-Usuario', 
            variables=['Ciclo_Vida_D28'])

imput_1000 = imputation.ArbitraryNumberImputer(
             arbitrary_number=1000,
             variables=['MediaIntervaloDias_Vida',
                        'MediaIntervaloDias_28dias',
                        'Qt_Dias_ult_atividade'])
# MODIFY - ONEHOT

onehot = encoding.OneHotEncoder(variables=cat_features)

# APLICANDO AS TRANSFORMAÇOES NO DATASET 
X_Train_transfom = drop_feature.fit_transform(X_train)
X_Train_transfom = imput_0.fit_transform(X_Train_transfom)
X_Train_transfom = imput_new.fit_transform(X_Train_transfom)
X_Train_transfom = imput_1000.fit_transform(X_Train_transfom)
X_Train_transfom = onehot.fit_transform(X_Train_transfom)

# %%

X_Train_transfom.head()


# %%

# validação para ver se tem missing
s_na = X_Train_transfom.isna().mean()
s_na[s_na>0]


# %%

# MODEL 



# model = tree.DecisionTreeClassifier(random_state=42, min_samples_leaf=50 )
# model =ensemble.RandomForestClassifier(random_state=42, 
#                                        n_estimators=150,
#                                        n_jobs=-1,
#                                        min_samples_leaf=60 )

model =ensemble.AdaBoostClassifier(random_state=42, 
                                   n_estimators=150,
                                   learning_rate=0.01)


model.fit(X_Train_transfom,y_train)

# %%

# ASSESS


y_pred_train = model.predict(X_Train_transfom)
y_prob_train = model.predict_proba(X_Train_transfom)

acc_train = metrics.accuracy_score(y_train, y_pred_train)
auc_train = metrics.roc_auc_score(y_train,y_prob_train[:,1])

print("Acurácia Treino:", acc_train)
print("AUC Treino:", auc_train)

# %%


X_test_transfom = drop_feature.transform(X_test)
X_test_transfom = imput_0.transform(X_test_transfom)
X_test_transfom = imput_new.transform(X_test_transfom)
X_test_transfom = imput_1000.transform(X_test_transfom)
X_test_transfom = onehot.transform(X_test_transfom)

y_pred_test = model.predict(X_test_transfom)
y_prob_test = model.predict_proba(X_test_transfom)


acc_test = metrics.accuracy_score(y_test, y_pred_test)
auc_test = metrics.roc_auc_score(y_test, y_prob_test[:,1])

print("Acurácia Teste:", acc_test)
print("AUC Teste:", auc_test)

# %%
X_oot = df_oot[features]
y_oot = df_oot[target]

X_oot_transfom = drop_feature.transform(X_oot)
X_oot_transfom = imput_0.transform(X_oot_transfom)
X_oot_transfom = imput_new.transform(X_oot_transfom)
X_oot_transfom = imput_1000.transform(X_oot_transfom)
X_oot_transfom = onehot.transform(X_oot_transfom)

y_pred_oot = model.predict(X_oot_transfom)
y_prob_oot = model.predict_proba(X_oot_transfom)


acc_oot = metrics.accuracy_score(y_oot, y_pred_oot)
auc_oot = metrics.roc_auc_score(y_oot, y_prob_oot[:,1])

print("Acurácia OOT:", acc_oot)
print("AUC OOT:", auc_oot)


# %%


features_name = X_Train_transfom.columns.tolist()

features_importance = pd.Series(model.feature_importances_,index=features_name)
features_importance.sort_values(ascending=False)

# %%
