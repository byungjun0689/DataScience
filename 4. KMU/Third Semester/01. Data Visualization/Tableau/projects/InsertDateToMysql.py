# -*- coding: utf-8 -*-
"""
Created on Sat Apr 15 18:31:26 2017

@author: BYUNGJUN
"""


import pandas as pd
import pymysql

customer = pd.read_csv(u"1.customer_info.txt",encoding="cp949")
tr = pd.read_csv(u"2.order_tr.txt",encoding="cp949")
product = pd.read_csv(u"3.product.txt",encoding="cp949")
competition = pd.read_csv(u"4.competition.txt",encoding="cp949")
membership = pd.read_csv(u"5.membership.txt",encoding="cp949")
channel = pd.read_csv(u"6.channel.txt",encoding="cp949")
zip_code = pd.read_csv("zipcode.csv",encoding="cp949")


customer.head()
print(product.head(1))
print(competition.head(1))
print(membership.head(1))
print(channel.head(1))
print(tr.head(1))

# connection 

conn = pymysql.connect(host='localhost', user='lbj', password='password', db='kmu') 

# Connection 으로부터 Cursor 생성
curs = conn.cursor()

#sql 문 실행
sql = "select * from customer"
curs.execute(sql)

rows = curs.fetchall()
print(rows)

conn.close()

# Connection 으로부터 Dictoionary Cursor 생성
curs = conn.cursor(pymysql.cursors.DictCursor)

# SQL문 실행
sql = "select * from customer where category=%s and region=%s"
curs.execute(sql, (1, '서울'))
 
# 데이타 Fetch
rows = curs.fetchall()
for row in rows:
    print(row)
    # 출력 : {'category': 1, 'id': 1, 'region': '서울', 'name': '김정수'}
    print(row['id'], row['name'], row['region'])
    # 1 김정수 서울
 
# Connection 닫기
conn.close()

curs = conn.cursor(pymysql.cursors.DictCursor)
# ...생략...
rows = curs.fetchall()
for row in rows:
  print(row)
  # 출력 : {'category': 1, 'id': 1, 'region': '서울', 'name': '김정수'}
  print(row['id'], row['name'], row['region'])
  # 1 김정수 서울
  


# dataframe to mysql
from sqlalchemy import create_engine
pymysql.install_as_MySQLdb()
import MySQLdb

engine = create_engine("mysql+mysqldb://lbj:"+"password"+"@localhost/kmu?charset=utf8", encoding='utf-8')
conn = engine.connect()
#customer.columns = ['Custid','Sex','Age','Resident']
#customer.to_sql(name='Customer',con=engine,if_exists='append',index =False)
product.columns
product.columns = ['Company','HCategory','MCategory','LCategory','MCateName','LCateName']
product.head()
product.to_sql(name='product',con=engine,if_exists='append',index=False)

tmp = channel.copy()
channel.columns = ['Custid','Company_Way','Visits']
channel.head()
channel['Company'] = channel['Company_Way'].str.split('_').apply(lambda x:x[0])
channel['Way'] = channel['Company_Way'].str.split('_').apply(lambda x:x[1])
del channel['Company_Way']

channel.head()
channel.to_sql(name='channel',con=engine,if_exists='append',index=False)

competition.head()
competition.columns = ['Custid','Company','Competitors','Date']
competition['Date'] = competition['Date'].astype(object)
competition['Date'] = competition['Date'].apply(lambda x:str(x)+str('01'))
competition.to_sql(name='competition',con=engine,if_exists='append',index=False)

membership.head()
membership.columns = ['Custid','Membership','JoinDate']
membership['JoinDate'] = membership['JoinDate'].astype(object)
membership['JoinDate'] = membership['JoinDate'].apply(lambda x:str(x)+str('01'))
membership.to_sql(name='membership',con=engine,if_exists='append',index=False)



tr.columns = ['Company','ReceiptNum','HCategory','MCategory','LCategory','Custid','StoreCode','OrderDate','OrderTime','Mount']
tr = tr[tr['Company']=="D"]
tr.to_sql(name='order_robs',con=engine,if_exists='append',index=False)

zip_code.columns = ['ZIP','City','Gu']
zip_code.to_sql(name='zipcode',con=engine,if_exists='append',index=False)

conn.close()

