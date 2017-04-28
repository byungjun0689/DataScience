# -*- coding: utf-8 -*-
"""
Created on Fri Apr 28 10:28:52 2017

@author: MCR007
"""

import pandas as pd
import pymysql

# connection 

from sqlalchemy import create_engine
pymysql.install_as_MySQLdb()
import MySQLdb
engine = create_engine("mysql+mysqldb://id:"+"password"+"@domain/kmu?charset=utf8", encoding='utf-8')
conn = engine.connect()
#customer.columns = ['Custid','Sex','Age','Resident']
#customer.to_sql(name='Customer',con=engine,if_exists='append',index =False)
product.to_sql(name='product',con=engine,if_exists='append',index=False)
  

df = pd.read_csv("astronauts.csv")
df.head()
df.columns
df['NumberOfAstronauts'] = range(1,len(df)+1)
df['Birth Date'] = pd.to_datetime(df['Birth Date'],format='%m/%d/%Y')

df['Space Walks (hr)'].unique()
df.ix[281,'Death Date'] = '04/23/2001'
df['Death Date'] = pd.to_datetime(df['Death Date'],format='%m/%d/%Y')
df.to_sql(name='astronauts',con=engine,if_exists='append',index=False)
