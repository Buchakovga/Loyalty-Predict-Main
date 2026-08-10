

# %% 

import requests
import sqlalchemy
import pandas as pd 
import json

con = sqlalchemy.create_engine("sqlite:///../../data/analytics/database.db")

# %% 


data = pd.read_sql("select * from fs_all limit 1", con )
data = {"data":data.to_dict(orient="records")[0]}
data 


# %%



resp = requests.post("http://localhost:5001/predict", json=data )  
resp.json()

# %%

data_many = pd.read_sql("select * from fs_all limit 5", con ).to_json(orient='records')
data_many = {"data": json.loads(data_many) }
data_many

# %% 

resp = requests.post("http://localhost:5001/predict_many", json=data_many )  
resp.json()







# %%


resp = requests.get("http://localhost:5001/health_check")

resp.json()


# %%
