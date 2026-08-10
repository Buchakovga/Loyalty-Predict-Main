


# %%


import os
from pathlib import Path

import dotenv
from kaggle import api

project_root = Path(__file__).resolve().parents[2]
env_path = project_root / '.env'
dotenv.load_dotenv(env_path)

kaggle_token = os.environ.get('KAGGLE_API_TOKEN')
if not kaggle_token:
    raise RuntimeError(f'KAGGLE_API_TOKEN not found in {env_path}')


# %%


datasets = [
    'teocalvo/teomewhy-loyalty-system',
    'teocalvo/teomewhy-education-platform'
]

for i in datasets:
        dataset_name = i.split("teomewhy-")[-1]
        print(f"Downloading {dataset_name}")
        path = f'../../data/{dataset_name}'
        api.dataset_download_file(i,'database.db',path)



# %%

