# -*- coding: utf-8 -*-
"""
Created on Wed Apr 19 21:11:42 2017

@author: byung
"""

import pandas as pd
import pandas as pd
import numpy as np 
import matplotlib.pyplot as plt 
import seaborn as sns 



#order = pd.read_csv("2. TR.csv", encoding="cp949")
customer = pd.read_csv("customer.csv")
product = pd.read_csv("product.csv")
tr_customer = pd.read_csv("order_seoul.csv")
zip_code = pd.read_csv("zipcode.csv",encoding="cp949")
customer.head()
#tr_customer = pd.merge(order,customer,on="고객번호")

#order['구매일자'] = order['구매일자'].astype(int)
#order = order[order['구매일자'] > 20150000]

#tr_customer = tr_customer[tr_customer['시도']=='서울특별시']


#tr_customer = pd.merge(tr_customer, product, on=['제휴사','대분류코드','중분류코드','소분류코드'])
#tr_customer.head()

#tr_customer.to_csv("order_seoul.csv",index=False)

store_zip = pd.DataFrame({'count':tr_customer.groupby(['점포코드','ZIP']).size()}).reset_index()
store_zip = store_zip.sort_values(by=['점포코드','count'],ascending=False)
tmp = store_zip.groupby(['점포코드']).first() 
tmp = tmp.reset_index()

tmp2 = pd.merge(tmp,zip_code,on="ZIP",how='left')
tmp2[tmp2['시군구']=='관악구']

# check how many store in each gu in seoul
tmp2[['점포코드','시군구']].groupby(['시군구']).size()

tmp2 = tmp2.rename(columns={'시군구': '점포위치','시도': '점포시위치'})
tmp2.to_csv("store_code.csv")

tr_customer = pd.merge(tr_customer,tmp2[['점포코드','점포위치']],on='점포코드')

tr_customer.groupby(['점포위치','제휴사']).size()
tr_customer[tr_customer['점포코드'].isin(list(tmp2[tmp2['점포위치']=='관악구']['점포코드']))]


