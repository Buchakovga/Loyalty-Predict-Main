


# %%


import os
import dotenv

dotenv.load_dotenv('../../.env')

print(os.environ["KAGGLE_API_TOKEN"])



# %%

from kaggle import api


api.dataset_download_file('teocalvo/teomewhy-loyalty-system','database.db') 






# %%

