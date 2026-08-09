

# %%

import argparse 
import os
from pathlib import Path

import pandas as pd
import sqlalchemy 
from datetime import datetime, timedelta
from tqdm import tqdm


# %%

PROJECT_ROOT = Path(__file__).resolve().parents[2]
ANALYTICS_DIR = Path(__file__).resolve().parent


def import_query(path):
    query_path = ANALYTICS_DIR / path
    if not query_path.exists():
        raise FileNotFoundError(f"SQL file not found: {query_path}")
    with open(query_path) as open_file:
        query = open_file.read()
    return query

def date_range(start, stop, monthly=False):
    start = datetime.strptime(start, '%Y-%m-%d')
    stop = datetime.strptime(stop, '%Y-%m-%d')

    dates = []

    while start <= stop:
        dates.append(start.strftime('%Y-%m-%d'))
        start += timedelta(days=1)

    if monthly:
        return [i for i in dates if i.endswith("01")]
    
    return dates


def exec_query(table, db_origem, db_target, dt_start,dt_stop, monthly, mode='append'):

    engine_app =  sqlalchemy.create_engine(f"sqlite:///../../data/{db_origem}/database.db")

    engine_analitico = sqlalchemy.create_engine(f"sqlite:///../../data/{db_target}/database.db")

    query = import_query(f"{table}.sql")

    dates = date_range(dt_start, dt_stop, monthly)


    for i in tqdm(dates):

        # with engine_analitico.connect() as con:
        #     query_delete = f"delete from {table} where dtref = date('{i}','-1 day')"
        #     con.execute(sqlalchemy.text(query_delete) )
        #     con.commit()

        print(i)
        query_format = query.format(date=i)
        df = pd.read_sql_query(query_format,engine_app)
        df.to_sql(table, engine_analitico, index=False, if_exists=mode)

def main():
    
    parser = argparse.ArgumentParser()
    parser.add_argument("--db_origem", choices=['loyalty-system','education-platform','analytics'], default='loyalty-system')
    parser.add_argument("--db_target", choices=['analytics'], default='analytics')
    parser.add_argument("--table",type=str,help="Tabela que será processada com o mesmo nome do arquivo")
    now=datetime.now().strftime("%Y-%m-%d")
    parser.add_argument("--start",type=str,default=now)
    parser.add_argument("--stop",type=str,default=now)
    parser.add_argument("--monthly", action='store_true')
    parser.add_argument("--mode", choices=['append', 'replace'])

    args=parser.parse_args()

    exec_query(args.table, args.db_origem, args.db_target, args.start, args.stop, args.monthly)
    
if __name__ == "__main__":
    main()
    






