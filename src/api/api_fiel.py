# %%


from flask import Flask, request

import mlflow

import pandas as pd 

mlflow.set_tracking_uri("http://localhost:5000")


# %%

versions = mlflow.search_model_versions(filter_string="name='model_fiel'")
last_version = max([int(i.version) for i in versions])
last_version
model = mlflow.sklearn.load_model(f"models:/model_fiel/{last_version}")

# %%



app = Flask(__name__)

@app.route("/health_check")
def hello_world():
    return {"status": "ok"}

@app.route("/predict", methods=['POST'])
def predict():
    try:
        data = request.json["data"]
        df = pd.DataFrame([data])
        X = df[model.feature_names_in_]
        predict = model.predict_proba(X)[:,1]
        return {"IdCliente": df["IdCliente"].iloc[0] ,
                "score" : float(predict[0]) }
    except Exception as err:
        return {"erro": str(err) }


@app.route("/predict_many", methods=['POST'])
def predict_many():
    try:
        data = request.json["data"]
        df = pd.DataFrame(data)
        X = df[model.feature_names_in_]
        df['score']= model.predict_proba(X)[:,1]
        resp = df[['IdCliente','score']].to_dict(orient='records')
        return {"score" : resp }
    except Exception as err:
        return {"erro": str(err) }

if __name__ == "__main__":
    app.run(port=5001,  debug=True)





    
# %%
