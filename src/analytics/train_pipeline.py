

# %%

import pandas as pd
import sqlalchemy 
from feature_engine import selection 
from feature_engine import imputation
from feature_engine import encoding
from sklearn import model_selection
import matplotlib.pyplot as plt
from sklearn import metrics
from sklearn import pipeline
from sklearn import tree
from sklearn import ensemble 


import mlflow 

mlflow.set_tracking_uri("http://localhost:5000")
mlflow.set_experiment(experiment_id=1)


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


# %%

####
#     MODEL
####
#model = tree.DecisionTreeClassifier(random_state=42, min_samples_leaf=50 )
# model =ensemble.AdaBoostClassifier(random_state=42, 
#                                    n_estimators=150,
#                                    learning_rate=0.01)

model =ensemble.RandomForestClassifier(random_state=42, 
                                       n_estimators=150,
                                       n_jobs=2,
                                       min_samples_leaf=60 )
# CRIANDO PIPELINE 

params = {
    "n_estimators": [100, 200, 400, 500, 1000],
    "min_samples_leaf": [10, 20, 30, 50, 75,100],
}

grid = model_selection.GridSearchCV(
    model,
    param_grid=params,
    cv=3,
    scoring='roc_auc',    
    refit=True,
    verbose=3,
    n_jobs=10,       
)
    
with mlflow.start_run() as r:

    mlflow.sklearn.autolog()
    
    model_pipeline = pipeline.Pipeline(steps=[
        ('Remocao de Features', drop_feature),
        ('Imputacao de Zeros', imput_0),
        ('Imputacao de Nao Unsuario', imput_new),
        ('Imputacao de 1000', imput_1000),
        ('OneHotEnconding', onehot),
        ('Algoritmo', grid),
    ])


    
    model_pipeline.fit(X_train,y_train)
   
    # ASSESS - MÉTRICAS

    y_pred_train = model_pipeline.predict(X_train)
    y_prob_train = model_pipeline.predict_proba(X_train)

    acc_train = metrics.accuracy_score(y_train, y_pred_train)
    auc_train = metrics.roc_auc_score(y_train,y_prob_train[:,1])

    print("Acurácia Treino:", acc_train)
    print("AUC Treino:", auc_train)

    y_pred_test = model_pipeline.predict(X_test)
    y_prob_test = model_pipeline.predict_proba(X_test)

    acc_test = metrics.accuracy_score(y_test, y_pred_test)
    auc_test = metrics.roc_auc_score(y_test, y_prob_test[:,1])

    print("Acurácia Teste:", acc_test)
    print("AUC Teste:", auc_test)
    
    X_oot = df_oot[features]
    y_oot = df_oot[target]

    y_pred_oot = model_pipeline.predict(X_oot)
    y_prob_oot = model_pipeline.predict_proba(X_oot)

    acc_oot = metrics.accuracy_score(y_oot, y_pred_oot)
    auc_oot = metrics.roc_auc_score(y_oot, y_prob_oot[:,1])

    print("Acurácia OOT:", acc_oot)
    print("AUC OOT:", auc_oot)

    mlflow.log_metrics({
        "acc_train": acc_train,
        "auc_train": auc_train,
        "acc_test": acc_test,
        "auc_test": auc_test,
        "acc_oot": acc_oot,
        "auc_oot": auc_oot,
    })

    roc_train = metrics.roc_curve(y_train, y_prob_train[:,1])
    roc_test  = metrics.roc_curve(y_test, y_prob_test[:,1])  
    roc_oot   = metrics.roc_curve(y_oot, y_prob_oot[:,1])  

    ####
    #     PLOT DA CURVA ROC
    ####
    plt.figure(dpi=100)
    plt.plot(roc_train[0], roc_train[1])
    plt.plot(roc_test[0], roc_test[1])
    plt.plot(roc_oot[0], roc_oot[1])
    plt.legend([f'Treino: {auc_train:.4f}', f'Teste: {auc_test:.4f}', f'OOT: {auc_oot:.4f}'])
    plt.plot([0, 1], [0, 1], color='black', linestyle='--')
    plt.grid(True)
    plt.title("Curva ROC")
    plt.savefig("Curva_ROC.png" )
    mlflow.log_artifact("Curva_ROC.png")

# %%

features_name = (model_pipeline[:-1].transform(X_train.head(1))
                                .columns
                                .tolist())

features_importance = pd.Series(model_pipeline[-1].feature_importances_,index=features_name)
features_importance.sort_values(ascending=False)


# %%


# ASSESS - PERSISTIR MODELO
# NÃO PRECISA MAIS FAZER LOCALMENTE, FAZ TUDO PELO MLFLOW

# model_series = pd.Series(
#     {
#         "model": model_pipeline,
#         "features": X_train.columns.tolist(),
#         "auc_train": auc_train,
#         "auc_test": auc_test,
#         "auc_oot": auc_oot,
#     }    
# )
# model_series.to_pickle("model_fiel.pkl")


# %%
