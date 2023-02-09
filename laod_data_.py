import psycopg2
import pandas as pd
from sqlalchemy import create_engine


def file_2_table(files):
    """
    :param files: excel files paths
    :return: create table from each file
    """
    conn_string = 'postgresql://postgres:CHiheb 10@localhost:5432/covid_project'
    db = create_engine(conn_string)
    conn = db.connect()
    for i, f in enumerate(files):
        # create table from each excel file
        name = f.split('/')[-1].split('.')[0]
        data = pd.read_excel(f)
        # fill table with excel file data
        data.to_sql('{}'.format(name), con=conn, if_exists='replace', index=False)
    conn.close()


if __name__ == "__main__":
    files = ['/home/chiheb/PycharmProjects/portfolio/SQL_data_cleaning/data/nashville_housing.xlsx']
    file_2_table(files)
