# -*- coding: utf-8 -*-
"""
Created on Sat Apr 15 10:02:01 2017

@author: BYUNGJUN
"""

import pandas as pd

customer = pd.read_csv(u"1.customer_info.txt",encoding="cp949")
tr = pd.read_csv(u"2.order_tr.txt",encoding="cp949")
product = pd.read_csv(u"3.product.txt",encoding="cp949")
competition = pd.read_csv(u"4.competition.txt",encoding="cp949")
membership = pd.read_csv(u"5.membership.txt",encoding="cp949")
channel = pd.read_csv(u"6.channel.txt",encoding="cp949")

customer.head()
product.head()
competition.head()
membership.head()
channel.head()
tr.head()
pd.merge(tr,customer,on="고객번호").head()

len(tr[:150000]['고객번호'].unique())

tr = tr[:150000]
tr = pd.merge(tr,customer,on="고객번호") 

product.head()
tr = pd.merge(tr,product,on=["대분류코드","중분류코드","소분류코드","제휴사"])
competition.head()

membership[membership['고객번호']==21]


tr = pd.merge(tr,membership,on="고객번호")
tr.to_csv("visualization.csv",index=False)


channel[channel[['고객번호']].duplicated()]
pd.melt(channel[channel['고객번호']==18795], id_vars=['고객번호'], value_vars=['제휴사','이용횟수'])
channel.unstack(0)


channel.stack().groupby(level=0).value_counts()

list(channel['제휴사'].unique())
ch = list(channel['제휴사'].unique())
channel['제휴사'] = channel['제휴사'].astype('category')
channel['제휴사'].cat.set_categories(['A_MOBILE/APP',
 'B_MOBILE/APP',
 'C_MOBILE/APP',
 'D_MOBILE/APP',
 'B_ONLINEMALL',
 'C_ONLINEMALL'], inplace=True)

ch = pd.pivot_table(channel, index=['고객번호'],columns=['제휴사'],values=['이용횟수']).fillna(0)

ch['고객번호'] = ch.index
tr = pd.merge(tr,ch,on="고객번호")