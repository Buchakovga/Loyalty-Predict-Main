


# %%


import os
import dotenv
from kaggle import api
import shutil

dotenv.load_dotenv('../../.env')

print(os.environ["KAGGLE_API_TOKEN"])



# %%


api.dataset_download_file('teocalvo/teomewhy-loyalty-system','database.db') 



# %%

