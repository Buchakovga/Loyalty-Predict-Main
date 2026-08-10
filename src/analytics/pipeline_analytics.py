


# %%

from exec_query import exec_query

import datetime 

now = datetime.datetime.now().strftime("%Y-%m-%d")  

steps = [
    {
        "table":"ciclo_vida",
        "db_origem":"loyalty-system",
        "db_target":"analytics",
        "dt_start":now,
        "dt_stop": now,
        "monthly": False   ,
        "mode": "append",
    },

    {
        "table":"fs_transacional",
        "db_origem":"loyalty-system",
        "db_target":"analytics",
        "dt_start":now,
        "dt_stop": now,
        "monthly": False   ,
        "mode": "append",
    },

    {
        "table":"fs_education",
        "db_origem":"education-platform",
        "db_target":"analytics",
        "dt_start":now,
        "dt_stop": now,
        "monthly": False   ,
        "mode": "append",
    },
    {
        "table":"fs_ciclo_de_vida",
        "db_origem":"analytics",
        "db_target":"analytics",
        "dt_start":now,
        "dt_stop": now,
        "monthly": False,
        "mode": "append",
    },
    {
        "table":"fs_all",
        "db_origem":"analytics",
        "db_target":"analytics",
        "dt_start":now,
        "dt_stop": now,
        "monthly": False   ,
        "mode": "replace",
    }



]


for s in steps:
    exec_query(**s)




# %%
